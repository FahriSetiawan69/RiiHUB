-- =========================================
-- COPY AVATAR FEATURE (TRANSPARENT FIX)
-- =========================================

return function(parent)
    local Players = game:GetService("Players")

    parent:ClearAllChildren()

    local COPY_COLORS = {
        Color3.fromRGB(255,80,80),
        Color3.fromRGB(255,140,80),
        Color3.fromRGB(255,200,80),
        Color3.fromRGB(255,120,160),
        Color3.fromRGB(200,80,255),
    }

    local function copy(txt)
        if setclipboard then
            setclipboard(txt)
        end
    end

    -- ROOT (TRANSPARENT, NO OVERLAY)
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1

    -- PLAYER LIST
    local plist = Instance.new("ScrollingFrame", root)
    plist.Position = UDim2.new(0,10,0,10)
    plist.Size = UDim2.new(0,200,1,-20)
    plist.ScrollBarThickness = 6
    plist.BackgroundTransparency = 1

    local plLayout = Instance.new("UIListLayout", plist)
    plLayout.Padding = UDim.new(0,6)

    plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        plist.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y + 10)
    end)

    -- RIGHT PANEL
    local right = Instance.new("Frame", root)
    right.Position = UDim2.new(0,220,0,10)
    right.Size = UDim2.new(1,-230,1,-20)
    right.BackgroundTransparency = 1

    -- AVATAR (2D)
    local avatar = Instance.new("ImageLabel", right)
    avatar.Size = UDim2.new(0,120,0,120)
    avatar.Position = UDim2.new(0.5,-60,0,0)
    avatar.BackgroundTransparency = 1
    avatar.ScaleType = Enum.ScaleType.Fit

    -- ASSET LIST
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,0,0,130)
    assetList.Size = UDim2.new(1,0,1,-130)
    assetList.ScrollBarThickness = 6
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,10)

    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    local function clearAssets()
        for _,v in ipairs(assetList:GetChildren()) do
            if not v:IsA("UIListLayout") then
                v:Destroy()
            end
        end
    end

    -- SHOW PLAYER ASSETS
    local function showAssets(player)
        clearAssets()

        avatar.Image =
            "rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=150&h=150"

        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(player.UserId)
        end)
        if not ok or not info or not info.assets then return end

        local batch = {}
        local colorIndex = 1

        local function flush()
            if #batch == 0 then return end
            local frozen = table.clone(batch)

            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0,#frozen*26 + 36)
            box.BackgroundTransparency = 1

            local y = 0
            for _,a in ipairs(frozen) do
                local label = Instance.new("TextLabel", box)
                label.Size = UDim2.new(1,0,0,24)
                label.Position = UDim2.new(0,0,0,y)
                label.BackgroundTransparency = 0.2
                label.BackgroundColor3 = Color3.fromRGB(0,0,0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = a.name.." ["..a.id.."]"
                label.TextColor3 = Color3.new(1,1,1)
                label.TextSize = 13
                label.Font = Enum.Font.Gotham
                Instance.new("UICorner", label)
                y += 26
            end

            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,y+4)
            btn.Text = "COPY"
            btn.TextColor3 = Color3.new(1,1,1)
            btn.BackgroundColor3 = COPY_COLORS[colorIndex]
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                local txt = "hat"
                for _,a in ipairs(frozen) do
                    txt ..= " "..a.id
                end
                copy(txt)

                colorIndex += 1
                if colorIndex > #COPY_COLORS then
                    colorIndex = 1
                end
                btn.BackgroundColor3 = COPY_COLORS[colorIndex]
            end)

            batch = {}
        end

        for _,asset in ipairs(info.assets) do
            table.insert(batch, asset)
            if #batch == 4 then
                flush()
            end
        end
        flush()
    end

    -- BUILD PLAYER LIST
    local function buildPlayers()
        for _,v in ipairs(plist:GetChildren()) do
            if not v:IsA("UIListLayout") then
                v:Destroy()
            end
        end

        local players = Players:GetPlayers()
        table.sort(players, function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)

        for _,plr in ipairs(players) do
            local btn = Instance.new("TextButton", plist)
            btn.Size = UDim2.new(1,0,0,32)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.BackgroundTransparency = 0.2
            btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                showAssets(plr)
            end)
        end
    end

    buildPlayers()
    Players.PlayerAdded:Connect(buildPlayers)
    Players.PlayerRemoving:Connect(buildPlayers)
end
