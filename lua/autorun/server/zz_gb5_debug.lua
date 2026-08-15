-- TEMPORARY DEBUG TOOL - put in lua/autorun/server/, reproduce the death, then check console/log
-- Remove this file once you're done diagnosing.

hook.Add("EntityTakeDamage", "GB5_Debug_LogPlayerDamage", function(target, dmginfo)
    if IsValid(target) and target:IsPlayer() then
        print(string.format(
            "[GB5 DEBUG] %s took %.1f dmg | HP before: %d | Inflictor: %s | Attacker: %s | DamageType: %d",
            target:Nick(),
            dmginfo:GetDamage(),
            target:Health(),
            IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() or "none",
            IsValid(dmginfo:GetAttacker()) and tostring(dmginfo:GetAttacker()) or "none",
            dmginfo:GetDamageType()
        ))
    end
end)

hook.Add("PlayerDeath", "GB5_Debug_LogPlayerDeath", function(victim, inflictor, attacker)
    print(string.format(
        "[GB5 DEBUG] DEATH: %s | Inflictor class: %s | Attacker: %s",
        IsValid(victim) and victim:Nick() or "?",
        IsValid(inflictor) and inflictor:GetClass() or "none",
        IsValid(attacker) and tostring(attacker) or "none"
    ))
end)
