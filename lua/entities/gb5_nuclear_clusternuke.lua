AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true    
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Cluster-Fucking Nuke"
ENT.Author			                 =  "Rogue (Fixed by Scoopy)"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Nuclear"

ENT.Model                            =  "models/thedoctor/tsar.mdl"                      
ENT.Effect                           =  "tsar_bomba_ground"                  
ENT.EffectAir                        =  "tsar_bomba_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/nuclear/tsar_detonate.mp3"
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
ENT.ExplosionRadius                  =  35000
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  200
ENT.SpecialRadius                    =  5000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  1000
ENT.ImpactSpeed                      =  1300
ENT.Mass                             =  18500
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.DEFAULT_PHYSFORCE = 1530
ENT.DEFAULT_PHYSFORCE_PLYAIR = 150
ENT.DEFAULT_PHYSFORCE_PLYGROUND = 15330

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.
ENT.Decal                            = "nuke_tsar"
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

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(not self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 if(data.Speed > 200) then
		if math.random(1,2)==1 then
			self:EmitSound("gbombs_5/arm/tsarland.wav", 80, math.random(90,110))
		else
			self:EmitSound("gbombs_5/arm/tsarland2.wav", 80, math.random(90,110))
		end
	 end
	 if(GetConVar("gb5_fragility"):GetInt() >= 1) then
	     if(data.Speed > self.ImpactSpeed) then
	 	     if(not self.Armed and not self.Arming) then

	             self:Arm()
	         end
		 end
	 end
	 if(not self.Armed) then return end
     if self.ShouldExplodeOnImpact then
	     if (data.Speed > self.ImpactSpeed ) then
			 self.Exploded = true
			 self:Explode()
		 end
	 end
end

function ENT:Explode()
     if not self.Exploded then return end
	 if self.Exploding then return end
	 local pos = self:GetPos()
	 
	 for i=1,5 do
		
		timer.Simple(i, function()
				
			local nuke_table = {"gb5_nuclear_clusternuke","gb5_nuclear_fatman","gb5_nuclear_grable","gb5_nuclear_ivymike","gb5_nuclear_littleboy","gb5_nuclear_trinity"}
			local ent = ents.Create(table.Random(nuke_table))
			
			ent:SetPos(pos)
			
			ent:Spawn()
			ent:Activate()
		end)
	 end
	 local pos = self:LocalToWorld(self:OBBCenter())
	 local Shockwave = gb5BeginShockwave() do
	 	Shockwave.Class              = "gb5_shockwave_ent"
	 	Shockwave.Origin             = pos
	 	Shockwave.Attacker           = self.GBOWNER
	 	Shockwave.MaxRange           = 35000
	 	Shockwave.ShockwaveIncrement = 100
	 	Shockwave.Delay              = 0.01
	 	Shockwave.PhysForce          = 955
	 	Shockwave.PhysForceAir       = 15
	 	Shockwave.PhysForceGround    = 155
	 	Shockwave.Trace              = self.TraceLength
	 	Shockwave.Decal              = self.Decal
	 gb5CommitShockwave() end
	 
	 local ent = ents.Create("gb5_emitlight_nuke")
	 ent:SetPos( pos + Vector(0,0,1000) ) 
	 ent:Spawn()
	 ent:Activate()
	 ent.RGB_Variable = {["red"] = 255, ["green"] = 130, ["blue"] = 0}
	 ent.Life = 15
	 
	if GetConVar("gb5_nuclear_fallout"):GetInt()== 1 then
		local ent = ents.Create("gb5_base_radiation_draw_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent.Burst = 50
		ent.RadRadius=35000
		
		local ent = ents.Create("gb5_base_radiation_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent.Burst = 50
		ent.RadRadius=35000
	 end			 
	 local Shockwave = gb5BeginShockwave() do
	 	Shockwave.Class              = "gb5_shockwave_rumbling"
	 	Shockwave.Origin             = pos
	 	Shockwave.Attacker           = self.GBOWNER
	 	Shockwave.MaxRange           = 50000
	 	Shockwave.ShockwaveIncrement = 5000
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Sound              = "gbombs_5/explosions/nuclear/tsar_in.mp3"
	 gb5CommitShockwave() end

	 
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
	 	Shockwave.MaxRange           = 50000
	 	Shockwave.ShockwaveIncrement = 110
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Sound              = "gbombs_5/explosions/nuclear/tsar_detonate.mp3"
	 gb5CommitShockwave() end
	 self:SetModel("models/gibs/scanner_gib02.mdl")
	 self.Exploding = true
	
	 local physo = self:GetPhysicsObject()
	 physo:Wake()
	 physo:EnableMotion(true)
	 -- Scaled blast damage (same model as light/medium bombs). The outward
	 -- push still comes entirely from the gb5_shockwave_ent shockwaves.
	 gb5ApplyExplosionDamage(self, pos)
	 for k, v in pairs(gb5FastSphereSearch(pos, self.ExplosionRadius)) do
	 	if v.GBombs_InForcefield == false or v.GBombs_InForcefield == nil then
	 		v:Ignite(4, 0)
	 	end
	 end
	 for k, v in pairs(gb5FastSphereSearch(pos,self.SpecialRadius*2)) do
		if (v:IsValid() or v:IsPlayer()) and (v.GBombs_InForcefield==false or v.GBombs_InForcefield==nil) then
			if v:IsPlayer() and v:Alive() then
			    v:SetModel("models/Humans/Charple04.mdl")
				v:Kill()
				ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,v,0) 
			end
		 end
	 end
	
  	 timer.Simple(2, function()
	     if not self:IsValid() then return end 
		 constraint.RemoveAll(self)
		 util.ScreenShake( pos, 55555, 255, 10, 121000 )
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
		         ParticleEffect(self.EffectWater, tr2.HitPos, angle_zero, nil)
		    
			 end
		 else
		     local tracedata    = {}
	         tracedata.start    = pos
		     tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		     tracedata.filter   = self.Entity
				
		     local trace = util.TraceLine(tracedata)
	     
		     if trace.HitWorld then
		         ParticleEffect(self.Effect,pos,angle_zero,nil)	
			     timer.Simple(2, function()
			         if not self:IsValid() then return end 
			         ParticleEffect("",trace.HitPos,angle_zero,nil)	
				     self:Remove()
             end)	
		     else 
			     ParticleEffect(self.EffectAir,pos,angle_zero,nil) 
				 --Here we do an emp check
				 timer.Simple(2, function()
					 if not self:IsValid() then return end 
					 ParticleEffect("",trace.HitPos,angle_zero,nil)	
					 self:Remove()
				end)	
				if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
					 local ent = ents.Create("gb5_emp_entity")
					 ent:SetPos( self:GetPos() ) 
					 ent:Spawn()
					 ent:Activate()	
				 end
		     end
		 end
end

gb5RegisterSpawnFunction( ENT, 56 )
