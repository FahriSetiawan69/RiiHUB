-- RiiHUB | ViolenceDistrict main.lua
-- BRIDGE: HomeGui -> ESPModule
-- ESP LOGIC: UNTOUCHED

print("[RiiHUB] ViolenceDistrict main.lua loading...")

-------------------------------------------------
-- WAIT HOME GUI
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
-- LOAD ESP MODULE (SIDE EFFECT BASED)
-------------------------------------------------
local ok, err = pcall(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/ESPModule.lua"
    ))()
end)

if not ok then
    warn("[RiiHUB] ESPModule load failed:", err)
    return
end

print("[RiiHUB] ESPModule injected")

-------------------------------------------------
-- ESP DISPATCHER (MATCH REAL ESP LOGIC)
-------------------------------------------------
local function setESP(category, state)
    local enableFn = _G["Enable" .. category .. "ESP"]
    local disableFn = _G["Disable" .. category .. "ESP"]

    if state and type(enableFn) == "function" then
        enableFn()
        return
    end

    if not state and type(disableFn) == "function" then
        disableFn()
        return
    end

    warn("[RiiHUB] ESP function missing:", category)
end

-------------------------------------------------
-- REGISTER TAB
-------------------------------------------------
local tabESP = UI:RegisterTab("ESP")

-------------------------------------------------
-- TOGGLES (PER CATEGORY)
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
-- DONE
-------------------------------------------------
print("[RiiHUB] ViolenceDistrict ESP UI linked successfully")