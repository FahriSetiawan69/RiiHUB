--==================================================
-- AimAssistModule.lua (OPTION 4 - MAX REALISTIC)
-- Magnet Ramp + Inner Head Offset + Fire-Release Lock
-- Target: Killer | Head | LOS Check | HOLD-only
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--========================
-- CONFIG
--========================
local RAMP_START = 0.30        -- magnet awal (30%)
local RAMP_MAX   = 0.95        -- magnet puncak (95%)
local RAMP_TIME  = 0.45        -- waktu ramp (detik)
local RELEASE_LOCK_TIME = 0.10 -- boost presisi sebelum release
local MAX_DISTANCE = 300
local FOV_DOT_LIMIT = 0.80
local TARGET_PART = "Head"

-- Inner head hitbox offset (ke dalam kepala)
local INNER_OFFSET_BACK = 0.08 -- masuk ke dalam hitbox
local INNER_OFFSET_UP   = 0.02

--========================
-- STATE
--========================
local AimAssist = {}
AimAssist.Enabled = false

local holding = false
local holdStart = 0
local lastRelease = 0

--========================
-- INPUT (HOLD = ANCANG)
--========================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        holding = true
        holdStart = os.clock()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        holding = false
        lastRelease = os.clock()
    end
end)

--========================
-- UTILS
--========================
local function isKiller(player)
    if not player.Team then return false end
    return string.find(string.lower(player.Team.Name), "killer") ~= nil
end

local function getHead(char)
    return char and char:FindFirstChild(TARGET_PART)
end

-- Line of Sight (anti wall-aim)
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

-- Inner offset aim point (lebih “dalam” head)
local function getInnerHeadPoint(head)
    -- masuk sedikit ke dalam arah pandang kepala + naik tipis
    return head.Position
        - head.CFrame.LookVector * INNER_OFFSET_BACK
        + Vector3.new(0, INNER_OFFSET_UP, 0)
end

--========================
-- TARGET SELECTION
--========================
local function getBestTarget(cam)
    local best, bestDot = nil, FOV_DOT_LIMIT

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isKiller(plr) and plr.Character then
            local head = getHead(plr.Character)
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local dir = head.Position - cam.CFrame.Position
                local dist = dir.Magnitude
                if dist <= MAX_DISTANCE then
                    local dot = cam.CFrame.LookVector:Dot(dir.Unit)
                    if dot > bestDot and isVisible(cam, head) then
                        bestDot = dot
                        best = head
                    end
                end
            end
        end
    end

    return best
end

--========================
-- MAGNET COMPUTATION
--========================
local function computeMagnet()
    if not holding then return 0 end

    -- Ramp dari 30% ke 95%
    local t = math.clamp((os.clock() - holdStart) / RAMP_TIME, 0, 1)
    local rampMagnet = RAMP_START + (RAMP_MAX - RAMP_START) * t

    -- Fire-release precision lock (boost singkat sebelum release)
    if os.clock() - lastRelease <= RELEASE_LOCK_TIME then
        return RAMP_MAX
    end

    return rampMagnet
end

--========================
-- MAIN LOOP (HOLD-ONLY)
--========================
RunService.RenderStepped:Connect(function()
    if not AimAssist.Enabled then return end
    if not holding then return end

    local cam = Workspace.CurrentCamera
    if not cam then return end

    local targetHead = getBestTarget(cam)
    if not targetHead then return end

    local aimPoint = getInnerHeadPoint(targetHead)
    local desired = CFrame.new(cam.CFrame.Position, aimPoint)

    local magnet = computeMagnet()
    if magnet <= 0 then return end

    cam.CFrame = cam.CFrame:Lerp(desired, magnet)
end)

--========================
-- PUBLIC API (HOMEGUI)
--========================
function AimAssist:Enable()
    AimAssist.Enabled = true
end

function AimAssist:Disable()
    AimAssist.Enabled = false
end

--========================
-- EXPORT
--========================
_G.AimAssistModule = AimAssist
return AimAssist
