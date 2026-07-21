AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_clbomb" )

ENT.Spawnable			             =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Radioactive Barrel"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "Natsu"
ENT.Category                         =  "GB5: Nuclear"

ENT.Model                            =  "models/thedoctor/radbarrel.mdl"                      
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""      
ENT.EffectWater                      =  "water_small"
ENT.ExplosionSound                   =  ""
ENT.ArmSound                         =  ""            
ENT.ActivationSound                  =  ""     
ENT.Bomblet                          =  "gb5_nuclear_c_plutonium"

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false    
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false
ENT.RandomAngles                     =  true          -- If this is false, the bomblets will spawn facing the general bomb direction.

ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  250
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0
ENT.NumBomblets                      =  6
ENT.Magnitude                        =  2
ENT.Shape                            =  "RANDOM"

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.



gb5RegisterSpawnFunction( ENT, {
	offset    = 16,
	postSpawn = function( stored, ent )
		ent.Armed = true
	end,
} )
