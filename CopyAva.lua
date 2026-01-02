-- =========================================
-- RII HUB - COPY AVATAR (MODULAR STABLE)
-- =========================================

return function(parent)
    local Players = game:GetService("Players")

    parent:ClearAllChildren()

    -- ================= THEME =================
    local BG = Color3.fromRGB(55,35,95)
    local BTN_COLORS = {
        Color3.fromRGB(120,80,255),
        Color3.fromRGB(90,160,255),
        Color3.fromRGB(120,200,150),
        Color3.fromRGB(255,180,90),
        Color3.fromRGB(255,120,150),
    }
    local TEXT = Color3.new(1,1,1)

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

    -- ================= AVATAR IMAGE =================
    local avatar = Instance.new("ImageLabel", right)
    avatar.Size = UDim2.new(0,160,0,160)
    avatar.Position = UDim2.new(0.5,-80,0,0)
    avatar.BackgroundTransparency = 1
    avatar.ScaleType = Enum.ScaleType.Fit

    -- ================= ASSET LIST =================
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,20,0,170)
    assetList.Size = UDim2.new(1,-40,1,-190)
    assetList.ScrollBarThickness = 6
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,10)

    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ================= UTIL =================
    local function copy(txt)
        if setclipboard then
            setclipboard(txt)
        end
    end

    local function clearAssets()
        for _,v in ipairs(assetList:GetChildren()) do
            if not v:IsA("UIListLayout") then
                v:Destroy()
            end
        end
    end

    -- ================= SORT ASSET =================
    local ORDER = {
        BodyColors = 1,
        Shirt = 2,
        Pants = 2,
        Accessory = 3,
        Animation = 4,
    }

    local function getOrder(a)
        return ORDER[a.assetType] or 99
    end

    -- ================= SHOW PLAYER =================
    local function showPlayer(plr)
        clearAssets()

        avatar.Image =
            "https://www.roblox.com/headshot-thumbnail/image?userId="
            ..plr.UserId.."&width=420&height=420&format=png"

        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(plr.UserId)
        end)
        if not ok or not info or not info.assets then return end

        table.sort(info.assets, function(a,b)
            return getOrder(a) < getOrder(b)
        end)

        local batch = {}
        local colorIndex = 1

        local function flush()
            if #batch == 0 then return end

            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0,#batch*26 + 36)
            box.BackgroundTransparency = 1

            local y = 0
            for _,a in ipairs(batch) do
                local t = Instance.new("TextLabel", box)
                t.Size = UDim2.new(1,0,0,24)
                t.Position = UDim2.new(0,0,0,y)
                t.TextXAlignment = Enum.TextXAlignment.Left
                t.Text = a.name.." ["..a.id.."]"
                t.TextColor3 = TEXT
                t.TextSize = 13
                t.Font = Enum.Font.Gotham
                t.BackgroundTransparency = 1
                y += 26
            end

            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(0,140,0,28)
            btn.Position = UDim2.new(0,0,0,y+4)
            btn.Text = "COPY"
            btn.TextColor3 = TEXT
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.BackgroundColor3 = BTN_COLORS[colorIndex]
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                local txt = "hat"
                for _,a in ipairs(batch) do
                    txt ..= " "..a.id
                end
                copy(txt)

                colorIndex += 1
                if colorIndex > #BTN_COLORS then
                    colorIndex = 1
                end
                btn.BackgroundColor3 = BTN_COLORS[colorIndex]
            end)

            batch = {}
        end

        for _,a in ipairs(info.assets) do
            table.insert(batch, a)
            if #batch == 4 then
                flush()
            end
        end
        flush()
    end

    -- ================= PLAYER LIST =================
    local function buildPlayers()
        plist:ClearAllChildren()
        local layout = Instance.new("UIListLayout", plist)
        layout.Padding = UDim.new(0,6)

        local players = Players:GetPlayers()
        table.sort(players, function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)

        for _,plr in ipairs(players) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,32)
            b.Text = plr.Name
            b.TextColor3 = TEXT
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.BackgroundColor3 = Color3.fromRGB(90,60,150)
            Instance.new("UICorner", b)

            b.MouseButton1Click:Connect(function()
                showPlayer(plr)
            end)
        end
    end

    buildPlayers()
    Players.PlayerAdded:Connect(buildPlayers)
    Players.PlayerRemoving:Connect(buildPlayers)
end
