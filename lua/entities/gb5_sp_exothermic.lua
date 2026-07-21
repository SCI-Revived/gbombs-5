AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Exothermic Bomb"
ENT.Author			                 =  "Natsu (Fixed by Scoopy)"
ENT.Contact		                     =  ""
ENT.Category                         =  "GB5: Specials"

ENT.Model                            =  "models/thedoctor/ex.mdl"                      
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
	 self.Unison    = false
	  if not (WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

function ENT:Explode()
    if not self.Exploded then return end
	if self.Exploding then return end
	
	for k, v in pairs(gb5FastSphereSearch(self:GetPos(), 200)) do
		if v:GetClass()=="gb5_sp_endothermic" then
			
			ParticleEffect("unison_beam",self:GetPos(),Angle(0,0,0),nil)	
			
			local Shockwave = gb5BeginShockwave() do
				Shockwave.Class              = "gb5_shockwave_sound_lowsh"
				Shockwave.Origin             = self:GetPos()
				Shockwave.Attacker           = self.GBOWNER
				Shockwave.MaxRange           = 500000
				Shockwave.ShockwaveIncrement = 20000
				Shockwave.Delay              = 0.01
				Shockwave.Shocktime          = 12
				Shockwave.Sound              = "gbombs_5/explosions/special/unison_exend.mp3"
			gb5CommitShockwave() end
			
			local pos = self:GetPos()
			local gbowner = self.GBOWNER
			self.Unison = true
			self:Remove()
			v:Remove()
			
			timer.Simple(10, function() 
				
				local Shockwave = gb5BeginShockwave() do
					Shockwave.Class              = "gb5_shockwave_fire"
					Shockwave.Origin             = pos
					Shockwave.PhysForce          = 25
					Shockwave.PhysForceAir       = 25
					Shockwave.PhysForceGround    = 25
					Shockwave.Attacker           = self.GBOWNER
					Shockwave.MaxRange           = 650
					Shockwave.ShockwaveIncrement = 100
					Shockwave.Delay              = 0.1
				gb5CommitShockwave() end
			
			
				local Shockwave = gb5BeginShockwave() do
					Shockwave.Class              = "gb5_shockwave_cold"
					Shockwave.Origin             = pos
					Shockwave.PhysForce          = 25
					Shockwave.PhysForceAir       = 25
					Shockwave.PhysForceGround    = 25
					Shockwave.Attacker           = self.GBOWNER
					Shockwave.MaxRange           = 650
					Shockwave.ShockwaveIncrement = 100
					Shockwave.Delay              = 0.1
				gb5CommitShockwave() end
				
				local Shockwave = gb5BeginShockwave() do
					Shockwave.Class              = "gb5_shockwave_ent"
					Shockwave.Origin             = pos
					Shockwave.PhysForce          = 50
					Shockwave.PhysForceAir       = 50
					Shockwave.PhysForceGround    = 50
					Shockwave.Attacker           = gbowner
					Shockwave.MaxRange           = 19000
					Shockwave.ShockwaveIncrement = 40
					Shockwave.Delay              = 0.01
				gb5CommitShockwave() end
				
			end)
			
		end
	end
	if self.Unison==false then
		local pos = self:LocalToWorld(self:OBBCenter())
		self:SetModel("models/gibs/scanner_gib02.mdl")
		self.Exploding = true
		constraint.RemoveAll(self)
		local physo = self:GetPhysicsObject()
		physo:Wake()
		physo:EnableMotion(false)
		local Shockwave = gb5BeginShockwave() do
			Shockwave.Class              = "gb5_shockwave_sound_lowsh"
			Shockwave.Origin             = pos
			Shockwave.Attacker           = self.GBOWNER
			Shockwave.MaxRange           = 500000
			Shockwave.ShockwaveIncrement = 20000
			Shockwave.Delay              = 0.01
			Shockwave.Sound              = "gbombs_5/explosions/special/exothermic_bomb.mp3"
			Shockwave.Shocktime          = 12
		gb5CommitShockwave() end
		--ent:SetPhysicsAttacker(ply)

		timer.Simple(5.6, function()
			 local Shockwave = gb5BeginShockwave() do
			 	Shockwave.Class              = "gb5_shockwave_fire"
			 	Shockwave.Origin             = pos
			 	Shockwave.PhysForce          = 25
			 	Shockwave.PhysForceAir       = 25
			 	Shockwave.PhysForceGround    = 25
			 	Shockwave.Attacker           = self.GBOWNER
			 	Shockwave.MaxRange           = 3500
			 	Shockwave.ShockwaveIncrement = 100
			 	Shockwave.Delay              = 0.1
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
				ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)
			end
		else
			local tracedata    = {}
			tracedata.start    = pos
			tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
			tracedata.filter   = self.Entity

			local trace = util.TraceLine(tracedata)

			if trace.HitWorld then
				ParticleEffect("beam_exothermic",pos,Angle(0,0,0),nil)	
				timer.Simple(0.1, function()
					if not self:IsValid() then return end 
						ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
				end)	
			else 
				ParticleEffect("beam_exothermic",pos,Angle(0,0,0),nil) 

			end
		end
	end
end

function ENT:SpawnFunction( ply, tr )
     if ( not tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end