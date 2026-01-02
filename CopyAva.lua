-- =====================================================
-- RII HUB - COPY AVATAR (FINAL MODULAR)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")
    local ThumbnailService = game:GetService("ThumbnailService")

    parent:ClearAllChildren()

    -- ================= COLORS =================
    local BG = Color3.fromRGB(55,35,95)
    local TEXT = Color3.new(1,1,1)

    local COPY_COLORS = {
        Color3.fromRGB(130,90,255),
        Color3.fromRGB(90,170,255),
        Color3.fromRGB(120,220,170),
        Color3.fromRGB(255,180,90),
        Color3.fromRGB(255,120,180),
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

    -- ================= AVATAR =================
    local avatar = Instance.new("ImageLabel", right)
    avatar.Size = UDim2.new(0,180,0,180)
    avatar.Position = UDim2.new(0.5,-90,0,0)
    avatar.BackgroundTransparency = 1

    -- ================= ASSET LIST =================
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,10,0,190)
    assetList.Size = UDim2.new(1,-20,1,-200)
    assetList.ScrollBarThickness = 6
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,10)
    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    local function copy(txt)
        if setclipboard then setclipboard(txt) end
    end

    -- ================= SORT ASSETS =================
    local function sortAssets(info)
        local body, clothing, accessory, animation = {},{},{},{}

        for _,a in ipairs(info.assets) do
            local t = string.lower(a.assetType.name)
            if t:find("body") or t:find("head") or t:find("face") then
                table.insert(body,a)
            elseif t:find("shirt") or t:find("pants") then
                table.insert(clothing,a)
            elseif t:find("animation") then
                table.insert(animation,a)
            else
                table.insert(accessory,a)
            end
        end

        local result = {}
        for _,g in ipairs({body, clothing, accessory, animation}) do
            for _,v in ipairs(g) do
                table.insert(result,v)
            end
        end
        return result
    end

    -- ================= SHOW PLAYER =================
    local function showPlayer(plr)
        assetList:ClearAllChildren()
        avatar.Image = ""

        local thumb = ThumbnailService:GetUserThumbnailAsync(
            plr.UserId,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailSize.Size420x420
        )
        avatar.Image = thumb

        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(plr.UserId)
        end)
        if not ok or not info then return end

        local assets = sortAssets(info)
        local batch = {}
        local colorIndex = 1

        local function flush()
            if #batch == 0 then return end

            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0,#batch*24 + 40)
            box.BackgroundTransparency = 1

            local y = 0
            for _,a in ipairs(batch) do
                local t = Instance.new("TextLabel", box)
                t.Size = UDim2.new(1,0,0,22)
                t.Position = UDim2.new(0,0,0,y)
                t.TextXAlignment = Enum.TextXAlignment.Left
                t.Text = a.name.." ["..a.id.."]"
                t.TextColor3 = TEXT
                t.BackgroundTransparency = 1
                t.Font = Enum.Font.Gotham
                t.TextSize = 13
                y += 24
            end

            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,y+4)
            btn.Text = "COPY"
            btn.BackgroundColor3 = COPY_COLORS[colorIndex]
            btn.TextColor3 = TEXT
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                local txt = "hat"
                for _,a in ipairs(batch) do
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

        for _,a in ipairs(assets) do
            table.insert(batch,a)
            if #batch == 4 then
                flush()
            end
        end
        flush()
    end

    -- ================= BUILD PLAYER LIST =================
    local function buildPlayers()
        plist:ClearAllChildren()
        Instance.new("UIListLayout", plist).Padding = UDim.new(0,6)

        local players = Players:GetPlayers()
        table.sort(players, function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)

        for _,p in ipairs(players) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,34)
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

    buildPlayers()
    Players.PlayerAdded:Connect(buildPlayers)
    Players.PlayerRemoving:Connect(buildPlayers)
end
