-- =====================================================
-- RII HUB - COPY AVATAR (FIXED MODULAR)
-- =====================================================

return function(parent)
    -- ===== SERVICES =====
    local Players = game:GetService("Players")
    local AvatarEditorService = game:GetService("AvatarEditorService")

    -- ===== CLEAN PARENT (PENTING) =====
    for _,v in ipairs(parent:GetChildren()) do
        v:Destroy()
    end

    -- ===== CONFIG =====
    local BATCH_SIZE = 4
    local TEXT_COLOR = Color3.fromRGB(255,255,255)
    local BG = Color3.fromRGB(55,35,95)
    local BTN = Color3.fromRGB(120,80,255)
    local BTN_HOVER = Color3.fromRGB(160,110,255)

    -- ===== ROOT =====
    local root = Instance.new("Frame", parent)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundColor3 = BG
    Instance.new("UICorner", root)

    -- ===== PLAYER LIST =====
    local playerList = Instance.new("ScrollingFrame", root)
    playerList.Size = UDim2.new(0.28, -10, 1, -20)
    playerList.Position = UDim2.new(0,10,0,10)
    playerList.CanvasSize = UDim2.zero
    playerList.ScrollBarThickness = 6
    playerList.BackgroundTransparency = 1

    local plLayout = Instance.new("UIListLayout", playerList)
    plLayout.Padding = UDim.new(0,6)
    plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        playerList.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ===== RIGHT PANEL =====
    local right = Instance.new("Frame", root)
    right.Position = UDim2.new(0.28,10,0,10)
    right.Size = UDim2.new(0.72,-20,1,-20)
    right.BackgroundTransparency = 1

    -- ===== AVATAR PREVIEW (CENTER) =====
    local viewport = Instance.new("ViewportFrame", right)
    viewport.Size = UDim2.new(0,220,0,260)
    viewport.Position = UDim2.new(0.5,-110,0,10)
    viewport.BackgroundTransparency = 1

    local cam = Instance.new("Camera", viewport)
    viewport.CurrentCamera = cam

    -- ===== ASSET LIST =====
    local assetList = Instance.new("ScrollingFrame", right)
    assetList.Position = UDim2.new(0,20,0,290)
    assetList.Size = UDim2.new(1,-40,1,-310)
    assetList.ScrollBarThickness = 6
    assetList.BackgroundTransparency = 1

    local asLayout = Instance.new("UIListLayout", assetList)
    asLayout.Padding = UDim.new(0,6)
    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ===== UTIL =====
    local function copy(text)
        if setclipboard then
            setclipboard(text)
        end
    end

    -- ===== GET ASSETS (ORDERED) =====
    local function getAssets(userId)
        local ordered = {
            Body = {},
            Clothing = {},
            Accessory = {}
        }

        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(userId)
        end)
        if not ok or not info or not info.assets then
            return {}
        end

        for _,a in ipairs(info.assets) do
            if a.assetType and a.id then
                if a.assetType:find("Body") then
                    table.insert(ordered.Body, a)
                elseif a.assetType:find("Shirt") or a.assetType:find("Pants") then
                    table.insert(ordered.Clothing, a)
                else
                    table.insert(ordered.Accessory, a)
                end
            end
        end

        local final = {}
        for _,grp in ipairs({ordered.Body, ordered.Clothing, ordered.Accessory}) do
            for _,v in ipairs(grp) do
                table.insert(final, v)
            end
        end

        return final
    end

    -- ===== BUILD ASSET UI =====
    local function showAssets(player)
        -- clear
        for _,v in ipairs(assetList:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end

        -- avatar preview
        viewport:ClearAllChildren()
        cam = Instance.new("Camera", viewport)
        viewport.CurrentCamera = cam

        local clone = Players:CreateHumanoidModelFromUserId(player.UserId)
        clone.Parent = viewport
        clone:SetPrimaryPartCFrame(CFrame.new(0,0,0))
        cam.CFrame = CFrame.new(0,1.5,5, 0,1,0)

        -- assets
        local assets = getAssets(player.UserId)
        if #assets == 0 then return end

        local batch = {}
        local function flushBatch(startIndex)
            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0, (#batch * 22) + 44)
            box.BackgroundTransparency = 1

            local y = 0
            for _,a in ipairs(batch) do
                local t = Instance.new("TextLabel", box)
                t.Position = UDim2.new(0,0,0,y)
                t.Size = UDim2.new(1,0,0,20)
                t.TextXAlignment = Left
                t.Text = a.name.." ("..a.id..")"
                t.TextColor3 = TEXT_COLOR
                t.BackgroundTransparency = 1
                y += 22
            end

            local btn = Instance.new("TextButton", box)
            btn.Position = UDim2.new(0,0,0,y+4)
            btn.Size = UDim2.new(0.4,0,0,32)
            btn.Text = "COPY"
            btn.BackgroundColor3 = BTN
            btn.TextColor3 = TEXT_COLOR
            Instance.new("UICorner", btn)

            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = BTN_HOVER
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = BTN
            end)

            btn.MouseButton1Click:Connect(function()
                local text = ""
                for _,a in ipairs(batch) do
                    text ..= a.id .. "\n"
                end
                copy(text)
            end)
        end

        for i,a in ipairs(assets) do
            table.insert(batch, a)
            if #batch == BATCH_SIZE then
                flushBatch(i - (#batch - 1))
                batch = {}
            end
        end
        if #batch > 0 then
            flushBatch(#assets - (#batch - 1))
        end
    end

    -- ===== BUILD PLAYER LIST =====
    local function buildPlayers()
        for _,v in ipairs(playerList:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end

        local list = Players:GetPlayers()
        table.sort(list, function(a,b)
            return a.Name:lower() < b.Name:lower()
        end)

        for _,p in ipairs(list) do
            local b = Instance.new("TextButton", playerList)
            b.Size = UDim2.new(1,0,0,36)
            b.Text = p.Name
            b.TextColor3 = TEXT_COLOR
            b.BackgroundColor3 = Color3.fromRGB(85,55,135)
            Instance.new("UICorner", b)

            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = BTN_HOVER
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(85,55,135)
            end)

            b.MouseButton1Click:Connect(function()
                showAssets(p)
            end)
        end
    end

    -- ===== INIT =====
    buildPlayers()
    Players.PlayerAdded:Connect(buildPlayers)
    Players.PlayerRemoving:Connect(buildPlayers)
end
