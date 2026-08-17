AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "GXM11 - Thermobaric"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Heavy Bombs"

ENT.Model                            =  "models/military2/bomb/bomb_gbu.mdl"                      
ENT.Effect                           =  "thermo_fireball_explosion"                  
ENT.EffectAir                        =  "thermo_fireball_explosion_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/heavy_bomb/ex1.mp3"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  50
ENT.PhysForce                        =  32
ENT.ExplosionRadius                  =  1800 -- Bigger blast because thermobaric.
ENT.PlayerDamageScale                =  1.2 -- 60 player damage, standard for heavy bombs.
ENT.PropDamageScale                  =  100 -- 5000 damage.
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  3000
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.Shocktime                        = 4
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.
ENT.Decal                            = "nuke_small"


gb5RegisterSpawnFunction( ENT, 16 )


function ENT:Explode()
     if not self.Exploded then return end
	 local pos = self:LocalToWorld(self:OBBCenter())
	 local owner = self.GBOWNER
   	 local Shockwave = gb5BeginShockwave() do
   	 	Shockwave.Class              = "gb5_shockwave_ent"
   	 	Shockwave.Origin             = pos
   	 	Shockwave.PhysForce          = 50
   	 	Shockwave.PhysForceAir       = 50
   	 	Shockwave.PhysForceGround    = 50
   	 	Shockwave.Attacker           = self.GBOWNER
   	 	Shockwave.MaxRange           = 2100
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
	 	Shockwave.Sound              = "gbombs_5/explosions/nuclear/tsar_in.mp3"
	 	Shockwave.Shocktime          = 1.2
	 gb5CommitShockwave() end
	 
	 timer.Simple(1, function()
			 
		 local Shockwave = gb5BeginShockwave() do
		 	Shockwave.Class              = "gb5_shockwave_ent"
		 	Shockwave.Origin             = pos
		 	Shockwave.PhysForce          = 200
		 	Shockwave.PhysForceAir       = 100
		 	Shockwave.PhysForceGround    = 100
		 	Shockwave.Attacker           = owner
		 	Shockwave.MaxRange           = 4000
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
		 	Shockwave.Sound              = "gbombs_5/explosions/heavy_bomb/ex1.mp3"
		 	Shockwave.Shocktime          = 3
		 gb5CommitShockwave() end
	 end)
	 
	 



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

	 for k, v in pairs(gb5FastSphereSearch(pos, self.ExplosionRadius)) do
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			if v:IsPlayer() then
				v:TakeDamage(self.ExplosionDamage * GetConVar("gb5_player_damage_scale"):GetFloat() * self.PlayerDamageScale, self.GBOWNER, self)
			else
				v:TakeDamage(self.ExplosionDamage * GetConVar("gb5_prop_damage_scale"):GetFloat() * self.PropDamageScale, self.GBOWNER, self)
			end
		end
	 end
	 
     self:Remove()
end