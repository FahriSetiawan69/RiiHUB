-- =========================================
-- COPY AVATAR VIEWER (HOME GUI MODULAR)
-- =========================================

return function(parent)
	local Players = game:GetService("Players")

	-- ROOT
	local main = Instance.new("Frame", parent)
	main.Size = UDim2.new(1,0,1,0)
	main.BackgroundColor3 = Color3.fromRGB(45,30,80)
	Instance.new("UICorner", main)

	-- LEFT: PLAYER LIST
	local playerList = Instance.new("ScrollingFrame", main)
	playerList.Position = UDim2.new(0,10,0,10)
	playerList.Size = UDim2.new(0.28,-10,1,-20)
	playerList.ScrollBarThickness = 6
	playerList.BackgroundTransparency = 1

	local plLayout = Instance.new("UIListLayout", playerList)
	plLayout.Padding = UDim.new(0,6)

	-- RIGHT: ASSET LIST
	local assetList = Instance.new("ScrollingFrame", main)
	assetList.Position = UDim2.new(0.28,10,0,10)
	assetList.Size = UDim2.new(0.72,-20,1,-20)
	assetList.ScrollBarThickness = 6
	assetList.BackgroundTransparency = 1

	local asLayout = Instance.new("UIListLayout", assetList)
	asLayout.Padding = UDim.new(0,10)

	plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		playerList.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y + 10)
	end)

	asLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		assetList.CanvasSize = UDim2.new(0,0,0,asLayout.AbsoluteContentSize.Y + 10)
	end)

	local function clearAssets()
		for _,v in ipairs(assetList:GetChildren()) do
			if not v:IsA("UIListLayout") then
				v:Destroy()
			end
		end
	end

	local function copy(text)
		if setclipboard then
			setclipboard(text)
		end
	end

	-- ================= SORT CONFIG =================
	local CATEGORY_PRIORITY = {
		Tubuh = 1,
		Pakaian = 2,
		Aksesoris = 3,
		Animasi = 4,
		Other = 5,
	}

	local TYPE_CATEGORY = {
		[17] = "Tubuh",[18] = "Tubuh",[27] = "Tubuh",[28] = "Tubuh",
		[29] = "Tubuh",[30] = "Tubuh",[31] = "Tubuh",

		[11] = "Pakaian",[12] = "Pakaian",[2] = "Pakaian",

		[8] = "Aksesoris",[41] = "Aksesoris",[42] = "Aksesoris",
		[43] = "Aksesoris",[44] = "Aksesoris",[45] = "Aksesoris",
		[46] = "Aksesoris",[47] = "Aksesoris",

		[24] = "Animasi",[48] = "Animasi",[50] = "Animasi",
		[51] = "Animasi",[52] = "Animasi",[53] = "Animasi",[54] = "Animasi",
	}

	-- ================= SHOW ASSETS =================
	local function showAssets(player)
		clearAssets()

		-- Avatar 2D
		local thumb = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.AvatarBust,
			Enum.ThumbnailSize.Size180x180
		)

		local avatar = Instance.new("ImageLabel", assetList)
		avatar.Size = UDim2.new(0,160,0,160)
		avatar.Position = UDim2.new(0.5,-80,0,0)
		avatar.Image = thumb
		avatar.BackgroundColor3 = Color3.fromRGB(70,50,120)
		avatar.ScaleType = Enum.ScaleType.Fit
		Instance.new("UICorner", avatar)

		local ok, info = pcall(function()
			return Players:GetCharacterAppearanceInfoAsync(player.UserId)
		end)
		if not ok or not info or not info.assets then return end

		table.sort(info.assets, function(a,b)
			local ca = CATEGORY_PRIORITY[TYPE_CATEGORY[a.assetTypeId] or "Other"]
			local cb = CATEGORY_PRIORITY[TYPE_CATEGORY[b.assetTypeId] or "Other"]
			if ca == cb then
				return a.name < b.name
			end
			return ca < cb
		end)

		local batch = {}

		local function flush()
			if #batch == 0 then return end

			local box = Instance.new("Frame", assetList)
			box.Size = UDim2.new(1,0,0,#batch*26 + 36)
			box.BackgroundTransparency = 1

			local y = 0
			for _,a in ipairs(batch) do
				local label = Instance.new("TextLabel", box)
				label.Size = UDim2.new(1,0,0,24)
				label.Position = UDim2.new(0,0,0,y)
				label.BackgroundColor3 = Color3.fromRGB(70,50,120)
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Text = a.name.." ["..a.id.."]"
				label.TextColor3 = Color3.new(1,1,1)
				label.TextSize = 13
				label.Font = Enum.Font.Gotham
				Instance.new("UICorner", label)
				y += 26
			end

			local btn = Instance.new("TextButton", box)
			btn.Size = UDim2.new(0,140,0,28)
			btn.Position = UDim2.new(0,0,0,y + 4)
			btn.Text = "COPY"
			btn.BackgroundColor3 = Color3.fromRGB(110,80,200)
			btn.TextColor3 = Color3.new(1,1,1)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 13
			Instance.new("UICorner", btn)

			btn.MouseButton1Click:Connect(function()
				local txt = "hat"
				for _,a in ipairs(batch) do
					txt ..= " "..a.id
				end
				copy(txt)
			end)

			batch = {}
		end

		for _,asset in ipairs(info.assets) do
			table.insert(batch, asset)
			if #batch == 4 then flush() end
		end
		flush()
	end

	-- ================= PLAYER LIST =================
	local function buildPlayers()
		for _,v in ipairs(playerList:GetChildren()) do
			if not v:IsA("UIListLayout") then
				v:Destroy()
			end
		end

		local players = Players:GetPlayers()
		table.sort(players, function(a,b)
			return a.Name:lower() < b.Name:lower()
		end)

		for _,plr in ipairs(players) do
			local btn = Instance.new("TextButton", playerList)
			btn.Size = UDim2.new(1,0,0,32)
			btn.Text = plr.Name
			btn.BackgroundColor3 = Color3.fromRGB(90,65,150)
			btn.TextColor3 = Color3.new(1,1,1)
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
