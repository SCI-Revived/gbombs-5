AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

local Models = {}
Models[1]                            =  "testmodel"

local ExploSnds = {}
ExploSnds[1]                         =  "BaseExplosionEffect.Sound"

local damagesound                    =  "weapons/rpg/shotdown.wav"

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "Name"
ENT.Author			                 =  "natsu"
ENT.Contact			                 =  "natsu"
ENT.Category                         =  ""

ENT.Model                            =  ""
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""
ENT.EffectWater                      =  ""
ENT.ExplosionSound                   =  ""
ENT.ArmSound                         =  ""
ENT.ActivationSound                  =  ""
ENT.NBCEntity                        =  ""


ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  false
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false
ENT.IsNBC                            =  false

ENT.ExplosionDamage                  =  5000
ENT.PropExplosionDamage              =  nil -- if a bomb does not use this, defaults to ENT.ExplosionDamage
ENT.PhysForce                        =  0
ENT.ExplosionRadius                  =  255
ENT.SpecialRadius                    =  0
ENT.MaxIgnitionTime                  =  5
ENT.Life                             =  20
ENT.MaxDelay                         =  2
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  500
ENT.Mass                             =  0
ENT.ArmDelay                         =  2
ENT.Timer                            =  0
ENT.Shocktime                        =  1

ENT.DEFAULT_PHYSFORCE                = 500
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 100
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 5000
ENT.GBOWNER                          =  nil

local Inputs = {"Arm", "Detonate"}

function ENT:Initialize()
	if SERVER then
		self:LoadModel()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(ONOFF_USE)

		local phys = self:GetPhysicsObject()
		local skincount = self:SkinCount()

		if IsValid(phys) then
			phys:SetMass(self.Mass)
			phys:Wake()
		end

		if (skincount > 0) then
			self:SetSkin(math.random(0,skincount))
		end

		self.Armed    = false
		self.Exploded = false
		self.Used     = false
		self.Arming   = false

		if WireAddon ~= nil then
			self.Inputs = Wire_CreateInputs(self, Inputs)
		end
	end
end


local InputFunctions = {}
function InputFunctions:Arm(Value)
	if Value < 1 then return end

	local SelfTbl = self:GetTable()

	if not SelfTbl.Exploded and not SelfTbl.Armed and not SelfTbl.Arming then
		self:EmitSound(SelfTbl.ActivationSound)
		self:Arm()
	end
end

function InputFunctions:Detonate(Value)
	if Value < 1 then return end

	local SelfTbl = self:GetTable()

	if (not SelfTbl.Exploded and SelfTbl.Armed) then
		timer.Simple(math.Rand(0,SelfTbl.MaxDelay),function()
			if not IsValid(self) then return end
			SelfTbl.Exploded = true
			self:Explode()
		end)
	end
end

function ENT:TriggerInput(Name, Value)
	if not IsValid(self) then return end

	local Fn = InputFunctions[Name]
	if Fn then Fn(self, Value) end
end

function ENT:LoadModel()
	if self.UseRandomModels then
		self:SetModel(table.Random(Models))
	else
		self:SetModel(self.Model)
	end
end

local gb5_sound_speed = GetConVar("gb5_sound_speed")

function ENT:Explode()
	if not self.Exploded then return end
	local pos = self:LocalToWorld(self:OBBCenter())
	local EntTable 					= self:GetTable()

	local Shockwave
	do Shockwave = gb5BeginShockwave()
		Shockwave.Origin				= pos
		Shockwave.PhysForce 			= EntTable.DEFAULT_PHYSFORCE
		Shockwave.PhysForceAir 			= EntTable.DEFAULT_PHYSFORCE_PLYAIR
		Shockwave.PhysForceGround 		= EntTable.DEFAULT_PHYSFORCE_PLYGROUND
		Shockwave.Attacker 				= EntTable.GBOWNER
		Shockwave.MaxRange 				= EntTable.ExplosionRadius
		Shockwave.ShockwaveIncrement 	= 100
		Shockwave.Delay 				= 0.01
		Shockwave.Trace 				= EntTable.TraceLength
		Shockwave.Decal 				= EntTable.Decal
	gb5CommitShockwave() end

	do Shockwave = gb5BeginShockwave()
		Shockwave.Origin				= pos
		Shockwave.Class 				= "gb5_shockwave_sound_lowsh"
		Shockwave.PhysForce 			= EntTable.DEFAULT_PHYSFORCE
		Shockwave.PhysForceAir 			= EntTable.DEFAULT_PHYSFORCE_PLYAIR
		Shockwave.PhysForceGround 		= EntTable.DEFAULT_PHYSFORCE_PLYGROUND
		Shockwave.Attacker 				= EntTable.GBOWNER
		Shockwave.MaxRange 				= 50000

		local SoundSpeed = gb5_sound_speed:GetInt()

		if SoundSpeed == 0 then
			Shockwave.ShockwaveIncrement = 200
		elseif SoundSpeed == 1 then
			Shockwave.ShockwaveIncrement = 300
		elseif SoundSpeed == 2 then
			Shockwave.ShockwaveIncrement = 400
		elseif SoundSpeed == -1 then
			Shockwave.ShockwaveIncrement = 100
		elseif SoundSpeed == -2 then
			Shockwave.ShockwaveIncrement = 50
		else
			Shockwave.ShockwaveIncrement = 200
		end

		Shockwave.Delay 				= 0.01
		Shockwave.Sound					= EntTable.ExplosionSound
		Shockwave.Trace 				= EntTable.TraceLength
		Shockwave.Decal 				= EntTable.Decal
		Shockwave.Shocktime 			= EntTable.Shocktime
	gb5CommitShockwave() end

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
			ParticleEffect(self.EffectWater, tr2.HitPos, angle_zero, nil)
		end
	else
		local tracedata    = {}
		tracedata.start    = pos
		tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		tracedata.filter   = self

		local trace = util.TraceLine(tracedata)

		if trace.HitWorld then
			ParticleEffect(self.Effect,pos,angle_zero,nil)
		else
			ParticleEffect(self.EffectAir,pos,angle_zero,nil)
		end
	end

	if self.IsNBC then
		local nbc = ents.Create(self.NBCEntity)
		nbc:SetVar("GBOWNER",self.GBOWNER)
		nbc:SetPos(self:GetPos())
		nbc:Spawn()
		nbc:Activate()
	end

	for k, v in pairs(gb5FastSphereSearch(pos, self.ExplosionRadius)) do
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			v:TakeDamage(self.ExplosionDamage, self.GBOWNER, self)
		else
			v:TakeDamage(self.PropExplosionDamage or self.ExplosionDamage, self.GBOWNER, self)
		end
	end

	self:Remove()
end

local gb5_fragility = GetConVar("gb5_fragility")

function ENT:OnTakeDamage(dmginfo)
	local SelfTbl = self:GetTable()

	if SelfTbl.Exploded then return end
	self:TakePhysicsDamage(dmginfo)

	if SelfTbl.Life <= 0 then return end
	if gb5_fragility:GetInt() >= 1 and not SelfTbl.Armed and not SelfTbl.Arming then
		self:Arm()
	end

	if not SelfTbl.Armed then return end

	if IsValid(self) then
		SelfTbl.Life = SelfTbl.Life - dmginfo:GetDamage()
		if (SelfTbl.Life <= SelfTbl.Life / 2) and not SelfTbl.Exploded and SelfTbl.Flamable then
			self:Ignite(SelfTbl.MaxDelay,0)
		end
		if (self.Life <= 0) then
			timer.Simple(math.Rand(0,SelfTbl.MaxDelay),function()
				if not self:IsValid() then return end
				SelfTbl.Exploded = true
				self:Explode()
			end)
		end
	end
end

function ENT:PhysicsCollide(data, physobj)
	if not IsValid(self) then return end

	local SelfTbl = self:GetTable()
	if SelfTbl.Exploded then return end
	if SelfTbl.Life <= 0 then return end

	if gb5_fragility:GetInt() >= 1 and data.Speed > SelfTbl.ImpactSpeed and (not SelfTbl.Armed and not SelfTbl.Arming) then
		self:EmitSound(damagesound)
		self:Arm()
	end

	if not SelfTbl.Armed then return end

	if SelfTbl.ShouldExplodeOnImpact and data.Speed > SelfTbl.ImpactSpeed then
		self:EnqueueExplosion()
	end
end

-- This should run after physics, some bombs spawn physics-changing entities in callbacks which
-- likely will cause issues down the line (hence why I (March) put this here, instead of trying to change the cluster bomb itself)
function ENT:EnqueueExplosion()
	timer.Simple(0, function()
		if not IsValid(self) then return end
		if self.Exploded then return end -- double check

		self.Exploded = true
		self:Explode()
	end)
end

function ENT:Arm()
	if not IsValid(self) then return false, "Not valid" end

	local SelfTbl = self:GetTable()

	if SelfTbl.Exploded then return false, "Already exploded" end
	if SelfTbl.Armed then return false, "Already armed" end

	SelfTbl.Arming = true
	SelfTbl.Used = true

	timer.Simple(self.ArmDelay, function()
		if not IsValid(self) then return end
		SelfTbl = self:GetTable()

		SelfTbl.Armed = true
		SelfTbl.Arming = false
		self:EmitSound(SelfTbl.ArmSound)

		if SelfTbl.Timed then
			timer.Simple(SelfTbl.Timer, function()
				if not IsValid(self) then return end
				SelfTbl = self:GetTable()

				timer.Simple(math.Rand(0,SelfTbl.MaxDelay), function()
					if not IsValid(self) then return end
					SelfTbl = self:GetTable()

					SelfTbl.Exploded = true
					self:Explode()
				end)
			end)
		end
	end)

	return true
end

local gb5_easyuse = GetConVar("gb5_easyuse")

function ENT:Use(Activator, Caller)
	if not IsValid(self) then return end

	local SelfTbl = self:GetTable()
	if SelfTbl.Exploded then return end

	if gb5_easyuse:GetInt() == 0 then return end
	if SelfTbl.Armed then return end
	if SelfTbl.Used then return end

	if not Activator:IsPlayer() then return end

	self:EmitSound(self.ActivationSound)
	self:Arm()
end

function ENT:OnRemove()
	self:StopParticles()
	-- Wire_Remove(self)
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		if WireAddon ~= nil then Wire_Render(self) end
	end
end

function ENT:OnRestore()
	Wire_Restored(self)
end

function ENT:BuildDupeInfo()
	return WireLib.BuildDupeInfo(self)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(ply, ent, info, GetEntByID)
end

function ENT:PreEntityCopy()
	local DupeInfo = self:BuildDupeInfo()
	if DupeInfo then
		duplicator.StoreEntityModifier(self, "WireDupeInfo", DupeInfo)
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	if Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
