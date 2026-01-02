-- =====================================================
-- RII HUB - HOME GUI MODULAR (Spectator Compatible)
-- =====================================================

return function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- Tunggu PlayerGui siap
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
    frame.BackgroundColor3 = Color3.fromRGB(55,35,95) -- Theme ungu
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
    title.TextColor3 = Color3.new(1,1,1)
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
    close.TextColor3 = Color3.new(1,1,1)
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
    minimize.TextColor3 = Color3.new(1,1,1)
    minimize.TextScaled = true
    Instance.new("UICorner", minimize).CornerRadius = UDim.new(0.5,0)
    local isMinimized = false

    local content = Instance.new("Frame", frame)
    content.Position = UDim2.new(0,0,0,40)
    content.Size = UDim2.new(1,0,1,-40)
    content.BackgroundTransparency = 1

    minimize.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        content.Visible = not isMinimized
        frame:TweenSize(isMinimized and UDim2.new(0,200,0,40) or originalSize, "Out", "Quad", 0.3, true)
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

    -- ================= PANEL CONTAINER =================
    local panelContainer = Instance.new("Frame", content)
    panelContainer.Position = UDim2.new(0,160,0,0)
    panelContainer.Size = UDim2.new(1,-160,1,0)
    panelContainer.BackgroundTransparency = 1

    -- ================= FEATURE LOADER =================
    local function loadFeature(featureFunc)
        -- Bersihkan panel dulu
        for _,v in ipairs(panelContainer:GetChildren()) do v:Destroy() end

        local success, result = pcall(function()
            return featureFunc(panelContainer)
        end)

        if success and type(result) == "table" and result.Toggle then
            -- Buat toggle otomatis
            local toggleBtn = Instance.new("TextButton", panelContainer)
            toggleBtn.Size = UDim2.new(0,120,0,35)
            toggleBtn.Position = UDim2.new(0,10,0,10)
            toggleBtn.Text = "OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(180,60,80)
            toggleBtn.TextColor3 = Color3.new(1,1,1)
            toggleBtn.Font = Enum.Font.GothamBold
            toggleBtn.TextSize = 14
            Instance.new("UICorner", toggleBtn)

            local isOn = false
            toggleBtn.MouseButton1Click:Connect(function()
                isOn = not isOn
                toggleBtn.Text = isOn and "ON" or "OFF"
                toggleBtn.BackgroundColor3 = isOn and Color3.fromRGB(60,180,90) or Color3.fromRGB(180,60,80)
                result.Toggle(isOn)
            end)
        end
    end

    local function addButton(name, featureFunc)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1,-20,0,40)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(90,60,140)
        btn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", btn)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(80,50,150) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(90,60,140) end)
        btn.MouseButton1Click:Connect(function()
            loadFeature(featureFunc)
        end)
    end

    -- ================= FEATURES =================
    local FEATURES = {
        ["Copy Ava"] = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/CopyAva.lua",
        ["Spectator"] = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/Spectator.lua"
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
