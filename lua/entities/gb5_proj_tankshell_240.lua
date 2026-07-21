AddCSLuaFile()

DEFINE_BASECLASS( "gb5_proj_tankshell_base" )

ENT.Spawnable		            	 =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "240mm Tankshell"
ENT.Author			                 =  ""
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/starchick971/tankshell_240.mdl"

ENT.ExplosionDamage                  =  3000
ENT.ExplosionRadius                  =  450
ENT.FuelBurnoutTime                  =  0.15

gb5RegisterSpawnFunction( ENT, 16 )
