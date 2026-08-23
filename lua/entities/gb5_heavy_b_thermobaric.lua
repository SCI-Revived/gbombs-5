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
ENT.ExplosionRadius                  =  2800 -- Bigger blast because thermobaric.
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

	 -- Initial (smaller) blast + its sound.
	 gb5CommitBlastShockwave({
	 	Origin          = pos,
	 	PhysForce       = 50,
	 	PhysForceAir    = 50,
	 	PhysForceGround = 50,
	 	Attacker        = self.GBOWNER,
	 	MaxRange        = 2100,
	 	Trace           = self.TraceLength,
	 	Decal           = self.Decal,
	 })
	 gb5CommitSoundShockwave({
	 	Origin    = pos,
	 	Attacker  = self.GBOWNER,
	 	Sound     = "gbombs_5/explosions/nuclear/tsar_in.mp3",
	 	Shocktime = 1.2,
	 })

	 -- Second, larger blast a moment later (thermobaric afterburn).
	 timer.Simple(1, function()
	 	gb5CommitBlastShockwave({
	 		Origin          = pos,
	 		PhysForce       = 200,
	 		PhysForceAir    = 100,
	 		PhysForceGround = 100,
	 		Attacker        = owner,
	 		MaxRange        = 4000,
	 		Trace           = self.TraceLength,
	 		Decal           = self.Decal,
	 	})
	 	gb5CommitSoundShockwave({
	 		Origin    = pos,
	 		Attacker  = self.GBOWNER,
	 		Sound     = "gbombs_5/explosions/heavy_bomb/ex1.mp3",
	 		Shocktime = 3,
	 	})
	 end)

	 gb5DoImpactParticles(self, pos)
	 gb5SpawnNBC(self)
	 gb5ApplyExplosionDamage(self, pos)

     self:Remove()
end