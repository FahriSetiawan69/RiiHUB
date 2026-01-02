-- =========================================
-- SPECTATOR FEATURE (Home GUI Ready)
-- =========================================
return function(parent)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer

    parent:ClearAllChildren()

    -- ================= TOGGLE =================
    local toggle = Instance.new("TextButton", parent)
    toggle.Size = UDim2.new(0,120,0,40)
    toggle.Position = UDim2.new(0,10,0,10)
    toggle.Text = "Spectator OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(90,60,140)
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    Instance.new("UICorner", toggle)

    local isOn = false
    local currentTargetIndex = 1
    local hud

    local function createHUD()
        hud = Instance.new("Frame", lp.PlayerGui)
        hud.Name = "SpectatorHUD"
        hud.Size = UDim2.new(0,200,0,50)
        hud.Position = UDim2.new(0,10,1,-60)
        hud.BackgroundTransparency = 0.3
        hud.BackgroundColor3 = Color3.fromRGB(30,30,30)
        hud.BorderSizePixel = 0
        Instance.new("UICorner", hud)

        local nameLabel = Instance.new("TextLabel", hud)
        nameLabel.Size = UDim2.new(1,0,0.5,0)
        nameLabel.Position = UDim2.new(0,0,0,0)
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.Text = ""

        local navFrame = Instance.new("Frame", hud)
        navFrame.Size = UDim2.new(1,0,0.5,0)
        navFrame.Position = UDim2.new(0,0,0.5,0)
        navFrame.BackgroundTransparency = 1

        local leftBtn = Instance.new("TextButton", navFrame)
        leftBtn.Size = UDim2.new(0,50,1,0)
        leftBtn.Position = UDim2.new(0,0,0,0)
        leftBtn.Text = "<"
        leftBtn.Font = Enum.Font.GothamBold
        leftBtn.TextSize = 18
        leftBtn.TextColor3 = Color3.new(1,1,1)
        leftBtn.BackgroundTransparency = 0.3
        Instance.new("UICorner", leftBtn)

        local rightBtn = Instance.new("TextButton", navFrame)
        rightBtn.Size = UDim2.new(0,50,1,0)
        rightBtn.Position = UDim2.new(1,-50,0,0)
        rightBtn.Text = ">"
        rightBtn.Font = Enum.Font.GothamBold
        rightBtn.TextSize = 18
        rightBtn.TextColor3 = Color3.new(1,1,1)
        rightBtn.BackgroundTransparency = 0.3
        Instance.new("UICorner", rightBtn)

        return {
            frame = hud,
            nameLabel = nameLabel,
            left = leftBtn,
            right = rightBtn
        }
    end

    local targetPlayer = nil
    local camConnection
    local dragging = false
    local lastPos = Vector2.new(0,0)

    local function updateTarget()
        local players = Players:GetPlayers()
        if #players == 0 then
            targetPlayer = nil
            return
        end
        currentTargetIndex = math.clamp(currentTargetIndex, 1, #players)
        targetPlayer = players[currentTargetIndex]
        hud.nameLabel.Text = targetPlayer.Name
    end

    -- ================= CAMERA =================
    local function startSpectator()
        if not hud then
            hud = createHUD()
        end
        hud.frame.Visible = true
        updateTarget()

        -- Left/right navigation
        hud.left.MouseButton1Click:Connect(function()
            currentTargetIndex -= 1
            updateTarget()
        end)
        hud.right.MouseButton1Click:Connect(function()
            currentTargetIndex += 1
            updateTarget()
        end)

        camConnection = RunService.RenderStepped:Connect(function()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = targetPlayer.Character.HumanoidRootPart
                local cam = workspace.CurrentCamera
                local offset = Vector3.new(0,2,6)
                cam.CFrame = CFrame.new(cam.CFrame.Position:Lerp(hrp.Position + offset,0.15), hrp.Position)
            end
        end)

        -- Mobile drag camera
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                lastPos = input.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - lastPos
                local cam = workspace.CurrentCamera
                cam.CFrame *= CFrame.Angles(0, -delta.X/200, 0)
                lastPos = input.Position
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function stopSpectator()
        if hud then
            hud.frame.Visible = false
        end
        if camConnection then
            camConnection:Disconnect()
            camConnection = nil
        end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end

    toggle.MouseButton1Click:Connect(function()
        isOn = not isOn
        toggle.Text = isOn and "Spectator ON" or "Spectator OFF"
        if isOn then
            startSpectator()
        else
            stopSpectator()
        end
    end)
end
