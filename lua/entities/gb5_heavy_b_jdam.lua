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
ENT.ExplosionRadius                  =  1000 -- Because it does the work of 2 Howitzer shells in 1, smaller blast compared to other bombs for balance.
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

	 gb5CommitBlastShockwave({
	 	Origin          = pos,
	 	PhysForce       = self.DEFAULT_PHYSFORCE,
	 	PhysForceAir    = self.DEFAULT_PHYSFORCE_PLYAIR,
	 	PhysForceGround = self.DEFAULT_PHYSFORCE_PLYGROUND,
	 	Attacker        = self.GBOWNER,
	 	MaxRange        = self.ExplosionRadius,
	 	Trace           = self.TraceLength,
	 	Decal           = self.Decal,
	 })

	 gb5CommitSoundShockwave({
	 	Origin    = pos,
	 	Attacker  = self.GBOWNER,
	 	Sound     = table.Random(ExploSnds),
	 	Shocktime = self.Shocktime,
	 })

	 gb5ApplyExplosionDamage(self, pos)

	 if self.ShouldIgnite then
		 for k, v in pairs(gb5FastSphereSearch(pos, self.SpecialRadius / 2)) do
			 if v:IsOnFire() then v:Extinguish() end
			 v:Ignite(math.Rand(self.MaxIgnitionTime - 2, self.MaxIgnitionTime), 5)
		 end
	 end

	 -- Custom-oriented impact particle (bunker-buster look), so this bomb keeps
	 -- its own particle block rather than using gb5DoImpactParticles.
	 if self:WaterLevel() >= 1 then
		 local trlength = Vector(0, 0, 9000)
		 local tr  = util.TraceLine({ start = pos, endpos = pos + trlength, filter = self })
		 local tr2 = util.TraceLine({ start = tr.HitPos, endpos = pos - trlength, filter = self, mask = MASK_WATER + CONTENTS_TRANSLUCENT })
		 if tr2.Hit then
			 ParticleEffect(self.EffectWater, tr2.HitPos, angle_zero, nil)
		 end
	 else
		 local trace = util.TraceLine({ start = pos, endpos = pos - Vector(0, 0, self.TraceLength), filter = self })
		 local ang = self:GetAngles()
		 ParticleEffect(trace.HitWorld and self.Effect or self.EffectAir, pos, Angle(0, ang.y - 270, 0), nil)
	 end

	 gb5SpawnNBC(self)
     self:Remove()
end