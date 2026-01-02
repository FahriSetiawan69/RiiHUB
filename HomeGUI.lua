-- =====================================================
-- RIIHUB - HOME GUI (RED THEME + FLOATING BUTTON)
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

    -- ================= FLOATING BUTTON =================
    local floatBtn = Instance.new("TextButton", gui)
    floatBtn.Size = UDim2.new(0,60,0,60)
    floatBtn.Position = UDim2.new(0,20,0.5,-30)
    floatBtn.Text = "R"
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 24
    floatBtn.TextColor3 = Color3.new(1,1,1)
    floatBtn.BackgroundColor3 = Color3.fromRGB(170,40,40)
    floatBtn.Visible = false
    floatBtn.Active = true
    floatBtn.Draggable = true
    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)

    -- ================= MAIN FRAME =================
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,620,0,500)
    frame.Position = UDim2.new(0.5,-310,0.5,-250)
    frame.BackgroundColor3 = Color3.fromRGB(120,20,20)
    frame.BackgroundTransparency = 0.12
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame)

    local originalSize = frame.Size
    local originalPos = frame.Position

    -- ================= TOP BAR =================
    local top = Instance.new("Frame", frame)
    top.Size = UDim2.new(1,0,0,36)
    top.BackgroundColor3 = Color3.fromRGB(0,0,0)
    top.BackgroundTransparency = 0.1

    -- ================= TITLE =================
    local title = Instance.new("TextLabel", top)
    title.Size = UDim2.new(1,-120,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.Text = "RiiHUB"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Left
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1

    -- ================= CLOSE =================
    local close = Instance.new("TextButton", top)
    close.Size = UDim2.new(0,36,0,36)
    close.Position = UDim2.new(1,-36,0,0)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 18
    close.TextColor3 = Color3.new(1,1,1)
    close.BackgroundColor3 = Color3.fromRGB(150,30,30)

    -- ================= MINIMIZE =================
    local minimize = Instance.new("TextButton", top)
    minimize.Size = UDim2.new(0,36,0,36)
    minimize.Position = UDim2.new(1,-72,0,0)
    minimize.Text = "–"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 22
    minimize.TextColor3 = Color3.new(1,1,1)
    minimize.BackgroundColor3 = Color3.fromRGB(110,30,30)

    -- ================= CONTENT =================
    local content = Instance.new("Frame", frame)
    content.Position = UDim2.new(0,0,0,36)
    content.Size = UDim2.new(1,0,1,-36)
    content.BackgroundTransparency = 1

    -- ================= SIDEBAR =================
    local sidebar = Instance.new("Frame", content)
    sidebar.Size = UDim2.new(0,160,1,0)
    sidebar.BackgroundColor3 = Color3.fromRGB(140,30,30)
    sidebar.BackgroundTransparency = 0.15
    Instance.new("UICorner", sidebar)

    local list = Instance.new("UIListLayout", sidebar)
    list.Padding = UDim.new(0,8)
    list.HorizontalAlignment = Center

    -- ================= PANEL =================
    local panelContainer = Instance.new("Frame", content)
    panelContainer.Position = UDim2.new(0,160,0,0)
    panelContainer.Size = UDim2.new(1,-160,1,0)
    panelContainer.BackgroundTransparency = 1

    -- ================= FEATURE LOADER =================
    local function loadFeature(func)
        for _,v in ipairs(panelContainer:GetChildren()) do
            v:Destroy()
        end
        task.spawn(func, panelContainer)
    end

    local function addButton(name, func)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1,-20,0,38)
        btn.Text = name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(160,40,40)
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            loadFeature(func)
        end)
    end

    -- ================= FEATURES =================
    local FEATURES = {
        ["Copy Ava"] = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/CopyAva.lua"
    }

    for name,url in pairs(FEATURES) do
        local ok,func = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok and type(func) == "function" then
            addButton(name, func)
        end
    end

    -- ================= ANIMATION =================
    local function tween(obj, goal, t)
        TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal):Play()
    end

    minimize.MouseButton1Click:Connect(function()
        tween(frame, {Size = UDim2.new(0,0,0,0)}, 0.25)
        task.wait(0.25)
        frame.Visible = false
        floatBtn.Visible = true
    end)

    floatBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        tween(frame, {Size = originalSize, Position = originalPos}, 0.3)
        floatBtn.Visible = false
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
end
