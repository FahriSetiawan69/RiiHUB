-- =====================================================
-- RII HUB - FEATURE COPY AVA FIXED
-- Modular version
-- parent = panelContainer dari Home GUI
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    local BATCH_SIZE = 4
    local COPY_COLORS = {
        Color3.fromRGB(120,80,255),
        Color3.fromRGB(160,100,255),
        Color3.fromRGB(200,120,255),
        Color3.fromRGB(180,150,255),
        Color3.fromRGB(220,180,255),
        Color3.fromRGB(255,200,255),
    }

    local PANEL_BG = Color3.fromRGB(60,40,100)
    local BTN_HOVER = Color3.fromRGB(80,50,150)
    local TEXT_COLOR = Color3.fromRGB(255,255,255)

    local function copyToClipboard(text)
        if setclipboard then
            setclipboard(text)
        end
    end

    local function getAssets(userId)
        local result = {}
        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(userId)
        end)
        if not ok or not info or not info.assets then
            return result
        end

        -- urut berdasarkan Tubuh > Pakaian > Aksesoris
        local assetOrder = {"Body", "Clothing", "Accessory"}
        local sorted = {}
        for _,category in ipairs(assetOrder) do
            for _,v in ipairs(info.assets) do
                if v.id and v.type == category then
                    table.insert(sorted, {id=v.id, name=v.name or "Unknown", type=category})
                end
            end
        end
        return sorted
    end

    -- ================= COPY PANEL =================
    local copyPanel = Instance.new("ScrollingFrame", parent)
    copyPanel.Size = UDim2.new(1,0,1,0)
    copyPanel.BackgroundColor3 = PANEL_BG
    copyPanel.BackgroundTransparency = 0.05
    copyPanel.ScrollBarThickness = 6
    Instance.new("UICorner", copyPanel)
    copyPanel.CanvasSize = UDim2.new(0,0,0,0)
    copyPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", copyPanel)
    layout.Padding = UDim.new(0,8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- ----- SEARCH BOX -----
    local searchBox = Instance.new("TextBox", copyPanel)
    searchBox.Size = UDim2.new(0.4,-20,0,30)
    searchBox.Position = UDim2.new(0,10,0,10)
    searchBox.PlaceholderText = "Search Player..."
    searchBox.TextColor3 = TEXT_COLOR
    searchBox.BackgroundColor3 = Color3.fromRGB(80,50,120)
    Instance.new("UICorner", searchBox)

    -- ----- PLAYER LIST -----
    local plist = Instance.new("ScrollingFrame", copyPanel)
    plist.Position = UDim2.new(0,10,0,45)
    plist.Size = UDim2.new(0.4,-15,1,-55)
    plist.ScrollBarThickness = 6
    plist.BackgroundTransparency = 1

    local plLayout = Instance.new("UIListLayout", plist)
    plLayout.Padding = UDim.new(0,6)
    plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        plist.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ----- ASSET PANEL -----
    local assetPanel = Instance.new("ScrollingFrame", copyPanel)
    assetPanel.Position = UDim2.new(0.4,10,0,10)
    assetPanel.Size = UDim2.new(0.6,-20,1,-20)
    assetPanel.ScrollBarThickness = 6
    assetPanel.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetPanel)
    asLayout.Padding = UDim.new(0,6)
    asLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetPanel.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ----- NOTIF -----
    local notif = Instance.new("TextLabel", copyPanel)
    notif.Size = UDim2.new(0,200,0,32)
    notif.Position = UDim2.new(0.5,-100,1,-38)
    notif.BackgroundColor3 = Color3.fromRGB(90,200,150)
    notif.TextColor3 = TEXT_COLOR
    notif.TextScaled = true
    notif.Visible = false
    Instance.new("UICorner", notif)

    local function showNotif(text)
        notif.Text = text
        notif.Visible = true
        task.delay(1.2, function()
            if notif then notif.Visible = false end
        end)
    end

    -- ================= DATA =================
    local CURRENT_ASSETS = {}
    local BUTTON_STATES = {}
    local AVATAR_IMAGE = nil

    local function rebuildAssetButtons()
        for _,c in ipairs(assetPanel:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("TextLabel") or c:IsA("ImageLabel") then
                c:Destroy()
            end
        end
        BUTTON_STATES = {}

        -- ----- AVATAR -----
        if AVATAR_IMAGE then AVATAR_IMAGE:Destroy() end
        local avatarId = "rbxthumb://type=AvatarHeadShot&id="..CURRENT_ASSETS.UserId.."&w=150&h=150"
        AVATAR_IMAGE = Instance.new("ImageLabel", assetPanel)
        AVATAR_IMAGE.Size = UDim2.new(0,150,0,150)
        AVATAR_IMAGE.Position = UDim2.new(0.5,-75,0,0)
        AVATAR_IMAGE.BackgroundTransparency = 1
        AVATAR_IMAGE.Image = avatarId

        -- ----- ASSET BUTTONS -----
        local total = #CURRENT_ASSETS.Assets
        if total == 0 then return end

        local batchCount = math.ceil(total / BATCH_SIZE)
        for i = 1, batchCount do
            local s = (i-1)*BATCH_SIZE + 1
            local e = math.min(i*BATCH_SIZE, total)

            -- display asset names
            for x = s, e do
                local asset = CURRENT_ASSETS.Assets[x]
                local lbl = Instance.new("TextLabel", assetPanel)
                lbl.Size = UDim2.new(1,-10,0,30)
                lbl.BackgroundTransparency = 0.3
                lbl.BackgroundColor3 = Color3.fromRGB(90,60,140)
                lbl.TextColor3 = TEXT_COLOR
                lbl.Text = asset.type.." "..asset.name.." ["..asset.id.."]"
                lbl.TextScaled = true
                Instance.new("UICorner", lbl)
            end

            -- copy button per batch
            local btn = Instance.new("TextButton", assetPanel)
            btn.Size = UDim2.new(1,0,0,36)
            btn.Text = "COPY "..i.." ("..s.." - "..e..")"
            btn.BackgroundColor3 = COPY_COLORS[1]
            btn.TextColor3 = TEXT_COLOR
            btn.TextScaled = true
            Instance.new("UICorner", btn)

            BUTTON_STATES[btn] = 1
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = BTN_HOVER end)
            btn.MouseLeave:Connect(function() 
                local idx = BUTTON_STATES[btn] 
                btn.BackgroundColor3 = COPY_COLORS[idx]
            end)

            btn.MouseButton1Click:Connect(function()
                local text = "hat"
                for x = s, e do
                    text ..= " " .. CURRENT_ASSETS.Assets[x].id
                end
                copyToClipboard(text)
                showNotif("COPIED "..s.." - "..e)

                local idx = BUTTON_STATES[btn] + 1
                if idx > #COPY_COLORS then idx = 1 end
                btn.BackgroundColor3 = COPY_COLORS[idx]
                BUTTON_STATES[btn] = idx
            end)
        end
    end

    -- ----- BUILD PLAYER LIST -----
    local function rebuildPlayerList()
        for _,c in ipairs(plist:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end

        local sortedPlayers = {}
        for _,p in ipairs(Players:GetPlayers()) do
            table.insert(sortedPlayers, p)
        end
        table.sort(sortedPlayers, function(a,b) return a.Name:lower() < b.Name:lower() end)

        for _,plr in ipairs(sortedPlayers) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,36)
            b.Text = plr.Name
            b.BackgroundColor3 = Color3.fromRGB(90,60,140)
            b.TextColor3 = TEXT_COLOR
            Instance.new("UICorner", b)

            b.MouseEnter:Connect(function() b.BackgroundColor3 = BTN_HOVER end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(90,60,140) end)

            b.MouseButton1Click:Connect(function()
                local assets = getAssets(plr.UserId)
                CURRENT_ASSETS = {Assets=assets, UserId=plr.UserId}
                rebuildAssetButtons()
            end)
        end
    end

    -- ----- SEARCH -----
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        for _,b in ipairs(plist:GetChildren()) do
            if b:IsA("TextButton") then
                b.Visible = b.Text:lower():find(query) ~= nil
            end
        end
    end)

    -- ================= INITIALIZE =================
    rebuildPlayerList()
    Players.PlayerAdded:Connect(rebuildPlayerList)
    Players.PlayerRemoving:Connect(rebuildPlayerList)
end
