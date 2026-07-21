AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_rocket_" )

sound.Add( {
	name = "photon_engine",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	pitch = {100, 100},
	sound = "gbombs_5/arm/photon_torpedo_engine.wav"
} )

photon_launch={}
photon_launch[1]="gbombs_5/arm/photon_torpedo.wav"
photon_launch[2]="gbombs_5/arm/photon_torpedo_2.mp3"

Photon_Explo={}
Photon_Explo[1]="gbombs_5/explosions/special/photon_torpedo.mp3"
Photon_Explo[2]="gbombs_5/explosions/special/photon_torpedo_2.mp3"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Photon Torpedo"
ENT.Author			                 =  ""
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Specials"

ENT.Model                            =  "models/thedoctor/photon.mdl"
ENT.RocketTrail                      =  ""
ENT.RocketBurnoutTrail               =  ""
ENT.Effect                           =  "photon_torpedo"
ENT.EffectAir                        =  "photon_torpedo" 
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "ambient/explosions/explode_1.wav"        
ENT.StartSound                       =  "gbombs_5/explosions/projectile/tankshell_01.wav"         
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  ""    
ENT.EngineSound                      =  "photon_engine"  

ENT.ShouldUnweld                     =  true          
ENT.ShouldIgnite                     =  false         
ENT.UseRandomSounds                  =  true                  
ENT.SmartLaunch                      =  true  
ENT.Timed                            =  false 

ENT.ExplosionDamage                  =  150
ENT.ExplosionRadius                  =  11000             
ENT.PhysForce                        =  300             
ENT.SpecialRadius                    =  225           
ENT.MaxIgnitionTime                  =  0           
ENT.Life                             =  25            
ENT.MaxDelay                         =  0           
ENT.TraceLength                      =  50          
ENT.ImpactSpeed                      =  100         
ENT.Mass                             =  500             
ENT.EnginePower                      =  9999          
ENT.FuelBurnoutTime                  =  25         
ENT.IgnitionDelay                    =  0          
ENT.ArmDelay                         =  0
ENT.RotationalForce                  =  0
ENT.ForceOrientation                 =  "NORMAL"       
ENT.Timer                            =  0


ENT.DEFAULT_PHYSFORCE                = 155
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000     
ENT.Shocktime                        = 2

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

gb5RegisterSpawnFunction( ENT, 16 )

function ENT:Launch()
     if(self.Exploded) then return end
	 if(self.Burned) then return end
	 --if(self.Armed) then return end
	 if(self.Fired) then return end
	 
	 local phys = self:GetPhysicsObject()
	 if not phys:IsValid() then return end
	 
	 self.Fired = true
	 if(self.SmartLaunch) then
		 constraint.RemoveAll(self)
	 end
	 timer.Simple(0.05,function()
	     if not self:IsValid() then return end
	     if(phys:IsValid()) then
             phys:Wake()
		     phys:EnableMotion(true)
	     end
	 end)
	 timer.Simple(self.IgnitionDelay,function()
	     if not self:IsValid() then return end  -- Make a short ignition delaynot 
		 local phys = self:GetPhysicsObject()
		 self.Ignition = true
		 self:Arm()
		 ParticleEffectAttach("photon_torpedo_launch_full",PATTACH_POINT_FOLLOW,self,0 )
	     self:SetModel("models/XQM/Rails/trackball_1.mdl")		 
		 self:SetMaterial("phoenix_storms/glass")
		 local pos = self:GetPos()
		 sound.Play(table.Random(photon_launch), pos, 130, 100,1)
	     self:EmitSound(self.EngineSound)
		 self:SetNetworkedBool("EmitLight",true)
		 self:SetNetworkedBool("self.Ignition",true)
		 ParticleEffectAttach(self.RocketTrail,PATTACH_ABSORIGIN_FOLLOW,self,1)
		 if(self.FuelBurnoutTime ~= 0) then 
	         timer.Simple(self.FuelBurnoutTime,function()
		         if not self:IsValid() then return end 
		         self.Burnt = true
		         self:StopParticles()
		         self:StopSound(self.EngineSound)
	             ParticleEffectAttach(self.RocketBurnoutTrail,PATTACH_ABSORIGIN_FOLLOW,self,1)
             end)	 
		 end
     end)		 
end

function ENT:Explode()
     if not self.Exploded then return end
	 local pos = self:LocalToWorld(self:OBBCenter())
	 
	 local Shockwave = gb5BeginShockwave() do
	 	Shockwave.Class              = "gb5_shockwave_ent"
	 	Shockwave.Origin             = pos
	 	Shockwave.PhysForce          = self.DEFAULT_PHYSFORCE
	 	Shockwave.PhysForceAir       = self.DEFAULT_PHYSFORCE_PLYAIR
	 	Shockwave.PhysForceGround    = self.DEFAULT_PHYSFORCE_PLYGROUND
	 	Shockwave.Attacker           = self.GBOWNER
	 	Shockwave.MaxRange           = self.ExplosionRadius
	 	Shockwave.ShockwaveIncrement = 400
	 	Shockwave.Delay              = 0.01
	 	Shockwave.Trace              = self.TraceLength
	 	Shockwave.Decal              = self.Decal
	 gb5CommitShockwave() end
	 timer.Simple(0.2, function() 
		 local Shockwave = gb5BeginShockwave() do
		 	Shockwave.Class              = "gb5_shockwave_sound_lowsh"
		 	Shockwave.Origin             = pos
		 	Shockwave.Attacker           = self.GBOWNER
		 	Shockwave.MaxRange           = 500000
		 	Shockwave.ShockwaveIncrement = 20000
		 	Shockwave.Delay              = 0.01
		 	Shockwave.Sound              = table.Random(Photon_Explo)
		 	Shockwave.Shocktime          = self.Shocktime
		 gb5CommitShockwave() end
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
		     ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)
		 else 
			 ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
		 end
     end
	 if self.IsNBC then
	     local nbc = ents.Create(self.NBCEntity)
		 nbc:SetVar("GBOWNER",self.GBOWNER)
		 nbc:SetPos(self:GetPos())
		 nbc:Spawn()
		 nbc:Activate()
	 end
	 timer.Simple(0.2, function() 
	 if not self:IsValid() then return end
		self:Remove()
	 end)
end
