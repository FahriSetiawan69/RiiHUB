-- =====================================================
-- RII HUB - COPY AVATAR (FINAL STABLE)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")

    -- ===== CLEAN SAFE =====
    local old = parent:FindFirstChild("CopyAvaRoot")
    if old then old:Destroy() end

    -- ===== ROOT =====
    local root = Instance.new("Frame")
    root.Name = "CopyAvaRoot"
    root.Parent = parent
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundColor3 = Color3.fromRGB(55,35,95)
    Instance.new("UICorner", root)

    local TEXT = Color3.new(1,1,1)
    local BTN = Color3.fromRGB(130,90,255)
    local BTN_H = Color3.fromRGB(170,130,255)

    -- ===== PLAYER LIST =====
    local plist = Instance.new("ScrollingFrame", root)
    plist.Position = UDim2.new(0,10,0,10)
    plist.Size = UDim2.new(0.28,-10,1,-20)
    plist.ScrollBarThickness = 6
    plist.BackgroundTransparency = 1

    local plLayout = Instance.new("UIListLayout", plist)
    plLayout.Padding = UDim.new(0,6)
    plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        plist.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ===== RIGHT PANEL =====
    local right = Instance.new("Frame", root)
    right.Position = UDim2.new(0.28,10,0,10)
    right.Size = UDim2.new(0.72,-20,1,-20)
    right.BackgroundTransparency = 1

    -- ===== AVATAR PREVIEW (CENTERED) =====
    local viewport = Instance.new("ViewportFrame", right)
    viewport.Size = UDim2.new(0,220,0,260)
    viewport.Position = UDim2.new(0.5,-110,0,0)
    viewport.BackgroundTransparency = 1

    local cam = Instance.new("Camera")
    cam.Parent = viewport
    viewport.CurrentCamera = cam

    -- ===== ASSET LIST =====
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,20,0,270)
    assetList.Size = UDim2.new(1,-40,1,-290)
    assetList.ScrollBarThickness = 6
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,10)
    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ===== CLIPBOARD =====
    local function copy(text)
        if setclipboard then setclipboard(text) end
    end

    -- ===== BUILD PLAYER VIEW =====
    local function showPlayer(plr)
        assetList:ClearAllChildren()
        viewport:ClearAllChildren()

        cam = Instance.new("Camera", viewport)
        viewport.CurrentCamera = cam

        -- === AVATAR ===
        local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(plr.UserId)
        local dummy = Instance.new("Model", viewport)
        local hum = Instance.new("Humanoid", dummy)

        hum:ApplyDescription(humanoidDescription)

        local rootPart = dummy:FindFirstChild("HumanoidRootPart")
        if rootPart then
            dummy.PrimaryPart = rootPart
            dummy:SetPrimaryPartCFrame(CFrame.new())
        end

        cam.CFrame = CFrame.new(0,1.5,6)

        -- === ASSETS ===
        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(plr.UserId)
        end)
        if not ok or not info or not info.assets then return end

        local batch = {}

        local function flush()
            if #batch == 0 then return end

            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0,#batch*22+40)
            box.BackgroundTransparency = 1

            local y = 0
            for _,a in ipairs(batch) do
                local t = Instance.new("TextLabel", box)
                t.Size = UDim2.new(1,0,0,20)
                t.Position = UDim2.new(0,0,0,y)
                t.TextXAlignment = Left
                t.Text = a.name.." ["..a.id.."]"
                t.TextColor3 = TEXT
                t.BackgroundTransparency = 1
                y += 22
            end

            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(0.35,0,0,30)
            btn.Position = UDim2.new(0,0,0,y+6)
            btn.Text = "COPY"
            btn.BackgroundColor3 = BTN
            btn.TextColor3 = TEXT
            Instance.new("UICorner", btn)

            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = BTN_H end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = BTN end)

            btn.MouseButton1Click:Connect(function()
                local txt = "hat"
                for _,a in ipairs(batch) do
                    txt ..= " "..a.id
                end
                copy(txt)
            end)

            batch = {}
        end

        for _,a in ipairs(info.assets) do
            table.insert(batch, a)
            if #batch == 4 then flush() end
        end
        flush()
    end

    -- ===== PLAYER LIST BUILD =====
    local function buildPlayers()
        plist:ClearAllChildren()

        local layout = Instance.new("UIListLayout", plist)
        layout.Padding = UDim.new(0,6)

        for _,p in ipairs(Players:GetPlayers()) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,36)
            b.Text = p.Name
            b.TextColor3 = TEXT
            b.BackgroundColor3 = Color3.fromRGB(90,60,150)
            Instance.new("UICorner", b)

            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = BTN_H
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(90,60,150)
            end)

            b.MouseButton1Click:Connect(function()
                showPlayer(p)
            end)
        end
    end

    -- ===== INIT =====
    buildPlayers()
    Players.PlayerAdded:Connect(buildPlayers)
    Players.PlayerRemoving:Connect(buildPlayers)
end
