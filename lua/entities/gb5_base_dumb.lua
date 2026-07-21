AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

util.PrecacheSound("BaseExplosionEffect.Sound")

local gb5_sound_speed = GetConVar("gb5_sound_speed")

local ExploSnds = {}
ExploSnds[1]                         =  "BaseExplosionEffect.Sound"

local Models = {}
Models[1]                            =  "model"

-- local damagesound                    =  "weapons/rpg/shotdown.wav"

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "Name"
ENT.Author			                 =  "Avatar natsu"
ENT.Contact			                 =  "GTFO"
ENT.Category                         =  "GTFOnot "

ENT.Model                            =  ""
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""
ENT.EffectWater                      =  ""
ENT.ExplosionSound                   =  ""
ENT.ParticleTrail                    =  ""
ENT.NBCEntity                        =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  false
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.IsNBC                            =  false

ENT.ExplosionDamage                  =  5000
ENT.PhysForce                        =  0
ENT.ExplosionRadius                  =  255
ENT.SpecialRadius                    =  0
ENT.MaxIgnitionTime                  =  5
ENT.Life                             =  20
ENT.MaxDelay                         =  2
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  500
ENT.Mass                             =  0
ENT.Shocktime                        =  1

ENT.DEFAULT_PHYSFORCE  = 0
ENT.DEFAULT_PHYSFORCE_PLYAIR  = 0
ENT.DEFAULT_PHYSFORCE_PLYGROUND = 0

function ENT:Initialize()
if (SERVER) then
	self:LoadModel()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	local phys = self:GetPhysicsObject()
	local skincount = self:SkinCount()
	if (phys:IsValid()) then
		phys:SetMass(self.Mass)
		phys:Wake()
	end
	if (skincount > 0) then
		self:SetSkin(math.random(0,skincount))
	end
	self.Exploded = false
	end
end

function ENT:LoadModel()
	if self.UseRandomModels then
		self:SetModel(table.Random(Models))
	else
		self:SetModel(self.Model)
	end
end

function ENT:Explode()
	local SelfTbl = self:GetTable()

	if not SelfTbl.Exploded then return end
	local pos = self:LocalToWorld(self:OBBCenter())

	local Shockwave = gb5BeginShockwave() do
		Shockwave.Class              = "gb5_shockwave_ent"
		Shockwave.Origin             = pos
		Shockwave.PhysForce          = SelfTbl.DEFAULT_PHYSFORCE
		Shockwave.PhysForceAir       = SelfTbl.DEFAULT_PHYSFORCE_PLYAIR
		Shockwave.PhysForceGround    = SelfTbl.DEFAULT_PHYSFORCE_PLYGROUND
		Shockwave.Attacker           = SelfTbl.GBOWNER
		Shockwave.MaxRange           = SelfTbl.ExplosionRadius
		Shockwave.ShockwaveIncrement = 100
		Shockwave.Delay              = 0.01
		Shockwave.Trace              = SelfTbl.TraceLength
		Shockwave.Decal              = SelfTbl.Decal
	gb5CommitShockwave() end

	Shockwave = gb5BeginShockwave() do
		Shockwave.Class              = "gb5_shockwave_sound_lowsh"
		Shockwave.Origin             = pos
		Shockwave.Attacker           = SelfTbl.GBOWNER
		Shockwave.MaxRange           = 50000
		if gb5_sound_speed:GetInt() == 0 then
			Shockwave.ShockwaveIncrement = 200
		elseif gb5_sound_speed:GetInt() == 1 then
			Shockwave.ShockwaveIncrement = 300
		elseif gb5_sound_speed:GetInt() == 2 then
			Shockwave.ShockwaveIncrement = 400
		elseif gb5_sound_speed:GetInt() == -1 then
			Shockwave.ShockwaveIncrement = 100
		elseif gb5_sound_speed:GetInt() == -2 then
			Shockwave.ShockwaveIncrement = 50
		else
			Shockwave.ShockwaveIncrement = 200
		end
		Shockwave.Delay              = 0.01
		Shockwave.Sound              = SelfTbl.ExplosionSound
		Shockwave.Shocktime          = SelfTbl.Shocktime
	gb5CommitShockwave() end

	for k, v in pairs(gb5FastSphereSearch(pos, SelfTbl.SpecialRadius)) do
		if v:IsValid() then
			v:TakeDamage(SelfTbl.ExplosionDamage, SelfTbl.GBOWNER, self)		-- Added TakeDamage to the explosion so things like vehicles (simfphys for example) also take damage
		end
	end

	local SelfClass = self:GetClass()
	for k, v in pairs(gb5FastSphereSearch(pos, SelfTbl.SpecialRadius / 2)) do
		if SelfTbl.ShouldIgnite and v ~= self then
			if v:IsOnFire() then
				v:Extinguish()
			end

			v:Ignite(math.Rand(SelfTbl.MaxIgnitionTime - 2, SelfTbl.MaxIgnitionTime), 5)
			if SelfClass == "gb5_misc_wildfire_vial" or SelfClass == "gb5_misc_wildfire_barrel" then
				ParticleEffectAttach("neuro_wildfire_burn_outside", PATTACH_ABSORIGIN_FOLLOW, v, 0)
			end

			if v:GetClass() ~= SelfClass then
				ParticleEffectAttach("neuro_gascan_burn_outside", PATTACH_ABSORIGIN_FOLLOW, v, 0)
			end
		end
	end

	if self:WaterLevel() >= 1 then
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
			ParticleEffect(SelfTbl.EffectWater, tr2.HitPos, angle_zero, nil)
		end
	else
		local tracedata    = {}
		tracedata.start    = pos
		tracedata.endpos   = tracedata.start - Vector(0, 0, SelfTbl.TraceLength)
		tracedata.filter   = self

		local trace = util.TraceLine(tracedata)

		if trace.HitWorld then
			ParticleEffect(SelfTbl.Effect,pos, angle_zero, nil)
		else
			ParticleEffect(SelfTbl.EffectAir,pos, angle_zero, nil)
		end
	end

	if self.IsNBC then
		local nbc = ents.Create(self.NBCEntity)
		nbc:SetVar("GBOWNER",self.GBOWNER)
		nbc:SetPos(self:GetPos())
		nbc:Spawn()
		nbc:Activate()
	end
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	if self.Exploded then return end
	self:TakePhysicsDamage(dmginfo)

	if (self.Life <= 0) then return end

	if self:IsValid() then
		self.Life = self.Life - dmginfo:GetDamage()
		if (self.Life <= self.Life / 2) and not self.Exploded and self.Flamable then
			self:Ignite(self.MaxDelay,0)
		end

		if (self.Life <= 0) then
			timer.Simple(math.Rand(0,self.MaxDelay),function()
				if not self:IsValid() then return end
				self.Exploded = true
				self:Explode()
			end)
		end
	end
end

function ENT:PhysicsCollide(data, physobj)
	if not IsValid(self) then return end
	if self.Exploded then return end
	if self.Life <= 0 then return end

	if self.ShouldExplodeOnImpact and (data.Speed > self.ImpactSpeed ) then
		self.Exploded = true
		self:Explode()
	end
end

function ENT:OnRemove()
	self:StopParticles()
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end