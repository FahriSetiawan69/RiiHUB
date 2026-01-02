-- =====================================================
-- RII HUB - HOME GUI (RED THEME + ANIMATION)
-- =====================================================

return function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local lp = Players.LocalPlayer

    repeat task.wait() until lp and lp:FindFirstChild("PlayerGui")
    local playerGui = lp.PlayerGui

    -- ================= MAIN GUI =================
    local gui = Instance.new("ScreenGui")
    gui.Name = "RiiHubGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,620,0,500)
    frame.Position = UDim2.new(0.5,-310,0.5,-250)
    frame.BackgroundColor3 = Color3.fromRGB(120,20,25) -- merah gelap
    frame.BackgroundTransparency = 0.12
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame)

    local originalSize = frame.Size
    local originalPos = frame.Position

    -- ================= TOP BAR =================
    local topBar = Instance.new("Frame", frame)
    topBar.Size = UDim2.new(1,0,0,36)
    topBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
    topBar.BackgroundTransparency = 0.15
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,10)

    -- ================= TITLE =================
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1,-120,1,0)
    title.Position = UDim2.new(0,12,0,0)
    title.Text = "RiiHUB"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16

    -- ================= CLOSE =================
    local close = Instance.new("TextButton", topBar)
    close.Size = UDim2.new(0,36,0,24)
    close.Position = UDim2.new(1,-40,0,6)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.BackgroundColor3 = Color3.fromRGB(170,40,40)
    close.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", close)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- ================= MINIMIZE =================
    local minimize = Instance.new("TextButton", topBar)
    minimize.Size = UDim2.new(0,28,0,24)
    minimize.Position = UDim2.new(1,-76,0,6)
    minimize.Text = "–"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 18
    minimize.BackgroundColor3 = Color3.fromRGB(90,20,20)
    minimize.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", minimize)

    -- ================= CONTENT =================
    local content = Instance.new("Frame", frame)
    content.Position = UDim2.new(0,0,0,36)
    content.Size = UDim2.new(1,0,1,-36)
    content.BackgroundTransparency = 1

    -- ================= ANIMATION =================
    local isMinimized = false
    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    minimize.MouseButton1Click:Connect(function()
        if not isMinimized then
            isMinimized = true
            content.Visible = false

            TweenService:Create(frame, tweenInfo, {
                Size = UDim2.new(0,220,0,36),
                Position = UDim2.new(
                    frame.Position.X.Scale,
                    frame.Position.X.Offset,
                    frame.Position.Y.Scale,
                    frame.Position.Y.Offset
                )
            }):Play()
        else
            isMinimized = false
            content.Visible = true

            TweenService:Create(frame, tweenInfo, {
                Size = originalSize,
                Position = originalPos
            }):Play()
        end
    end)

    -- ================= SIDEBAR =================
    local sidebar = Instance.new("Frame", content)
    sidebar.Size = UDim2.new(0,160,1,0)
    sidebar.BackgroundColor3 = Color3.fromRGB(140,30,35)
    sidebar.BackgroundTransparency = 0.1
    Instance.new("UICorner", sidebar)

    local layout = Instance.new("UIListLayout", sidebar)
    layout.Padding = UDim.new(0,8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- ================= PANEL =================
    local panelContainer = Instance.new("Frame", content)
    panelContainer.Position = UDim2.new(0,160,0,0)
    panelContainer.Size = UDim2.new(1,-160,1,0)
    panelContainer.BackgroundTransparency = 1

    -- ================= FEATURE LOADER =================
    local function loadFeature(featureFunc)
        for _,v in ipairs(panelContainer:GetChildren()) do
            v:Destroy()
        end
        pcall(function()
            featureFunc(panelContainer)
        end)
    end

    local function addButton(name, featureFunc)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1,-20,0,40)
        btn.Text = name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(160,40,45)
        Instance.new("UICorner", btn)

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(190,50,55)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(160,40,45)
        end)

        btn.MouseButton1Click:Connect(function()
            loadFeature(featureFunc)
        end)
    end

    -- ================= FEATURES =================
    local FEATURES = {
        ["Copy Ava"] = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/CopyAva.lua"
    }

    for name, url in pairs(FEATURES) do
        local ok, featureFunc = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok and type(featureFunc) == "function" then
            addButton(name, featureFunc)
        else
            warn("Gagal load fitur:", name)
        end
    end
end
