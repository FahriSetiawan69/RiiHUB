-- ViolenceDistrict/main.lua FINAL

_G.RiiHUB = _G.RiiHUB or {}

local ESP = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
))()

_G.RiiHUB.Game = {
    Name = "Violence District",

    Sidebar = {
        "ESP",
        "Survivor",
        "Killer",
        "Other",
        "Visual",
    },

    Modules = {
        ESP = ESP
    }
}

print("[RiiHUB] ViolenceDistrict main.lua loaded")