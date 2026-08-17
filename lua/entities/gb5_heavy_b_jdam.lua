AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "gbombs_5/explosions/heavy_bomb/explosion_big_2.mp3"
ExploSnds[2]                         =  "gbombs_5/explosions/heavy_bomb/explosion_big_5.mp3"
ExploSnds[2]                         =  "gbombs_5/explosions/light_bomb/mine_explosion.mp3"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Jdam - 1150lb"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Heavy Bombs"

ENT.Model                            =  "models/military2/bomb/bomb_jdam.mdl"                      
ENT.Effect                           =  "jdam_explosion_ground"                  
ENT.EffectAir                        =  "jdam_explosion_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/heavy_bomb/ex2.mp3"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  60
ENT.PhysForce                        =  2600
ENT.ExplosionRadius                  =  2000
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  50 -- 3000 damage
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  500
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.Shocktime                        = 4
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

ENT.Decal                            = "scorch_big"
function ENT:ExploSound(pos)
     if not self.Exploded then return end
	 if self.UseRandomSounds then
         sound.Play(table.Random(ExploSnds), pos, 160, 100,1)
     else
	     sound.Play(self.ExplosionSound, pos, 160, 100,1)
	 end
end

gb5RegisterSpawnFunction( ENT, 16 )

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
   	 	Shockwave.Trace              = self.TraceLength
   	 	Shockwave.Decal              = self.Decal
   	 gb5CommitShockwave() end
	
	 local Shockwave = gb5BeginShockwave() do
	 	Shockwave.Class              = "gb5_shockwave_sound_lowsh"
	 	Shockwave.Origin             = pos
	 	Shockwave.Attacker           = self.GBOWNER
	 	Shockwave.MaxRange           = 50000
	 	Shockwave.ShockwaveIncrement = 100
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Sound              = table.Random(ExploSnds)
	 	Shockwave.Shocktime          = self.Shocktime
	 gb5CommitShockwave() end
	 
	 for k, v in pairs(gb5FastSphereSearch(pos,self.SpecialRadius)) do
		if (v:IsValid() or v:IsPlayer()) then
			if v:IsValid() and v:GetPhysicsObject():IsValid() then
				v:TakeDamage(self.ExplosionDamage, self.GBOWNER, self)		-- Added TakeDamage to the explosion so things like vehicles (simfphys for example) also take damage
			end
		 end
	     if v:IsValid() and not v:IsNPC() then
			 local i = 0
		     while i < v:GetPhysicsObjectCount() do
			 local phys = v:GetPhysicsObjectNum(i)
			 i = i + 1
			 end
		 end
	 end
	 for k, v in pairs(gb5FastSphereSearch(pos,self.SpecialRadius/2)) do
		 if self.ShouldIgnite then
			 if v:IsOnFire() then
				 v:Extinguish()
			 end
			 v:Ignite(math.Rand(self.MaxIgnitionTime-2,self.MaxIgnitionTime),5)
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
			 local ang = self:GetAngles()
			 ParticleEffect(self.Effect,pos,Angle(0,ang.y-270,0),nil) 
		 else 
			 local ang = self:GetAngles()
			 ParticleEffect(self.EffectAir,pos,Angle(0,ang.y-270,0),nil) 
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