--========================================
-- RiiHUB Loader (FIXED LOAD ORDER)
--========================================

if _G.RiiHUB_LOADER_LOADED then
    warn("[RiiHUB] Loader already executed")
    return
end
_G.RiiHUB_LOADER_LOADED = true

print("[RiiHUB] Loader started")

local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/refs/heads/main/"

local function loadModule(name, url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok then
        warn("[RiiHUB] Failed to load "..name..": "..tostring(result))
        return
    end

    print("[RiiHUB] "..name.." loaded")
end

--==============================
-- LOAD MODULES (ORDER MATTERS)
--==============================

loadModule("ESPModule",        BASE.."ESPModule.lua")
loadModule("AimAssistModule",  BASE.."AimAssistModule.lua")
loadModule("EventModule",      BASE.."EventModule.lua")
loadModule("KillerModule",     BASE.."KillerModule.lua")
loadModule("StalkAssistModule",BASE.."StalkAssistModule.lua")

-- Pastikan module benar-benar masuk _G
task.wait(0.1)

--==============================
-- LOAD GUI TERAKHIR
--==============================
loadModule("HomeGui", BASE.."HomeGui.lua")

print("[RiiHUB] Loader finished")
