AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  false        
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "Field Raper"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "Garry's Bombs 5"

ENT.Model                            =  "models/thedoctor/pellet.mdl"                      
ENT.Effect                           =  "50lb_main"                  
ENT.EffectAir                        =  "50lb_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/small_explosion_1.mp3"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  99
ENT.PhysForce                        =  600
ENT.ExplosionRadius                  =  300
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  1
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  98                                 
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  110
ENT.Mass                             =  90
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil 

ENT.DEFAULT_PHYSFORCE                = 255
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 1000 
ENT.Decal                            = "scorch_small"

ENT.DEFAULT_PHYSFORCE                = 195
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 1000 
ENT.Decal                            = "scorch_small"

gb5RegisterSpawnFunction( ENT, 16 )

function ENT:Arm()
     if(not self:IsValid()) then return end
	 if(self.Exploded) then return end
	 if(self.Armed) then return end
	 self.Arming = true
	 self.Used = true
	

	
	 self:SetMaterial("Models/effects/vol_light001")
 
	 
	 timer.Simple(self.ArmDelay, function()
	     if not self:IsValid() then return end 
	     self.Armed = true
		 self.Arming = false
		 self:EmitSound(self.ArmSound)
		 if(self.Timed) then
	         timer.Simple(self.Timer, function()
	             if not self:IsValid() then return end 
				 timer.Simple(math.Rand(0,self.MaxDelay),function()
			         if not self:IsValid() then return end 
			         self.Exploded = true
			         self:Explode()
				 end)
	         end)
	     end
	 end)
end	 


function ENT:Initialize()
	if (SERVER) then
		self:LoadModel()
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE ) -- doesen't fucking work
		local phys = self:GetPhysicsObject()
		local skincount = self:SkinCount()
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:Wake()
		end
		if (skincount > 0) then
			self:SetSkin(math.random(0,skincount))
		end
		self.Exploded = false
		timer.Simple(math.random()+0.3, function() 
			if not self:IsValid() then return end
			self.Exploded=true
			self:Explode()
		end)
	end
end
function ENT:Explode()
     if not self.Exploded then return end
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
	 
	 for i=0, (8-1) do
		 local ent1 = ents.Create("gb5_m_clustermine_bomblet") 
		 local phys = ent1:GetPhysicsObject()
		 ent1:SetPos( self:GetPos() ) 
		 ent1:Spawn()
		 ent1:Activate()
		 ent1:SetVar("GBOWNER", self.GBOWNER)
		 local bphys = ent1:GetPhysicsObject()
		 local phys = self:GetPhysicsObject()
		  if bphys:IsValid() and phys:IsValid() then
			 bphys:ApplyForceCenter(VectorRand() * bphys:GetMass() / math.random(10,100) )
			 bphys:AddVelocity(Vector(0,0,100))
			 ent1:Ignite(1)
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
		 else 
			 ParticleEffect(self.EffectAir,pos,angle_zero,nil) 
		 end
	 end
	 if self.IsNBC then
	     local nbc = ents.Create(self.NBCEntity)
		 nbc:SetVar("GBOWNER",self.GBOWNER)
		 nbc:SetPos(self:GetPos())
		 nbc:Spawn()
		 nbc:Activate()
	 end
     self:Remove()
end