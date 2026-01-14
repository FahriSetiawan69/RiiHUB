--==================================================
-- StalkAssistModule.lua
-- Meyers Stalk HUD Assist (Single Priority Target)
-- Symbols: <  >  •  ∆
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local StalkAssist = {}

--========================
-- CONFIG (AMAN)
--========================
local MAX_DISTANCE = 15
local SAFE_DISTANCE = 7
local FACING_DOT = 0.6
local UPDATE_PRIORITY = Enum.RenderPriority.Last.Value

--========================
-- STATE
--========================
local ENABLED = false
local renderConn = nil
local currentBillboard = nil
local currentTarget = nil

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

local function hasLOS(hrp)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { player.Character }
    params.IgnoreWater = true

    local origin = camera.CFrame.Position
    local dir = hrp.Position - origin
    local res = Workspace:Raycast(origin, dir, params)

    if not res then return true end
    return res.Instance:IsDescendantOf(hrp.Parent)
end

local function distanceOK(hrp)
    return (hrp.Position - camera.CFrame.Position).Magnitude <= MAX_DISTANCE
end

--========================
-- SKILL 2 UI DETECTION
--========================
local function isStalking()
    local gui = player:FindFirstChildOfClass("PlayerGui")
    if not gui then return false end

    -- Heuristik aman: UI skill aktif → ada ImageLabel / Frame progress
    for _,v in ipairs(gui:GetDescendants()) do
        if v:IsA("ImageLabel") or v:IsA("Frame") then
            if v.Name:lower():find("skill")
                or v.Name:lower():find("power")
                or v.Name:lower():find("stalk")
            then
                if v.Visible == true then
                    return true
                end
            end
        end
    end
    return false
end

--========================
-- BILLBOARD
--========================
local function clearBillboard()
    if currentBillboard then
        currentBillboard:Destroy()
        currentBillboard = nil
        currentTarget = nil
    end
end

local function showSymbol(char, symbol)
    if currentTarget == char and currentBillboard then
        currentBillboard.TextLabel.Text = symbol
        return
    end

    clearBillboard()

    local head = char:FindFirstChild("Head")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromScale(2, 2)
    bb.StudsOffset = Vector3.new(0, 2.8, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.Text = symbol
    txt.TextColor3 = Color3.fromRGB(230,230,230)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.Parent = bb

    currentBillboard = bb
    currentTarget = char
end

--========================
-- SYMBOL LOGIC
--========================
local function decideSymbol(hrp)
    local dist = (hrp.Position - camera.CFrame.Position).Magnitude
    if dist < SAFE_DISTANCE then
        return "∆"
    end

    -- Kamera bias kiri / kanan
    local camCF = camera.CFrame
    local toTarget = (hrp.Position - camCF.Position).Unit
    local right = camCF.RightVector:Dot(toTarget)

    if right > 0.15 then
        return "<"
    elseif right < -0.15 then
        return ">"
    end

    return "•"
end

--========================
-- MAIN LOOP
--========================
local function step()
    if not ENABLED then
        clearBillboard()
        return
    end

    if not isStalking() then
        clearBillboard()
        return
    end

    local bestScore = -math.huge
    local bestChar = nil
    local bestHRP = nil

    for _,plr in ipairs(Players:GetPlayers()) do
        if isSurvivor(plr) then
            local char = plr.Character
            local hrp = getHRP(char)
            if hrp
                and distanceOK(hrp)
                and facingCamera(hrp)
                and hasLOS(hrp)
            then
                local dist = (hrp.Position - camera.CFrame.Position).Magnitude
                local score = 100 - dist
                if score > bestScore then
                    bestScore = score
                    bestChar = char
                    bestHRP = hrp
                end
            end
        end
    end

    if bestChar and bestHRP then
        local sym = decideSymbol(bestHRP)
        showSymbol(bestChar, sym)
    else
        clearBillboard()
    end
end

--========================
-- PUBLIC API
--========================
function StalkAssist.Enable(state)
    ENABLED = state and true or false
    if ENABLED then
        RunService:BindToRenderStep(
            "_StalkAssistMeyers",
            UPDATE_PRIORITY,
            step
        )
        warn("[StalkAssist] ENABLED")
    else
        RunService:UnbindFromRenderStep("_StalkAssistMeyers")
        clearBillboard()
        warn("[StalkAssist] DISABLED")
    end
end

--========================
-- GLOBAL
--========================
_G.StalkAssistModule = StalkAssist
warn("[StalkAssist] Module loaded & registered")
