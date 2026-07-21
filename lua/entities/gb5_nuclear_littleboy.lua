AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Little boy"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Nuclear"

ENT.Model                            =  "models/thedoctor/littleboy.mdl"                      
ENT.Effect                           =  "littleboy_main"                  
ENT.EffectAir                        =  "littleboy_air_main"                   
ENT.EffectWater                      =  "water_huge"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.ExplosionRadius                  =  8000
ENT.SpecialRadius                    =  2000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  0                                 
ENT.TraceLength                      =  1000
ENT.ImpactSpeed                      =  1000
ENT.Mass                             =  1000
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0


ENT.DEFAULT_PHYSFORCE                = 255
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 25
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 2555
ENT.GBOWNER                          =  nil     
ENT.Decal                            = "nuke_medium"



function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end 
	 if(self.Dumb) then
	     self.Armed    = true
	 else
	     self.Armed    = false
	 end
	 self.Exploded = false
	 self.Used     = false
	 self.Arming = false
	 self.Exploding = false
	  if not (WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end


function ENT:Explode()
     if not self.Exploded then return end
	 if self.Exploding then return end
     local pos = self:LocalToWorld(self:OBBCenter())
	 
	 for k, v in pairs(gb5FastSphereSearch(pos,6000)) do
		 if (v:IsValid() or v:IsPlayer()) and (v.GBombs_InForcefield==false or v.GBombs_InForcefield==nil) then
			if v:IsValid() and v:GetPhysicsObject():IsValid() then
				v:TakeDamage(self.ExplosionDamage, self.GBOWNER, self)		-- Added TakeDamage to the explosion so things like vehicles (simfphys for example) also take damage
				v:Ignite(4,0)
			end
		 end
	 end
	 for k, v in pairs(gb5FastSphereSearch(pos,self.SpecialRadius)) do
		if (v:IsValid() or v:IsPlayer()) and (v.GBombs_InForcefield==false or v.GBombs_InForcefield==nil) then
			if v:IsPlayer() and not v:IsNPC() then
			    v:SetModel("models/Humans/Charple04.mdl")
				ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0) 
				v:Kill()
			end
		 end
	 end
	 
	 local ent = ents.Create("gb5_emitlight_nuke")
	 ent:SetPos( pos + Vector(0,0,1000) ) 
	 ent:Spawn()
	 ent:Activate()
	 ent.RGB_Variable = {["red"] = 179, ["green"] = 175, ["blue"] = 150}
	 ent.Life = 11
	 


  	 timer.Simple(0, function()
	     if not self:IsValid() then return end 
		 local Shockwave = gb5BeginShockwave() do
		 	Shockwave.Class              = "gb5_shockwave_ent"
		 	Shockwave.Origin             = pos
		 	Shockwave.PhysForce          = self.DEFAULT_PHYSFORCE
		 	Shockwave.PhysForceAir       = self.DEFAULT_PHYSFORCE_PLYAIR
		 	Shockwave.PhysForceGround    = self.DEFAULT_PHYSFORCE_PLYGROUND
		 	Shockwave.Attacker           = self.GBOWNER
		 	Shockwave.MaxRange           = 8000
		 	Shockwave.ShockwaveIncrement = 100
		 	Shockwave.Delay              = 0.01
		 	Shockwave.Trace              = self.TraceLength
		 	Shockwave.Decal              = self.Decal
		 gb5CommitShockwave() end
	 	if GetConVar("gb5_nuclear_fallout"):GetInt()== 1 then
			local ent = ents.Create("gb5_base_radiation_draw_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent.Burst = 25
			ent.RadRadius=7000
			
			local ent = ents.Create("gb5_base_radiation_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent.Burst = 25
			ent.RadRadius=7000
		end	
		 local Shockwave = gb5BeginShockwave() do
		 	Shockwave.Class              = "gb5_shockwave_rumbling"
		 	Shockwave.Origin             = pos
		 	Shockwave.Attacker           = self.GBOWNER
		 	Shockwave.MaxRange           = 9000
		 	Shockwave.ShockwaveIncrement = 200
		 	Shockwave.Delay              = 0.01
		 	Shockwave.Sound              = self.ExplosionSound
		 gb5CommitShockwave() end
		 self:SetModel("models/gibs/scanner_gib02.mdl")
		 
		 local Shockwave = gb5BeginShockwave() do
		 	Shockwave.Class              = "gb5_shockwave_sound_burst"
		 	Shockwave.Origin             = pos
		 	Shockwave.Attacker           = self.GBOWNER
		 	Shockwave.MaxRange           = 50000
		 	Shockwave.ShockwaveIncrement = 100
		 	Shockwave.Delay              = 0.01
		 	Shockwave.Sound              = self.ExplosionSound
		 gb5CommitShockwave() end
	    
		 local Shockwave = gb5BeginShockwave() do
		 	Shockwave.Class              = "gb5_shockwave_sound_lowsh"
		 	Shockwave.Origin             = pos
		 	Shockwave.Attacker           = self.GBOWNER
		 	Shockwave.MaxRange           = 12000
		 	Shockwave.ShockwaveIncrement = 100
		 	Shockwave.Delay              = 0.01
		 	Shockwave.Sound              = "gbombs_5/explosions/nuclear/abomb.mp3"
		 gb5CommitShockwave() end
		 
		 self:SetModel("models/gibs/scanner_gib02.mdl")
		 self.Exploding = true
	
		 self:StopParticles()
     end)
	 if(self:WaterLevel() >= 1) then
		 local trdata   = {}
		 local trlength = Vector(0,0,9000)

		 trdata.start   = pos
		 trdata.endpos  = trdata.start + trlength
		 trdata.filter  = self
		 local tr = util.TraceLine(trdata) 

		 local trdat2   = {}
		 trdat2.start   = tr.HitPos
		 trdat2.endpos  = trdata.start - trlength
		 trdat2.filter  = self
		 trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT
		 
		 local tr2 = util.TraceLine(trdat2)
		 
		 if tr2.Hit then
			 ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)
		
		 end
	 else
		 local tracedata    = {}
		 tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		 tracedata.filter   = self.Entity
			
		 local trace = util.TraceLine(tracedata)
	 
		 if trace.HitWorld then
			 ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)	
			 timer.Simple(0, function()
				 if not self:IsValid() then return end 
				 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
				 self:Remove()
		 end)	
		 else 
			 ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
			 timer.Simple(0, function()
				 if not self:IsValid() then return end 
				 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
				 self:Remove()
			end)	
			 --Here we do an emp check
			if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
				 local ent = ents.Create("gb5_emp_entity")
				 ent:SetPos( self:GetPos() ) 
				 ent:Spawn()
				 ent:Activate()	
			 end
		 end
	 end
end

gb5RegisterSpawnFunction( ENT, 16 )
