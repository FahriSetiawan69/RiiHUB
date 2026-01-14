--==================================================
-- RiiHUB Loader (FINAL)
-- One Execute Loader | Delta Mobile Safe
--==================================================

-- Anti double execute
if _G.RiiHUB_LOADED then
    warn("RiiHUB already loaded")
    return
end
_G.RiiHUB_LOADED = true

-- URLs
local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/refs/heads/main/"

local HomeGuiURL = BASE .. "HomeGui.lua"
local ESPURL = BASE .. "ESPModule.lua"
local AimAssistURL = BASE .. "AimAssistModule.lua"
local EventURL = Base .. "EventModule.lua"

-- Load Home GUI
local ok, err = pcall(function()
    loadstring(game:HttpGet(HomeGuiURL))()
end)
if not ok then
    warn("Failed to load HomeGui.lua:", err)
    return
end

task.wait(0.25)

-- Load ESP Module
ok, err = pcall(function()
    loadstring(game:HttpGet(ESPURL))()
end)
if not ok then
    warn("Failed to load ESPModule.lua:", err)
    return
end

task.wait(0.25)

-- Load Repair Fail Guard
ok, err = pcall(function()
    loadstring(game:HttpGet(RepairURL))()
end)
if not ok then
    warn("Failed to load AimAssistModule.lua:", err)
    return
end

task.wait(0.25)

-- Load Event Module
ok, err = pcall(function()
    loadstring(game:HttpGet(RepairURL))()
end)
if not ok then
    warn("Failed to load EventModule.lua:", err)
    return
end

warn("RiiHUB loaded successfully")


