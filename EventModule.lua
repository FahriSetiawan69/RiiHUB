--==================================================
-- EventModule.lua (FINAL - HITBOX TOUCH FIX)
-- Gift deposit requires TOOL TOUCH to Tree hitbox
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================
local GIFT_MODEL_NAME = "Gift"
local TREE_MODEL_NAME = "ChristmasTree"

local GIFT_TOOL_KEYWORDS = { "gift", "present", "christmas" }
local LOBBY_KEYWORDS = { "lobby", "spawn", "waiting", "menu" }

-- movement tuning (PENTING)
local TREE_APPROACH_DISTANCE = 6     -- posisi awal di depan pohon
local TREE_PUSH_DISTANCE = 4         -- jarak dorong menembus hitbox
local TREE_UP_OFFSET = 2
local GIFT_UP_OFFSET = 3

local PUSH_TIME = 0.30               -- durasi dorong (detik)

--==================================================
-- MODULE
--==================================================
local EventModule = {}
EventModule.Enabled = false

local gifts, trees = {}, {}
local giftIndex = 1
local waitingForPickup = false
local toolConn
local gui, floatBtn

--==================================================
-- UTILS
--==================================================
local function isLobbyContainer(inst)
    local cur = inst
    while cur do
        local n = string.lower(cur.Name)
        for _, k in ipairs(LOBBY_KEYWORDS) do
            if string.find(n, k) then return true end
        end
        cur = cur.Parent
    end
    return false
end

local function getPrimary(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
end

local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function hasGiftTool()
    local c = getChar()
    if not c then return false end
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") then
            local lname = string.lower(ch.Name)
            for _, k in ipairs(GIFT_TOOL_KEYWORDS) do
                if string.find(lname, k) then
                    return true
                end
            end
        end
    end
    return false
end

--==================================================
-- SCAN MAP
--==================================================
local function scanMap()
    table.clear(gifts)
    table.clear(trees)

    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and not isLobbyContainer(m) then
            if m.Name == GIFT_MODEL_NAME then
                table.insert(gifts, m)
            elseif m.Name == TREE_MODEL_NAME then
                table.insert(trees, m)
            end
        end
    end

    print("[EventModule] Gifts:", #gifts, "| Trees:", #trees)
end

--==================================================
-- TELEPORT LOGIC
--==================================================
local function teleportToGift(gift)
    local hrp = getHRP()
    local p = getPrimary(gift)
    if hrp and p then
        hrp.CFrame = CFrame.new(p.Position + Vector3.new(0, GIFT_UP_OFFSET, 0))
        print("[EventModule] Teleport to Gift")
    end
end

local function depositToTree(tree)
    local hrp = getHRP()
    local p = getPrimary(tree)
    if not (hrp and p) then return end

    -- 1) posisi awal di depan pohon
    local treeCF = p.CFrame
    local startPos =
        treeCF.Position
        - treeCF.LookVector * TREE_APPROACH_DISTANCE
        + Vector3.new(0, TREE_UP_OFFSET, 0)

    hrp.CFrame = CFrame.new(startPos, treeCF.Position)
    task.wait(0.05)

    -- 2) dorong masuk ke hitbox (MENYENTUH)
    local pushPos =
        startPos
        + treeCF.LookVector * TREE_PUSH_DISTANCE

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(PUSH_TIME, Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(pushPos, treeCF.Position) }
    )

    tween:Play()
    tween.Completed:Wait()

    print("[EventModule] Gift deposited via hitbox touch")
end

local function depositToNearestTree()
    if not hasGiftTool() then return end

    local hrp = getHRP()
    if not hrp then return end

    local nearest, best = nil, math.huge
    for _, t in ipairs(trees) do
        local p = getPrimary(t)
        if p then
            local d = (p.Position - hrp.Position).Magnitude
            if d < best then
                best = d
                nearest = t
            end
        end
    end

    if nearest then
        depositToTree(nearest)
    end
end

--==================================================
-- PICKUP DETECTOR (TOOL BASED)
--==================================================
local function startPickupWatcher()
    if toolConn then toolConn:Disconnect() end

    toolConn = LocalPlayer.Character.ChildAdded:Connect(function(child)
        if not waitingForPickup then return end
        if not child:IsA("Tool") then return end

        local lname = string.lower(child.Name)
        for _, k in ipairs(GIFT_TOOL_KEYWORDS) do
            if string.find(lname, k) then
                waitingForPickup = false
                task.wait(0.1)
                depositToNearestTree()
                return
            end
        end
    end)
end

--==================================================
-- GUI
--==================================================
local function destroyGui()
    if gui then gui:Destroy() end
    gui, floatBtn = nil, nil
end

local function createGui()
    destroyGui()

    gui = Instance.new("ScreenGui")
    gui.Name = "EventModule_GUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.Parent = PlayerGui

    floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.fromOffset(190, 44)
    floatBtn.Position = UDim2.fromScale(0.05, 0.7)
    floatBtn.Text = "EVENT: NEXT GIFT"
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 16
    floatBtn.TextColor3 = Color3.new(1,1,1)
    floatBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 220)
    floatBtn.BackgroundTransparency = 0.15
    floatBtn.Parent = gui
    Instance.new("UICorner", floatBtn)

    -- drag
    do
        local dragging, startPos, dragStart
        floatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = floatBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local d = input.Position - dragStart
                floatBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function()
            dragging = false
        end)
    end

    -- CLICK -> TELEPORT TO GIFT ONLY
    floatBtn.MouseButton1Click:Connect(function()
        if not EventModule.Enabled then return end
        if #gifts == 0 then return end

        teleportToGift(gifts[giftIndex])
        giftIndex += 1
        if giftIndex > #gifts then giftIndex = 1 end

        waitingForPickup = true
        startPickupWatcher()
    end)
end

--==================================================
-- PUBLIC API
--==================================================
function EventModule:Enable()
    if EventModule.Enabled then return end
    EventModule.Enabled = true
    scanMap()
    createGui()
    print("[EventModule] Enabled")
end

function EventModule:Disable()
    EventModule.Enabled = false
    waitingForPickup = false
    if toolConn then toolConn:Disconnect() end
    destroyGui()
    print("[EventModule] Disabled")
end

--==================================================
-- EXPORT
--==================================================
_G.EventModule = EventModule
return EventModule
