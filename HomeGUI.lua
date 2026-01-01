return function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    repeat wait() until lp and lp:FindFirstChild("PlayerGui")
    local playerGui = lp.PlayerGui

    -- ===== MAIN GUI =====
    local gui = Instance.new("ScreenGui")
    gui.Name = "RiiHubGUI"
    gui.Parent = playerGui

    -- Frame, Sidebar, Panel
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,620,0,500)
    frame.Position = UDim2.new(0.5,-310,0.5,-250)
    frame.BackgroundColor3 = Color3.fromRGB(35,20,70)
    frame.BackgroundTransparency = 0.05
    Instance.new("UICorner", frame)

    local content = Instance.new("Frame", frame)
    content.Size = UDim2.new(1,0,1,-40)
    content.Position = UDim2.new(0,0,0,40)
    content.BackgroundTransparency = 1

    local sidebar = Instance.new("Frame", content)
    sidebar.Size = UDim2.new(0,160,1,0)
    sidebar.BackgroundColor3 = Color3.fromRGB(50,30,90)
    sidebar.BackgroundTransparency = 0.05
    Instance.new("UICorner", sidebar)

    local panelContainer = Instance.new("Frame", content)
    panelContainer.Position = UDim2.new(0,160,0,0)
    panelContainer.Size = UDim2.new(1,-160,1,0)
    panelContainer.BackgroundTransparency = 1

    local function loadFeature(featureFunc)
        for _,v in ipairs(panelContainer:GetChildren()) do v:Destroy() end
        pcall(function() featureFunc(panelContainer) end)
    end

    local function addButton(name, featureFunc)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1,-20,0,40)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(90,60,140)
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(function()
            loadFeature(featureFunc)
        end)
    end

    -- ===== LOAD FEATURES VIA RAW GITHUB =====
    local FEATURES = {
        ["Copy Ava"] = "PASTE_LINK_RAW_COPYAVA_HERE",
        -- ["Feature Lain"] = "PASTE_LINK_RAW_FITURLAIN_HERE"
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
