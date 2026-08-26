AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Davy Crockett"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/thedoctor/davy.mdl"                      
ENT.Effect                           =  "davycrockett_main"                  
ENT.EffectAir                        =  "davycrockett_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  50
ENT.PhysForce                        =  2500
ENT.ExplosionRadius                  =  700 -- As much as I want this to be a fun base wrecker, going beyond 1500 radius is gonna be a problem for bases.
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  600 -- 30,000 Damage, for when you really want to blow a base open in one (or two) explosions.
ENT.SpecialRadius                    =  2000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  255
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.DEFAULT_PHYSFORCE                = 255
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 25
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 25
ENT.GBOWNER                          =  nil     
ENT.Decal                            = "nuke_small"

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


if SERVER then
	function ENT:Explode()
		 if not self.Exploded then return end
		 if self.Exploding then return end
		
		 local pos = self:LocalToWorld(self:OBBCenter())
		 self:SetModel("models/gibs/scanner_gib02.mdl")
		 self.Exploding = true
		 
		 local Shockwave = gb5BeginShockwave() do
		 	Shockwave.Class              = "gb5_shockwave_sound_instant"
		 	Shockwave.Origin             = pos
		 	Shockwave.Attacker           = self.GBOWNER
		 	Shockwave.MaxBursts          = 1
		 	Shockwave.MaxRange           = 50000
		 	Shockwave.Delay              = 0.1
		 	Shockwave.Sound              = "gbombs_5/explosions/nuclear/tsar_in.mp3"
		 	Shockwave.Shocktime          = 1
		 gb5CommitShockwave() end
		 
		 local Shockwave = gb5BeginShockwave() do
		 	Shockwave.Class              = "gb5_shockwave_ent"
		 	Shockwave.Origin             = pos
		 	Shockwave.PhysForce          = self.DEFAULT_PHYSFORCE
		 	Shockwave.PhysForceAir       = self.DEFAULT_PHYSFORCE_PLYAIR
		 	Shockwave.PhysForceGround    = self.DEFAULT_PHYSFORCE_PLYGROUND
		 	Shockwave.Attacker           = self.GBOWNER
		 	Shockwave.MaxRange           = 1000
			Shockwave.ShockwaveIncrement = gb5SoundShockwaveIncrement()
		 	Shockwave.Delay              = 0.01
		 	Shockwave.Sound              = "gbombs_5/explosions/nuclear/abomb.mp3"
		 	Shockwave.Trace              = self.TraceLength
		 	Shockwave.Decal              = self.Decal
		 gb5CommitShockwave() end
		 
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_rumbling"
			Shockwave.Origin             = pos
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 12000
			Shockwave.ShockwaveIncrement = gb5SoundShockwaveIncrement()
			Shockwave.Delay              = 0.01
			Shockwave.Sound              = self.ExplosionSound
		gb5CommitShockwave() end
		self:SetModel("models/gibs/scanner_gib02.mdl")
		constraint.RemoveAll(self)

		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_sound_lowsh"
			Shockwave.Origin             = pos
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 50000
			Shockwave.ShockwaveIncrement = gb5SoundShockwaveIncrement()
			Shockwave.Delay              = 0.01
			Shockwave.Shocktime          = 4
			Shockwave.Sound              = "gbombs_5/explosions/nuclear/davy_explosion.mp3"
		gb5CommitShockwave() end
		if GetConVar("gb5_nuclear_fallout"):GetInt()== 1 then
			local ent = ents.Create("gb5_base_radiation_draw_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent.Burst = 25
			ent.RadRadius=3000
			
			local ent = ents.Create("gb5_base_radiation_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent.Burst = 25
			ent.RadRadius=3000
		 end
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
		 for k, v in pairs(gb5FastSphereSearch(pos,250)) do
			 if (v:IsValid() or v:IsPlayer()) and (v.GBombs_InForcefield==false or v.GBombs_InForcefield==nil) then
				if v:IsPlayer() and not v:IsNPC() then
					v:SetModel("models/Humans/Charple04.mdl")
					ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0) 
					v:Kill()
				end
			 end
		 end
		 if not self:IsValid() then return end  
		 self:SetModel("models/gibs/scanner_gib02.mdl")
		 self.Exploding = true
		 self:StopParticles()
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
				 timer.Simple(1, function()
					 if not self:IsValid() then return end 
					 self:Remove()
				end)	
			else 
				 ParticleEffect(self.EffectAir,pos,angle_zero,nil) 
				 self:Remove()
				 if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
					 local ent = ents.Create("gb5_emp_entity")
					 ent:SetPos( self:GetPos() ) 
					 ent:Spawn()
					 ent:Activate()	
				 end
			end
		end
	end
end

gb5RegisterSpawnFunction( ENT, 16 )
