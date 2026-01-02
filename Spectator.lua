-- =========================================
-- RII HUB - SPECTATOR FEATURE (HOME GUI COMPATIBLE)
-- =========================================

return function(parent)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    parent:ClearAllChildren()

    -- ================= ROOT PANEL =================
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1

    -- ================= HUD =================
    local hud = Instance.new("Frame")
    hud.Size = UDim2.new(0,220,0,60)
    hud.Position = UDim2.new(0,10,1,-70) -- pojok kiri bawah
    hud.BackgroundTransparency = 1
    hud.ZIndex = 10

    local nameLabel = Instance.new("TextLabel", hud)
    nameLabel.Size = UDim2.new(0,180,0,30)
    nameLabel.Position = UDim2.new(0,20,0,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local leftArrow = Instance.new("TextButton", hud)
    leftArrow.Size = UDim2.new(0,20,0,20)
    leftArrow.Position = UDim2.new(0,0,0,20)
    leftArrow.Text = "<"
    leftArrow.Font = Enum.Font.GothamBold
    leftArrow.TextSize = 18
    leftArrow.BackgroundTransparency = 0.5
    leftArrow.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", leftArrow)

    local rightArrow = Instance.new("TextButton", hud)
    rightArrow.Size = UDim2.new(0,20,0,20)
    rightArrow.Position = UDim2.new(1,-20,0,20)
    rightArrow.Text = ">"
    rightArrow.Font = Enum.Font.GothamBold
    rightArrow.TextSize = 18
    rightArrow.BackgroundTransparency = 0.5
    rightArrow.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", rightArrow)

    hud.Parent = game:GetService("CoreGui") -- floating HUD, tetap di screen

    -- ================= VARIABLES =================
    local spectatorOn = false
    local currentIndex = 1
    local spectatingPlayer = nil
    local cam = workspace.CurrentCamera
    local playerList = {}

    local function updateHUD()
        if spectatingPlayer then
            nameLabel.Text = spectatingPlayer.Name
        else
            nameLabel.Text = "No Player"
        end
    end

    local function spectatePlayer(player)
        spectatingPlayer = player
        updateHUD()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,6)
        end
    end

    -- ================= PLAYER NAVIGATION =================
    leftArrow.MouseButton1Click:Connect(function()
        if #playerList < 1 then return end
        currentIndex = currentIndex - 1
        if currentIndex < 1 then currentIndex = #playerList end
        spectatePlayer(playerList[currentIndex])
    end)

    rightArrow.MouseButton1Click:Connect(function()
        if #playerList < 1 then return end
        currentIndex = currentIndex + 1
        if currentIndex > #playerList then currentIndex = 1 end
        spectatePlayer(playerList[currentIndex])
    end)

    -- ================= UPDATE PLAYER LIST =================
    local function rebuildPlayerList()
        playerList = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(playerList,p)
            end
        end
        table.sort(playerList,function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)
        if #playerList > 0 then
            currentIndex = 1
            spectatePlayer(playerList[currentIndex])
        end
    end

    rebuildPlayerList()
    Players.PlayerAdded:Connect(rebuildPlayerList)
    Players.PlayerRemoving:Connect(rebuildPlayerList)

    -- ================= DRAG CAMERA =================
    local dragging = false
    local lastPos = Vector2.new()
    local sensitivity = 0.2

    UserInputService.InputBegan:Connect(function(input,gp)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            lastPos = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input,gp)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            if spectatingPlayer and spectatingPlayer.Character and spectatingPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local delta = input.Position - lastPos
                local hrp = spectatingPlayer.Character.HumanoidRootPart
                local cf = hrp.CFrame
                cf = cf * CFrame.Angles(0, -math.rad(delta.X*sensitivity),0)
                cam.CFrame = cf + Vector3.new(0,3,6)
                lastPos = input.Position
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input,gp)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ================= TOGGLE =================
    local toggle = Instance.new("TextButton", root)
    toggle.Size = UDim2.new(0,120,0,36)
    toggle.Position = UDim2.new(0,10,0,10)
    toggle.Text = "Spectator OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(90,60,140)
    toggle.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", toggle)

    toggle.MouseButton1Click:Connect(function()
        spectatorOn = not spectatorOn
        hud.Visible = spectatorOn
        toggle.Text = spectatorOn and "Spectator ON" or "Spectator OFF"
        if not spectatorOn then
            cam.CameraType = Enum.CameraType.Custom
        elseif spectatingPlayer then
            cam.CameraType = Enum.CameraType.Scriptable
        end
    end)
end
