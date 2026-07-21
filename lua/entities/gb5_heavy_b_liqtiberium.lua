AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Liquid Tiberium Bomb"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Heavy Bombs"

ENT.Model                            =  "models/thedoctor/tiberium.mdl"                      
ENT.Effect                           =  "tiberium_main"                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/heavy_bomb/ex2.mp3"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  99
ENT.PhysForce                        =  2600
ENT.ExplosionRadius                  =  6000
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  1000
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.Shocktime                        = 4
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.


gb5RegisterSpawnFunction( ENT, 16 )

function ENT:SpawnCrystals()

	for i=0,3 do
		local offset = Vector(math.random(-1000,1000),math.random(-1000,1000),0)
		local tr = util.TraceLine( {
			start = self:GetPos()+Vector(0,0,1000)+offset, 
			endpos = self:GetPos()-Vector(0,0,1500)+offset
		} )
		timer.Simple(math.random(2,4), function()
			
			local ent = ents.Create("gb5_tiberium_crystal" )
			ent:SetPos( tr.HitPos )  
			ent:Spawn()
			ent:Activate()		
		end)
	
	end

end

function ENT:Explode()
    if not self.Exploded then return end
	local pos = self:LocalToWorld(self:OBBCenter())
	self:SetMoveType( MOVETYPE_NONE )
	self:SetMaterial("phoenix_storms/glass")
	self:SetModel("models/hunter/plates/plate.mdl")
	self:SpawnCrystals()

	
	
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
			 
			 local Shockwave = gb5BeginShockwave() do
			 	Shockwave.Class              = "gb5_shockwave_sound_lowsh"
			 	Shockwave.Origin             = pos
			 	Shockwave.Attacker           = self.GBOWNER
			 	Shockwave.MaxRange           = 500000
			 	Shockwave.ShockwaveIncrement = 20000
			 	Shockwave.Delay              = 0.01
			 	Shockwave.Sound              = "gbombs_5/explosions/special/liquid_tiberium.mp3"
			 	Shockwave.Shocktime          = 1
			 gb5CommitShockwave() end
			 
			 timer.Simple(1, function()
				 if not self:IsValid() then return end
				 local Shockwave = gb5BeginShockwave() do
				 	Shockwave.Class              = "gb5_shockwave_ent"
				 	Shockwave.Origin             = pos
				 	Shockwave.PhysForce          = self.DEFAULT_PHYSFORCE
				 	Shockwave.PhysForceAir       = self.DEFAULT_PHYSFORCE_PLYAIR
				 	Shockwave.PhysForceGround    = self.DEFAULT_PHYSFORCE_PLYGROUND
				 	Shockwave.Attacker           = self.GBOWNER
				 	Shockwave.MaxRange           = self.ExplosionRadius
				 	Shockwave.ShockwaveIncrement = 500
				 	Shockwave.Delay              = 0.01
				 	Shockwave.Decal              = "tiberium"
				 gb5CommitShockwave() end
			 end)
			
			 
		 end
     end
	 if self.IsNBC then
	     local nbc = ents.Create(self.NBCEntity)
		 nbc:SetVar("GBOWNER",self.GBOWNER)
		 nbc:SetPos(self:GetPos())
		 nbc:Spawn()
		 nbc:Activate()
	 end
	 timer.Simple(1, function()
		if not self:IsValid() then return end
		self:Remove()
	 end)
end