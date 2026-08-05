AddCSLuaFile()


DEFINE_BASECLASS( "gb5_base_dumb" )




ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "ICBM Warhead"
ENT.Author			                 =  ""
ENT.Contact			                 =  ""
ENT.Category                         =  "GB5: Custom Nukes"

ENT.Model                            =  "models/thedoctor/icbm/capsule.mdl"           
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""   
ENT.EffectWater                      =  "" 
ENT.ExplosionSound                   =  ""                   
ENT.ParticleTrail                    =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false      
ENT.ShouldExplodeOnImpact            =  false         
ENT.Flamable                         =  false        
ENT.UseRandomSounds                  =  false       
ENT.UseRandomModels                  =  false

ENT.ExplosionDamage                  =  1          
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  3           
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  1
ENT.SpecialRadius                    =  4            
ENT.MaxIgnitionTime                  =  1           
ENT.Life                             =  500          
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  0        
ENT.ImpactSpeed                      =  0           
ENT.Mass                             =  2500

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:ExploSound(pos)
	 local EntTable = self:GetTable()
	local Shockwave = gb5BeginShockwave() do
		Shockwave.Class					= "gb5_shockwave_sound_lowsh"
		Shockwave.Origin				= pos
		Shockwave.Attacker 				= EntTable.GBOWNER
		Shockwave.MaxRange 				= 500000
		Shockwave.ShockwaveIncrement 	= 20000
		Shockwave.Delay 				= 0.01
		Shockwave.Sound 				= EntTable.ExplosionSound
		Shockwave.Shocktime 			= 4
	gb5CommitShockwave() end
end

gb5RegisterSpawnFunction( ENT, -600 )
