-- AimAssistModule (Delta Mobile Safe)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

-- WAIT for camera to be ready
local camera = nil
Task.spawn(function()
    repeat
        camera = Workspace:FindFirstChildOfClass("Camera")
        task.wait()
    until camera
end)

-- CONFIG
local MAGNET_STRENGTH = 0.70
local BASE_STRENGTH = 0.55
local RAMP_TIME = 0.25
local HOLD_DELAY = 0.12
local MAX_LOCK_ANGLE = math.rad(35)
local PROJECTILE_SPEED = 180

-- STATE
local enabled = false
local holding = false
local holdStart = 0

-- INPUT
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        holding = true
        holdStart = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        holding = false
    end
end)

-- SAFE RAYCAST CHECK
local function isVisible(part)
    if not camera or not camera.CFrame then
        return false
    end

    local origin = camera.CFrame.Position
    local dir = part.Position - origin

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {localPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, dir, params)
    return result and result.Instance:IsDescendantOf(part.Parent)
end

-- TARGETING
local function isKillerPlayer(plr)
    return plr and plr ~= localPlayer and plr.Team == Teams:FindFirstChild("Killer")
end

local function getTargetPart(char)
    return char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function getBestKillerTarget()
    local bestPart, bestAngle = nil, MAX_LOCK_ANGLE
    if not camera then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if isKillerPlayer(plr) and plr.Character then
            local part = getTargetPart(plr.Character)
            if part then
                local dir = (part.Position - camera.CFrame.Position).Unit
                local angle = math.acos(math.clamp(camera.CFrame.LookVector:Dot(dir), -1, 1))
                if angle <= bestAngle then
                    bestAngle = angle
                    bestPart = part
                end
            end
        end
    end

    return bestPart
end

-- PREDICT POSITION
local function predictPosition(part)
    if not camera then return part.Position end
    local vel = part.AssemblyLinearVelocity
    local dist = (part.Position - camera.CFrame.Position).Magnitude
    local t = dist / PROJECTILE_SPEED
    return part.Position + vel * t
end

-- CONNECT SAFE RENDER LOOP
RunService.RenderStepped:Connect(function()
    if not enabled then return end
    if not holding then return end
    if (tick() - holdStart) < HOLD_DELAY then return end
    if not camera then return end

    local target = getBestKillerTarget()
    if not target then return end

    if not isVisible(target) then return end

    local ramp = math.clamp((tick() - holdStart - HOLD_DELAY) / RAMP_TIME, 0, 1)
    local strength = BASE_STRENGTH + (MAGNET_STRENGTH - BASE_STRENGTH) * ramp

    local aimPos = predictPosition(target)
    local desired = CFrame.new(camera.CFrame.Position, aimPos)

    -- SAFE CAMERA ADJUST
    local success, err = pcall(function()
        camera.CFrame = camera.CFrame:Lerp(desired, strength)
    end)
    if not success then
        warn("[AimAssist] Failed to update camera:", err)
    end
end)

-- TOGGLE FROM HOMEGUI
_G.AimAssistModule = {
    Enable = function()
        enabled = true
        holding = false
        holdStart = 0
    end,
    Disable = function()
        enabled = false
        holding = false
    end
}

return _G.AimAssistModule
