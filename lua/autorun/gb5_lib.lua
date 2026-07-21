local ENTITY                        = FindMetaTable("Entity")
local ENTITY_GetPos                 = ENTITY.GetPos

local VECTOR                        = FindMetaTable("Vector")
local VECTOR_SetUnpacked            = VECTOR.SetUnpacked
local VECTOR_Unpack                 = VECTOR.Unpack
local VECTOR_Add                    = VECTOR.Add
local VECTOR_Sub                    = VECTOR.Sub
local VECTOR_Distance               = VECTOR.Distance

local ents_FindInBox                = ents.FindInBox

local VEC_MIN, VEC_MAX, VEC_RADIUS  = Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0)

-- Does sphere searching using spatial partition (box), then performing spherical distance checks.
-- This is faster than FindInSphere since that function iterates over every entity.
-- It follows the same pattern as ents.FindInSphere, and can be used as (effectively) a drop in
-- replacement (for all intents and purposes of this addon).
function gb5FastSphereSearch(Origin, Radius)
    VECTOR_SetUnpacked(VEC_MIN, VECTOR_Unpack(Origin))
    VECTOR_SetUnpacked(VEC_MAX, VECTOR_Unpack(Origin))
    VECTOR_SetUnpacked(VEC_RADIUS, Radius, Radius, Radius)

    VECTOR_Sub(VEC_MIN, VEC_RADIUS)
    VECTOR_Add(VEC_MAX, VEC_RADIUS)

    local Ents = ents_FindInBox(VEC_MIN, VEC_MAX)
    local Result, N = {}, 0
    for I = 1, #Ents do
        local Ent = Ents[I]
        if VECTOR_Distance(ENTITY_GetPos(Ent), Origin) <= Radius then
            N = N + 1
            Result[N] = Ent
        end
    end
    return Result
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
    CurrentShockwaveBuilder.PhysForce = nil
    CurrentShockwaveBuilder.PhysForceAir = nil
    CurrentShockwaveBuilder.PhysForceGround = nil
    CurrentShockwaveBuilder.PhysForce = nil
    CurrentShockwaveBuilder.Attacker = nil
    CurrentShockwaveBuilder.MaxRange = nil
    CurrentShockwaveBuilder.ShockwaveIncrement = nil
    CurrentShockwaveBuilder.Delay = nil
    CurrentShockwaveBuilder.Sound = nil
    CurrentShockwaveBuilder.Trace = nil
    CurrentShockwaveBuilder.Shocktime = nil
    CurrentShockwaveBuilder.Decal = nil

    return CurrentShockwaveBuilder
end

function gb5CommitShockwave()
    local CurrentShockwaveBuilder = ShockwaveBuilderTables[CurrentShockwavePtr]
    CurrentShockwavePtr = CurrentShockwavePtr - 1

    local Shockwave = ents.Create(CurrentShockwaveBuilder.Class)
    Shockwave:SetPos(CurrentShockwaveBuilder.Origin)
    Shockwave:Spawn()
    Shockwave:Activate()

    local EntTable = Shockwave:GetTable()
    EntTable.DEFAULT_PHYSFORCE              = EntTable.DEFAULT_PHYSFORCE or CurrentShockwaveBuilder.PhysForce
    EntTable.DEFAULT_PHYSFORCE_PLYAIR       = EntTable.DEFAULT_PHYSFORCE_PLYAIR or CurrentShockwaveBuilder.PhysForceAir or CurrentShockwaveBuilder.PhysForce
    EntTable.DEFAULT_PHYSFORCE_PLYGROUND    = EntTable.DEFAULT_PHYSFORCE_PLYGROUND or CurrentShockwaveBuilder.PhysForceGround or CurrentShockwaveBuilder.PhysForce
    EntTable.DEFAULT_PHYSFORCE              = EntTable.DEFAULT_PHYSFORCE or CurrentShockwaveBuilder.PhysForce
    EntTable.GBOWNER                        = EntTable.GBOWNER or CurrentShockwaveBuilder.Attacker
    EntTable.MAX_RANGE                      = EntTable.MAX_RANGE or CurrentShockwaveBuilder.MaxRange
    EntTable.SHOCKWAVE_INCREMENT            = EntTable.SHOCKWAVE_INCREMENT or CurrentShockwaveBuilder.ShockwaveIncrement
    EntTable.DELAY                          = EntTable.DELAY or CurrentShockwaveBuilder.Delay
    EntTable.SOUND                          = EntTable.SOUND or CurrentShockwaveBuilder.Sound
    EntTable.trace                          = EntTable.trace or CurrentShockwaveBuilder.Trace
    EntTable.Shocktime                      = EntTable.Shocktime or CurrentShockwaveBuilder.Shocktime
    EntTable.decal                          = EntTable.decal or CurrentShockwaveBuilder.Decal
end