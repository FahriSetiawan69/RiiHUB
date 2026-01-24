-- ViolenceDistrict/main.lua (FINAL)

_G.RiiHUB = _G.RiiHUB or {}

_G.RiiHUB.Game = {
    Name = "Violence District",

    Sidebar = {
        "ESP",
        "Survivor",
        "Killer",
        "Other",
        "Visual"
    },

    Modules = {
        ESP = {
            Survivor = loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
            ))(),

            Killer = loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
            ))(),

            Generator = loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
            ))(),

            Pallet = loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
            ))(),

            Gate = loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
            ))(),

            NameHP = loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
            ))(),
        }
    }
}

print("[RiiHUB] Violence District main.lua loaded")