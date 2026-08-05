AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "gbombs_5/explosions/medium_bomb/explosion_petrol_small.mp3"
ExploSnds[2]                         =  "gbombs_5/explosions/medium_bomb/explosion_petrol_medium.mp3"
ExploSnds[3]                         =  "gbombs_5/explosions/medium_bomb/explosion_petrol_small2.mp3"
ExploSnds[4]                         =  "gbombs_5/explosions/medium_bomb/explosion_petrol_medium2.mp3"


ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Mark 77 Napalm"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Chemical"

ENT.Model                            =  "models/thedoctor/napalm.mdl"                      
ENT.Effect                           =  "napalm_explosion"                  
ENT.EffectAir                        =  "napalm_explosion_midair"                   
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

ENT.ExplosionDamage                  =  750
ENT.PhysForce                        =  600
ENT.ExplosionRadius                  =  950
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  1
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  300
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  500
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Explode()
	local ent = ents.Create("gb5_chemical_napalm_b")
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
 		Shockwave.Sound              = table.Random(ExploSnds)
 		Shockwave.Shocktime          = self.Shocktime
 	gb5CommitShockwave() end
	for k, v in pairs(gb5FastSphereSearch(pos,1700)) do
		if v:IsPlayer() or v:IsNPC() then
			if v:GetClass()=="npc_helicopter" then return end
			v:Ignite(6,0)
		else
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				v:TakeDamage(self.ExplosionDamage, self.GBOWNER, self)		-- Added TakeDamage to the explosion so things like vehicles (simfphys for example) also take damage
				v:Ignite(12,0)
			end
		end
	end
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
			ParticleEffect(self.Effect,pos,Angle(0,ang.y,0),nil) 

		else 
			ParticleEffect(self.EffectAir,pos,angle_zero,nil) 
		end
	end
	self:Remove()
end

gb5RegisterSpawnFunction( ENT, 26 )
