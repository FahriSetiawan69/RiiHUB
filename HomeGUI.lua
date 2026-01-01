-- =====================================================
-- RII HUB - HOME GUI (Delta Mobile Ready)
-- =====================================================

return function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- Tunggu LocalPlayer & PlayerGui siap
    repeat wait() until lp and lp:FindFirstChild("PlayerGui")
    local playerGui = lp.PlayerGui

    -- ================= MAIN GUI =================
    local gui = Instance.new("ScreenGui")
    gui.Name = "RiiHubGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,620,0,500)
    frame.Position = UDim2.new(0.5,-310,0.5,-250)
    frame.BackgroundColor3 = Color3.fromRGB(35,20,70)
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
    title.TextColor3 = Color3.fromRGB(255,255,255)
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
    close.TextColor3 = Color3.fromRGB(255,255,255)
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
    minimize.TextColor3 = Color3.fromRGB(255,255,255)
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
    sidebar.BackgroundColor3 = Color3.fromRGB(50,30,90)
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
        for _,v in ipairs(panelContainer:GetChildren()) do v:Destroy() end
        pcall(function() featureFunc(panelContainer) end)
    end

    local function addButton(name, featureFunc)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1,-20,0,40)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(90,60,140)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        Instance.new("UICorner", btn)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(80,50,150) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(90,60,140) end)
        btn.MouseButton1Click:Connect(function()
            loadFeature(featureFunc)
        end)
    end

    -- ================= FEATURES =================
    local FEATURES = {
        ["Copy Ava"] = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/CopyAva.lua"
        -- Tambahkan fitur lain dengan URL raw disini
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
