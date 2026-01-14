-- KillerModule.lua (Delta Mobile Safe + Logic)

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local KillerModule = {}
KillerModule.Enabled = false
KillerModule.IsKiller = false
KillerModule.Connection = nil

-- DETECT KILLER (AMAN, GENERIC)
local function checkKiller()
    if not LocalPlayer.Team then
        return false
    end

    -- Aman untuk game berbasis Team
    if string.lower(LocalPlayer.Team.Name):find("killer") then
        return true
    end

    return false
end

-- ENABLE
function KillerModule:Enable()
    if KillerModule.Enabled then return end
    KillerModule.Enabled = true

    KillerModule.IsKiller = checkKiller()

    KillerModule.Connection = RunService.Heartbeat:Connect(function()
        KillerModule.IsKiller = checkKiller()
    end)

    warn("[KillerModule] Enabled | IsKiller =", KillerModule.IsKiller)
end

-- DISABLE
function KillerModule:Disable()
    KillerModule.Enabled = false

    if KillerModule.Connection then
        KillerModule.Connection:Disconnect()
        KillerModule.Connection = nil
    end

    KillerModule.IsKiller = false
    warn("[KillerModule] Disabled")
end

-- STATUS (DIPAKAI MODULE LAIN)
function KillerModule:IsActive()
    return KillerModule.Enabled
end

function KillerModule:IsPlayerKiller()
    return KillerModule.IsKiller
end

-- EXPORT
_G.KillerModule = KillerModule
return KillerModule
