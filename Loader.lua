--==================================================
-- RiiHUB Loader (FINAL - SAFE RE-EXECUTE)
--==================================================

print("[RiiHUB] Loader executing")

local function safeLoad(name, url)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("[RiiHUB] Failed loading "..name..": "..tostring(res))
        return nil
    end
    print("[RiiHUB] "..name.." loaded")
    return res
end

-- OPTIONAL: disable old modules if exist
pcall(function()
    if _G.ESPModule and _G.ESPModule.Disable then _G.ESPModule:Disable() end
    if _G.AimAssistModule and _G.AimAssistModule.Disable then _G.AimAssistModule:Disable() end
end)

-- LOAD MODULES
_G.ESPModule        = safeLoad("ESPModule",        "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ESPModule.lua")
_G.AimAssistModule  = safeLoad("AimAssistModule",  "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/AimAssistModule.lua")
_G.EventModule      = safeLoad("EventModule",      "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/EventModule.lua")
_G.KillerModule     = safeLoad("KillerModule",     "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/KillerModule.lua")
_G.StalkAssistModule= safeLoad("StalkAssistModule","https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/StalkAssistModule.lua")

-- LOAD GUI TERAKHIR
safeLoad("HomeGui", "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua")

print("[RiiHUB] Loader finished")
