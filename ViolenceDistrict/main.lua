-- ViolenceDistrict/main.lua (FINAL GAME CONTROLLER)

repeat task.wait() until _G.RiiHUB_UI
local UI = _G.RiiHUB_UI

-- Load ESP module
local ESP = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
))()

-- Tabs
UI:AddTab("ESP")
UI:AddTab("Survivor")
UI:AddTab("Killer")
UI:AddTab("Other")
UI:AddTab("Visual")

-- ESP Toggles
UI:AddToggle("ESP", "Survivor ESP"):Bind(function(v)
    ESP.ToggleSurvivor(v)
end)

UI:AddToggle("ESP", "Killer ESP"):Bind(function(v)
    ESP.ToggleKiller(v)
end)

UI:AddToggle("ESP", "Generator ESP"):Bind(function(v)
    ESP.ToggleGenerator(v)
end)

UI:AddToggle("ESP", "Pallet ESP"):Bind(function(v)
    ESP.TogglePallet(v)
end)

UI:AddToggle("ESP", "Gate ESP"):Bind(function(v)
    ESP.ToggleGate(v)
end)

UI:AddToggle("ESP", "Name + HP"):Bind(function(v)
    ESP.ToggleNameHP(v)
end)

print("[RiiHUB] ViolenceDistrict features registered")