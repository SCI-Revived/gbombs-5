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