-- =====================================================
-- RII HUB - FEATURE COPY AVA
-- Modular version
-- parent = panelContainer dari Home GUI
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local HttpService = game:GetService("HttpService")

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

    -- ----- COPY PANEL -----
    local copyPanel = Instance.new("Frame", parent)
    copyPanel.Size = UDim2.new(1,0,1,0)
    copyPanel.BackgroundColor3 = PANEL_BG
    copyPanel.BackgroundTransparency = 0.05
    copyPanel.Visible = true
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

    -- ----- THUMBNAIL -----
    local thumbImage = Instance.new("ImageLabel", assetPanel)
    thumbImage.Size = UDim2.new(0,100,0,100)
    thumbImage.Position = UDim2.new(0.5,-50,0,0)
    thumbImage.BackgroundTransparency = 1
    thumbImage.Image = ""

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

    -- ----- UTILS -----
    local function sortAssetsByCategory(assets)
        -- separate into Tubuh / Pakaian / Aksesoris
        local body, clothes, acc = {}, {}, {}
        for _,v in ipairs(assets) do
            if v.assetType == "Body" then
                table.insert(body, v)
            elseif v.assetType == "Clothing" then
                table.insert(clothes, v)
            else
                table.insert(acc, v)
            end
        end
        local sorted = {}
        for _,t in ipairs(body) do table.insert(sorted, t) end
        for _,t in ipairs(clothes) do table.insert(sorted, t) end
        for _,t in ipairs(acc) do table.insert(sorted, t) end
        return sorted
    end

    local function getAssets(userId)
        local result = {}
        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(userId)
        end)
        if not ok or not info or not info.assets then return result end
        for _,v in ipairs(info.assets) do
            if v.id then
                table.insert(result, {id = v.id, name = v.name or "Asset", assetType = v.assetType or "Accessory"})
            end
        end
        return sortAssetsByCategory(result)
    end

    local function rebuildAssetButtons()
        for _,c in ipairs(assetPanel:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        BUTTON_STATES = {}

        if #CURRENT_ASSETS == 0 then return end

        local batchCount = math.ceil(#CURRENT_ASSETS / BATCH_SIZE)
        local offsetY = 110
        for i = 1, batchCount do
            local s = (i-1)*BATCH_SIZE + 1
            local e = math.min(i*BATCH_SIZE, #CURRENT_ASSETS)

            -- ----- SHOW ASSET NAMES -----
            for j = s, e do
                local lbl = Instance.new("TextLabel", assetPanel)
                lbl.Size = UDim2.new(1,0,0,24)
                lbl.Position = UDim2.new(0,0,0,offsetY)
                lbl.Text = CURRENT_ASSETS[j].name.." ["..CURRENT_ASSETS[j].id.."]"
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = TEXT_COLOR
                lbl.TextScaled = true
                offsetY = offsetY + 24
            end

            -- ----- COPY BUTTON -----
            local btn = Instance.new("TextButton", assetPanel)
            btn.Size = UDim2.new(1,0,0,36)
            btn.Position = UDim2.new(0,0,0,offsetY)
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
                    text ..= " " .. CURRENT_ASSETS[x].id
                end
                copyToClipboard(text)
                showNotif("COPIED "..s.." - "..e)

                local idx = BUTTON_STATES[btn] + 1
                if idx > #COPY_COLORS then idx = 1 end
                btn.BackgroundColor3 = COPY_COLORS[idx]
                BUTTON_STATES[btn] = idx
            end)

            offsetY = offsetY + 36 + 6
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
                CURRENT_ASSETS = getAssets(plr.UserId)
                -- update thumbnail
                local thumbURL = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                thumbImage.Image = thumbURL
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
