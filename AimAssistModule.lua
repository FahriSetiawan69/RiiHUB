-- AimAssistModule.lua (FINAL - Delta Mobile Safe)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- STATE
local enabled = false
local holding = false
local holdStart = 0
local camera = nil

-- WAIT CAMERA (SAFE)
task.spawn(function()
    repeat
        camera = Workspace.CurrentCamera
        task.wait()
    until camera
end)

-- INPUT (TOUCH + MOUSE)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = true
        holdStart = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = false
    end
end)

-- UTILS
local function isKiller(plr)
    return plr and plr ~= LocalPlayer and plr.Team == Teams:FindFirstChild("Killer")
end

local function getTargetPart(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function getBestTarget()
    if not camera then return nil end
    local best, bestDot = nil, 0.8

    for _, plr in ipairs(Players:GetPlayers()) do
        if isKiller(plr) and plr.Character then
            local part = getTargetPart(plr.Character)
            if part then
                local dir = (part.Position - camera.CFrame.Position).Unit
                local dot = camera.CFrame.LookVector:Dot(dir)
                if dot > bestDot then
                    bestDot = dot
                    best = part
                end
            end
        end
    end

    return best
end

-- RENDER LOOP (NO SPAWN, NO CRASH)
RunService.RenderStepped:Connect(function()
    if not enabled or not holding or not camera then return end

    local target = getBestTarget()
    if not target then return end

    local desired = CFrame.new(camera.CFrame.Position, target.Position)
    camera.CFrame = camera.CFrame:Lerp(desired, 0.15)
end)

-- EXPORT MODULE
_G.AimAssistModule = {
    Enable = function()
        enabled = true
        holding = false
    end,
    Disable = function()
        enabled = false
        holding = false
    end
}

return _G.AimAssistModule
