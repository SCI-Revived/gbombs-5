AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Howitzer Incen Shell"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/thedoctor/howitzer/howitzer_inc.mdl"                      
ENT.Effect                           =  "500lb_ground"                  
ENT.EffectAir                        =  "500lb_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/mine_explosion.mp3"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"    
 
ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  40
ENT.PhysForce                        =  200
ENT.ExplosionRadius                  =  500
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  25 -- 1000 Damage
ENT.SpecialRadius                    =  500
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  0                               
ENT.TraceLength                      =  300
ENT.ImpactSpeed                      =  300
ENT.Mass                             =  255
ENT.ArmDelay                         =  0.1
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.
ENT.Decal                            = "scorch_medium"

ENT.DEFAULT_PHYSFORCE                = 55
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000 

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
	     self.Armed    = false
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
	 if not self:IsValid() then return end 
	 local pos = self:LocalToWorld(self:OBBCenter())
	 self:SetMoveType( MOVETYPE_NONE )
	 self:SetMaterial("phoenix_storms/glass")
	 self:SetModel("models/hunter/plates/plate.mdl")
	 local Shockwave = gb5BeginShockwave() do
	 	Shockwave.Class              = "gb5_shockwave_ent"
	 	Shockwave.Origin             = pos
	 	Shockwave.PhysForce          = self.DEFAULT_PHYSFORCE
	 	Shockwave.PhysForceAir       = self.DEFAULT_PHYSFORCE_PLYAIR
	 	Shockwave.PhysForceGround    = self.DEFAULT_PHYSFORCE_PLYGROUND
	 	Shockwave.Attacker           = self.GBOWNER
	 	Shockwave.MaxRange           = self.ExplosionRadius
	 	Shockwave.ShockwaveIncrement = 100
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Trace              = self.TraceLength
	 	Shockwave.Decal              = self.Decal
	 gb5CommitShockwave() end
	 
	 local Shockwave = gb5BeginShockwave() do
	 	Shockwave.Class              = "gb5_shockwave_sound_lowsh"
	 	Shockwave.Origin             = pos
	 	Shockwave.Attacker           = self.GBOWNER
	 	Shockwave.MaxRange           = 50000
		Shockwave.ShockwaveIncrement = gb5SoundShockwaveIncrement()
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Sound              = self.ExplosionSound
	 	Shockwave.Shocktime          = self.Shocktime
	 gb5CommitShockwave() end
	 gb5ApplyExplosionDamage(self, pos)
	 -- Set living things caught in the blast on fire.
	 for k, v in pairs(gb5FastSphereSearch(pos, self.ExplosionRadius)) do
	 	if v:IsPlayer() or v:IsNPC() then
	 		v:Ignite(6, 0)
	 	end
	 end
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
				 self:Remove()
		 end)	
		 else 
			 ParticleEffect(self.EffectAir,pos,angle_zero,nil) 
			 timer.Simple(2, function()
				 if not self:IsValid() then return end 
				 self:Remove()
			end)	
		 end
	 end
end

gb5RegisterSpawnFunction( ENT, 16 )
