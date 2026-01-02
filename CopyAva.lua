-- =====================================================
-- RII HUB - COPY AVATAR (DELTA SAFE FIX)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")

    parent:ClearAllChildren()

    local BG = Color3.fromRGB(55,35,95)
    local BTN = Color3.fromRGB(130,90,255)
    local BTN_H = Color3.fromRGB(170,130,255)
    local TEXT = Color3.new(1,1,1)

    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundColor3 = BG
    Instance.new("UICorner", root)

    -- ================= PLAYER LIST =================
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

    -- ================= RIGHT PANEL =================
    local right = Instance.new("Frame", root)
    right.Position = UDim2.new(0.28,10,0,10)
    right.Size = UDim2.new(0.72,-20,1,-20)
    right.BackgroundTransparency = 1

    -- ================= VIEWPORT =================
    local viewport = Instance.new("ViewportFrame", right)
    viewport.Size = UDim2.new(0,260,0,320)
    viewport.Position = UDim2.new(0.5,-130,0,0)
    viewport.BackgroundTransparency = 1

    local cam = Instance.new("Camera")
    viewport.CurrentCamera = cam
    cam.Parent = viewport

    -- ================= ASSET LIST =================
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,20,0,340)
    assetList.Size = UDim2.new(1,-40,1,-360)
    assetList.ScrollBarThickness = 6
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,14)

    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 20)
    end)

    local function copy(txt)
        if setclipboard then setclipboard(txt) end
    end

    -- ================= SHOW PLAYER =================
    local function showPlayer(plr)
        viewport:ClearAllChildren()
        assetList:ClearAllChildren()

        cam = Instance.new("Camera")
        cam.Parent = viewport
        viewport.CurrentCamera = cam

        -- ===== LOAD AVATAR =====
        local model = Players:GetCharacterAppearanceAsync(plr.UserId)
        model.Parent = viewport

        -- auto center + scale
        local cf, size = model:GetBoundingBox()
        local maxSize = math.max(size.X, size.Y, size.Z)

        cam.CFrame = CFrame.new(
            cf.Position + Vector3.new(0, size.Y * 0.3, maxSize * 2.2),
            cf.Position
        )

        -- ===== LOAD ASSETS =====
        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(plr.UserId)
        end)
        if not ok or not info or not info.assets then return end

        local batch = {}

        local function flush()
            if #batch == 0 then return end

            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0,0)
            box.BackgroundTransparency = 1

            local y = 0

            for _,a in ipairs(batch) do
                local label = Instance.new("TextLabel", box)
                label.Size = UDim2.new(1,-10,0,20)
                label.Position = UDim2.new(0,0,0,y)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = a.name.." ["..a.id.."]"
                label.TextColor3 = TEXT
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.TextSize = 14

                y += 22
            end

            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(0.35,0,0,32)
            btn.Position = UDim2.new(0,0,0,y+6)
            btn.Text = "COPY"
            btn.BackgroundColor3 = BTN
            btn.TextColor3 = TEXT
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
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

            box.Size = UDim2.new(1,0,0,y + 46)
            batch = {}
        end

        for _,a in ipairs(info.assets) do
            table.insert(batch, a)
            if #batch == 4 then flush() end
        end
        flush()
    end

    -- ================= BUILD PLAYER LIST =================
    local function build()
        plist:ClearAllChildren()
        local layout = Instance.new("UIListLayout", plist)
        layout.Padding = UDim.new(0,6)

        for _,p in ipairs(Players:GetPlayers()) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,36)
            b.Text = p.Name
            b.TextColor3 = TEXT
            b.BackgroundColor3 = Color3.fromRGB(90,60,150)
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            Instance.new("UICorner", b)

            b.MouseButton1Click:Connect(function()
                showPlayer(p)
            end)
        end
    end

    build()
    Players.PlayerAdded:Connect(build)
    Players.PlayerRemoving:Connect(build)
end
