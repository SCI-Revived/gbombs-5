AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Howitzer Frag Shell"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/thedoctor/howitzer/howitzer_frag.mdl"                      
ENT.Effect                           =  "500lb_ground"                  
ENT.EffectAir                        =  "500lb_air"                   
ENT.EffectWater                      =  "water_huge"                 
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/mine_explosion.mp3"

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.ExplosionRadius                  =  500
ENT.SpecialRadius                    =  2000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  0                              
ENT.TraceLength                      =  200
ENT.ImpactSpeed                      =  300
ENT.Mass                             =  255
ENT.ArmDelay                         =  0.1   
ENT.Timer                            =  0

ENT.DEFAULT_PHYSFORCE                = 255
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 25
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 2555
ENT.GBOWNER                          =  nil     
ENT.Decal                            = "scorch_small"


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
	 self:SetModel("models/gibs/scanner_gib02.mdl")
	 self.Exploding = true
	 
	 self:SetMoveType( MOVETYPE_NONE )
	 self:SetMaterial("phoenix_storms/glass")
	 self:SetModel("models/hunter/plates/plate.mdl")
	 	 
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

	 for k, v in pairs(gb5FastSphereSearch(pos,1200)) do
		if v:IsPlayer() or v:IsNPC() then
			v:Ignite(2,0)
		else
			 local phys = self:GetPhysicsObject()
			 if phys:IsValid() then
				v:TakeDamage(self.ExplosionDamage, self.GBOWNER, self)		-- Added TakeDamage to the explosion so things like vehicles (simfphys for example) also take damage
			 end
		end
	 end
	 
	 local Shockwave = gb5BeginShockwave() do
	 	Shockwave.Class              = "gb5_shockwave_ent"
	 	Shockwave.Origin             = pos
	 	Shockwave.PhysForce          = self.DEFAULT_PHYSFORCE
	 	Shockwave.PhysForceAir       = self.DEFAULT_PHYSFORCE_PLYAIR
	 	Shockwave.PhysForceGround    = self.DEFAULT_PHYSFORCE_PLYGROUND
	 	Shockwave.Attacker           = self.GBOWNER
	 	Shockwave.MaxRange           = 800
	 	Shockwave.ShockwaveIncrement = 100
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Sound              = "gbombs_5/explosions/nuclear/abomb.mp3"
	 	Shockwave.Trace              = self.TraceLength
	 	Shockwave.Decal              = self.Decal
	 gb5CommitShockwave() end
	 for i=0, (25-1) do
		 local ent1 = ents.Create("gb5_light_peldumb") 
		 local phys = ent1:GetPhysicsObject()
		 ent1:SetPos( self:GetPos() ) 
		 ent1:Spawn()
		 ent1:Activate()
		 ent1:SetVar("GBOWNER", self.GBOWNER)
		 local bphys = ent1:GetPhysicsObject()
		 local phys = self:GetPhysicsObject()
		 if bphys:IsValid() and phys:IsValid() then
			 bphys:ApplyForceCenter(VectorRand() * bphys:GetMass() * 1055)
			 ent1:Ignite(4,0)
			 bphys:AddVelocity(phys:GetVelocity()/2)
		 end
		 timer.Simple(6, function()
		    if ent1:IsValid() then
				ent1:Remove()
			end
		 end)
	 end
	 local physo = self:GetPhysicsObject()
	 physo:Wake()
	 physo:EnableMotion(true)
	
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
			 timer.Simple(2, function()
				 if not self:IsValid() then return end 
				 self:Remove()
		 end)	
		 else 
			 ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
			 timer.Simple(2, function()
				 if not self:IsValid() then return end 
				 self:Remove()
			end)	
		 end
	 end
end

gb5RegisterSpawnFunction( ENT, 16 )
