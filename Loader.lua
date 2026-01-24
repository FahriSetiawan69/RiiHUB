-- RiiHUB Loader.lua (FINAL)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local PLACE_ID = game.PlaceId

-- Mapping PlaceId → Folder Game
local GAME_MAP = {
    [93978595733734] = "ViolenceDistrict",
    [6358567974] = "SalonDeFiestas",
}

local gameFolder = GAME_MAP[PLACE_ID]

if not gameFolder then
    warn("[RiiHUB] Game tidak didukung. PlaceId:", PLACE_ID)
    return
end

-- Load MAIN
local mainUrl = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/Games/"..gameFolder.."/main.lua"
loadstring(game:HttpGet(mainUrl))()

-- === POPUP ===
local popup = Instance.new("ScreenGui", guiParent)
popup.Name = "RiiHUB_Popup"

local frame = Instance.new("Frame", popup)
frame.Size = UDim2.fromScale(0,0)
frame.Position = UDim2.fromScale(0.85,0.85)
frame.BackgroundColor3 = Color3.fromRGB(30,0,60)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundTransparency = 0.1
frame.ZIndex = 50
frame.UICorner = Instance.new("UICorner", frame)
frame.UICorner.CornerRadius = UDim.new(0,12)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.fromScale(1,1)
label.BackgroundTransparency = 1
label.Text = "[R] Game berhasil diload\n"..gameFolder
label.TextColor3 = Color3.fromRGB(180,120,255)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.ZIndex = 51

TweenService:Create(
    frame,
    TweenInfo.new(0.35, Enum.EasingStyle.Back),
    {Size = UDim2.fromScale(0.25,0.12)}
):Play()

task.delay(2.5, function()
    popup:Destroy()
end)

-- Load HomeGui
task.wait(0.2)
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/HomeGui.lua"
))()