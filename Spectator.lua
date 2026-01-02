-- =====================================================
-- SPECTATOR FEATURE FOR HOME GUI (TRANSPARENT)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer

    parent:ClearAllChildren()

    -- ================= ROOT =================
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1 -- Transparan agar mengikuti home GUI

    -- ================= TOGGLE BUTTON =================
    local toggleBtn = Instance.new("TextButton", root)
    toggleBtn.Size = UDim2.new(0,120,0,40)
    toggleBtn.Position = UDim2.new(0,10,0,10)
    toggleBtn.Text = "Spectator OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    toggleBtn.BackgroundTransparency = 0.2
    Instance.new("UICorner", toggleBtn)

    -- ================= HUD =================
    local hud = Instance.new("Frame", root)
    hud.Size = UDim2.new(0,220,0,50)
    hud.Position = UDim2.new(0,10,1,-60)
    hud.BackgroundTransparency = 0.2
    hud.BackgroundColor3 = Color3.fromRGB(40,40,50)
    Instance.new("UICorner", hud)
    hud.Visible = false

    local nameLabel = Instance.new("TextLabel", hud)
    nameLabel.Size = UDim2.new(0,120,1,0)
    nameLabel.Position = UDim2.new(0,95,0,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Text = "No Player"

    local leftArrow = Instance.new("TextButton", hud)
    leftArrow.Size = UDim2.new(0,25,0,25)
    leftArrow.Position = UDim2.new(0,95,0.5,-12)
    leftArrow.Text = "<"
    leftArrow.TextColor3 = Color3.new(1,1,1)
    leftArrow.Font = Enum.Font.GothamBold
    leftArrow.TextSize = 16
    leftArrow.BackgroundColor3 = Color3.fromRGB(60,60,80)
    Instance.new("UICorner", leftArrow)

    local rightArrow = Instance.new("TextButton", hud)
    rightArrow.Size = UDim2.new(0,25,0,25)
    rightArrow.Position = UDim2.new(0,190,0.5,-12)
    rightArrow.Text = ">"
    rightArrow.TextColor3 = Color3.new(1,1,1)
    rightArrow.Font = Enum.Font.GothamBold
    rightArrow.TextSize = 16
    rightArrow.BackgroundColor3 = Color3.fromRGB(60,60,80)
    Instance.new("UICorner", rightArrow)

    -- ================= VARIABLES =================
    local spectatorEnabled = false
    local playersList = {}
    local currentIndex = 1
    local spectatingPlayer = nil

    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom

    local dragging = false
    local dragStart = Vector2.new()
    local yaw, pitch = 0, 0
    local sensitivity = 0.003

    -- ================= FUNCTIONS =================
    local function updatePlayersList()
        playersList = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                table.insert(playersList, p)
            end
        end
    end

    local function setSpectating(index)
        if #playersList == 0 then
            spectatingPlayer = nil
            nameLabel.Text = "No Player"
            return
        end
        currentIndex = ((index-1)%#playersList)+1
        spectatingPlayer = playersList[currentIndex]
        nameLabel.Text = spectatingPlayer.Name
    end

    local function nextPlayer()
        setSpectating(currentIndex+1)
    end

    local function prevPlayer()
        setSpectating(currentIndex-1)
    end

    -- ================= INPUT =================
    toggleBtn.MouseButton1Click:Connect(function()
        spectatorEnabled = not spectatorEnabled
        hud.Visible = spectatorEnabled
        toggleBtn.Text = spectatorEnabled and "Spectator ON" or "Spectator OFF"

        if spectatorEnabled then
            updatePlayersList()
            setSpectating(currentIndex)
            yaw, pitch = 0,0
            dragging = false
            camera.CameraType = Enum.CameraType.Scriptable
        else
            spectatingPlayer = nil
            nameLabel.Text = "No Player"
            camera.CameraType = Enum.CameraType.Custom
        end
    end)

    leftArrow.MouseButton1Click:Connect(prevPlayer)
    rightArrow.MouseButton1Click:Connect(nextPlayer)

    -- Drag control
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not spectatorEnabled then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gpe)
        if not spectatorEnabled or not dragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            yaw -= delta.X * sensitivity
            pitch = math.clamp(pitch - delta.Y * sensitivity, -math.pi/2 + 0.01, math.pi/2 - 0.01)
            dragStart = input.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ================= RENDER =================
    RunService.RenderStepped:Connect(function()
        if spectatorEnabled and spectatingPlayer and spectatingPlayer.Character and spectatingPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = spectatingPlayer.Character.HumanoidRootPart
            local offset = Vector3.new(math.sin(yaw)*6, 3 + math.sin(pitch)*2, math.cos(yaw)*6)
            local camPos = hrp.Position + offset
            camera.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0,2,0))
        end
    end)

    -- ================= PLAYER EVENTS =================
    Players.PlayerAdded:Connect(updatePlayersList)
    Players.PlayerRemoving:Connect(function(p)
        updatePlayersList()
        if p == spectatingPlayer then
            setSpectating(currentIndex)
        end
    end)

    -- ================= INITIALIZE =================
    updatePlayersList()
end