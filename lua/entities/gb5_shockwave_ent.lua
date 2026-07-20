AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  ""
ENT.Author			                 =  ""
ENT.Contact			                 =  ""

ENT.GBOWNER                          =  nil
ENT.MAX_RANGE                        = 0
ENT.SHOCKWAVE_INCREMENT              = 0
ENT.DELAY                            = 0
ENT.SOUND                            = ""

local gb5_decals 				= GetConVar("gb5_decals")
local gb5_shockwave_unfreeze 	= GetConVar("gb5_shockwave_unfreeze")

if SERVER then
	function ENT:Initialize()
		self.FILTER = {}
		self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(ONOFF_USE)
		self.Bursts = 0
		self.CURRENTRANGE = 0
		self.GBOWNER = self:GetVar("GBOWNER")
		self.SOUND = self:GetVar("SOUND")

		self.DEFAULT_PHYSFORCE  = self:GetVar("DEFAULT_PHYSFORCE")
		self.DEFAULT_PHYSFORCE_PLYAIR  = self:GetVar("DEFAULT_PHYSFORCE_PLYAIR")
		self.DEFAULT_PHYSFORCE_PLYGROUND = self:GetVar("DEFAULT_PHYSFORCE_PLYGROUND")

		-- For some reason Ivy Mike and Cluster Nuke don't obey so I'm adding an if statement to check if one specific bomb has DEFAULT_PHYSFORCE values or not. If it does not (Ivy Mike and Cluster for example), it will use these default values.
		-- This failsafe should still work and not return the shockwave nil Lua-error if the code ever breaks in the future. - Scoopy

		if self.DEFAULT_PHYSFORCE == nil then
			self.DEFAULT_PHYSFORCE  = 1020
			self.DEFAULT_PHYSFORCE_PLYAIR  = 100
			self.DEFAULT_PHYSFORCE_PLYGROUND = 10220
		else
			self.DEFAULT_PHYSFORCE  = self:GetVar("DEFAULT_PHYSFORCE")
			self.DEFAULT_PHYSFORCE_PLYAIR  = self:GetVar("DEFAULT_PHYSFORCE_PLYAIR")
			self.DEFAULT_PHYSFORCE_PLYGROUND = self:GetVar("DEFAULT_PHYSFORCE_PLYGROUND")
		end

		self.SHOCKWAVEDAMAGE = self:GetVar("SHOCKWAVE_DAMAGE")
		self.allowtrace = true
	end
end

function ENT:Trace()
	if SERVER then
		if not self:IsValid() then return end
		if gb5_decals:GetInt() >= 1 then
			local pos = self:GetPos()
			util.Decal(self.decal, pos, pos - Vector(0, 0, self.trace))
		end
	end
end

local Breakables = {
	["func_breakable"] 		= true,
	["func_breakable_surf"] = true,
	["func_physbox"] 		= true
}

local function DoPhysicsEffects(v, phys, EntTable, pos)
	if phys:IsValid() then
		local FoundEntityClass = v:GetClass()

		-- local mass = phys:GetMass()
		local F_ang = EntTable.DEFAULT_PHYSFORCE
		local dist = (pos - v:GetPos()):Length()

		local relation = math.Clamp((EntTable.CURRENTRANGE - dist) / EntTable.CURRENTRANGE, 0, 1)
		local F_dir = (v:GetPos() - pos):GetNormal() * EntTable.DEFAULT_PHYSFORCE
		phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
		phys:AddVelocity(F_dir)
		if gb5_shockwave_unfreeze:GetInt() >= 1 and not v.isWacAircraft then
			phys:Wake()
			phys:EnableMotion(true)
			constraint.RemoveAll(v)
		end

		if Breakables[FoundEntityClass] then
			v:Fire("Break", 0)
		end
	end
end

function ENT:Think()
	if SERVER then
		if not IsValid(self) then return end

		local pos = self:GetPos()
		local EntTable = self:GetTable()

		EntTable.CURRENTRANGE = EntTable.CURRENTRANGE + (EntTable.SHOCKWAVE_INCREMENT * 10)
		if EntTable.allowtrace then
			self:Trace()
			EntTable.allowtrace = false
		end

		for k, v in pairs(ents.FindInSphere(pos,EntTable.CURRENTRANGE)) do
			if (v:IsValid() or v:IsPlayer()) and not v.forcefielded then
				local i = 0
				while i < v:GetPhysicsObjectCount() do
					local dmg = DamageInfo()
					dmg:SetDamage(math.random(1,20))
					dmg:SetDamageType(DMG_BLAST)
					if EntTable.GBOWNER == nil then
						EntTable.GBOWNER = table.Random(player.GetAll())
					end
					if not IsValid(EntTable.GBOWNER) then
						EntTable.GBOWNER = table.Random(player.GetAll())
					end
					dmg:SetAttacker(EntTable.GBOWNER)
					phys = v:GetPhysicsObjectNum(i)
					DoPhysicsEffects(v, phys, EntTable, pos)

					if (v:IsPlayer()) then
						v:SetMoveType( MOVETYPE_WALK )
						v:TakeDamageInfo(dmg)
						--local mass = phys:GetMass()
						--local F_ang = EntTable.DEFAULT_PHYSFORCE_PLYAIR
						--local dist = (pos - v:GetPos()):Length()
						--local relation = math.Clamp((EntTable.CURRENTRANGE - dist) / EntTable.CURRENTRANGE, 0, 1)
						local F_dir = (v:GetPos() - pos):GetNormal() * EntTable.DEFAULT_PHYSFORCE_PLYAIR
						v:SetVelocity( F_dir )
					end

					if (v:IsPlayer()) and v:IsOnGround() then
						v:SetMoveType( MOVETYPE_WALK )
						v:TakeDamageInfo(dmg)
						--local mass = phys:GetMass()
						--local F_ang = EntTable.DEFAULT_PHYSFORCE_PLYGROUND
						--local dist = (pos - v:GetPos()):Length()
						--local relation = math.Clamp((EntTable.CURRENTRANGE - dist) / EntTable.CURRENTRANGE, 0, 1)
						local F_dir = (v:GetPos() - pos):GetNormal() * EntTable.DEFAULT_PHYSFORCE_PLYGROUND
						v:SetVelocity( F_dir )
					end

					if (v:IsNPC()) then
						v:TakeDamageInfo(dmg)
					end
				i = i + 1
				end
			end
		end

		EntTable.Bursts = EntTable.Bursts + 1
		if (EntTable.CURRENTRANGE >= EntTable.MAX_RANGE) then
			self:Remove()
		end

		self:NextThink(CurTime() + (EntTable.DELAY * 10))
		return true
	end
end

function ENT:Draw()
	return false
end