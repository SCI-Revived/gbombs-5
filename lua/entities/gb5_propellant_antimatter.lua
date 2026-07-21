AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_rocket_" )

local ExploSnds = {}
ExploSnds[1]                         =  "gbombs/srb/srb_explo.wav"


ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "[4] Anti-Matter Propellant"
ENT.Author			                 =  "Natsu (Code fixed by Scoopy)"
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Missiles"

ENT.Model                            =  "models/starchick971/nebelwerfer_rocket.mdl"
ENT.RocketTrail                      =  "anti_matter_trail"
ENT.RocketBurnoutTrail               =  "antimatter_burnout"
ENT.Effect                           =  "high_explosive_air"
ENT.EffectAir                        =  "high_explosive_air" 
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/missles/propellant_explosion.wav"   	-- ExplosionSound had a missing file? Swapped it out for a custom explosion sound. - Scoopy      
ENT.StartSound                       =  "weapons/rpg/rocketfire1.wav"         
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"    
ENT.EngineSound                      =  "Motor_Medium2"  

ENT.ShouldUnweld                     =  false         
ENT.ShouldIgnite                     =  false         
ENT.UseRandomSounds                  =  true                  
ENT.SmartLaunch                      =  false 
ENT.Timed                            =  false 

ENT.ExplosionDamage                  =  150
ENT.ExplosionRadius                  =  300             
ENT.PhysForce                        =  300             
ENT.SpecialRadius                    =  225           
ENT.MaxIgnitionTime                  =  0           
ENT.Life                             =  25            
ENT.MaxDelay                         =  0           
ENT.TraceLength                      =  100           
ENT.ImpactSpeed                      =  100         
ENT.Mass                             =  345             
ENT.EnginePower                      =  45           
ENT.FuelBurnoutTime                  =  30          
ENT.IgnitionDelay                    =  0.2            
ENT.ArmDelay                         =  1
ENT.RotationalForce                  =  500  
ENT.ForceOrientation                 =  "NORMAL"       
ENT.Timer                            =  0

-- The following 3 lines were missing (causing the original code to multiply by nil), or couldn't be found previously. Adding these 3 lines fixed the shockwave Lua error. - Scoopy
ENT.DEFAULT_PHYSFORCE = 1020
ENT.DEFAULT_PHYSFORCE_PLYAIR = 100
ENT.DEFAULT_PHYSFORCE_PLYGROUND = 10210

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.


function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)  
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType(MOVETYPE_VPHYSICS)
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
	 self.Armed    = false
	 self.Exploded = false
	 self.Fired    = false
	 self.Burnt    = false
	 self.Ignition = false
	 self.Arming   = false
	 self.Power    = 0.5
	 if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "Arm", "Detonate", "Launch" }) end
	end
end

function ENT:ExploSound(pos)
	 local EntTable = self:GetTable()
	local Shockwave = gb5BeginShockwave() do
		Shockwave.Class					= "gb5_shockwave_sound_lowsh"
		Shockwave.Origin				= pos
		Shockwave.Attacker 				= EntTable.GBOWNER
		Shockwave.MaxRange 				= 500000
		Shockwave.ShockwaveIncrement 	= 20000
		Shockwave.Delay 				= 0.01
		Shockwave.Sound 				= EntTable.ExplosionSound
		Shockwave.Shocktime 			= 4
	gb5CommitShockwave() end
end

function ENT:Think()
     if(self.Burnt) then return end
     if(not self.Ignition) then return end -- if there wasn't ignition, we won't fly
	 if(self.Exploded) then return end -- if we exploded then what the fuck are we doing here
	 if(not self:IsValid()) then return end -- if we aren't good then something fucked up

	 if self.Power <= 1.5 then
		self.Power = self.Power + 0.001
	 elseif self.Power >=1.5 then
		self.Power = 1.5
	 end
	 local phys = self:GetPhysicsObject()  
	 local thrustpos = self:GetPos()
	 if(self.ForceOrientation == "RIGHT") then
	     phys:AddVelocity(self:GetRight() * self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "LEFT") then
	     phys:AddVelocity(self:GetRight() * -self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "UP") then
	     phys:AddVelocity(self:GetUp() * self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "DOWN") then 
	     phys:AddVelocity(self:GetUp() * -self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "INV") then
	     phys:AddVelocity(self:GetForward() * -self.EnginePower) -- Continuous engine impulse
	 else
		 phys:AddVelocity(self:GetForward() * (self.EnginePower*self.Power)) -- Continuous engine impulse
	 end
	 if (self.Armed) then
        phys:AddAngleVelocity(Vector(self.RotationalForce,0,0)) -- Rotational force
	 end
	 
	 self:NextThink(CurTime() + 0.01)
	 return true
end

gb5RegisterSpawnFunction( ENT, 16 )
