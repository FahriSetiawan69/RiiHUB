--==================================================
-- RiiHUB Loader (DELTA MOBILE FINAL)
--==================================================

if _G.RiiHUB_LOADED then
    warn("[RiiHUB] Loader already executed, aborting.")
    return
end
_G.RiiHUB_LOADED = true

print("[RiiHUB] Delta-safe loader started")

-- SERVICES
local Players = game:GetService("Players")
repeat task.wait() until Players.LocalPlayer

-- RAW URLS
local URLS = {
    ESP = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ESPModule.lua",
    AIM = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/AimAssistModule.lua",
    EVENT = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/EventModule.lua",
    KILLER = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/KillerModule.lua",
    STALK = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/StalkAssistModule.lua",
    HOME = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
}

-- SAFE LOAD
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

-- LOAD CORE MODULES
_G.ESPModule = safeLoad("ESPModule", URLS.ESP)
assert(_G.ESPModule, "ESPModule failed")

_G.AimAssistModule = safeLoad("AimAssistModule", URLS.AIM)
assert(_G.AimAssistModule, "AimAssistModule failed")

_G.EventModule = safeLoad("EventModule", URLS.EVENT)
assert(_G.EventModule, "EventModule failed")

-- LOAD EXTRA FEATURE MODULES (INI YANG KURANG SELAMA INI)
_G.KillerModule = safeLoad("KillerModule", URLS.KILLER)
_G.StalkAssistModule = safeLoad("StalkAssistModule", URLS.STALK)

-- WAIT ALL GLOBALS
repeat task.wait() until
    _G.ESPModule and
    _G.AimAssistModule and
    _G.EventModule

-- LOAD GUI TERAKHIR
print("[RiiHUB] Loading HomeGui...")
safeLoad("HomeGui", URLS.HOME)

print("[RiiHUB] Loader finished successfully")
