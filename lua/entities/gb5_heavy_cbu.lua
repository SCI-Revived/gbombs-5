AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "CBU-52U"
ENT.Author			                 =  "Natsu (Fixed by Scoopy)"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Heavy Bombs"

ENT.Model                            =  "models/military2/bomb/bomb_cbu.mdl"                      
ENT.Effect                           =  "high_explosive_main_2"                  
ENT.EffectAir                        =  "high_explosive_air_2"                   
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

ENT.ExplosionDamage                  =  200
ENT.PhysForce                        =  200
ENT.ExplosionRadius                  =  100
ENT.SpecialRadius                    =  500
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  0                                 
ENT.TraceLength                      =  3000
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  52
ENT.ArmDelay                         =  0  
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.


ENT.DEFAULT_PHYSFORCE                = 155
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
		if GetConVar("gb5_sound_speed"):GetInt() == 0 then
	 	Shockwave.ShockwaveIncrement = 200
		elseif GetConVar("gb5_sound_speed"):GetInt()== 1 then
	 	Shockwave.ShockwaveIncrement = 300
		elseif GetConVar("gb5_sound_speed"):GetInt() == 2 then
	 	Shockwave.ShockwaveIncrement = 400
		elseif GetConVar("gb5_sound_speed"):GetInt() == -1 then
	 	Shockwave.ShockwaveIncrement = 100
		elseif GetConVar("gb5_sound_speed"):GetInt() == -2 then
	 	Shockwave.ShockwaveIncrement = 50
		else
	 	Shockwave.ShockwaveIncrement = 200
		end
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Sound              = self.ExplosionSound
	 	Shockwave.Shocktime          = self.Shocktime
	 gb5CommitShockwave() end

	 for i=0, (15-1) do
		 local ent1 = ents.Create("gb5_heavy_cbu_bomblet") 
		 local phys = ent1:GetPhysicsObject()
		 ent1:SetPos( self:GetPos() ) 
		 ent1:Spawn()
		 ent1:Activate()
		 ent1:SetVar("GBOWNER", self.GBOWNER)
		 local bphys = ent1:GetPhysicsObject()
		 local phys = self:GetPhysicsObject()
		 if bphys:IsValid() and phys:IsValid() then
			 bphys:ApplyForceCenter(VectorRand() * bphys:GetMass() * 155)
			 bphys:AddVelocity(phys:GetVelocity()/2)
		 end
		 timer.Simple(4, function()
		    if ent1:IsValid() then
				ent1:Remove()
			end
		 end)
	 end
	 for k, v in pairs(gb5FastSphereSearch(pos,self.SpecialRadius/2)) do
		 if self.ShouldUnweld then
			 if v:IsValid() then
				 if v:IsValid() and v:GetPhysicsObject():IsValid() then
					 constraint.RemoveAll(v)
				 end
			 end
		 end
		 if self.ShouldIgnite then
			 if v:IsOnFire() then
				 v:Extinguish()
			 end
			 v:Ignite(math.Rand(self.MaxIgnitionTime-2,self.MaxIgnitionTime),5)
		 end
	 end
	 for k, v in pairs(gb5FastSphereSearch(pos,self.SpecialRadius)) do
		 if v:IsValid() and (v ~= self) then
			 local phys = v:GetPhysicsObject()
			 if (phys:IsValid()) then
				 local mass = phys:GetMass()
				 local F_ang = self.PhysForce
				 local dist = (pos - v:GetPos()):Length()
				 local relation = math.Clamp((self.SpecialRadius - dist) / self.SpecialRadius, 0, 1)
				 local F_dir = (v:GetPos() - pos):GetNormal() * self.PhysForce
		
				 phys:Wake()
				 phys:EnableMotion(true)
			   
				 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
				 phys:AddVelocity(F_dir)
			 end
		 end
	 end 
	 local pos = self:GetPos()
	 util.BlastDamage(self, self.GBOWNER, pos, self.ExplosionRadius, self.ExplosionDamage)
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
