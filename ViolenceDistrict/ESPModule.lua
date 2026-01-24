-- ViolenceDistrict/main.lua
-- ESP binding sesuai dengan API yang ada di ESPModule.lua

print("[RiiHUB] ViolenceDistrict main.lua loaded")

-- UI API
local UI = _G.RiiHUB_UI
if not UI then
    warn("[RiiHUB] UI API belum tersedia")
    return
end

-- Load ESPModule
local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/"
local function loadModule(file)
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet(BASE .. file))()
    end)
    if not ok then
        warn("[RiiHUB] Gagal load:", file)
        return nil
    end
    return mod
end

local ESP = loadModule("ESPModule.lua")

-- Simpan ke global (opsional untuk debug atau akses modul lain)
_G.RiiHUB = _G.RiiHUB or {}
_G.RiiHUB.Modules = _G.RiiHUB.Modules or {}
_G.RiiHUB.Modules.ESP = ESP

-- Buat tab-tab
UI:AddTab("ESP")
UI:AddTab("Survivor")
UI:AddTab("Killer")
UI:AddTab("Other")
UI:AddTab("Visual")

-- ========================
-- ESP Controls
-- ========================
if ESP then
    -- Player ESP (Survivor + Killer)
    local tPlayer = UI:AddToggle("ESP", "Player ESP")
    if tPlayer then
        tPlayer:Bind(function(on)
            ESP:SetPlayer(on)
        end)
    end

    -- Generator ESP
    local tGen = UI:AddToggle("ESP", "Generator ESP")
    if tGen then
        tGen:Bind(function(on)
            ESP:SetGenerator(on)
        end)
    end

    -- Pallet ESP
    local tPal = UI:AddToggle("ESP", "Pallet ESP")
    if tPal then
        tPal:Bind(function(on)
            ESP:SetPallet(on)
        end)
    end

    -- Gate ESP
    local tGate = UI:AddToggle("ESP", "Gate ESP")
    if tGate then
        tGate:Bind(function(on)
            ESP:SetGate(on)
        end)
    end
end

print("[RiiHUB] ViolenceDistrict ESP UI siap (semua OFF)")
