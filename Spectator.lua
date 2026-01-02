-- =========================================
-- SPECTATOR FEATURE (Standalone & Modular)
-- =========================================

return function(parent)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer

    parent:ClearAllChildren()

    -- ================= ROOT FRAME =================
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1

    -- ================= HUD =================
    local hud = Instance.new("Frame", root)
    hud.Size = UDim2.new(0,220,0,50)
    hud.Position = UDim2.new(0,10,1,-60)
    hud.BackgroundTransparency = 0.5
    hud.BackgroundColor3 = Color3.fromRGB(0,0,0)
    hud.Visible = false
    Instance.new("UICorner", hud)

    local nameLabel = Instance.new("TextLabel", hud)
    nameLabel.Size = UDim2.new(0.6,0,1,0)
    nameLabel.Position = UDim2.new(0,0,0,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local leftBtn = Instance.new("TextButton", hud)
    leftBtn.Size = UDim2.new(0.2,0,1,0)
    leftBtn.Position = UDim2.new(0.6,0,0,0)
    leftBtn.Text = "<"
    leftBtn.TextScaled = true
    leftBtn.Font = Enum.Font.GothamBold
    leftBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    leftBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", leftBtn)

    local rightBtn = Instance.new("TextButton", hud)
    rightBtn.Size = UDim2.new(0.2,0,1,0)
    rightBtn.Position = UDim2.new(0.8,0,0,0)
    rightBtn.Text = ">"
    rightBtn.TextScaled = true
    rightBtn.Font = Enum.Font.GothamBold
    rightBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    rightBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", rightBtn)

    -- ================= TOGGLE =================
    local toggle = false

    -- ================= DATA =================
    local currentIndex = 1
    local targetPlayers = {}

    local function updateTargetPlayers()
        targetPlayers = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                table.insert(targetPlayers,p)
            end
        end
        table.sort(targetPlayers,function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)
        if currentIndex > #targetPlayers then currentIndex = 1 end
    end

    local function updateHUD()
        if #targetPlayers == 0 then
            nameLabel.Text = "No Players"
        else
            local target = targetPlayers[currentIndex]
            nameLabel.Text = target.Name
        end
    end

    -- ================= CAMERA CONTROL =================
    local cam = workspace.CurrentCamera
    local dragging = false
    local lastPos = Vector2.new(0,0)
    local sensitivity = 0.2
    local rotX, rotY = 0,0

    local function startDrag(pos)
        dragging = true
        lastPos = pos
    end

    local function endDrag()
        dragging = false
    end

    local function drag(pos)
        if not dragging then return end
        local delta = pos - lastPos
        lastPos = pos
        rotX = rotX - delta.Y * sensitivity
        rotY = rotY - delta.X * sensitivity
        rotX = math.clamp(rotX,-80,80)
    end

    -- ================= SWITCH PLAYER =================
    local function switchLeft()
        if #targetPlayers == 0 then return end
        currentIndex -= 1
        if currentIndex < 1 then currentIndex = #targetPlayers end
        updateHUD()
    end

    local function switchRight()
        if #targetPlayers == 0 then return end
        currentIndex += 1
        if currentIndex > #targetPlayers then currentIndex = 1 end
        updateHUD()
    end

    leftBtn.MouseButton1Click:Connect(switchLeft)
    rightBtn.MouseButton1Click:Connect(switchRight)

    -- ================= UPDATE CAMERA =================
    RunService.RenderStepped:Connect(function()
        if not toggle then return end
        if #targetPlayers == 0 then return end
        local target = targetPlayers[currentIndex]
        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = target.Character.HumanoidRootPart
        local camPos = hrp.Position + Vector3.new(0,2,0)
        local cf = CFrame.new(camPos) * CFrame.Angles(math.rad(rotX),math.rad(rotY),0)
        cam.CFrame = cf
    end)

    -- ================= INPUT =================
    UserInputService.InputBegan:Connect(function(input)
        if not toggle then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag(input.Position)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not toggle then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            drag(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            endDrag()
        end
    end)

    -- ================= TOGGLE FUNCTION =================
    local function setToggle(state)
        toggle = state
        hud.Visible = state
        updateTargetPlayers()
        updateHUD()
        rotX, rotY = 0,0
    end

    -- ================= RETURN MODULE =================
    return {
        setToggle = setToggle, -- call module:setToggle(true/false)
        switchLeft = switchLeft,
        switchRight = switchRight,
        getHUD = function() return hud end
    }
end
