-- =====================================================
-- RII HUB - Spectator Feature (Modular, Home GUI Ready)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer

    -- ================= STATE =================
    local enabled = false
    local targetIndex = 1
    local targetPlayer = nil
    local playerList = {}

    -- ================= HUD =================
    local hudGui = Instance.new("ScreenGui")
    hudGui.Name = "SpectatorHUD"
    hudGui.Enabled = false
    hudGui.Parent = game:GetService("CoreGui")

    local hudFrame = Instance.new("Frame", hudGui)
    hudFrame.Size = UDim2.new(0,200,0,60)
    hudFrame.Position = UDim2.new(0,10,1,-70)
    hudFrame.BackgroundTransparency = 0.3
    hudFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", hudFrame)

    local nameLabel = Instance.new("TextLabel", hudFrame)
    nameLabel.Size = UDim2.new(1,0,1,0)
    nameLabel.Position = UDim2.new(0,0,0,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Text = ""

    -- Left & Right buttons
    local btnLeft = Instance.new("TextButton", hudFrame)
    btnLeft.Size = UDim2.new(0,30,0,30)
    btnLeft.Position = UDim2.new(0,5,0.5,-15)
    btnLeft.Text = "<"
    btnLeft.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btnLeft.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnLeft)

    local btnRight = Instance.new("TextButton", hudFrame)
    btnRight.Size = UDim2.new(0,30,0,30)
    btnRight.Position = UDim2.new(1,-35,0.5,-15)
    btnRight.Text = ">"
    btnRight.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btnRight.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnRight)

    -- ================= CAMERA =================
    local cam = workspace.CurrentCamera
    local camOffset = Vector3.new(0,2,6)
    local drag = false
    local lastPos = nil
    local yaw, pitch = 0, 0

    -- ================= FUNCTIONS =================
    local function updatePlayerList()
        playerList = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                table.insert(playerList, p)
            end
        end
        table.sort(playerList, function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)
    end

    local function setTarget(index)
        if #playerList == 0 then
            targetPlayer = nil
            nameLabel.Text = "No players"
            return
        end
        if index < 1 then index = #playerList end
        if index > #playerList then index = 1 end
        targetIndex = index
        targetPlayer = playerList[targetIndex]
        nameLabel.Text = targetPlayer and targetPlayer.Name or "None"
    end

    local function nextPlayer()
        setTarget(targetIndex + 1)
    end

    local function prevPlayer()
        setTarget(targetIndex - 1)
    end

    local function enable()
        enabled = true
        hudGui.Enabled = true
        updatePlayerList()
        setTarget(1)
    end

    local function disable()
        enabled = false
        hudGui.Enabled = false
        targetPlayer = nil
        cam.CameraType = Enum.CameraType.Custom
    end

    -- ================= BUTTON EVENTS =================
    btnLeft.MouseButton1Click:Connect(prevPlayer)
    btnRight.MouseButton1Click:Connect(nextPlayer)

    -- ================= DRAG CAMERA =================
    UserInputService.InputBegan:Connect(function(input)
        if enabled and input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            lastPos = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if enabled and drag and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - lastPos
            lastPos = input.Position
            yaw += delta.X * 0.005
            pitch += delta.Y * 0.005
            if pitch > math.rad(80) then pitch = math.rad(80) end
            if pitch < math.rad(-80) then pitch = math.rad(-80) end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if enabled and input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    -- ================= UPDATE CAMERA =================
    RunService.RenderStepped:Connect(function()
        if enabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = targetPlayer.Character.HumanoidRootPart
            local rotCFrame = CFrame.Angles(pitch, yaw, 0)
            cam.CFrame = CFrame.new(hrp.Position + rotCFrame:Vector3() * camOffset.magnitude, hrp.Position)
        end
    end)

    -- ================= HOME GUI TOGGLE HOOK =================
    local toggleOn = Instance.new("BoolValue", parent)
    toggleOn.Name = "SpectatorEnabled"

    toggleOn:GetPropertyChangedSignal("Value"):Connect(function()
        if toggleOn.Value then
            enable()
        else
            disable()
        end
    end)

    -- ================= INITIALIZE =================
    disable()
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
end
