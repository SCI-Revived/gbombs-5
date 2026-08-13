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

ENT.PrintName		                 =  "VX Gas"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Chemical"

ENT.Model                            =  "models/thedoctor/vx.mdl"                      
ENT.Effect                           =  "vx_ground"                  
ENT.EffectAir                        =  "vx_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/chemical/gasleak_long.mp3"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  25
ENT.PhysForce                        =  600
ENT.ExplosionRadius                  =  1
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  0
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  300
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  75
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Explode()
	local ent = ents.Create("gb5_chemical_vx_gas_dmg")
	local pos = self:GetPos()
	ent:SetPos( pos )
	ent:Spawn()
	ent:Activate()
	ent:SetVar("GBOWNER",self.GBOWNER)
 	local Shockwave = gb5BeginShockwave() do
 		Shockwave.Class              = "gb5_shockwave_sound_lowsh"
 		Shockwave.Origin             = pos
 		Shockwave.Attacker           = self.GBOWNER
 		Shockwave.MaxRange           = 50000
		if GetConVar("gb5_sound_speed"):GetInt() == 0 then
 		Shockwave.ShockwaveIncrement = 200
		elseif GetConVar("gb5_sound_speed"):GetInt()== 1 then
 		Shockwave.ShockwaveIncrement = 300
		elseif GetConVar("gb5_sound_speed"):GetInt() == 2 then
 		Shockwave.ShockwaveIncrement = 400
		elseif GetConVar("gb5_sound_speed"):GetInt() == -1 then
 		Shockwave.ShockwaveIncrement = 100
		elseif GetConVar("gb5_sound_speed"):GetInt() == -2 then
 		Shockwave.ShockwaveIncrement = 50
		else
 		Shockwave.ShockwaveIncrement = 200
		end
 		Shockwave.Delay              = 0.01
 		Shockwave.Sound              = self.ExplosionSound
 		Shockwave.Shocktime          = self.Shocktime
 	gb5CommitShockwave() end
	if(self:WaterLevel() >= 1) then
		local trdata   = {}
		local trlength = Vector(0,0,9000)

		trdata.start   = pos
		trdata.endpos  = trdata.start + trlength
		trdata.filter  = self

		local tr = util.TraceLine(trdata) 
		local trdat2   = {}
		trdat2.start   = tr.HitPos
		trdat2.endpos  = trdata.start - trlength
		trdat2.filter  = self
		trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT

		local tr2 = util.TraceLine(trdat2)

		if tr2.Hit then
			ParticleEffect(self.EffectWater, tr2.HitPos, angle_zero, nil)
		end
	else
		local tracedata    = {}
		tracedata.start    = pos
		tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		tracedata.filter   = self.Entity

		local trace = util.TraceLine(tracedata)

		if trace.HitWorld then
			local ang = self:GetAngles()
			ParticleEffect(self.Effect,pos,Angle(0,ang.y-270,0),nil) 

		else 
			ParticleEffect(self.EffectAir,pos,angle_zero,nil) 
		end
	end
	self:Remove()
end

gb5RegisterSpawnFunction( ENT, 26 )
