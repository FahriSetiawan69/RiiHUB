--========================================
-- RiiHUB Event Module (Christmas FINAL)
-- Auto Teleport Gift -> ChristmasTree
-- HARD MAP LOCK (ANTI LOBBY)
--========================================

local EventModule = {}
EventModule.Enabled = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

--==============================
-- CONSTANT PATH LOCK
--==============================
local MAP_ROOT = Workspace:WaitForChild("Map")
local CHRIS_ROOT = MAP_ROOT:WaitForChild("chris")
local GIFT_ROOT = CHRIS_ROOT:WaitForChild("gifts", 10) or CHRIS_ROOT
local TREE_ROOT = CHRIS_ROOT:WaitForChild("ChristmasTrees")

--==============================
-- STATE
--==============================
local giftHighlights = {}
local floatingBtn
local connections = {}

--==============================
-- UTILS
--==============================
local function log(msg)
    print("[RiiHUB EVENT]", msg)
end

local function getModelCFrame(model)
    local cf, _ = model:GetBoundingBox()
    return cf
end

--==============================
-- FIND VALID TREE (MAP ONLY)
--==============================
local function getChristmasTree()
    for _, obj in ipairs(TREE_ROOT:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "ChristmasTree" then
            return obj
        end
    end
    return nil
end

--==============================
-- FIND VALID GIFTS (MAP ONLY)
--==============================
local function getGifts()
    local list = {}
    for _, obj in ipairs(GIFT_ROOT:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Gift" then
            if obj:IsDescendantOf(MAP_ROOT) then
                table.insert(list, obj)
            end
        end
    end
    return list
end

--==============================
-- HIGHLIGHT GIFTS
--==============================
local function clearHighlights()
    for _, h in ipairs(giftHighlights) do
        h:Destroy()
    end
    giftHighlights = {}
end

local function highlightGifts()
    clearHighlights()
    for _, gift in ipairs(getGifts()) do
        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(0, 255, 120)
        h.OutlineColor = Color3.fromRGB(0, 180, 80)
        h.FillTransparency = 0.55
        h.OutlineTransparency = 0
        h.Parent = gift
        table.insert(giftHighlights, h)
    end
    log("Gift highlighted: " .. tostring(#giftHighlights))
end

--==============================
-- TELEPORT TO NEAREST GIFT
--==============================
local function teleportToGift()
    local gifts = getGifts()
    if #gifts == 0 then
        log("No gift found in map")
        return
    end

    local root = Character:WaitForChild("HumanoidRootPart")
    local closest, dist = nil, math.huge

    for _, g in ipairs(gifts) do
        local cf = getModelCFrame(g)
        local d = (root.Position - cf.Position).Magnitude
        if d < dist then
            dist = d
            closest = g
        end
    end

    if closest then
        root.CFrame = getModelCFrame(closest) * CFrame.new(0, 0, -3)
        log("Teleported to Gift")
    end
end

--==============================
-- AUTO TELEPORT WHEN GIFT PICKED
--==============================
local function onCharacterChildAdded(child)
    if child:IsA("Tool") and child.Name == "Gift" then
        task.wait(0.15)
        local tree = getChristmasTree()
        if tree then
            local root = Character:WaitForChild("HumanoidRootPart")
            root.CFrame = getModelCFrame(tree) * CFrame.new(0, 0, -4)
            log("Auto teleported to ChristmasTree")
        else
            log("ChristmasTree NOT FOUND (map lock active)")
        end
    end
end

--==============================
-- FLOATING BUTTON
--==============================
local function createFloatingButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "RiiHUB_EventGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(160, 50)
    btn.Position = UDim2.fromScale(0.5, 0.7)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Text = "TELE TO GIFT"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = gui
    btn.ZIndex = 9999
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

    -- Drag
    local dragging, dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputEnded:Connect(function()
        dragging = false
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local delta = (game:GetService("UserInputService"):GetMouseLocation() - dragStart)
            btn.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)

    btn.MouseButton1Click:Connect(teleportToGift)

    floatingBtn = gui
end

--==============================
-- ENABLE / DISABLE
--==============================
function EventModule.Enable()
    if EventModule.Enabled then return end
    EventModule.Enabled = true

    highlightGifts()
    createFloatingButton()

    connections.char = Character.ChildAdded:Connect(onCharacterChildAdded)

    log("Event module ENABLED")
end

function EventModule.Disable()
    EventModule.Enabled = false

    clearHighlights()
    if floatingBtn then floatingBtn:Destroy() floatingBtn = nil end

    for _, c in pairs(connections) do
        c:Disconnect()
    end
    connections = {}

    log("Event module DISABLED")
end

return EventModule
