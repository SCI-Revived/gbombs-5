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
ENT.ExplosionRadius                  =  3000
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  400 -- 20,000 damage. Use for especially strong bases.
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

ENT.ShockwaveClass         = "gb5_shockwave_ent"
ENT.AppliesExplosionDamage = false
function ENT:GetExplosionSound() return table.Random(ExploSnds) end
