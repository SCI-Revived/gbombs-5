AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Howitzer HE Shell"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/thedoctor/howitzer/howitzer_he.mdl"                      
ENT.Effect                           =  "500lb_ground"                  
ENT.EffectAir                        =  "500lb_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/mine_explosion.mp3"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"    

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  40
ENT.PhysForce                        =  200
ENT.ExplosionRadius                  =  700
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  37.5 -- 1500 Damage
ENT.SpecialRadius                    =  500
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  0                                
ENT.TraceLength                      =  300
ENT.ImpactSpeed                      =  300
ENT.Mass                             =  255
ENT.ArmDelay                         =  0.1
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.
ENT.Decal                            = "scorch_big"

ENT.DEFAULT_PHYSFORCE                = 75
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 500


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
	 
	 self:SetMoveType( MOVETYPE_NONE )
	 self:SetMaterial("phoenix_storms/glass")
	 self:SetModel("models/hunter/plates/plate.mdl")
	 
	 constraint.RemoveAll(self)
	 local physo = self:GetPhysicsObject()
	 physo:Wake()	
	 self.Exploding = true
	 if not self:IsValid() then return end 
	 self:StopParticles()
	 local pos = self:LocalToWorld(self:OBBCenter())
	 
	 gb5CommitBlastShockwave({
	 	Origin          = pos,
	 	PhysForce       = self.DEFAULT_PHYSFORCE,
	 	PhysForceAir    = self.DEFAULT_PHYSFORCE_PLYAIR,
	 	PhysForceGround = self.DEFAULT_PHYSFORCE_PLYGROUND,
	 	Attacker        = self.GBOWNER,
	 	MaxRange        = self.ExplosionRadius,
	 	Trace           = self.TraceLength,
	 	Decal           = self.Decal,
	 })

	 gb5CommitSoundShockwave({
	 	Origin    = pos,
	 	Attacker  = self.GBOWNER,
	 	Sound     = self.ExplosionSound,
	 	Shocktime = self.Shocktime,
	 })

	 gb5ApplyExplosionDamage(self, pos)

	 -- Set living things on fire in addition to the blast damage.
	 for k, v in pairs(gb5FastSphereSearch(pos, self.ExplosionRadius)) do
	 	if v:IsPlayer() or v:IsNPC() then
	 		v:Ignite(2, 0)
	 	end
	 end

	 gb5DoImpactParticles(self, pos)

	 timer.Simple(2, function()
	 	if not self:IsValid() then return end
	 	self:Remove()
	 end)
end

gb5RegisterSpawnFunction( ENT, 16 )
