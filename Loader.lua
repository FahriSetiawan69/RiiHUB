--==================================================
-- RiiHUB Loader.lua (SAFE)
--==================================================

if _G.RiiHUB_LOADED then
    warn("[RiiHUB] already loaded, skipping")
    return
end
_G.RiiHUB_LOADED = true

local function load(url)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("Failed to load:", url)
        warn(err)
    end
end

-- LOAD MODULES FIRST
load("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ESPModule.lua")
load("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/AimAssistModule.lua")
load("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/EventModule.lua")
load("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/KillerModule.lua")
load("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/StalkAssistModule.lua")

-- LOAD GUI LAST
load("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua")

warn("[RiiHUB] Loader finished")
