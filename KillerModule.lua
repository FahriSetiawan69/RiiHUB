--==================================================
-- KillerModule.lua
-- Hitbox Assist Cube (Facing + Line of Sight)
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local KillerModule = {}

--========================
-- CONFIG
--========================
local MAX_DISTANCE = 10
local FACING_DOT = 0.6
local CUBE_PADDING = Vector3.new(1.2, 1.5, 1.2)
local UPDATE_STEP = Enum.RenderPriority.Last.Value

--========================
-- STATE
--========================
local ENABLED = false
local cubes = {}
local conn = nil

--========================
-- UTIL
--========================
local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function isSurvivor(plr)
    return plr ~= player
end

local function facingCamera(hrp)
    local camDir = camera.CFrame.LookVector
    local toTarget = (hrp.Position - camera.CFrame.Position).Unit
    return camDir:Dot(toTarget) > FACING_DOT
end

local function hasLineOfSight(hrp)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { player.Character }
    params.IgnoreWater = true

    local origin = camera.CFrame.Position
    local dir = (hrp.Position - origin)
    local res = Workspace:Raycast(origin, dir, params)
    if not res then return true end
    return res.Instance:IsDescendantOf(hrp.Parent)
end

local function inRange(hrp)
    return (hrp.Position - camera.CFrame.Position).Magnitude <= MAX_DISTANCE
end

local function ensureCube(char, hrp)
    if cubes[char] then return end

    local cube = Instance.new("Part")
    cube.Name = "_HitboxAssistCube"
    cube.Anchored = true
    cube.CanCollide = false
    cube.CanQuery = true
    cube.CanTouch = false
    cube.Transparency = 0.85
    cube.Color = Color3.fromRGB(220, 220, 220)
    cube.Material = Enum.Material.SmoothPlastic
    cube.Parent = Workspace

    cubes[char] = cube
end

local function removeCube(char)
    local c = cubes[char]
    if c then c:Destroy() end
    cubes[char] = nil
end

local function updateCube(char, hrp)
    local cube = cubes[char]
    if not cube then return end
    cube.Size = hrp.Size + CUBE_PADDING
    cube.CFrame = hrp.CFrame
end

local function clearAll()
    for char,_ in pairs(cubes) do
        removeCube(char)
    end
end

--========================
-- MAIN LOOP
--========================
local function step()
    if not ENABLED then return end

    for _,plr in ipairs(Players:GetPlayers()) do
        if isSurvivor(plr) then
            local char = plr.Character
            local hrp = getHRP(char)
            if hrp
                and inRange(hrp)
                and facingCamera(hrp)
                and hasLineOfSight(hrp)
            then
                ensureCube(char, hrp)
                updateCube(char, hrp)
            else
                removeCube(char)
            end
        end
    end
end

--========================
-- PUBLIC API
--========================
function KillerModule.Enable(state)
    ENABLED = state and true or false
    if ENABLED then
        if conn then conn:Disconnect() end
        conn = RunService:BindToRenderStep(
            "_KillerHitboxAssist",
            UPDATE_STEP,
            step
        )
        warn("[KillerModule] Hitbox Assist ON")
    else
        if conn then
            RunService:UnbindFromRenderStep("_KillerHitboxAssist")
            conn = nil
        end
        clearAll()
        warn("[KillerModule] Hitbox Assist OFF")
    end
end

--========================
-- GLOBAL REGISTER
--========================
_G.KillerModule = KillerModule
warn("[KillerModule] Global KillerModule registered")
