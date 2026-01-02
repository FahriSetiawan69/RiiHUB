-- =====================================================
-- RII HUB - COPY AVATAR (MODULAR FINAL)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")

    parent:ClearAllChildren()

    -- ================= THEME =================
    local BG = Color3.fromRGB(55,35,95)
    local BTN_COLORS = {
        Color3.fromRGB(120,80,255),
        Color3.fromRGB(150,100,255),
        Color3.fromRGB(180,120,255),
        Color3.fromRGB(210,150,255),
        Color3.fromRGB(240,180,255),
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

    -- ================= AVATAR (2D) =================
    local avatar = Instance.new("ImageLabel", right)
    avatar.Size = UDim2.new(0,180,0,180)
    avatar.Position = UDim2.new(0.5,-90,0,0)
    avatar.BackgroundTransparency = 1

    -- ================= ASSET LIST =================
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,20,0,190)
    assetList.Size = UDim2.new(1,-40,1,-200)
    assetList.ScrollBarThickness = 6
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,10)

    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ================= HELPERS =================
    local function copy(text)
        if setclipboard then
            setclipboard(text)
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
    local function sortAssets(assets)
        local body, clothing, accessory, animation = {}, {}, {}, {}

        for _,a in ipairs(assets) do
            local t = string.lower(a.assetType.name)
            if t:find("body") or t:find("head") then
                table.insert(body, a)
            elseif t:find("shirt") or t:find("pant") then
                table.insert(clothing, a)
            elseif t:find("animation") then
                table.insert(animation, a)
            else
                table.insert(accessory, a)
            end
        end

        local result = {}
        for _,g in ipairs({body, clothing, accessory, animation}) do
            for _,v in ipairs(g) do
                table.insert(result, v)
            end
        end
        return result
    end

    -- ================= SHOW PLAYER =================
    local function showAssets(plr)
        clearAssets()

        avatar.Image =
            "https://www.roblox.com/headshot-thumbnail/image?userId="
            ..plr.UserId.."&width=420&height=420&format=png"

        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(plr.UserId)
        end)
        if not ok or not info or not info.assets then return end

        local assets = sortAssets(info.assets)
        local batch = {}
        local colorIndex = 1

        local function flush()
            if #batch == 0 then return end

            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0,#batch*26 + 38)
            box.BackgroundTransparency = 1

            local y = 0
            for _,a in ipairs(batch) do
                local label = Instance.new("TextLabel", box)
                label.Size = UDim2.new(1,0,0,24)
                label.Position = UDim2.new(0,0,0,y)
                label.BackgroundTransparency = 1
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = a.name.." ["..a.id.."]"
                label.TextColor3 = TEXT
                label.Font = Enum.Font.Gotham
                label.TextSize = 13
                y += 26
            end

            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(0,140,0,28)
            btn.Position = UDim2.new(0,0,0,y)
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

        for _,a in ipairs(assets) do
            table.insert(batch, a)
            if #batch == 4 then flush() end
        end
        flush()
    end

    -- ================= PLAYER LIST =================
    local function rebuild()
        plist:ClearAllChildren()
        Instance.new("UIListLayout", plist).Padding = UDim.new(0,6)

        local players = Players:GetPlayers()
        table.sort(players, function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)

        for _,p in ipairs(players) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,32)
            b.Text = p.Name
            b.TextColor3 = TEXT
            b.BackgroundColor3 = Color3.fromRGB(90,60,150)
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            Instance.new("UICorner", b)

            b.MouseButton1Click:Connect(function()
                showAssets(p)
            end)
        end
    end

    rebuild()
    Players.PlayerAdded:Connect(rebuild)
    Players.PlayerRemoving:Connect(rebuild)
end
