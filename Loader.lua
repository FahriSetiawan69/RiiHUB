--==================================================
-- RiiHUB Loader.lua (FINAL FIX)
-- Compatible with Delta / Mobile
--==================================================

--========================
-- ANTI DOUBLE LOAD
--========================
if _G.RiiHUB_LOADED then
    warn("[RiiHUB] Loader already executed")
    return
end
_G.RiiHUB_LOADED = true

warn("[RiiHUB] Loader started")

--========================
-- BASE RAW GITHUB URL (CORRECT)
--========================
local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"

--========================
-- FILE URLS
--========================
local ESP_URL       = BASE .. "ESPModule.lua"
local AIM_URL       = BASE .. "AimAssistModule.lua"
local EVENT_URL     = BASE .. "EventModule.lua"
local HOMEGUI_URL   = BASE .. "HomeGui.lua"

--========================
-- SAFE LOAD FUNCTION
--========================
local function safeLoad(url, name)
    warn("[RiiHUB] Loading:", name)
    local src = game:HttpGet(url)
    if not src or #src < 20 then
        warn("[RiiHUB] FAILED to load:", name, "(empty response)")
        return false
    end

    local fn, err = loadstring(src)
    if not fn then
        warn("[RiiHUB] COMPILE ERROR:", name, err)
        return false
    end

    local ok, runtimeErr = pcall(fn)
    if not ok then
        warn("[RiiHUB] RUNTIME ERROR:", name, runtimeErr)
        return false
    end

    warn("[RiiHUB] Loaded:", name)
    return true
end

--========================
-- LOAD MODULES (ORDER IS IMPORTANT)
--========================
safeLoad(ESP_URL,     "ESPModule.lua")
safeLoad(AIM_URL,     "AimAssistModule.lua")
safeLoad(EVENT_URL,   "EventModule.lua")

--========================
-- LOAD GUI LAST
--========================
safeLoad(HOMEGUI_URL, "HomeGui.lua")

warn("[RiiHUB] Loader finished successfully")
