-- =====================================================
-- RII HUB - COPY AVATAR (FIXED & STABLE)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")

    local BATCH = 4
    local TEXT = Color3.fromRGB(255,255,255)
    local BTN = Color3.fromRGB(120,80,255)
    local HOVER = Color3.fromRGB(160,120,255)

    local function copy(txt)
        if setclipboard then
            setclipboard(txt)
        end
    end

    -- ================= MAIN PANEL =================
    local panel = Instance.new("Frame", parent)
    panel.Size = UDim2.new(1,0,1,0)
    panel.BackgroundTransparency = 1

    -- PLAYER LIST
    local plist = Instance.new("ScrollingFrame", panel)
    plist.Size = UDim2.new(0.35,-10,1,-20)
    plist.Position = UDim2.new(0,10,0,10)
    plist.CanvasSize = UDim2.new(0,0,0,0)
    plist.ScrollBarThickness = 6
    plist.BackgroundTransparency = 1

    local plLayout = Instance.new("UIListLayout", plist)
    plLayout.Padding = UDim.new(0,6)

    plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        plist.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y + 10)
    end)

    -- RIGHT PANEL
    local right = Instance.new("ScrollingFrame", panel)
    right.Position = UDim2.new(0.35,10,0,10)
    right.Size = UDim2.new(0.65,-20,1,-20)
    right.ScrollBarThickness = 6
    right.BackgroundTransparency = 1

    local rLayout = Instance.new("UIListLayout", right)
    rLayout.Padding = UDim.new(0,8)

    rLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        right.CanvasSize = UDim2.new(0,0,0,rLayout.AbsoluteContentSize.Y + 20)
    end)

    -- ================= GET ASSETS =================
    local function getAssets(userId)
        local result = {}
        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(userId)
        end)
        if not ok or not info or not info.assets then
            return result
        end

        local body, cloth, acc = {}, {}, {}

        for _,v in ipairs(info.assets) do
            local id = v.id
            local name = v.name or "Unknown"
            local t = v.assetTypeId

            if table.find({27,28,29,30,31}, t) then
                table.insert(body, {id=id, name=name})
            elseif t == 11 or t == 12 then
                table.insert(cloth, {id=id, name=name})
            else
                table.insert(acc, {id=id, name=name})
            end
        end

        for _,v in ipairs(body) do table.insert(result,v) end
        for _,v in ipairs(cloth) do table.insert(result,v) end
        for _,v in ipairs(acc) do table.insert(result,v) end

        return result
    end

    -- ================= SHOW PLAYER =================
    local function showPlayer(plr)
        right:ClearAllChildren()
        rLayout.Parent = right

        -- AVATAR
        local avatar = Instance.new("ImageLabel", right)
        avatar.Size = UDim2.new(0,140,0,140)
        avatar.BackgroundTransparency = 1
        avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="
            ..plr.UserId.."&width=420&height=420&format=png"

        Instance.new("UICorner", avatar)

        local assets = getAssets(plr.UserId)

        -- LIST ASSET
        for _,v in ipairs(assets) do
            local lbl = Instance.new("TextLabel", right)
            lbl.Size = UDim2.new(1,-10,0,24)
            lbl.Text = v.name.." ["..v.id.."]"
            lbl.TextColor3 = TEXT
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Left
            lbl.Font = Enum.Font.Gotham
            lbl.TextScaled = true
        end

        -- COPY BUTTONS
        for i=1,#assets,BATCH do
            local btn = Instance.new("TextButton", right)
            btn.Size = UDim2.new(1,-10,0,36)
            btn.BackgroundColor3 = BTN
            btn.TextColor3 = TEXT
            btn.TextScaled = true

            local txt = "hat"
            for x=i,math.min(i+BATCH-1,#assets) do
                txt ..= " "..assets[x].id
            end

            btn.Text = "COPY "..math.ceil(i/BATCH)
            Instance.new("UICorner", btn)

            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = HOVER
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = BTN
            end)
            btn.MouseButton1Click:Connect(function()
                copy(txt)
            end)
        end
    end

    -- ================= BUILD PLAYER LIST =================
    local function rebuild()
        plist:ClearAllChildren()
        plLayout.Parent = plist

        local list = Players:GetPlayers()
        table.sort(list,function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)

        for _,plr in ipairs(list) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,36)
            b.Text = plr.Name
            b.TextColor3 = TEXT
            b.BackgroundColor3 = BTN
            Instance.new("UICorner", b)

            b.MouseButton1Click:Connect(function()
                showPlayer(plr)
            end)
        end
    end

    rebuild()
    Players.PlayerAdded:Connect(rebuild)
    Players.PlayerRemoving:Connect(rebuild)
end
