AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Wildfire Vial"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Misc"

ENT.Model                            =  "models/thedoctor/wildfire.mdl"                      
ENT.Effect                           =  "neuro_wildfire_explo"                  
ENT.EffectAir                        =  "neuro_wildfire_explo_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/fieryexplosion.mp3"    

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  true
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  25         
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  150           
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  1
ENT.SpecialRadius                    =  252            
ENT.MaxIgnitionTime                  =  4           
ENT.Life                             =  25       
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  65       
ENT.ImpactSpeed                      =  255          
ENT.Mass                             =  50

ENT.DEFAULT_PHYSFORCE                = 50
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000 

ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil           

gb5RegisterSpawnFunction( ENT, 16 )
