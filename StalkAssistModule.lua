-- StalkAssistModule.lua (DUMMY SAFE - DELTA MOBILE)

local StalkAssistModule = {}

-- STATE
StalkAssistModule.Enabled = false

function StalkAssistModule:Enable()
    StalkAssistModule.Enabled = true
end

function StalkAssistModule:Disable()
    StalkAssistModule.Enabled = false
end

function StalkAssistModule:IsActive()
    return StalkAssistModule.Enabled
end

-- ⚠️ PAKSA GLOBAL SEGERA
_G.StalkAssistModule = StalkAssistModule
return StalkAssistModule
