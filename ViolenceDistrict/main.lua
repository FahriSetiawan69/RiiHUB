-- =====================================================
-- RiiHUB | Violence District - main.lua
-- Bertugas: Mengikat ESPModule ke HomeGui (UI)
-- =====================================================

print("[RiiHUB] ViolenceDistrict main.lua loaded")

-- Ambil UI API dari HomeGui
local UI = _G.RiiHUB_UI
if not UI then
    warn("[RiiHUB] UI API belum tersedia")
    return
end

-- Helper load module
local BASE_URL = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/"

local function LoadModule(file)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. file))()
    end)
    if not ok then
        warn("[RiiHUB] Gagal load module:", file)
        return nil
    end
    return result
end

-- Load ESPModule (TANPA MODIFIKASI LOGIC)
local ESP = LoadModule("ESPModule.lua")
if not ESP then
    warn("[RiiHUB] ESPModule gagal dimuat")
    return
end

-- Simpan ke global (opsional / debug)
_G.RiiHUB = _G.RiiHUB or {}
_G.RiiHUB.Modules = _G.RiiHUB.Modules or {}
_G.RiiHUB.Modules.ESP = ESP

-- =====================================================
-- Sidebar Tabs
-- =====================================================
UI:AddTab("ESP")
UI:AddTab("Survivor")
UI:AddTab("Killer")
UI:AddTab("Other")
UI:AddTab("Visual")

-- =====================================================
-- ESP : Survivor
-- =====================================================
do
    local t = UI:AddToggle("Survivor", "Survivor ESP")
    if t then
        t:Bind(function(state)
            ESP:SetSurvivor(state)
        end)
    end
end

-- =====================================================
-- ESP : Killer
-- =====================================================
do
    local t = UI:AddToggle("Killer", "Killer ESP")
    if t then
        t:Bind(function(state)
            ESP:SetKiller(state)
        end)
    end
end

-- =====================================================
-- ESP : Generator
-- =====================================================
do
    local t = UI:AddToggle("ESP", "Generator ESP")
    if t then
        t:Bind(function(state)
            ESP:SetGenerator(state)
        end)
    end
end

-- =====================================================
-- ESP : Pallet
-- =====================================================
do
    local t = UI:AddToggle("ESP", "Pallet ESP")
    if t then
        t:Bind(function(state)
            ESP:SetPallet(state)
        end)
    end
end

-- =====================================================
-- ESP : Gate
-- =====================================================
do
    local t = UI:AddToggle("ESP", "Gate ESP")
    if t then
        t:Bind(function(state)
            ESP:SetGate(state)
        end)
    end
end

-- =====================================================
-- ESP : Name + HP
-- =====================================================
do
    local t = UI:AddToggle("Visual", "Name + HP")
    if t then
        t:Bind(function(state)
            ESP:SetNameHP(state)
        end)
    end
end

print("[RiiHUB] ESP berhasil di-bind ke HomeGui (semua OFF)")