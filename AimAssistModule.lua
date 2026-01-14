--==================================================
-- AimAssistModule.lua
-- Hard-Lock Aim Assist (70%) - HOLD to lock
-- R6 | Projectile Leading | Delta Mobile Safe
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

--========================
-- CONFIG
--========================
local MAGNET_STRENGTH = 0.70          -- 70% hard-lock
local BASE_STRENGTH = 0.55            -- ramp-in awal saat mulai hold
local RAMP_TIME = 0.25                -- waktu naik ke 70%
local PROJECTILE_SPEED = 180          -- estimasi kecepatan peluru (sesuaikan jika perlu)
local MAX_LOCK_ANGLE = math.rad(35)   -- tidak lock target di luar sudut wajar

--========================
-- STATE
--========================
local enabled = false
local holdingFire = false
local holdStart = 0

--========================
-- INPUT DETECT (HOLD)
--========================
-- Asumsi: tombol tembak = tap/hold layar (mouse/touch)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        holdingFire = true
        holdStart = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        holdingFire = false
    end
end)

--========================
-- TARGET ACQUISITION
--========================
local function isKiller(model)
    -- Heuristik aman: Humanoid + bukan player sendiri
    if not model or not model:IsA("Model") then return false end
    if model == player.Character then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum ~= nil
end

local function getTargetPart(model)
    return model:FindFirstChild("Torso")
        or model:FindFirstChild("HumanoidRootPart")
end

local function getBestTarget()
    local best, bestAngle
    bestAngle = MAX_LOCK_ANGLE

    for _,m in ipairs(Workspace:GetChildren()) do
        if isKiller(m) then
            local part = getTargetPart(m)
            if part then
                local dir = (part.Position - camera.CFrame.Position).Unit
                local angle = math.acos(math.clamp(camera.CFrame.LookVector:Dot(dir), -1, 1))
                if angle <= bestAngle then
                    bestAngle = angle
                    best = part
                end
            end
        end
    end
    return best
end

--========================
-- PROJECTILE LEADING
--========================
local function predictPosition(part)
    local vel = part.AssemblyLinearVelocity
    local dist = (part.Position - camera.CFrame.Position).Magnitude
    local travelTime = dist / PROJECTILE_SPEED
    return part.Position + vel * travelTime
end

--========================
-- CORE LOOP
--========================
RunService.RenderStepped:Connect(function(dt)
    if not enabled then return end
    if not holdingFire then return end

    local target = getBestTarget()
    if not target then return end

    -- ramp strength
    local t = math.clamp((tick() - holdStart) / RAMP_TIME, 0, 1)
    local strength = BASE_STRENGTH + (MAGNET_STRENGTH - BASE_STRENGTH) * t

    local aimPos = predictPosition(target)
    local desired = CFrame.new(camera.CFrame.Position, aimPos)

    camera.CFrame = camera.CFrame:Lerp(desired, strength)
end)

--========================
-- GLOBAL TOGGLE (HOMEGUI)
--========================
_G.ToggleAimAssist = function(state)
    enabled = state and true or false
    holdingFire = false
end
