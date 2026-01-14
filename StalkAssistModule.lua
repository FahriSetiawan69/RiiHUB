-- StalkAssistModule.lua (Delta Mobile Safe + Logic)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local StalkAssistModule = {}
StalkAssistModule.Enabled = false
StalkAssistModule.Target = nil
StalkAssistModule.Connection = nil

local MAX_DISTANCE = 80 -- jarak stalk (stud)

-- UTIL
local function getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- CARI SURVIVOR TERDEKAT
local function getClosestSurvivor()
    if not _G.KillerModule or not _G.KillerModule:IsPlayerKiller() then
        return nil
    end

    if not LocalPlayer.Character then return nil end
    local myRoot = getRoot(LocalPlayer.Character)
    if not myRoot then return nil end

    local closest, dist = nil, MAX_DISTANCE

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = getRoot(plr.Character)
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")

            if root and hum and hum.Health > 0 then
                local d = (root.Position - myRoot.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = plr
                end
            end
        end
    end

    return closest
end

-- ENABLE
function StalkAssistModule:Enable()
    if StalkAssistModule.Enabled then return end
    StalkAssistModule.Enabled = true

    StalkAssistModule.Connection = RunService.Heartbeat:Connect(function()
        StalkAssistModule.Target = getClosestSurvivor()
    end)

    warn("[StalkAssistModule] Enabled")
end

-- DISABLE
function StalkAssistModule:Disable()
    StalkAssistModule.Enabled = false

    if StalkAssistModule.Connection then
        StalkAssistModule.Connection:Disconnect()
        StalkAssistModule.Connection = nil
    end

    StalkAssistModule.Target = nil
    warn("[StalkAssistModule] Disabled")
end

-- GET TARGET (DIPAKAI UI / AIM / ESP)
function StalkAssistModule:GetTarget()
    return StalkAssistModule.Target
end

-- EXPORT
_G.StalkAssistModule = StalkAssistModule
return StalkAssistModule
