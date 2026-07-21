AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      
         
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
		 self.spawns = 0
		 self.extra=26

     end
end
function ENT:SpawnMulti()
	local x = 1
	for i=0, (26-1) do
		x = x + 1
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_roar"
			Shockwave.Model              = "models/hunter/blocks/cube025x025x025.mdl"
			Shockwave.Origin             = self:GetPos() + (90*x) * self:GetForward()
			Shockwave.PhysForce          = 155
			Shockwave.PhysForceAir       = 155
			Shockwave.PhysForceGround    = 55
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 400
			Shockwave.ShockwaveIncrement = 100
			Shockwave.Delay              = 0.01
			Shockwave.Ignore             = self.GBOWNER
			Shockwave.Ignoreowner        = true
		gb5CommitShockwave() end
	end
end
function ENT:Think()
	if (SERVER) then
	if not self:IsValid() then return end
	self.spawns = self.spawns+1
	local Shockwave = gb5BeginShockwave() do
		Shockwave.Class              = "gb5_shockwave_roar"
		Shockwave.Model              = "models/hunter/blocks/cube025x025x025.mdl"
		Shockwave.Origin             = self:GetPos() + (90*self.spawns) * self:GetForward()
		Shockwave.PhysForce          = 155
		Shockwave.PhysForceAir       = 155
		Shockwave.PhysForceGround    = 55
		Shockwave.Attacker           = self.GBOWNER
		Shockwave.MaxRange           = 400
		Shockwave.ShockwaveIncrement = 100
		Shockwave.Delay              = 0.01
		Shockwave.Ignore             = self.GBOWNER
		Shockwave.Ignoreowner        = true
	gb5CommitShockwave() end
	local pl = self.GBOWNER
	local traceRes=pl:GetEyeTrace()
	self:SetPos( pl:GetPos() ) 
	self:SetAngles(pl:EyeAngles())
	if traceRes.HitWorld and self.spawns > 26 then
		if traceRes.HitPos:Distance(self:GetPos()) <= 2586 then
			ParticleEffect("shadowdragon_roar_tracer_hit",traceRes.HitPos,Angle(0,0,0),nil)
		end
	end
	if self.spawns > 26 then 
		self:SpawnMulti()
		if self.extra>100 then
			self:Remove()
		end
		self.extra=self.extra+1
	end
	self:NextThink(CurTime() + 0.05)
	return true
	end
end

function ENT:Draw()
     return false
end