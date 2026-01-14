--==================================================
-- AimAssistModule.lua (HOLD-ONLY AIM ASSIST)
-- 70% Magnet | Killer Only | Head Lock | LOS Check
-- Delta Mobile Safe
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================
local MAGNET_STRENGTH = 0.70      -- 70% pull
local MAX_DISTANCE = 300         -- studs
local FOV_DOT_LIMIT = 0.80       -- must be in front
local TARGET_PART = "Head"       -- aim to head

--==================================================
-- STATE
--==================================================
local AimAssist = {}
AimAssist.Enabled = false

local holding = false
local camera = nil

--==================================================
-- INPUT (HOLD = ANCANG-ANCANG)
--==================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        holding = false
    end
end)

--==================================================
-- UTILS
--==================================================
local function isKiller(player)
    if not player.Team then return false end
    return string.find(string.lower(player.Team.Name), "killer") ~= nil
end

local function getHead(char)
    return char and char:FindFirstChild(TARGET_PART)
end

-- LINE OF SIGHT (ANTI WALL AIM)
local function isVisible(cam, targetPart)
    local origin = cam.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, params)
    return result and result.Instance:IsDescendantOf(targetPart.Parent)
end

--==================================================
-- TARGET SELECTION
--==================================================
local function getBestTarget(cam)
    local bestTarget = nil
    local bestDot = FOV_DOT_LIMIT

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isKiller(plr) and plr.Character then
            local head = getHead(plr.Character)
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                local dir = head.Position - cam.CFrame.Position
                local dist = dir.Magnitude

                if dist <= MAX_DISTANCE then
                    local unitDir = dir.Unit
                    local dot = cam.CFrame.LookVector:Dot(unitDir)

                    if dot > bestDot and isVisible(cam, head) then
                        bestDot = dot
                        bestTarget = head
                    end
                end
            end
        end
    end

    return bestTarget
end

--==================================================
-- MAIN LOOP (HANYA SAAT HOLD)
--==================================================
RunService.RenderStepped:Connect(function()
    if not AimAssist.Enabled then return end
    if not holding then return end  -- 🔴 KRUSIAL: hanya saat ancang-ancang

    camera = Workspace.CurrentCamera
    if not camera then return end

    local target = getBestTarget(camera)
    if not target then return end

    local camPos = camera.CFrame.Position
    local desired = CFrame.new(camPos, target.Position)

    -- Smooth magnet (tidak snap)
    camera.CFrame = camera.CFrame:Lerp(desired, MAGNET_STRENGTH)
end)

--==================================================
-- PUBLIC API (HOMEGUI)
--==================================================
function AimAssist:Enable()
    AimAssist.Enabled = true
end

function AimAssist:Disable()
    AimAssist.Enabled = false
end

--==================================================
-- EXPORT
--==================================================
_G.AimAssistModule = AimAssist
return AimAssist
