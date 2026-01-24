-- =====================================================
-- RiiHUB - ViolenceDistrict/main.lua
-- Entry point Violence District
-- ESP per kategori + Name & HP
-- =====================================================

print("[RiiHUB] ViolenceDistrict main.lua start")

-- Tunggu HomeGui UI API siap
repeat task.wait() until _G.RiiHUB_UI
local UI = _G.RiiHUB_UI

-- =====================================================
-- LOAD ESP MODULE (STABLE, TIDAK DIUBAH)
-- =====================================================
local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/"

local function loadModule(file)
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet(BASE .. file))()
    end)
    if not ok then
        warn("[RiiHUB] Gagal load module:", file)
        return nil
    end
    return mod
end

local ESP = loadModule("ESPModule.lua")
if not ESP then
    warn("[RiiHUB] ESPModule gagal dimuat")
    return
end

-- Global (opsional)
_G.RiiHUB = _G.RiiHUB or {}
_G.RiiHUB.Modules = _G.RiiHUB.Modules or {}
_G.RiiHUB.Modules.ESP = ESP

-- =====================================================
-- SIDEBAR
-- =====================================================
UI:AddTab("ESP")
UI:AddTab("Survivor")
UI:AddTab("Killer")
UI:AddTab("Other")
UI:AddTab("Visual")

-- =====================================================
-- ESP TAB (PER KATEGORI)
-- =====================================================

-- Player ESP (Survivor + Killer)
do
    local t = UI:AddToggle("ESP", "Player ESP")
    if t then
        t:Bind(function(state)
            ESP:SetPlayer(state)
        end)
    end
end

-- Name + HP ESP
do
    local t = UI:AddToggle("ESP", "Name + HP")
    if t then
        t:Bind(function(state)
            ESP:SetNameHP(state)
        end)
    end
end

-- Generator ESP
do
    local t = UI:AddToggle("ESP", "Generator ESP")
    if t then
        t:Bind(function(state)
            ESP:SetGenerator(state)
        end)
    end
end

-- Pallet ESP
do
    local t = UI:AddToggle("ESP", "Pallet ESP")
    if t then
        t:Bind(function(state)
            ESP:SetPallet(state)
        end)
    end
end

-- Gate ESP
do
    local t = UI:AddToggle("ESP", "Gate ESP")
    if t then
        t:Bind(function(state)
            ESP:SetGate(state)
        end)
    end
end

print("[RiiHUB] ViolenceDistrict ESP + NameHP siap (semua OFF)")
