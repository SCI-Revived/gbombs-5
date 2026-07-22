AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

local gb5_easyuse 				= GetConVar("gb5_easyuse")
local gb5_deleteconstraints 	= GetConVar("gb5_deleteconstraints")
local gb5_explosion_damage 		= GetConVar("gb5_explosion_damage")
local gb5_fragility 			= GetConVar("gb5_fragility")

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
ENT.GASENTITY                        =  ""
ENT.PARALIZentITY                    =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  false
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false
ENT.IsParalize                       =  false
ENT.IsNBC                            =  false
ENT.IsGas                            =  false

ENT.ExplosionDamage                  =  10000
ENT.PhysForce                        =  0
ENT.ExplosionRadius                  =  1000
ENT.SpecialRadius                    =  0
ENT.MaxIgnitionTime                  =  5
ENT.Life                             =  20
ENT.MaxDelay                         =  2
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  500
ENT.Mass                             =  0
ENT.ArmDelay                         =  2
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil

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

		if skincount > 0 then
			self:SetSkin(math.random(0,skincount))
		end

		self.Armed    = false
		self.Exploded = false
		self.Used     = false
		self.Arming   = false

		if WireAddon ~= nil then self.Inputs = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
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

function ENT:Explode()
	if not self.Exploded then return end
	local pos = self:LocalToWorld(self:OBBCenter())
	for k, v in pairs(gb5FastSphereSearch(pos,self.SpecialRadius)) do
		if v:IsValid() then
			local i = 0
			while i < v:GetPhysicsObjectCount() do
			local phys = v:GetPhysicsObjectNum(i)
			if (phys:IsValid()) then
				-- local mass = phys:GetMass()
				local F_ang = self.PhysForce
				local dist = (pos - v:GetPos()):Length()
				local relation = math.Clamp((self.SpecialRadius - dist) / self.SpecialRadius, 0, 1)
				local F_dir = (v:GetPos() - pos):GetNormal() * self.PhysForce	 
				if(GetConVar("gb5_unfreeze"):GetInt() >= 1) then
					phys:Wake()
					phys:EnableMotion(true)
				end
				phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
					phys:AddVelocity(F_dir)
			end
			i = i + 1
			end
		end
	end

	local deleteConstraints = gb5_deleteconstraints:GetInt() >= 1
	local explosionDamage = gb5_explosion_damage:GetInt() >= 1

	for k, v in pairs(gb5FastSphereSearch(pos,self.SpecialRadius / 2)) do
		if deleteConstraints and self.ShouldUnweld and IsValid(v) and IsValid(v:GetPhysicsObject()) then
			constraint.RemoveAll(v)
		end

		if self.ShouldIgnite then
			if v:IsOnFire() then
				v:Extinguish()
			end
			v:Ignite(math.Rand(self.MaxIgnitionTime-2,self.MaxIgnitionTime),5)
		end
	end

	if explosionDamage and IsValid(self.GBOWNER) then
		util.BlastDamage(self, self.GBOWNER, pos, self.ExplosionRadius, self.ExplosionDamage)
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
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	if self.Exploded then return end
	self:TakePhysicsDamage(dmginfo)
	local phys = self:GetPhysicsObject()
	
	if (self.Life <= 0) then return end
	if gb5_fragility:GetInt() >= 1 then
		if(not self.Armed and not self.Arming) then
			self:Arm()
		end
	end
	
	if(not self.Armed) then return end

	if self:IsValid() then
		self.Life = self.Life - dmginfo:GetDamage()
		if (self.Life <= self.Life/2) and not self.Exploded and self.Flamable then
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
	self.GBOMBS_EXPLODING_SOON = true
	timer.Simple(0, function()
		if not IsValid(self) then return end
		if self.Exploded then return end -- double check

		self.GBOMBS_EXPLODING_SOON = false
		self.Exploded = true
		self:Explode()
	end)
end

function ENT:Arm()
	if(not self:IsValid()) then return end
	if(self.Exploded) then return end
	if(self.Armed) then return end
	self.Arming = true
	self.Used = true
	timer.Simple(self.ArmDelay, function()
		if not self:IsValid() then return end 
		self.Armed = true
		self.Arming = false
		self:EmitSound(self.ArmSound)
		if(self.Timed) then
			timer.Simple(self.Timer, function()
				if not self:IsValid() then return end 
				timer.Simple(math.Rand(0,self.MaxDelay),function()
					if not self:IsValid() then return end 
					self.Exploded = true
					self:Explode()
				end)
			end)
		end
	end)
end

function ENT:Use(Activator, Caller)
	if not IsValid(self) then return end
	local SelfTbl = self:GetTable()

	if gb5_easyuse:GetInt() < 1 then return end
	if SelfTbl.Armed or SelfTbl.Exploded or SelfTbl.Used then return end
	if not IsValid(Activator) or not Activator:IsPlayer() then return end

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
	WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )
end

function ENT:PreEntityCopy()
	local DupeInfo = self:BuildDupeInfo()
	if DupeInfo then
		duplicator.StoreEntityModifier(self, "WireDupeInfo", DupeInfo)
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
