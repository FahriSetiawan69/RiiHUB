--==================================================
-- RiiHUB Loader
-- One-Execute Loader (Delta Mobile Safe)
--==================================================

-- Anti double execute
if _G.RiiHUB_LOADED then
    warn("RiiHUB already loaded")
    return
end
_G.RiiHUB_LOADED = true

-- HomeGui
local homeGuiUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/refs/heads/main/HomeGui.lua"
local espModuleUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/refs/heads/main/ESPModule.lua"

local success, err = pcall(function()
    loadstring(game:HttpGet(homeGuiUrl))()
end)

if not success then
    warn("Failed to load HomeGui.lua:", err)
    return
end

task.wait(0.3)

success, err = pcall(function()
    loadstring(game:HttpGet(espModuleUrl))()
end)

if not success then
    warn("Failed to load ESPModule.lua:", err)
    return
end

warn("RiiHUB loaded successfully")
