-- RiiHUB | ViolenceDistrict main.lua
-- PURPOSE:
-- - Bridge HomeGui <-> ESPModule
-- - NO ESP LOGIC MODIFIED
-- - SAFE WAIT + SAFE CALL

print("[RiiHUB] ViolenceDistrict main.lua loading...")

-------------------------------------------------
-- WAIT HOMEGUI READY
-------------------------------------------------
local function waitForUI()
    while not _G.RiiHUB_UI do
        task.wait()
    end

    if _G.RiiHUB_UI.WaitUntilReady then
        _G.RiiHUB_UI:WaitUntilReady()
    end

    return _G.RiiHUB_UI
end

local UI = waitForUI()
print("[RiiHUB] HomeGui connected")

-------------------------------------------------
-- LOAD ESP MODULE (NO LOGIC CHANGE)
-------------------------------------------------
local ESPModule
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
        ))()
    end)

    if not ok then
        warn("[RiiHUB] Failed to load ESPModule:", result)
        return
    end

    ESPModule = result
end

print("[RiiHUB] ESPModule loaded")

-------------------------------------------------
-- SAFE ESP CALLER (ANTI ERROR)
-------------------------------------------------
local function setESP(category, state)
    if not ESPModule then return end

    -- Pattern 1: ESPModule:SetEnabled("Survivor", true)
    if ESPModule.SetEnabled then
        pcall(ESPModule.SetEnabled, ESPModule, category, state)
        return
    end

    -- Pattern 2: ESPModule.EnableSurvivor / DisableSurvivor
    local fnName = (state and "Enable" or "Disable") .. category
    if ESPModule[fnName] then
        pcall(ESPModule[fnName], ESPModule)
        return
    end

    -- Pattern 3: ESPModule.Survivor = true
    if ESPModule[category] ~= nil then
        ESPModule[category] = state
        return
    end

    warn("[RiiHUB] ESP handler not found for:", category)
end

-------------------------------------------------
-- REGISTER UI TABS
-------------------------------------------------
local tabESP = UI:RegisterTab("ESP")

-------------------------------------------------
-- REGISTER ESP TOGGLES (PER CATEGORY)
-------------------------------------------------
UI:AddToggle(tabESP, "Survivor ESP", function(v)
    setESP("Survivor", v)
end)

UI:AddToggle(tabESP, "Killer ESP", function(v)
    setESP("Killer", v)
end)

UI:AddToggle(tabESP, "Generator ESP", function(v)
    setESP("Generator", v)
end)

UI:AddToggle(tabESP, "Pallet ESP", function(v)
    setESP("Pallet", v)
end)

UI:AddToggle(tabESP, "Gate ESP", function(v)
    setESP("Gate", v)
end)

UI:AddToggle(tabESP, "Name + HP", function(v)
    setESP("NameHP", v)
end)

-------------------------------------------------
-- FINAL CONFIRMATION
-------------------------------------------------
print("[RiiHUB] ViolenceDistrict ESP menu registered successfully")