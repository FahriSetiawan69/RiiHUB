-- =====================================
-- SPECTATOR - HOME GUI INTEGRATION
-- =====================================
return function(parent)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local lp = Players.LocalPlayer
    local cam = workspace.CurrentCamera

    parent:ClearAllChildren()

    -- ================= ROOT FRAME =================
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1

    -- ================= HUD =================
    local hud = Instance.new("Frame", root)
    hud.Size = UDim2.new(0,220,0,60)
    hud.Position = UDim2.new(0,10,1,-70)
    hud.BackgroundColor3 = Color3.fromRGB(40,40,40)
    hud.BackgroundTransparency = 0.3
    hud.Active = true
    hud.Draggable = true
    Instance.new("UICorner", hud)

    local nameLabel = Instance.new("TextLabel", hud)
    nameLabel.Size = UDim2.new(0.6,0,1,0)
    nameLabel.Position = UDim2.new(0,10,0,0)
    nameLabel.Text = ""
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true

    local btnPrev = Instance.new("TextButton", hud)
    btnPrev.Size = UDim2.new(0.18,0,0.4,0)
    btnPrev.Position = UDim2.new(0.62,0,0.1,0)
    btnPrev.Text = "◀"
    btnPrev.TextColor3 = Color3.new(1,1,1)
    btnPrev.BackgroundColor3 = Color3.fromRGB(70,70,70)
    Instance.new("UICorner", btnPrev)

    local btnNext = Instance.new("TextButton", hud)
    btnNext.Size = UDim2.new(0.18,0,0.4,0)
    btnNext.Position = UDim2.new(0.8,0,0.1,0)
    btnNext.Text = "▶"
    btnNext.TextColor3 = Color3.new(1,1,1)
    btnNext.BackgroundColor3 = Color3.fromRGB(70,70,70)
    Instance.new("UICorner", btnNext)

    hud.Visible = false

    -- ================= VARIABLES =================
    local enabled = false
    local targetIndex = 1
    local targetPlayers = {}
    local camOffset = Vector3.new(0,3,8)
    local yaw, pitch = 0, 0
    local dragging = false
    local lastPos = Vector2.new()

    local function updatePlayerList()
        targetPlayers = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                table.insert(targetPlayers, p)
            end
        end
        table.sort(targetPlayers, function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)
        if targetIndex > #targetPlayers then targetIndex = 1 end
    end

    updatePlayerList()
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)

    local function getTarget()
        return targetPlayers[targetIndex]
    end

    local function updateHUD()
        local t = getTarget()
        if t then
            nameLabel.Text = t.Name
        else
            nameLabel.Text = "No player"
        end
    end

    local function switchPlayer(dir)
        if #targetPlayers == 0 then return end
        targetIndex += dir
        if targetIndex < 1 then targetIndex = #targetPlayers end
        if targetIndex > #targetPlayers then targetIndex = 1 end
        updateHUD()
    end

    btnPrev.MouseButton1Click:Connect(function() switchPlayer(-1) end)
    btnNext.MouseButton1Click:Connect(function() switchPlayer(1) end)

    -- ================= DRAG CAMERA =================
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            lastPos = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragging and enabled then
            local delta = input.Position - lastPos
            lastPos = input.Position
            yaw -= delta.X * 0.003
            pitch = math.clamp(pitch - delta.Y * 0.003, -0.6,0.6)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ================= UPDATE CAMERA =================
    RunService.RenderStepped:Connect(function()
        if not enabled then return end
        local t = getTarget()
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = t.Character.HumanoidRootPart
            local offset = CFrame.Angles(pitch, yaw,0) * CFrame.new(camOffset)
            cam.CFrame = CFrame.new(hrp.Position + offset.Position, hrp.Position)
        end
    end)

    -- ================= TOGGLE FOR HOME GUI =================
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(0,120,0,40)
    toggleFrame.Position = UDim2.new(0.5,-60,0,10)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
    toggleFrame.BackgroundTransparency = 0.3
    Instance.new("UICorner", toggleFrame)

    local toggleLabel = Instance.new("TextLabel", toggleFrame)
    toggleLabel.Size = UDim2.new(0.6,0,1,0)
    toggleLabel.Position = UDim2.new(0,10,0,0)
    toggleLabel.Text = "Spectator"
    toggleLabel.TextColor3 = Color3.new(1,1,1)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextScaled = true

    local toggleBtn = Instance.new("TextButton", toggleFrame)
    toggleBtn.Size = UDim2.new(0.35,0,0.6,0)
    toggleBtn.Position = UDim2.new(0.63,0,0.2,0)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
    Instance.new("UICorner", toggleBtn)

    local function setToggle(val)
        enabled = val
        hud.Visible = enabled
        if enabled then
            toggleBtn.Text = "ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(40,160,40)
            cam.CameraType = Enum.CameraType.Scriptable
        else
            toggleBtn.Text = "OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
            cam.CameraType = Enum.CameraType.Custom
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        setToggle(not enabled)
    end)

    -- RETURN API (Optional)
    return {
        Toggle = setToggle
    }
end
