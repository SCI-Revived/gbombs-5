local ents_FindInSphere                = ents.FindInSphere

-- Thought findinbox would be cheaper; it is not
function gb5FastSphereSearch(Origin, Radius)
    return ents_FindInSphere(Origin, Radius)
end

function gb5RegisterSpawnFunction(ENT, opts)
    if isnumber(opts) then opts = { offset = opts } end
    opts = opts or {}

    local offset    = opts.offset or 16
    local angle     = opts.angle
    local postSpawn = opts.postSpawn

    function ENT:SpawnFunction(ply, tr, ClassName)
        if not tr.Hit then return end

        local ent = ents.Create(ClassName or self.ClassName)
        if not IsValid(ent) then return end

        ent:SetPos(tr.HitPos + tr.HitNormal * offset)
        if angle then ent:SetAngles(angle) end
        ent:SetPhysicsAttacker(ply)

        -- Set the owner on the ENTITY instance!!!
        ent.GBOWNER = ply

        ent:Spawn()
        ent:Activate()

        if postSpawn then postSpawn(self, ent, ply, tr) end

        return ent
    end
end

local ShockwaveBuilderTables = {}
local CurrentShockwavePtr     = 0
function gb5BeginShockwave()
    if CurrentShockwavePtr >= #ShockwaveBuilderTables then
        ShockwaveBuilderTables[CurrentShockwavePtr + 1] = {}
    end

    CurrentShockwavePtr = CurrentShockwavePtr + 1
    local CurrentShockwaveBuilder = ShockwaveBuilderTables[CurrentShockwavePtr]

    CurrentShockwaveBuilder.Class = "gb5_shockwave_ent"
    CurrentShockwaveBuilder.Model = nil
    CurrentShockwaveBuilder.Origin = nil
    CurrentShockwaveBuilder.PhysForce = nil
    CurrentShockwaveBuilder.PhysForceAir = nil
    CurrentShockwaveBuilder.PhysForceGround = nil
    CurrentShockwaveBuilder.Attacker = nil
    CurrentShockwaveBuilder.MaxRange = nil
    CurrentShockwaveBuilder.ShockwaveIncrement = nil
    CurrentShockwaveBuilder.Delay = nil
    CurrentShockwaveBuilder.Sound = nil
    CurrentShockwaveBuilder.Trace = nil
    CurrentShockwaveBuilder.Shocktime = nil
    CurrentShockwaveBuilder.Decal = nil
    CurrentShockwaveBuilder.Burst = nil
    CurrentShockwaveBuilder.MaxBursts = nil
    CurrentShockwaveBuilder.PropForce = nil
    CurrentShockwaveBuilder.PlyForce = nil
    CurrentShockwaveBuilder.PlyAirForce = nil
    CurrentShockwaveBuilder.Ignore = nil
    CurrentShockwaveBuilder.Ignoreowner = nil

    return CurrentShockwaveBuilder
end

function gb5CommitShockwave()
    local CurrentShockwaveBuilder = ShockwaveBuilderTables[CurrentShockwavePtr]
    CurrentShockwavePtr = CurrentShockwavePtr - 1

    local Shockwave = ents.Create(CurrentShockwaveBuilder.Class)
    Shockwave:SetPos(CurrentShockwaveBuilder.Origin)
    if CurrentShockwaveBuilder.Model then Shockwave:SetModel(CurrentShockwaveBuilder.Model) end
    Shockwave:Spawn()
    Shockwave:Activate()

    local EntTable = Shockwave:GetTable()
    EntTable.DEFAULT_PHYSFORCE              = CurrentShockwaveBuilder.PhysForce        or EntTable.DEFAULT_PHYSFORCE
    EntTable.DEFAULT_PHYSFORCE_PLYAIR       = CurrentShockwaveBuilder.PhysForceAir     or CurrentShockwaveBuilder.PhysForce or EntTable.DEFAULT_PHYSFORCE_PLYAIR
    EntTable.DEFAULT_PHYSFORCE_PLYGROUND    = CurrentShockwaveBuilder.PhysForceGround  or CurrentShockwaveBuilder.PhysForce or EntTable.DEFAULT_PHYSFORCE_PLYGROUND
    EntTable.GBOWNER                        = CurrentShockwaveBuilder.Attacker           or EntTable.GBOWNER
    EntTable.MAX_RANGE                      = CurrentShockwaveBuilder.MaxRange           or EntTable.MAX_RANGE
    EntTable.SHOCKWAVE_INCREMENT            = CurrentShockwaveBuilder.ShockwaveIncrement or EntTable.SHOCKWAVE_INCREMENT
    EntTable.DELAY                          = CurrentShockwaveBuilder.Delay              or EntTable.DELAY
    EntTable.SOUND                          = CurrentShockwaveBuilder.Sound              or EntTable.SOUND
    EntTable.trace                          = CurrentShockwaveBuilder.Trace              or EntTable.trace
    EntTable.Shocktime                      = CurrentShockwaveBuilder.Shocktime          or EntTable.Shocktime
    EntTable.decal                          = CurrentShockwaveBuilder.Decal              or EntTable.decal
    EntTable.Burst                          = CurrentShockwaveBuilder.Burst              or EntTable.Burst
    EntTable.MAX_BURSTS                     = CurrentShockwaveBuilder.MaxBursts          or EntTable.MAX_BURSTS
    EntTable.PropForce                      = CurrentShockwaveBuilder.PropForce          or EntTable.PropForce
    EntTable.PlyForce                       = CurrentShockwaveBuilder.PlyForce           or EntTable.PlyForce
    EntTable.PlyAirForce                    = CurrentShockwaveBuilder.PlyAirForce        or EntTable.PlyAirForce
    EntTable.Ignore                         = CurrentShockwaveBuilder.Ignore             or EntTable.Ignore
    EntTable.Ignoreowner                    = CurrentShockwaveBuilder.Ignoreowner        or EntTable.Ignoreowner
end

hook.Add("EntityTakeDamage", "GBombs_BlockPhysicsDamageFromExplodingBombs", function(Target, DamageInfo)
    local Inflictor = DamageInfo:GetInflictor()
    if IsValid(Inflictor) and Inflictor.GBOMBS_EXPLODING_SOON then
        return true
    end
end)

-- Ignite()'s fFireSize/fFireDuration only affect the flame's visuals and how
-- long it burns for - the per-tick damage the engine's entityflame deals is
-- fixed regardless of those args. Scale it down here instead.
local GBOMBS_BURN_DAMAGE_SCALE = 0.1
hook.Add("EntityTakeDamage", "GBombs_ScaleBurnDamage", function(Target, DamageInfo)
    if Target:IsPlayer() and DamageInfo:IsDamageType(DMG_BURN) then
        DamageInfo:ScaleDamage(GBOMBS_BURN_DAMAGE_SCALE)
    end
end)

-- Maps the gb5_sound_speed convar to a shockwave increment. Was duplicated as a
-- 6-branch if/else in every bomb that spawned a sound shockwave.
function gb5SoundShockwaveIncrement()
    local speed = GetConVar("gb5_sound_speed"):GetInt()
    if speed == 1 then
        return 300
    elseif speed == 2 then
        return 400
    elseif speed == -1 then
        return 100
    elseif speed == -2 then
        return 50
    else
        -- covers 0 and any unexpected value
        return 200
    end
end

-- Spawns the expanding physics/decal shockwave (the thing that pushes the world
-- and scorches the ground). opts fields mirror the gb5BeginShockwave builder.
function gb5CommitBlastShockwave(opts)
    local Shockwave = gb5BeginShockwave()
        Shockwave.Class              = opts.Class or "gb5_shockwave_ent"
        Shockwave.Origin             = opts.Origin
        Shockwave.PhysForce          = opts.PhysForce
        Shockwave.PhysForceAir       = opts.PhysForceAir
        Shockwave.PhysForceGround    = opts.PhysForceGround
        Shockwave.Attacker           = opts.Attacker
        Shockwave.MaxRange           = opts.MaxRange
        Shockwave.ShockwaveIncrement = opts.ShockwaveIncrement or 100
        Shockwave.Delay              = opts.Delay or 0.01
        Shockwave.Trace              = opts.Trace
        Shockwave.Decal              = opts.Decal
        Shockwave.Sound              = opts.Sound
    gb5CommitShockwave()
end

-- Spawns the delayed explosion sound shockwave. Handles the sound-speed switch
-- so callers don't have to repeat it.
function gb5CommitSoundShockwave(opts)
    local Shockwave = gb5BeginShockwave()
        Shockwave.Class              = opts.Class or "gb5_shockwave_sound_lowsh"
        Shockwave.Origin             = opts.Origin
        Shockwave.Attacker           = opts.Attacker
        Shockwave.MaxRange           = opts.MaxRange or 50000
        Shockwave.ShockwaveIncrement = opts.ShockwaveIncrement or gb5SoundShockwaveIncrement()
        Shockwave.Delay              = opts.Delay or 0.01
        Shockwave.Sound              = opts.Sound
        Shockwave.Shocktime          = opts.Shocktime
    gb5CommitShockwave()
end

-- Explosion damage with distance falloff and partial obstruction.
--
-- Distance:
--   Damage falls off quadratically as the target gets farther from the
--   explosion. A target at the edge of the radius receives 0 damage.
--
-- Obstruction:
--   Props/entities between the explosion and the target reduce the damage
--   rather than completely blocking it. Each obstruction multiplies the
--   remaining damage by 0.65, with a minimum obstruction multiplier of 0.10.
--
-- Examples:
--   0 obstructions -> 100% damage
--   1 obstruction  -> 65% damage
--   2 obstructions -> 42.25% damage
--   3 obstructions -> 27.46% damage
--   4 obstructions -> 17.85% damage
--   5+             -> 10% damage minimum
--
-- Players and non-player entities continue to use their separate damage
-- scales as before.
function gb5ApplyExplosionDamage(self, pos, radius)
    radius = radius or self.ExplosionRadius

    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end

    local playerScale = GetConVar("gb5_player_damage_scale"):GetFloat() * self.PlayerDamageScale
    local propScale   = GetConVar("gb5_prop_damage_scale"):GetFloat()   * self.PropDamageScale

    for _, v in pairs(gb5FastSphereSearch(pos, radius)) do
        if not IsValid(v) then continue end

        -- Calculate distance from the explosion.
        local targetPos = v:WorldSpaceCenter()
        local distance = pos:Distance(targetPos)

        if distance >= radius then
            continue
        end

        -- Quadratic distance falloff.
        -- 0 distance = 100% damage
        -- 50% radius = 75% damage
        -- 75% radius = 43.75% damage
        -- 100% radius = 0% damage
        local distanceFraction = distance / radius
        local distanceScale = 1 - (distanceFraction * distanceFraction)

        -- Count physical obstructions between the explosion and the target.
        --
        -- The target itself and the exploding entity are ignored. Each
        -- intervening entity reduces the remaining blast damage by 35%.
        local obstructionScale = 1
        local traceStart = pos
        local traceEnd = targetPos

        local traceFilter = { self, v }

        while obstructionScale > 0.10 do
            local tr = util.TraceLine({
                start  = traceStart,
                endpos = traceEnd,
                filter = traceFilter,
                mask   = MASK_SOLID
            })

            if not tr.Hit then
                break
            end

            -- The world completely blocks further propagation along this
            -- particular path. We still leave a small amount of blast damage
            -- rather than making LOS binary.
            if tr.HitWorld then
                obstructionScale = math.max(obstructionScale * 0.35, 0.10)
                break
            end

            if not IsValid(tr.Entity) then
                break
            end

            -- An entity is obstructing the blast.
            obstructionScale = math.max(obstructionScale * 0.65, 0.10)

            -- Continue tracing beyond this obstruction so layered props
            -- progressively reduce the remaining blast energy.
            table.insert(traceFilter, tr.Entity)

            local direction = (traceEnd - traceStart):GetNormalized()

            -- Move slightly beyond the entity that was hit to avoid hitting
            -- the exact same surface again.
            traceStart = tr.HitPos + direction * 1
        end

        local damageScale = distanceScale * obstructionScale
        local damage = self.ExplosionDamage * damageScale

        if v:IsPlayer() then
            v:TakeDamage(damage * playerScale, self.GBOWNER, self)
        else
            v:TakeDamage(damage * propScale, self.GBOWNER, self)
        end
    end
end

-- Emits the correct particle effect for where the bomb detonated (underwater,
-- on the ground, or in the air). Uses self.Effect / self.EffectAir /
-- self.EffectWater and self.TraceLength. Returns "water", "ground" or "air" so
-- callers that need branch-specific follow-up (EMP, delayed removal) can react.
function gb5DoImpactParticles(self, pos)
    if self:WaterLevel() >= 1 then
        local trlength = Vector(0, 0, 9000)

        local tr = util.TraceLine({
            start = pos,
            endpos = pos + trlength,
            filter = self,
        })

        local tr2 = util.TraceLine({
            start = tr.HitPos,
            endpos = pos - trlength,
            filter = self,
            mask   = MASK_WATER + CONTENTS_TRANSLUCENT,
        })

        if tr2.Hit then
            ParticleEffect(self.EffectWater, tr2.HitPos, angle_zero, nil)
        end

        return "water"
    end

    local trace = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, self.TraceLength),
        filter = self,
    })

    if trace.HitWorld then
        ParticleEffect(self.Effect, pos, angle_zero, nil)
        return "ground", trace
    else
        ParticleEffect(self.EffectAir, pos, angle_zero, nil)
        return "air", trace
    end
end

-- Spawns the bomb's NBC (nuclear/bio/chem) lingering entity, if it has one.
function gb5SpawnNBC(self)
    if not self.IsNBC then return end

    local nbc = ents.Create(self.NBCEntity)
    nbc:SetVar("GBOWNER", self.GBOWNER)
    nbc:SetPos(self:GetPos())
    nbc:Spawn()
    nbc:Activate()
    return nbc
end
