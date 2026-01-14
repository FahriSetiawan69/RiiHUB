--==================================================
-- RiiHUB Loader (FIXED)
-- One Execute Loader | Delta Mobile Safe
--==================================================

-- Prevent double load
if _G.RiiHUB_LOADED then
    warn("RiiHUB already loaded")
    return
end
_G.RiiHUB_LOADED = true

-- Base URL
local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/refs/heads/main/"

local HomeGuiURL       = BASE .. "HomeGui.lua"
local ESPURL           = BASE .. "ESPModule.lua"
local AimAssistURL     = BASE .. "AimAssistModule.lua"
local EventModuleURL   = BASE .. "EventModule.lua"

-- Load Home GUI
do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(HomeGuiURL))()
    end)
    if not ok then
        warn("Failed to load HomeGui.lua:", err)
        return
    end
end
task.wait(0.25)

-- Load ESP Module
do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(ESPURL))()
    end)
    if not ok then
        warn("Failed to load ESPModule.lua:", err)
        return
    end
end
task.wait(0.25)

-- Load Aim Assist Module
do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(AimAssistURL))()
    end)
    if not ok then
        warn("Failed to load AimAssistModule.lua:", err)
        return
    end
end
task.wait(0.25)

-- Load Event Module
do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(EventModuleURL))()
    end)
    if not ok then
        warn("Failed to load EventModule.lua:", err)
        return
    end
end

warn("RiiHUB loaded successfully")
