-- HOMEGUI.LUA (Fixed Integration)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/Library.lua"))()

local Window = Library:CreateWindow("RiiHUB | Mobile Version")

-- TABS
local HomePage = Window:CreateTab("Home")
local ESPPage = Window:CreateTab("Visuals")
local SurvivorPage = Window:CreateTab("Survivor")

-- [ TAB HOME: COLOR PICKERS ]
HomePage:CreateSection("ESP Colors")

HomePage:CreateColorPicker("Survivor Color", _G.SurvivorColor, function(color)
    _G.SurvivorColor = color
end)

HomePage:CreateColorPicker("Killer Color", _G.KillerColor, function(color)
    _G.KillerColor = color
end)

HomePage:CreateColorPicker("Generator Color", _G.GenColor, function(color)
    _G.GenColor = color
end)

-- [ TAB VISUALS: TOGGLES ]
ESPPage:CreateSection("Main ESP")

ESPPage:CreateToggle("Enable Player ESP", false, function(state)
    if _G.RiiLoader then
        -- Memanggil ESPModule.lua dari GitHub
        _G.RiiLoader.RunModule("ESPModule.lua", state)
    else
        warn("RiiLoader not found!")
    end
end)

-- [ TAB SURVIVOR ]
SurvivorPage:CreateSection("Survival Cheats")
SurvivorPage:CreateButton("Coming Soon", function()
    print("Fitur sedang dikembangkan")
end)

print("RiiHUB: HomeGui Loaded Successfully!")
