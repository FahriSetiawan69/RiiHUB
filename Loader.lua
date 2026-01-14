--==================================================
-- RiiHUB Loader (Delta Mobile Safe)
--==================================================

if _G.RiiHUB_LOADED then
    warn("[RiiHUB] Loader already executed, aborting.")
    return
end
_G.RiiHUB_LOADED = true

print("[RiiHUB] Delta-safe loader started")

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer

--==================================================
-- RAW URLS (SESUIKAN JIKA PINDAH FILE)
--==================================================
local URLS = {
    ESP = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ESPModule.lua",
    AIM = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/AimAssistModule.lua",
    EVENT = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/EventModule.lua",
    HOME = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
}

--==================================================
-- SAFE LOAD FUNCTION
--==================================================
local function safeLoad(name, url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not success then
        warn("[RiiHUB] Failed loading "..name..": "..tostring(result))
        return nil
    end

    print("[RiiHUB] "..name.." loaded")
    return result
end

--==================================================
-- LOAD MODULES (ORDER IS CRITICAL)
--==================================================

-- ESP
_G.ESPModule = safeLoad("ESPModule", URLS.ESP)
assert(_G.ESPModule, "ESPModule failed to load")

-- Aim Assist
_G.AimAssistModule = safeLoad("AimAssistModule", URLS.AIM)
assert(_G.AimAssistModule, "AimAssistModule failed to load")

-- Event
_G.EventModule = safeLoad("EventModule", URLS.EVENT)
assert(_G.EventModule, "EventModule failed to load")

--==================================================
-- WAIT GUARANTEE (ANTI DELTA RACE CONDITION)
--==================================================
local timeout = os.clock() + 10
repeat task.wait()
until (_G.ESPModule and _G.AimAssistModule and _G.EventModule)
   or os.clock() > timeout

if not (_G.ESPModule and _G.AimAssistModule and _G.EventModule) then
    warn("[RiiHUB] Dependency timeout, aborting HomeGui")
    return
end

--==================================================
-- LOAD HOME GUI (LAST)
--==================================================
safeLoad("HomeGui", URLS.HOME)

print("[RiiHUB] Loader finished successfully")
