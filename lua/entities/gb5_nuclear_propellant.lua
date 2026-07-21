AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Mk33 Propellant"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/props_junk/metal_paintcan001a.mdl"                      
ENT.Effect                           =  "high_explosive_air"                  
ENT.EffectAir                        =  "high_explosive_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/ex_2.mp3"
 
ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  true

ENT.ExplosionRadius                  =  100
ENT.SpecialRadius                    =  100
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  2555                                
ENT.MaxDelay                         =  0                                 
ENT.TraceLength                      =  3000
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  52
ENT.ArmDelay                         =  0  
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

ENT.Shocktime                        =  3
ENT.DEFAULT_PHYSFORCE                = 9955
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 9000
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 9000 

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
	
	 local pos_sound = self:LocalToWorld(self:OBBCenter())
	 constraint.RemoveAll(self)
	 local physo = self:GetPhysicsObject()
	 physo:Wake()	
	 if not self:IsValid() then return end 
	 self.Exploding = true
	 local pos = self:GetPos()
	 for k, v in pairs(gb5FastSphereSearch(pos,45)) do
		if v:GetClass()=="gb5_nuclear_grable" then
			local phys = v:GetPhysicsObject()
			if (phys:IsValid()) then
				local mass = phys:GetMass()
				local F_ang = 5555
				local dist = (pos - v:GetPos()):Length()
				local relation = math.Clamp((45- dist) / 45, 0, 1)
				local F_dir = (v:GetPos() - pos):GetNormal() * 5555

				phys:Wake()
				phys:EnableMotion(true)

				phys:AddVelocity(F_dir)
				if not v:IsValid() then return end
				timer.Simple(0.2, function()
					phys:AddVelocity(F_dir)		
					if not v:IsValid() then return end
					timer.Simple(0.2, function()
						phys:AddVelocity(F_dir)			
						if not v:IsValid() then return end
						timer.Simple(0.2, function()				
							phys:AddVelocity(F_dir)			
							if not v:IsValid() then return end
							timer.Simple(0.2, function()				
								phys:AddVelocity(F_dir)							
							end)
						end)
					end)
				end)
				
			end
		end
	 end
	 local Shockwave = gb5BeginShockwave() do
	 	Shockwave.Class              = "gb5_shockwave_sound_lowsh"
	 	Shockwave.Origin             = pos
	 	Shockwave.Attacker           = self.GBOWNER
	 	Shockwave.MaxRange           = 50000
	 	Shockwave.ShockwaveIncrement = 100
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Sound              = "gbombs_5/explosions/medium_bomb/ex7.mp3"
	 	Shockwave.Shocktime          = self.Shocktime
	 gb5CommitShockwave() end
	
	 self:StopParticles()

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
			 ParticleEffect(self.Effect,pos,self:GetAngles(),nil)	
			 timer.Simple(0.1, function()
				 self:Remove()
			 end)	
		 else 
			 ParticleEffect(self.EffectAir,self:GetPos(),angle_zero,nil) 
			 self:Remove()

		 end
	 end
end

gb5RegisterSpawnFunction( ENT, 16 )
