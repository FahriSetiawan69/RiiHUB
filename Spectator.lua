-- =========================================
-- RII HUB - SPECTATOR (MODULAR FIX)
-- =========================================

return function(parent)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer

    parent:ClearAllChildren()

    -- ROOT
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1

    -- TOGGLE
    local toggleFrame = Instance.new("Frame", root)
    toggleFrame.Size = UDim2.new(0,200,0,40)
    toggleFrame.Position = UDim2.new(0,10,0,10)
    toggleFrame.BackgroundTransparency = 0.1
    toggleFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", toggleFrame)

    local toggleBtn = Instance.new("TextButton", toggleFrame)
    toggleBtn.Size = UDim2.new(1,0,1,0)
    toggleBtn.Text = "Spectator: OFF"
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.TextSize = 14

    -- HUD
    local hud = Instance.new("Frame", root)
    hud.Size = UDim2.new(0,200,0,60)
    hud.Position = UDim2.new(0,10,1,-70)
    hud.BackgroundTransparency = 0.2
    hud.BackgroundColor3 = Color3.fromRGB(0,0,0)
    hud.Visible = false
    Instance.new("UICorner", hud)

    local targetLabel = Instance.new("TextLabel", hud)
    targetLabel.Size = UDim2.new(1,0,1,0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.TextColor3 = Color3.new(1,1,1)
    targetLabel.Text = "No Target"
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.TextScaled = true

    -- VARIABLES
    local spectatorOn = false
    local targetIndex = 1
    local targetPlayer = nil
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom

    -- FUNCTIONS
    local function updateTarget()
        local allPlayers = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                table.insert(allPlayers, p)
            end
        end
        if #allPlayers == 0 then
            targetPlayer = nil
            targetLabel.Text = "No Target"
            return
        end
        if targetIndex > #allPlayers then
            targetIndex = 1
        elseif targetIndex < 1 then
            targetIndex = #allPlayers
        end
        targetPlayer = allPlayers[targetIndex]
        targetLabel.Text = targetPlayer.Name
    end

    local function nextTarget()
        targetIndex += 1
        updateTarget()
    end

    local function prevTarget()
        targetIndex -= 1
        updateTarget()
    end

    -- TOGGLE BUTTON
    toggleBtn.MouseButton1Click:Connect(function()
        spectatorOn = not spectatorOn
        hud.Visible = spectatorOn
        toggleBtn.Text = spectatorOn and "Spectator: ON" or "Spectator: OFF"
        if spectatorOn then
            updateTarget()
        else
            camera.CameraType = Enum.CameraType.Custom
        end
    end)

    -- INPUT
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not spectatorOn then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Right then
                nextTarget()
            elseif input.KeyCode == Enum.KeyCode.Left then
                prevTarget()
            end
        end
    end)

    -- CAMERA DRAG VARIABLES
    local dragging = false
    local lastPos = Vector2.zero
    local yaw = 0
    local pitch = 0
    local distance = 10

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not spectatorOn then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            lastPos = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gpe)
        if not spectatorOn then return end
        if input.UserInputType == Enum.UserInputType.Touch and dragging then
            local delta = input.Position - lastPos
            yaw -= delta.X * 0.005
            pitch = math.clamp(pitch - delta.Y * 0.005, -math.pi/2 + 0.1, math.pi/2 - 0.1)
            lastPos = input.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- CAMERA UPDATE
    RunService.RenderStepped:Connect(function()
        if spectatorOn and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = targetPlayer.Character.HumanoidRootPart
            local offset = Vector3.new(
                math.sin(yaw)*distance,
                3,
                math.cos(yaw)*distance
            )
            local camPos = hrp.Position + offset
            camera.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0,2,0))
        end
    end)
end
