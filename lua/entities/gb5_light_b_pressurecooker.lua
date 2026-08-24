AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Pressure-Cooker"
ENT.Author			                 =  "Natsu (Fixed by Scoopy)"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Light Bombs"

ENT.Model                            =  "models/props_junk/garbage_milkcarton001a.mdl"                      
ENT.Effect                           =  "steam_explosion"                  
ENT.EffectAir                        =  "steam_explosion_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/medium_bomb/ex9.mp3"
 
ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  true

ENT.ExplosionDamage                  =  50
ENT.PhysForce                        =  500
ENT.ExplosionRadius                  =  250
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  1
ENT.SpecialRadius                    =  500
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25000                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  300
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  52
ENT.ArmDelay                         =  1   
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.
ENT.Decal                            = "scorch_small"

ENT.DEFAULT_PHYSFORCE                = 155
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000 

sound.Add( {
	name = "gas",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	pitch = {100, 100},
	sound = "gbombs_5/explosions/misc/kettle_pressure_buildup.mp3"
} )

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
	 self:EmitSound("gas")
	
	 constraint.RemoveAll(self)
	 local physo = self:GetPhysicsObject()
	 physo:Wake()	
  	 timer.Simple(15, function()
		 self.Exploding = true
	     if not self:IsValid() then return end 
		 self:StopParticles()
		 local pos = self:LocalToWorld(self:OBBCenter())
		 
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
			     timer.Simple(0.1, function()
			         if not self:IsValid() then return end 
				     self:Remove()
             end)	
		     else 
			     ParticleEffect(self.EffectAir,self:GetPos(),angle_zero,nil) 
				 self:Remove()
		     end
		 end
     end)
end
function ENT:OnRemove()
	self:StopSound("gas")
end
gb5RegisterSpawnFunction( ENT, 16 )
