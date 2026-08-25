AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Antimatter Canister"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Nuclear"

ENT.Model                            =  "models/thedoctor/antimatter_canister.mdl"                      
ENT.Effect                           =  "photon_torpedo"                  
ENT.EffectAir                        =  "photon_torpedo"                   
ENT.EffectWater                      =  "water_huge"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  6500
ENT.ExplosionRadius                  =  9000
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  200
ENT.SpecialRadius                    =  2500
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  150
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
		 self:StopParticles()
		 ParticleEffectAttach("flash_antimatter_warning",PATTACH_POINT_FOLLOW,self,0 ) 
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
function ENT:Explode()
	if not self.Exploded then return end
	if self.Exploding then return end
	local pos = self:LocalToWorld(self:OBBCenter())
	self:SetMoveType( MOVETYPE_NONE )
	self:SetMaterial("phoenix_storms/glass")
	self:SetModel("models/hunter/plates/plate.mdl")
	ParticleEffect("antimatter_main_burst",pos,angle_zero,nil)	
	self.Exploding = true
	timer.Simple(0.2, function()
		if not self:IsValid() then return end
		for k, v in pairs(gb5FastSphereSearch(self:GetPos(), 5000)) do
			if v:GetClass()=="gb5_redmatter_pull" then
				v:SetMoveType( MOVETYPE_VPHYSICS )
				ParticleEffectAttach("redmatter_swirl_overdrive", PATTACH_POINT_FOLLOW, v, 0)
				ParticleEffect("fusionbomb_main",self:GetPos(),angle_zero,nil) 
				ParticleEffect("spacenuke_main",self:GetPos(),angle_zero,nil) 
				
				local Shockwave = gb5BeginShockwave() do
					Shockwave.Class              = "gb5_shockwave_sound_lowsh"
					Shockwave.Origin             = self:GetPos()
					Shockwave.Attacker           = self.GBOWNER
					Shockwave.MaxRange           = 500000
					Shockwave.ShockwaveIncrement = 20000
					Shockwave.Delay              = 0.01
					Shockwave.Shocktime          = 12
					Shockwave.Sound              = "gbombs_5/explosions/nuclear/tsar_detonate.mp3"
				gb5CommitShockwave() end
				
				local F_dir = (v:GetPos() - self:GetPos()):GetNormal() * 150
				phys:AddVelocity(F_dir)
			end
		end
		
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_sound_lowsh"
			Shockwave.Origin             = pos
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 500000
			Shockwave.ShockwaveIncrement = 20000
			Shockwave.Delay              = 0.01
			Shockwave.Shocktime          = 12
			Shockwave.Sound              = "gbombs_5/explosions/nuclear/antimatter.mp3"
		gb5CommitShockwave() end
		
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_ent_instant"
			Shockwave.Origin             = pos
			Shockwave.PhysForce          = 2550
			Shockwave.PhysForceAir       = 1250
			Shockwave.PhysForceGround    = 2555
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 11000
			Shockwave.Burst              = 2
			Shockwave.Delay              = 0.5
		gb5CommitShockwave() end
	end)
	timer.Simple(8, function()	
		if not self:IsValid() then return end
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_ent_instant"
			Shockwave.Origin             = pos
			Shockwave.PhysForce          = 2550
			Shockwave.PhysForceAir       = 1205
			Shockwave.PhysForceGround    = 2555
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 11000
			Shockwave.Burst              = 2
			Shockwave.Delay              = 0.5
		gb5CommitShockwave() end
	end)
	timer.Simple(20, function()	
		if not self:IsValid() then return end
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_ent"
			Shockwave.Origin             = pos
			Shockwave.PhysForce          = -255
			Shockwave.PhysForceAir       = -655
			Shockwave.PhysForceGround    = -2550
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 11000
			Shockwave.ShockwaveIncrement = 500
			Shockwave.Delay              = 0.1
		gb5CommitShockwave() end
	end)
	timer.Simple(23, function()	
		if not self:IsValid() then return end
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_ent"
			Shockwave.Origin             = pos
			Shockwave.PhysForce          = 255
			Shockwave.PhysForceAir       = 655
			Shockwave.PhysForceGround    = 2550
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 11000
			Shockwave.ShockwaveIncrement = 1000
			Shockwave.Delay              = 0.1
		gb5CommitShockwave() end
		self:Remove()
	end)
	
 
end


gb5RegisterSpawnFunction( ENT, {
	offset    = 26,
	postSpawn = function( stored, ent )
		ParticleEffectAttach( "anti_glow", PATTACH_POINT_FOLLOW, ent, 0 )
		ent:EmitSound( "gbombs_5/explosions/nuclear/antimatter_flicker.mp3", 50, 100 )
	end,
} )
