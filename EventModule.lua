-- =========================================
-- EventModule.lua (AUTO TELEPORT PICKUP)
-- =========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local EventModule = {}
EventModule.Enabled = false

local Character, Root
local gifts = {}
local treeModel = nil
local highlights = {}
local connections = {}

-- ===============================
-- UTILS
-- ===============================
local function disconnectAll()
	for _,c in pairs(connections) do
		pcall(function() c:Disconnect() end)
	end
	connections = {}
end

local function clearHighlights()
	for _,h in pairs(highlights) do
		if h then h:Destroy() end
	end
	highlights = {}
end

local function updateCharacter()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Root = Character:WaitForChild("HumanoidRootPart")
end

local function getTeleportPart(model)
	if not model then return nil end
	if model.PrimaryPart then return model.PrimaryPart end
	for _,v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			return v
		end
	end
end

-- ===============================
-- SCAN MAP
-- ===============================
local function scanMap()
	gifts = {}
	treeModel = nil

	for _,obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") then
			local n = obj.Name:lower()
			if n:find("gift") then
				table.insert(gifts, obj)
			elseif n:find("tree") or n:find("christmas") then
				treeModel = obj
			end
		end
	end

	print("[EVENT] Scan | Gifts:", #gifts, "| Tree:", treeModel and treeModel.Name)
end

-- ===============================
-- HIGHLIGHT
-- ===============================
local function highlightGifts()
	clearHighlights()
	for _,gift in ipairs(gifts) do
		local h = Instance.new("Highlight")
		h.FillColor = Color3.fromRGB(0,255,0)
		h.OutlineColor = Color3.fromRGB(0,180,0)
		h.FillTransparency = 0.75
		h.Parent = gift
		table.insert(highlights, h)
	end
end

-- ===============================
-- TELEPORT
-- ===============================
function EventModule.TeleportToNearestGift()
	if not Root or #gifts == 0 then return end

	local nearest, dist = nil, math.huge
	for _,gift in ipairs(gifts) do
		local part = getTeleportPart(gift)
		if part then
			local d = (part.Position - Root.Position).Magnitude
			if d < dist then
				dist = d
				nearest = part
			end
		end
	end

	if nearest then
		Root.CFrame = nearest.CFrame * CFrame.new(0, 0, -3)
	end
end

function EventModule.TeleportToTree()
	if not Root or not treeModel then return end
	local part = getTeleportPart(treeModel)
	if part then
		Root.CFrame = part.CFrame * CFrame.new(0, 0, -4)
	end
end

-- ===============================
-- FLOATING BUTTONS
-- ===============================
local function createFloatingButtons()
	local gui = LocalPlayer.PlayerGui:WaitForChild("RiiHUB_GUI")

	local function makeBtn(name, text, pos, color)
		local b = Instance.new("TextButton", gui)
		b.Name = name
		b.Size = UDim2.fromOffset(120, 46)
		b.Position = pos
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 16
		b.TextColor3 = Color3.new(1,1,1)
		b.BackgroundColor3 = color
		b.Active = true
		b.Draggable = true
		b.ZIndex = 9999
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
		return b
	end

	local giftBtn = makeBtn(
		"EventGiftBtn",
		"Gift",
		UDim2.fromScale(0.72, 0.72),
		Color3.fromRGB(0,180,120)
	)

	local treeBtn = makeBtn(
		"EventTreeBtn",
		"Tree",
		UDim2.fromScale(0.72, 0.80),
		Color3.fromRGB(180,120,0)
	)

	giftBtn.MouseButton1Click:Connect(EventModule.TeleportToNearestGift)
	treeBtn.MouseButton1Click:Connect(EventModule.TeleportToTree)
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
-- AUTO TELEPORT ON PICKUP (INTI)
-- ===============================
local function setupAutoTeleport()
	if not Character then return end

	connections[#connections+1] =
		Character.ChildAdded:Connect(function(obj)
			if not EventModule.Enabled then return end

			if obj:IsA("Tool") then
				local name = obj.Name:lower()
				if name:find("gift") or name:find("present") then
					task.wait(0.15) -- pastikan pickup selesai
					print("[EVENT] Gift picked up → auto teleport to tree")
					EventModule.TeleportToTree()
				end
			end
		end)
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
		setupAutoTeleport()

		connections[#connections+1] =
			LocalPlayer.CharacterAdded:Connect(function()
				updateCharacter()
				setupAutoTeleport()
			end)

		print("[EVENT] Enabled (auto teleport ON)")
	else
		clearHighlights()
		removeFloatingButtons()
		disconnectAll()
		print("[EVENT] Disabled")
	end
end

-- ===============================
-- GLOBAL ENTRY
-- ===============================
_G.ToggleEvent = function(state)
	EventModule.Enable(state)
end

_G.TeleportNearestGift = EventModule.TeleportToNearestGift
_G.TeleportTree = EventModule.TeleportToTree

return EventModule
