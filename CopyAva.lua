-- =====================================================
-- RII HUB - COPY AVATAR (STABLE MODULAR FIX)
-- =====================================================

return function(parent)
    local Players = game:GetService("Players")

    -- ===== SAFE CLEAR =====
    local old = parent:FindFirstChild("CopyAvaRoot")
    if old then old:Destroy() end

    -- ===== ROOT =====
    local root = Instance.new("Frame")
    root.Name = "CopyAvaRoot"
    root.Parent = parent
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundColor3 = Color3.fromRGB(55,35,95)
    Instance.new("UICorner", root)

    local TEXT = Color3.new(1,1,1)
    local BTN = Color3.fromRGB(120,80,255)
    local BTN_H = Color3.fromRGB(160,120,255)

    -- ===== PLAYER LIST =====
    local plist = Instance.new("ScrollingFrame", root)
    plist.Position = UDim2.new(0,10,0,10)
    plist.Size = UDim2.new(0.3,-15,1,-20)
    plist.ScrollBarThickness = 6
    plist.BackgroundTransparency = 1

    local plLayout = Instance.new("UIListLayout", plist)
    plLayout.Padding = UDim.new(0,6)
    plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        plist.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ===== RIGHT PANEL =====
    local right = Instance.new("Frame", root)
    right.Position = UDim2.new(0.3,10,0,10)
    right.Size = UDim2.new(0.7,-20,1,-20)
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
    asLayout.Padding = UDim.new(0,8)
    asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ===== UTIL =====
    local function copy(txt)
        if setclipboard then setclipboard(txt) end
    end

    -- ===== GET PLAYER ASSETS ONLY =====
    local function getAssets(userId)
        local ok, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(userId)
        end)
        if not ok or not info or not info.assets then return {} end

        local body, cloth, acc = {}, {}, {}

        for _,a in ipairs(info.assets) do
            if not a.id then continue end
            if a.assetType:find("Body") then
                table.insert(body, a)
            elseif a.assetType:find("Shirt") or a.assetType:find("Pants") then
                table.insert(cloth, a)
            else
                table.insert(acc, a)
            end
        end

        local final = {}
        for _,t in ipairs({body, cloth, acc}) do
            for _,v in ipairs(t) do
                table.insert(final, v)
            end
        end
        return final
    end

    -- ===== SHOW PLAYER DATA =====
    local function showPlayer(plr)
        assetList:ClearAllChildren()

        viewport:ClearAllChildren()
        cam = Instance.new("Camera", viewport)
        viewport.CurrentCamera = cam

        local model = Players:CreateHumanoidModelFromUserId(plr.UserId)
        model.Parent = viewport
        model:SetPrimaryPartCFrame(CFrame.new())
        cam.CFrame = CFrame.new(0,1.5,6)

        local assets = getAssets(plr.UserId)
        local batch = {}

        local function flush()
            if #batch == 0 then return end

            local box = Instance.new("Frame", assetList)
            box.Size = UDim2.new(1,0,0,#batch*22+36)
            box.BackgroundTransparency = 1

            local y = 0
            for _,a in ipairs(batch) do
                local t = Instance.new("TextLabel", box)
                t.Size = UDim2.new(1,0,0,20)
                t.Position = UDim2.new(0,0,0,y)
                t.TextXAlignment = Left
                t.Text = a.name.." ["..a.id.."]"
                t.TextColor3 = TEXT
                t.BackgroundTransparency = 1
                y += 22
            end

            local btn = Instance.new("TextButton", box)
            btn.Size = UDim2.new(0.4,0,0,30)
            btn.Position = UDim2.new(0,0,0,y+4)
            btn.Text = "COPY"
            btn.BackgroundColor3 = BTN
            btn.TextColor3 = TEXT
            Instance.new("UICorner", btn)

            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = BTN_H end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = BTN end)

            btn.MouseButton1Click:Connect(function()
                local text = "hat"
                for _,a in ipairs(batch) do
                    text ..= " "..a.id
                end
                copy(text)
            end)

            batch = {}
        end

        for _,a in ipairs(assets) do
            table.insert(batch, a)
            if #batch == 4 then flush() end
        end
        flush()
    end

    -- ===== BUILD PLAYER LIST =====
    local function buildPlayers()
        plist:ClearAllChildren()

        local layout = Instance.new("UIListLayout", plist)
        layout.Padding = UDim.new(0,6)

        for _,p in ipairs(Players:GetPlayers()) do
            local b = Instance.new("TextButton", plist)
            b.Size = UDim2.new(1,0,0,36)
            b.Text = p.Name
            b.TextColor3 = TEXT
            b.BackgroundColor3 = Color3.fromRGB(85,55,135)
            Instance.new("UICorner", b)

            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = BTN_H
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(85,55,135)
            end)

            b.MouseButton1Click:Connect(function()
                showPlayer(p)
            end)
        end
    end

    -- ===== INIT =====
    buildPlayers()
    Players.PlayerAdded:Connect(buildPlayers)
    Players.PlayerRemoving:Connect(buildPlayers)
end
