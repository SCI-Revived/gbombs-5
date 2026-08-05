AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Space nuke"
ENT.Author			                 =  "Natsu (Fixed by Scoopy)"
ENT.Contact		                     =  ""
ENT.Category                         =  "GB5: Specials"

ENT.Model                            =  "models/failure/spacenuke/spacenuke.mdl"                      
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs/fab/fab_explo.wav"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.ExplosionRadius                  =  2000
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  1
ENT.SpecialRadius                    =  3000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  3000
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  500
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end 
	 if(self.Dumb) then
	     self.Armed    = true
	 else
	     self.Armed    = false
	 end
	 self.Exploded = false
	 self.Used     = false
	 self.Arming = false
	 self.Exploding = false
	  if not (WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end
function ENT:Explode()
    if not self.Exploded then return end
	if self.Exploding then return end
	
	local pos = self:LocalToWorld(self:OBBCenter())
	self:SetModel("models/gibs/scanner_gib02.mdl")
	self.Exploding = true
	constraint.RemoveAll(self)
	local physo = self:GetPhysicsObject()
	physo:Wake()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetMaterial("phoenix_storms/glass")
	self:SetModel("models/hunter/plates/plate.mdl")
	timer.Simple(0.5, function()
		if not self:IsValid() then return end
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
			Shockwave.Shocktime          = 12
			Shockwave.Sound              = "ambient/explosions/explode_9.wav"
		gb5CommitShockwave() end
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_ent"
			Shockwave.Origin             = pos
			Shockwave.PhysForce          = 155
			Shockwave.PhysForceAir       = 1555
			Shockwave.PhysForceGround    = 155
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 5000
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
		gb5CommitShockwave() end
		self:Remove()
	end)
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
			ParticleEffect("spacenuke_main",pos,self:GetAngles(),nil)	
			timer.Simple(0.1, function()
				if not self:IsValid() then return end 
					ParticleEffect("",trace.HitPos,angle_zero,nil)	
			end)	
		else 
			ParticleEffect("spacenuke_main",pos,angle_zero,nil) 

		end
	end
end

gb5RegisterSpawnFunction( ENT, 16 )
