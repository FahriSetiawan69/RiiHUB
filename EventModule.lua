-- =========================================
-- EventModule.lua (FINAL FIX)
-- Christmas Gift Event Helper
-- =========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = nil
local Root = nil

local EventModule = {}
EventModule.Enabled = false

-- ===============================
-- INTERNAL STATE
-- ===============================
local gifts = {}
local tree = nil
local highlights = {}
local connections = {}

-- ===============================
-- UTILS
-- ===============================
local function clearHighlights()
	for _,h in pairs(highlights) do
		if h and h.Parent then
			h:Destroy()
		end
	end
	highlights = {}
end

local function disconnectAll()
	for _,c in pairs(connections) do
		pcall(function() c:Disconnect() end)
	end
	connections = {}
end

local function updateCharacter()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Root = Character:WaitForChild("HumanoidRootPart")
end

-- ===============================
-- SCAN MAP (GAME MAP ONLY)
-- ===============================
local function scanMap()
	gifts = {}
	tree = nil

	local workspace = game:GetService("Workspace")

	for _,obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") then
			if obj.Name:lower():find("gift") then
				table.insert(gifts, obj)
			elseif obj.Name:lower():find("tree") then
				tree = obj
			end
		end
	end

	print("[EVENT] Scan result | Gifts:", #gifts, "| Tree:", tree ~= nil)
end

-- ===============================
-- HIGHLIGHT GIFTS
-- ===============================
local function highlightGifts()
	clearHighlights()

	for _,gift in ipairs(gifts) do
		local h = Instance.new("Highlight")
		h.FillColor = Color3.fromRGB(0, 255, 0)
		h.OutlineColor = Color3.fromRGB(0, 180, 0)
		h.FillTransparency = 0.75
		h.Parent = gift
		table.insert(highlights, h)
	end
end

-- ===============================
-- TELEPORT LOGIC
-- ===============================
function EventModule.TeleportToNearestGift()
	if not Root then return end
	if #gifts == 0 then return end

	local nearest, dist = nil, math.huge
	for _,gift in ipairs(gifts) do
		if gift.PrimaryPart then
			local d = (gift.PrimaryPart.Position - Root.Position).Magnitude
			if d < dist then
				dist = d
				nearest = gift
			end
		end
	end

	if nearest and nearest.PrimaryPart then
		Root.CFrame = nearest.PrimaryPart.CFrame * CFrame.new(0, 0, -3)
	end
end

function EventModule.TeleportToTree()
	if not Root or not tree or not tree.PrimaryPart then return end
	Root.CFrame = tree.PrimaryPart.CFrame * CFrame.new(0, 0, -3)
end

-- ===============================
-- FLOATING BUTTONS
-- ===============================
local function createFloatingButtons()
	local gui = LocalPlayer.PlayerGui:WaitForChild("RiiHUB_GUI")

	local giftBtn = Instance.new("TextButton", gui)
	giftBtn.Name = "EventGiftBtn"
	giftBtn.Size = UDim2.fromOffset(110, 44)
	giftBtn.Position = UDim2.fromScale(0.75, 0.75)
	giftBtn.Text = "Gift"
	giftBtn.Font = Enum.Font.GothamBold
	giftBtn.TextSize = 16
	giftBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
	giftBtn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", giftBtn).CornerRadius = UDim.new(0,12)

	local treeBtn = Instance.new("TextButton", gui)
	treeBtn.Name = "EventTreeBtn"
	treeBtn.Size = UDim2.fromOffset(110, 44)
	treeBtn.Position = UDim2.fromScale(0.75, 0.83)
	treeBtn.Text = "Tree"
	treeBtn.Font = Enum.Font.GothamBold
	treeBtn.TextSize = 16
	treeBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 0)
	treeBtn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", treeBtn).CornerRadius = UDim.new(0,12)

	giftBtn.MouseButton1Click:Connect(EventModule.TeleportToNearestGift)
	treeBtn.MouseButton1Click:Connect(EventModule.TeleportToTree)

	table.insert(connections, giftBtn.Destroying:Connect(function() end))
	table.insert(connections, treeBtn.Destroying:Connect(function() end))
end

local function removeFloatingButtons()
	local gui = LocalPlayer.PlayerGui:FindFirstChild("RiiHUB_GUI")
	if not gui then return end

	for _,n in ipairs({"EventGiftBtn","EventTreeBtn"}) do
		local b = gui:FindFirstChild(n)
		if b then b:Destroy() end
	end
end

-- ===============================
-- ENABLE / DISABLE
-- ===============================
function EventModule.Enable(state)
	if state == EventModule.Enabled then return end
	EventModule.Enabled = state

	if state then
		updateCharacter()
		scanMap()
		highlightGifts()
		createFloatingButtons()

		connections[#connections+1] =
			LocalPlayer.CharacterAdded:Connect(function()
				updateCharacter()
			end)

		print("[EVENT] Enabled")
	else
		clearHighlights()
		removeFloatingButtons()
		disconnectAll()
		print("[EVENT] Disabled")
	end
end

-- ===============================
-- GLOBAL ENTRY POINT (INI KUNCINYA)
-- ===============================
_G.ToggleEvent = function(state)
	EventModule.Enable(state)
end

_G.TeleportNearestGift = function()
	EventModule.TeleportToNearestGift()
end

_G.TeleportTree = function()
	EventModule.TeleportToTree()
end

return EventModule
