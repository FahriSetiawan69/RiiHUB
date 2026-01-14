--==================================================
--  (Christmas Event Assist)
-- Teleport any-distance | Green Outline Gift
-- Manual UI Tap (pickup) | Auto Touch (tree)
-- Delta Mobile Safe
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

--========================
-- STATE
--========================
local enabled = false
local flyBtnGift, flyBtnTree, hintGui
local activeHighlight
local currentGiftTarget

--========================
-- CONFIG
--========================
local GIFT_HIGHLIGHT_COLOR = Color3.fromRGB(0,255,120)
local TELEPORT_OFFSET_GIFT = Vector3.new(0, 0, -3)
local TELEPORT_OFFSET_TREE = Vector3.new(3, 0, 0)

--========================
-- UTIL
--========================
local function getHRP()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function lookAt(pos)
    camera.CFrame = CFrame.new(camera.CFrame.Position, pos)
end

local function clearHighlight()
    if activeHighlight then
        activeHighlight:Destroy()
        activeHighlight = nil
    end
end

local function setHighlight(model)
    clearHighlight()
    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineColor = GIFT_HIGHLIGHT_COLOR
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = model
    activeHighlight = h
end

--========================
-- FINDERS (NAMELESS)
--========================
-- Cari kandidat object interaktif (bukan player, bukan map statis)
local function findGiftCandidate()
    local best, bestScore

    for _,inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") and inst.CanCollide then
            local model = inst:FindFirstAncestorOfClass("Model")
            if model and not Players:GetPlayerFromCharacter(model) then
                -- heuristik: object kecil-menengah, bukan terrain
                local size = inst.Size
                local score = size.Magnitude
                if score < 30 then
                    best = model
                    bestScore = score
                    break
                end
            end
        end
    end

    return best
end

local function findChristmasTree()
    -- dari debug Anda, path pohon konsisten
    return Workspace:FindFirstChild("Map", true)
        and Workspace:FindFirstChild("ChristmasTree", true)
end

--========================
-- TELEPORT ACTIONS
--========================
local function goToGift()
    local hrp = getHRP()
    if not hrp then return end

    local gift = findGiftCandidate()
    if not gift then return end

    currentGiftTarget = gift
    setHighlight(gift)

    local pivot = gift:GetPivot()
    hrp.CFrame = pivot * CFrame.new(TELEPORT_OFFSET_GIFT)
    lookAt(pivot.Position)

    if hintGui then hintGui.Enabled = true end
end

local function goToTree()
    local hrp = getHRP()
    if not hrp then return end

    local tree = findChristmasTree()
    if not tree then return end

    clearHighlight()
    currentGiftTarget = nil

    local pivot = tree:GetPivot()
    hrp.CFrame = pivot * CFrame.new(TELEPORT_OFFSET_TREE)
    lookAt(pivot.Position)

    if hintGui then hintGui.Enabled = false end
end

--========================
-- UI (FLY BUTTONS)
--========================
local function makeFlyButton(text, pos)
    local gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0,120,0,42)
    btn.Position = pos
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(120,70,180)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.Draggable = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    return gui, btn
end

local function spawnUI()
    local g1, b1 = makeFlyButton("Go to Gift", UDim2.new(0.65,0,0.55,0))
    local g2, b2 = makeFlyButton("Go to Tree", UDim2.new(0.65,0,0.65,0))
    flyBtnGift, flyBtnTree = g1, g2

    b1.MouseButton1Click:Connect(goToGift)
    b2.MouseButton1Click:Connect(goToTree)

    -- Hint UI
    hintGui = Instance.new("ScreenGui", player.PlayerGui)
    hintGui.ResetOnSpawn = false
    hintGui.Enabled = false

    local lbl = Instance.new("TextLabel", hintGui)
    lbl.Size = UDim2.new(0,260,0,30)
    lbl.Position = UDim2.new(1,-270,1,-120) -- kanan-bawah, dekat tombol besar
    lbl.BackgroundColor3 = Color3.fromRGB(0,150,90)
    lbl.BackgroundTransparency = 0.15
    lbl.BorderSizePixel = 0
    lbl.Text = "TEKAN TOMBOL BESAR UNTUK AMBIL KADO"
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0,8)
end

local function destroyUI()
    if flyBtnGift then flyBtnGift:Destroy(); flyBtnGift = nil end
    if flyBtnTree then flyBtnTree:Destroy(); flyBtnTree = nil end
    if hintGui then hintGui:Destroy(); hintGui = nil end
    clearHighlight()
    currentGiftTarget = nil
end

--========================
-- TOGGLE (FROM HOMEGUI)
--========================
_G.ToggleEvent = function(state)
    enabled = state and true or false
    if enabled then
        spawnUI()
    else
        destroyUI()
    end
end
