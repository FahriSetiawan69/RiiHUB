-- =====================================================
-- RII HUB - COPY AVATAR (FINAL FIX)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")

    parent:ClearAllChildren()

    -- ================= COLORS =================
    local BG = Color3.fromRGB(55,35,95)
    local TEXT = Color3.new(1,1,1)

    local COPY_COLORS = {
        Color3.fromRGB(120,80,255),
        Color3.fromRGB(160,120,255),
        Color3.fromRGB(200,150,255),
        Color3.fromRGB(180,100,220),
        Color3.fromRGB(220,180,255)
    }

    -- ================= ROOT =================
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

    -- ================= AVATAR (2D) =================
    local avatar = Instance.new("ImageLabel", right)
    avatar.Size = UDim2.new(0,160,0,160)
    avatar.Position = UDim2.new(0.5,-80,0,0)
    avatar.BackgroundTransparency = 1

    -- ================= ASSET LIST =================
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,10,0,170)
    assetList.Size = UDim2.new(1,-20,1,-180)
    assetList.ScrollBarThickness = 6
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,10)

    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    local function copy(text)
        if setclipboard then
            setclipboard(text)
        end
    end

    -- ================= SHOW ASSETS =================
    local function showAssets(plr)
        assetList:ClearAllChildren()

        avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="
            ..plr.UserId.."&width=420&height=420&format=png"

        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(plr.UserId)
        end)
        if not ok or not info or not info.assets then return end

        local batch = {}

        local function flush()
            if #batch == 0 then return end

            local copyIds = {}
            for _,a in ipairs(batch) do
                table.insert(copyIds, a.id)
            end

            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0,#batch*26 + 40)
            box.BackgroundTransparency = 1

            local y = 0
            for _,a in ipairs(batch) do
                local label = Instance.new("TextLabel", box)
                label.Size = UDim2.new(1,0,0,24)
                label.Position = UDim2.new(0,0,0,y)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = a.name.." ["..a.id.."]"
                label.TextColor3 = TEXT
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.TextSize = 13
                y += 26
            end

            local colorIndex = 1
            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(0,140,0,28)
            btn.Position = UDim2.new(0,0,0,y+4)
            btn.Text = "COPY"
            btn.BackgroundColor3 = COPY_COLORS[colorIndex]
            btn.TextColor3 = TEXT
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                local txt = "hat"
                for _,id in ipairs(copyIds) do
                    txt ..= " "..id
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

    -- ================= PLAYER LIST =================
    local function buildPlayers()
        plist:ClearAllChildren()
        Instance.new("UIListLayout", plist).Padding = UDim.new(0,6)

        local players = Players:GetPlayers()
        table.sort(players, function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)

        for _,plr in ipairs(players) do
            local btn = Instance.new("TextButton", plist)
            btn.Size = UDim2.new(1,0,0,32)
            btn.Text = plr.Name
            btn.TextColor3 = TEXT
            btn.BackgroundColor3 = Color3.fromRGB(90,60,150)
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
