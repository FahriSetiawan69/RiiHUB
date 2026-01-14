-- KillerModule.lua (DUMMY SAFE - DELTA MOBILE)

local KillerModule = {}

-- STATE
KillerModule.Enabled = false

function KillerModule:Enable()
    KillerModule.Enabled = true
end

function KillerModule:Disable()
    KillerModule.Enabled = false
end

function KillerModule:IsActive()
    return KillerModule.Enabled
end

-- ⚠️ PAKSA GLOBAL SEGERA
_G.KillerModule = KillerModule
return KillerModule
