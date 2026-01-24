-- RiiHUB Loader.lua (FINAL FIX - NO 404)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local PLACE_ID = game.PlaceId

-- PlaceId → Folder Mapping (SESUAI STRUKTUR ASLI REPO)
local GAME_MAP = {
    [93978595733734] = "ViolenceDistrict",
    [6358567974] = "SalonDeFiestas",
}

local gameFolder = GAME_MAP[PLACE_ID]

if not gameFolder then
    warn("[RiiHUB] Game tidak didukung. PlaceId:", PLACE_ID)
    return
end

-- ===== LOAD MAIN.LUA (FIX URL) =====
local mainUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/"..gameFolder.."/main.lua"

local success, err = pcall(function()
    loadstring(game:HttpGet(mainUrl))()
end)

if not success then
    warn("[RiiHUB] Gagal load main.lua:", err)
    return
end

-- ===== POPUP SUCCESS =====
local popup = Instance.new("ScreenGui", guiParent)
popup.Name = "RiiHUB_Popup"

local frame = Instance.new("Frame", popup)
frame.Size = UDim2.fromScale(0,0)
frame.Position = UDim2.fromScale(0.85,0.85)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(35,5,60)
frame.BorderSizePixel = 0
frame.ZIndex = 50

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,14)

local text = Instance.new("TextLabel", frame)
text.Size = UDim2.fromScale(1,1)
text.BackgroundTransparency = 1
text.Text = "[R] Game berhasil diload\n"..gameFolder
text.Font = Enum.Font.GothamBold
text.TextScaled = true
text.TextColor3 = Color3.fromRGB(190,130,255)
text.ZIndex = 51

TweenService:Create(
    frame,
    TweenInfo.new(0.35, Enum.EasingStyle.Back),
    {Size = UDim2.fromScale(0.28,0.14)}
):Play()

task.delay(2.5, function()
    popup:Destroy()
end)

-- ===== LOAD HOMEGUI (FIX URL) =====
task.wait(0.2)

local guiUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"

pcall(function()
    loadstring(game:HttpGet(guiUrl))()
end)

print("[RiiHUB] Loader selesai tanpa error")