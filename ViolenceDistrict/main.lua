-- ViolenceDistrict/main.lua
-- RiiHUB Game Entry Point
-- Fokus: Register Menu + Connect Module (NO LOGIC CHANGE)

-- =====================================================
-- SERVICES
-- =====================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- REQUIRE MODULES (LOCAL GAME FOLDER)
-- =====================================================
local ESPModule = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
))()

-- =====================================================
-- SAFETY CHECK
-- =====================================================
if not _G.RiiHUB_RegisterMenu then
    warn("[RiiHUB] HomeGui not ready. Menu registration failed.")
    return
end

-- =====================================================
-- INTERNAL STATE (DEFAULT OFF)
-- =====================================================
local State = {
    SurvivorESP = false,
    KillerESP = false,
    GeneratorESP = false,
    PalletESP = false,
    GateESP = false,
    NameHP = false,
}

-- =====================================================
-- HELPER : APPLY ESP STATE
-- =====================================================
local function RefreshESP()
    ESPModule:SetSurvivorESP(State.SurvivorESP)
    ESPModule:SetKillerESP(State.KillerESP)
    ESPModule:SetGeneratorESP(State.GeneratorESP)
    ESPModule:SetPalletESP(State.PalletESP)
    ESPModule:SetGateESP(State.GateESP)
    ESPModule:SetNameHP(State.NameHP)
end

-- =====================================================
-- REGISTER MENU TO HOMEGUI
-- =====================================================
_G.RiiHUB_RegisterMenu({

    Sidebar = {
        "ESP",
        "Survivor",
        "Killer",
        "Other",
        "Visual",
    },

    Tabs = {

        ESP = {
            {
                Name = "Survivor ESP",
                Type = "Toggle",
                Default = false,
                Callback = function(v)
                    State.SurvivorESP = v
                    RefreshESP()
                end
            },
            {
                Name = "Killer ESP",
                Type = "Toggle",
                Default = false,
                Callback = function(v)
                    State.KillerESP = v
                    RefreshESP()
                end
            },
            {
                Name = "Generator ESP",
                Type = "Toggle",
                Default = false,
                Callback = function(v)
                    State.GeneratorESP = v
                    RefreshESP()
                end
            },
            {
                Name = "Pallet ESP",
                Type = "Toggle",
                Default = false,
                Callback = function(v)
                    State.PalletESP = v
                    RefreshESP()
                end
            },
            {
                Name = "Gate ESP",
                Type = "Toggle",
                Default = false,
                Callback = function(v)
                    State.GateESP = v
                    RefreshESP()
                end
            },
            {
                Name = "Name + HP",
                Type = "Toggle",
                Default = false,
                Callback = function(v)
                    State.NameHP = v
                    RefreshESP()
                end
            },
        },

        Survivor = {
            {
                Name = "Reserved",
                Type = "Label",
            }
        },

        Killer = {
            {
                Name = "Reserved",
                Type = "Label",
            }
        },

        Other = {
            {
                Name = "Reserved",
                Type = "Label",
            }
        },

        Visual = {
            {
                Name = "Reserved",
                Type = "Label",
            }
        }
    }
})

-- =====================================================
-- FINAL LOG
-- =====================================================
print("[RiiHUB] Violence District main.lua loaded successfully.")