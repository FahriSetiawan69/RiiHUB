-- ==========================================
-- RiiHUB | ViolenceDistrict/main.lua
-- Daftar fitur SAJA (tidak render UI)
-- ==========================================

print("[RiiHUB] Load ViolenceDistrict main.lua")

-- Init registry
_G.RiiHUB = _G.RiiHUB or {}
_G.RiiHUB.Game = {
    Name = "Violence District",
    Tabs = {
        ESP = {},
        Survivor = {},
        Killer = {},
        Other = {},
        Visual = {}
    }
}

local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/"

local function loadModule(file)
    return loadstring(game:HttpGet(BASE .. file))()
end

local ESP = loadModule("ESPModule.lua")

-- Simpan modul (opsional)
_G.RiiHUB.Modules = {
    ESP = ESP
}

-- ======================
-- DAFTARKAN FITUR ESP
-- ======================
table.insert(_G.RiiHUB.Game.Tabs.ESP, {
    Name = "Survivor ESP",
    Callback = function(state)
        ESP:SetSurvivor(state)
    end
})

table.insert(_G.RiiHUB.Game.Tabs.ESP, {
    Name = "Killer ESP",
    Callback = function(state)
        ESP:SetKiller(state)
    end
})

table.insert(_G.RiiHUB.Game.Tabs.ESP, {
    Name = "Generator ESP",
    Callback = function(state)
        ESP:SetGenerator(state)
    end
})

table.insert(_G.RiiHUB.Game.Tabs.ESP, {
    Name = "Pallet ESP",
    Callback = function(state)
        ESP:SetPallet(state)
    end
})

table.insert(_G.RiiHUB.Game.Tabs.ESP, {
    Name = "Gate ESP",
    Callback = function(state)
        ESP:SetGate(state)
    end
})

table.insert(_G.RiiHUB.Game.Tabs.ESP, {
    Name = "Name + HP",
    Callback = function(state)
        ESP:SetNameHP(state)
    end
})

print("[RiiHUB] ViolenceDistrict features registered")