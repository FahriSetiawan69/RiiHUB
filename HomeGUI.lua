-- =====================================================
-- RII HUB - HOME GUI MODULAR MULTI-FEATURE (Delta Ready)
-- =====================================================

return function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- Debug: Pastikan LocalPlayer ada
    if not lp then
        warn("LocalPlayer belum siap! Jalankan sebagai LocalScript / executor lokal.")
        return
    end

    local playerGui = lp:WaitForChild("PlayerGui")

    -- ================= SETTINGS =================
    local THEME_BG = Color3.fromRGB(35,20,70)
    local SIDEBAR_BG = Color3.fromRGB(50,30,90)
    local BTN_HOVER = Color3.fromRGB(80,50,150)
    local TEXT_COLOR = Color3.fromRGB(255,255,255)

    -- ================= MAIN GUI =================
    local gui = Instance.new("ScreenGui")
    gui.Name = "RiiHubGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,620,0,500)
    frame.Position = UDim2.new(0.5,-310,0.5,-250)
    frame.BackgroundColor3 = THEME_BG
    frame.BackgroundTransparency = 0.05
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame)

    local originalSize = frame.Size

    -- ================= TITLE =================
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,-80,0,40)
    title.Position = UDim2.new(0,10,0,0)
    title.Text = "Rii HUB"
    title.TextColor3 = TEXT_COLOR
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true

    -- ================= CLOSE =================
    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0,40,0,40)
    close.Position = UDim2.new(1,-40,0,0)
    close.Text = "X"
    close.BackgroundColor3 = Color3.fromRGB(180,50,90)
    close.TextColor3 = TEXT_COLOR
    Instance.new("UICorner", close)
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- ================= MINIMIZE =================
    local minimize = Instance.new("TextButton", frame)
    minimize.Size = UDim2.new(0,28,0,28)
    minimize.Position = UDim2.new(1,-70,0,6)
    minimize.Text = "–"
    minimize.BackgroundColor3 = Color3.fromRGB(100,70,180)
    minimize.TextColor3 = TEXT_COLOR
    minimize.TextScaled = true
    Instance.new("UICorner", minimize).CornerRadius = UDim.new(0.5,0)

    local isMinimized = false

    -- ================= CONTENT =================
    local content = Instance.new("Frame", frame)
    content.Position = UDim2.new(0,0,0,40)
    content.Size = UDim2.new(1,0,1,-40)
    content.BackgroundTransparency = 1

    minimize.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        content.Visible = not isMinimized
        frame.Size = isMinimized and UDim2.new(0,200,0,40) or originalSize
    end)

    -- ================= SIDEBAR =================
    local sidebar = Instance.new("Frame", content)
    sidebar.Size = UDim2.new(0,160,1,0)
    sidebar.BackgroundColor3 = SIDEBAR_BG
    sidebar.BackgroundTransparency = 0.05
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
        pcall(function() featureFunc(panelContainer) end)
    end

    local function addButton(name, func)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1,-20,0,40)
        btn.Text = name
        btn.TextColor3 = TEXT_COLOR
        btn.BackgroundColor3 = Color3.fromRGB(90,60,140)
        Instance.new("UICorner", btn)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = BTN_HOVER end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(90,60,140) end)
        btn.MouseButton1Click:Connect(function()
            loadFeature(func)
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
            warn("Gagal load fitur:", name, url)
        end
    end

end
