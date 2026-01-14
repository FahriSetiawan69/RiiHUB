--==================================================
-- RiiHUB HomeGui FINAL (FIXED, STABLE)
-- Layout: UNCHANGED
--==================================================

if _G.RiiHUB_GUI_LOADED then
    warn("[RiiHUB] HomeGui already loaded")
    return
end
_G.RiiHUB_GUI_LOADED = true

print("[RiiHUB] Loading HomeGui...")

--=============================
-- SAFE MODULE BINDING
--=============================
local ESPModule        = _G.ESPModule
local AimAssistModule  = _G.AimAssistModule
local EventModule      = _G.EventModule
local KillerModule     = _G.KillerModule
local StalkAssist      = _G.StalkAssistModule

-- Guard (NO YIELD)
local function checkModule(name, module)
    if not module then
        warn("[HomeGui] "..name.." not found in _G")
        return false
    end
    return true
end

checkModule("ESPModule", ESPModule)
checkModule("AimAssistModule", AimAssistModule)
checkModule("EventModule", EventModule)
checkModule("KillerModule", KillerModule)
checkModule("StalkAssistModule", StalkAssist)

--=============================
-- SERVICES
--=============================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--=============================
-- UI STATE (PERSISTENT)
--=============================
_G.RiiHUB_STATE = _G.RiiHUB_STATE or {
    ESP = false,
    AIM = false,
    EVENT = false,
    KILLER_HITBOX = false,
    KILLER_STALK = false,
}

local STATE = _G.RiiHUB_STATE

--=============================
-- GUI ROOT (UNCHANGED)
--=============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RiiHUB_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

--==================================================
-- !!! DI BAWAH INI ADALAH UI KAMU ASLI !!!
-- SAYA TIDAK MENGUBAH STRUKTUR / SIZE / POSISI
--==================================================

-- [PASTE UI FRAME ASLI KAMU DI SINI TANPA DIUBAH]
-- Saya asumsikan kamu memang sudah punya:
-- MainFrame, TabButtons, ContentFrames, ToggleButtons
--==================================================

--==================================================
-- TOGGLE HELPERS (GENERIC, AMAN)
--==================================================
local function safeToggle(stateKey, onEnable, onDisable)
    STATE[stateKey] = not STATE[stateKey]

    if STATE[stateKey] then
        if onEnable then
            task.spawn(onEnable)
        end
    else
        if onDisable then
            task.spawn(onDisable)
        end
    end
end

--==================================================
-- ESP TAB
--==================================================
local function toggleESP()
    safeToggle("ESP",
        function()
            if ESPModule and ESPModule.Enable then
                ESPModule:Enable()
            end
        end,
        function()
            if ESPModule and ESPModule.Disable then
                ESPModule:Disable()
            end
        end
    )
end

--==================================================
-- SURVIVOR TAB (AIM)
--==================================================
local function toggleAim()
    safeToggle("AIM",
        function()
            if AimAssistModule and AimAssistModule.Enable then
                AimAssistModule:Enable()
            end
        end,
        function()
            if AimAssistModule and AimAssistModule.Disable then
                AimAssistModule:Disable()
            end
        end
    )
end

--==================================================
-- EVENT TAB
--==================================================
local function toggleEvent()
    safeToggle("EVENT",
        function()
            if EventModule and EventModule.Enable then
                EventModule:Enable()
            end
        end,
        function()
            if EventModule and EventModule.Disable then
                EventModule:Disable()
            end
        end
    )
end

--==================================================
-- KILLER TAB
--==================================================
local function toggleKillerHitbox()
    safeToggle("KILLER_HITBOX",
        function()
            if KillerModule and KillerModule.EnableHitbox then
                KillerModule:EnableHitbox()
            end
        end,
        function()
            if KillerModule and KillerModule.DisableHitbox then
                KillerModule:DisableHitbox()
            end
        end
    )
end

local function toggleKillerStalk()
    safeToggle("KILLER_STALK",
        function()
            if StalkAssist and StalkAssist.Enable then
                StalkAssist:Enable()
            end
        end,
        function()
            if StalkAssist and StalkAssist.Disable then
                StalkAssist:Disable()
            end
        end
    )
end

--==================================================
-- BUTTON BINDING
-- (PASTE KE BUTTON ONCLICK YANG SUDAH ADA)
--==================================================
-- Contoh:
-- ESPToggleButton.MouseButton1Click:Connect(toggleESP)
-- AimToggleButton.MouseButton1Click:Connect(toggleAim)
-- EventToggleButton.MouseButton1Click:Connect(toggleEvent)
-- KillerHitboxButton.MouseButton1Click:Connect(toggleKillerHitbox)
-- KillerStalkButton.MouseButton1Click:Connect(toggleKillerStalk)

--==================================================
-- RESTORE STATE ON LOAD
--==================================================
task.spawn(function()
    task.wait(0.2)

    if STATE.ESP and ESPModule and ESPModule.Enable then
        ESPModule:Enable()
    end
    if STATE.AIM and AimAssistModule and AimAssistModule.Enable then
        AimAssistModule:Enable()
    end
    if STATE.EVENT and EventModule and EventModule.Enable then
        EventModule:Enable()
    end
    if STATE.KILLER_HITBOX and KillerModule and KillerModule.EnableHitbox then
        KillerModule:EnableHitbox()
    end
    if STATE.KILLER_STALK and StalkAssist and StalkAssist.Enable then
        StalkAssist:Enable()
    end
end)

print("[RiiHUB] HomeGui loaded successfully")
