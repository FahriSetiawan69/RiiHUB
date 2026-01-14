--==================================================
-- AimAssistModule.lua (FINAL FIX)
-- Hard-Lock 70% | HOLD only | Killer-only (Teams)
-- R6 | Projectile Leading | Delta Mobile Safe
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

--========================
-- CONFIG
--========================
local MAGNET_STRENGTH = 0.70
local BASE_STRENGTH   = 0.55
local RAMP_TIME       = 0.25
local HOLD_DELAY      = 0.12        -- gate agar tidak aktif terlalu dini
local MAX_LOCK_ANGLE  = math.rad(35)
local PROJECTILE_SPEED = 180         -- sesuaikan jika perlu

--========================
-- STATE
--========================
local enabled = false
local holding = false
local holdStart = 0

--========================
-- INPUT (HOLD DETECT)
--========================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        holding = true
        holdStart = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        holding = false
    end
end)

--========================
-- TARGETING (KILLER ONLY)
--========================
local function isKillerPlayer(plr)
    return plr
        and plr ~= localPlayer
        and plr.Team == Teams:FindFirstChild("Killer")
end

local function getTargetPart(char)
    return char:FindFirstChild("Torso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function getBestKillerTarget()
    local bestPart, bestAngle = nil, MAX_LOCK_ANGLE

    for _,plr in ipairs(Players:GetPlayers()) do
        if isKillerPlayer(plr) and plr.Character then
            local part = getTargetPart(plr.Character)
            if part then
                local dir = (part.Position - camera.CFrame.Position).Unit
                local angle = math.acos(
                    math.clamp(camera.CFrame.LookVector:Dot(dir), -1, 1)
                )
                if angle <= bestAngle then
                    bestAngle = angle
                    bestPart = part
                end
            end
        end
    end

    return bestPart
end

--========================
-- PROJECTILE LEADING
--========================
local function predictPosition(part)
    local vel = part.AssemblyLinearVelocity
    local dist = (part.Position - camera.CFrame.Position).Magnitude
    local t = dist / PROJECTILE_SPEED
    return part.Position + vel * t
end

--========================
-- CORE LOOP
--========================
RunService.RenderStepped:Connect(function()
    if not enabled then return end
    if not holding then return end
    if (tick() - holdStart) < HOLD_DELAY then return end

    local target = getBestKillerTarget()
    if not target then return end

    local ramp = math.clamp((tick() - holdStart - HOLD_DELAY) / RAMP_TIME, 0, 1)
    local strength = BASE_STRENGTH + (MAGNET_STRENGTH - BASE_STRENGTH) * ramp

    local aimPos = predictPosition(target)
    local desired = CFrame.new(camera.CFrame.Position, aimPos)

    camera.CFrame = camera.CFrame:Lerp(desired, strength)
end)

--========================
-- TOGGLE FROM HOMEGUI
--========================
_G.ToggleAimAssist = function(state)
    enabled = state and true or false
    holding = false
    holdStart = 0
end
