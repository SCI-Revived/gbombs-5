AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "gbombs_5/explosions/heavy_bomb/t_12.mp3"
ExploSnds[2]                         =  "gbombs_5/explosions/heavy_bomb/explosion_big_6.mp3"
ExploSnds[3]                         =  "gbombs_5/explosions/heavy_bomb/explosion_big_7.mp3"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "T-12 Cloudmaker"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Heavy Bombs"

ENT.Model                            =  "models/thedoctor/t12.mdl"                      
ENT.Effect                           =  "cloudmaker_ground"                  
ENT.EffectAir                        =  "cloudmaker_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  ""
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
ENT.PhysForce                        =  2600
ENT.ExplosionRadius                  =  1400
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  420 -- 21,000 damage. Use for especially strong bases.
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  400
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  3000
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.Shocktime                        = 4
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.
ENT.Decals                           = "scorch_big_3"

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

	gb5DoImpactParticles(self, pos)
	gb5SpawnNBC(self)
	self:Remove()
end