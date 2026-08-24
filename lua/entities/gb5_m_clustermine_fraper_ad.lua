AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "LEM - Field Raper [Warning OP]" 
ENT.Author			                 =  "Rogue"
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Mines"

ENT.Model                            =  "models/thedoctor/mines/clustermine_2.mdl"         
ENT.Effect                           =  "50lb_main"
ENT.EffectAir                        =  "50lb_air" 
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/mine_explosion.mp3"         
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"  

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false         
ENT.ShouldExplodeOnImpact            =  true         
ENT.Flamable                         =  false         
ENT.UseRandomSounds                  =  false         
ENT.UseRandomModels                  =  false         
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  450            
ENT.PhysForce                        =  400             
ENT.ExplosionRadius                  =  200             
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  1
ENT.SpecialRadius                    =  200             
ENT.MaxIgnitionTime                  =  0             
ENT.Life                             =  15            
ENT.MaxDelay                         =  2            
ENT.TraceLength                      =  200        
ENT.ImpactSpeed                      =  900           
ENT.Mass                             =  30     
ENT.ArmDelay                         =  1        
ENT.Timer                            =  0

ENT.PushWeight                       =  5    --If something heavier or equal touches us - we explode.

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(not self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 if(GetConVar("gb5_fragility"):GetInt() >= 1) then
	     if(data.Speed > self.ImpactSpeed) then
	 	     if(not self.Armed and not self.Arming) then
	             self:Arm()
	         end
		 end
	 end
	 if(not self.Armed) then return end
	 local pusher = data.HitEntity
	 if (pusher:IsWorld() == true) then return end
	 local phys = pusher:GetPhysicsObject()
	 local pweight = phys:GetMass()
	 if (pweight >= self.PushWeight ) then         
			 self.Exploded = true
			 self:Explode()
	 end
end

function ENT:Explode()
     if not self.Exploded then return end
	 if self.Exploding then return end
	
	 local pos = self:LocalToWorld(self:OBBCenter())
	
	 constraint.RemoveAll(self)
	 local physo = self:GetPhysicsObject()
	 physo:Wake()	
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
	 
	 for i=1, 6 do
		 local ent1 = ents.Create("gb5_m_clustermine_blet_ad") 
		 local phys = ent1:GetPhysicsObject()
		 ent1:SetPos( self:GetPos() ) 
		 ent1:Spawn()
		 ent1:Activate()
		 ent1:SetVar("GBOWNER", self.GBOWNER)
		 ent1:Ignite(1,0)
		 ent1.Count = 0
		 local bphys = ent1:GetPhysicsObject()
		 local phys = self:GetPhysicsObject()
		  if bphys:IsValid() and phys:IsValid() then
			 bphys:ApplyForceCenter(VectorRand() * bphys:GetMass() * 85)
			 bphys:AddVelocity(phys:GetVelocity()/4)
		 end
	 end

	 local pos = self:GetPos()

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
			 if not self:IsValid() then return end 
				self:Remove()
		 end
	 end
end


gb5RegisterSpawnFunction( ENT, 16 )
