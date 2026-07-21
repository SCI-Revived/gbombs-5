AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Howitzer Propellant"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/props_lab/jar01b.mdl"                      
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
		if v:GetClass()=="gb5_proj_howitzer_shell_in" or v:GetClass()=="gb5_proj_howitzer_shell_he" or  v:GetClass()=="gb5_proj_howitzer_shell_frag" then
			local phys = v:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				v:Arm()
				phys:EnableMotion(true)
				phys:AddVelocity(v:GetForward() * -5500)
				if not v:IsValid() then return end
				if not phys:IsValid() then return end
				timer.Simple(0.2, function()
					phys:AddVelocity(v:GetForward() * -5500)
					if not v:IsValid() then return end
					if not phys:IsValid() then return end
					timer.Simple(0.2, function()
						phys:AddVelocity(v:GetForward() * -5500)
						if not v:IsValid() then return end
						if not phys:IsValid() then return end
						timer.Simple(0.2, function()				
							phys:AddVelocity(v:GetForward() * -5500)
							if not v:IsValid() then return end
							if not phys:IsValid() then return end
							timer.Simple(0.2, function()		
								if not v:IsValid() then return end
								if not phys:IsValid() then return end							
								phys:AddVelocity(v:GetForward() * -5500)					
							end)
						end)
					end)
				end)
				
			end
		end
		if v:GetClass()=="gb5_proj_howitzer_shell_cl" then
			v:Arm()
			local phys = v:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableMotion(true)
				phys:AddVelocity(v:GetForward() * -5500)
				if not v:IsValid() then return end
				if not phys:IsValid() then return end
				local temp_vel = v:GetForward() * -5500
				timer.Simple(0.2, function()
					phys:AddVelocity(temp_vel)
					if not v:IsValid() then return end
					if not phys:IsValid() then return end
					timer.Simple(0.2, function()
						phys:AddVelocity(temp_vel)
						if not v:IsValid() then return end
						if not phys:IsValid() then return end
						timer.Simple(0.2, function()				
							phys:AddVelocity(temp_vel)
							if not v:IsValid() then return end
							if not phys:IsValid() then return end
							timer.Simple(0.2, function()		
								if not v:IsValid() then return end
								if not phys:IsValid() then return end							
								phys:AddVelocity(temp_vel)					
							end)
						end)
					end)
				end)
				
			end
		end
	 end
	 local howitzer={}
	 howitzer[1]="gbombs_5/explosions/medium_bomb/howitzer_fire.mp3"
	 howitzer[2]="gbombs_5/explosions/medium_bomb/howitzer_fire2.mp3"
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
	 	Shockwave.Sound              = table.Random(howitzer)
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
