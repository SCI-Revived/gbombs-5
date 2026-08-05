AddCSLuaFile()

DEFINE_BASECLASS( "gb5_proj_tankshell_base" )

ENT.Spawnable		            	 =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "135mm Tankshell"
ENT.Author			                 =  ""
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/starchick971/tankshell.mdl"

ENT.ExplosionDamage                  =  1000
ENT.ExplosionRadius                  =  250
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  1
ENT.FuelBurnoutTime                  =  0.23

gb5RegisterSpawnFunction( ENT, 16 )
