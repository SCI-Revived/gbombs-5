AddCSLuaFile()

DEFINE_BASECLASS( "gb5_proj_tankshell_base" )

ENT.Spawnable		            	 =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "170mm Tankshell"
ENT.Author			                 =  ""
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/starchick971/tankshell_170.mdl"

ENT.ExplosionDamage                  =  50
ENT.ExplosionRadius                  =  350
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  40 -- 2000 Damage
ENT.FuelBurnoutTime                  =  0.18

gb5RegisterSpawnFunction( ENT, 16 )
