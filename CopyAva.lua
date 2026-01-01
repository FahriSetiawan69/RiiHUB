-- =====================================================
-- RII HUB - FEATURE COPY AVA (FIXED)
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
        if ok and info and info.assets then
            for _,v in ipairs(info.assets) do
                if v.id then
                    table.insert(result, {id = v.id, name = v.name or "Unknown", category = v.assetType or "Asset"})
                end
            end
        end
        return result
    end

    -- ================= COPY PANEL =================
    local copyPanel = Instance.new("ScrollingFrame", parent)
    copyPanel.Size = UDim2.new(1,0,1,0)
    copyPanel.BackgroundColor3 = PANEL_BG
    copyPanel.BackgroundTransparency = 0.05
    copyPanel.ScrollBarThickness = 6
    Instance.new("UICorner", copyPanel)

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
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        BUTTON_STATES = {}

        if AVATAR_IMAGE then AVATAR_IMAGE:Destroy() end
        -- tambahkan avatar di tengah atas
        AVATAR_IMAGE = Instance.new("ImageLabel", assetPanel)
        AVATAR_IMAGE.Size = UDim2.new(0,120,0,120)
        AVATAR_IMAGE.Position = UDim2.new(0.5,0,0,10)
        AVATAR_IMAGE.AnchorPoint = Vector2.new(0.5,0)
        AVATAR_IMAGE.BackgroundTransparency = 1
        AVATAR_IMAGE.Image = "rbxthumb://type=AvatarHeadShot&id="..CURRENT_ASSETS.playerId.."&w=420&h=420"
        Instance.new("UICorner", AVATAR_IMAGE)

        -- tambah jarak bawah avatar
        local currentY = 140

        local total = #CURRENT_ASSETS.assets
        if total == 0 then return end

        local batchCount = math.ceil(total / BATCH_SIZE)
        for i = 1, batchCount do
            local s = (i-1)*BATCH_SIZE + 1
            local e = math.min(i*BATCH_SIZE, total)

            -- buat label tiap asset
            for x = s, e do
                local info = CURRENT_ASSETS.assets[x]
                local lbl = Instance.new("TextLabel", assetPanel)
                lbl.Size = UDim2.new(1,0,0,24)
                lbl.Position = UDim2.new(0,0,0,currentY)
                lbl.Text = info.name.." ["..info.id.."]"
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = TEXT_COLOR
                lbl.TextScaled = false
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                currentY = currentY + 26
            end

            -- buat tombol copy batch
            local btn = Instance.new("TextButton", assetPanel)
            btn.Size = UDim2.new(1,0,0,36)
            btn.Position = UDim2.new(0,0,0,currentY)
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
                    text ..= " "..CURRENT_ASSETS.assets[x].id
                end
                copyToClipboard(text)
                showNotif("COPIED "..s.." - "..e)

                local idx = BUTTON_STATES[btn] + 1
                if idx > #COPY_COLORS then idx = 1 end
                btn.BackgroundColor3 = COPY_COLORS[idx]
                BUTTON_STATES[btn] = idx
            end)

            currentY = currentY + 46
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
                CURRENT_ASSETS = {playerId = plr.UserId, assets = assets}
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
