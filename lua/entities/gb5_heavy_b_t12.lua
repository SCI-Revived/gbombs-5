AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "gbombs_5/explosions/heavy_bomb/t_12.mp3"
ExploSnds[2]                         =  "gbombs_5/explosions/heavy_bomb/explosion_big_6.mp3"
ExploSnds[3]                         =  "gbombs_5/explosions/heavy_bomb/explosion_big_7.mp3"


ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "T-12 Cloudmaker"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Heavy Bombs"

ENT.Model                            =  "models/thedoctor/t12.mdl"                      
ENT.Effect                           =  "cloudmaker_ground"                  
ENT.EffectAir                        =  "cloudmaker_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  ""
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  50
ENT.PhysForce                        =  600
ENT.ExplosionRadius                  =  1500
ENT.PlayerDamageScale                =  1
ENT.PropDamageScale                  =  400 -- 20,000 damage. Use for especially strong bases.
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  400
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  3000
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.Shocktime                        = 4
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.
ENT.Decals                           = "scorch_big_3"

gb5RegisterSpawnFunction( ENT, 16 )

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
		Shockwave.ShockwaveIncrement = 100
		Shockwave.Delay              = 0.01
		Shockwave.Trace              = self.TraceLength
		Shockwave.Decal              = self.Decal
	gb5CommitShockwave() end

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
		Shockwave.Sound              = table.Random(ExploSnds)
		Shockwave.Shocktime          = self.Shocktime
	gb5CommitShockwave() end
	
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