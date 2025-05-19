-- HDHITBOX GUI Script for Fortblox

-- Ensure the script runs only in Fortblox
if game.PlaceId ~= 11242080327 then return end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HDHITBOX_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Startup Animation
local animFrame = Instance.new("Frame", screenGui)
animFrame.BackgroundColor3 = Color3.new(0, 0, 0)
animFrame.Size = UDim2.new(1, 0, 1, 0)

local animText = Instance.new("TextLabel", animFrame)
animText.Text = "HDHITBOX"
animText.Font = Enum.Font.GothamBlack
animText.TextScaled = true
animText.Size = UDim2.new(1, 0, 1, 0)
animText.TextColor3 = Color3.new(1, 1, 1)
animText.BackgroundTransparency = 1

TweenService:Create(animText, TweenInfo.new(2), {TextTransparency = 1}):Play()
wait(2.5)
animFrame:Destroy()

-- Theme Colors
local themes = {
    Red = {bg = Color3.fromRGB(40, 0, 0), accent = Color3.fromRGB(200, 0, 0)},
    Blue = {bg = Color3.fromRGB(0, 0, 40), accent = Color3.fromRGB(0, 0, 200)},
    Green = {bg = Color3.fromRGB(0, 40, 0), accent = Color3.fromRGB(0, 200, 0)}
}
local currentTheme = "Red"

-- Main Frame
local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.Size = UDim2.new(0, 400, 0, 300)
frame.BackgroundColor3 = themes[currentTheme].bg
frame.BorderSizePixel = 0

-- Dragging Functionality
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "HDHITBOX Settings"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = themes[currentTheme].accent

-- Tabs
local tabButtons = Instance.new("Frame", frame)
tabButtons.Position = UDim2.new(0, 0, 0, 40)
tabButtons.Size = UDim2.new(1, 0, 0, 30)
tabButtons.BackgroundTransparency = 1

local pages = {}

local function createTab(name)
    local button = Instance.new("TextButton", tabButtons)
    button.Size = UDim2.new(0, 130, 1, 0)
    button.Text = name
    button.BackgroundColor3 = themes[currentTheme].accent
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold

    local page = Instance.new("Frame", frame)
    page.Position = UDim2.new(0, 0, 0, 70)
    page.Size = UDim2.new(1, 0, 1, -70)
    page.Visible = false
    page.BackgroundTransparency = 1
    pages[name] = page

    button.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        page.Visible = true
    end)
end

createTab("Hitbox")
createTab("Settings")

-- Slider Creation Function
local function createSlider(parent, label, min, max, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -20, 0, 50)
    container.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 55)
    container.BackgroundTransparency = 1

    local text = Instance.new("TextLabel", container)
    text.Size = UDim2.new(1, 0, 0, 20)
    text.Text = label
    text.TextColor3 = Color3.new(1, 1, 1)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.Gotham
    text.TextSize = 14

    local bar = Instance.new("Frame", container)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.Size = UDim2.new(1, 0, 0, 5)
    bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0, 10, 0, 20)
    knob.Position = UDim2.new(0, 0, -0.75, 0)
    knob.BackgroundColor3 = themes[currentTheme].accent

    local dragging = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = input.Position.X - bar.AbsolutePosition.X
            rel = math.clamp(rel, 0, bar.AbsoluteSize.X)
            knob.Position = UDim2.new(0, rel, -0.75, 0)
            local val = min + ((rel / bar.AbsoluteSize.X) * (max - min))
            callback(val)
        end
    end)
end

-- Hitbox Logic
local size, transparency = 5, 0.5
local function updateHitbox(char, part)
    local hb = part:FindFirstChild("HD_Hitbox") or Instance.new("BoxHandleAdornment")
    hb.Name = "HD_Hitbox"
    hb.Adornee = part
    hb.Size = Vector3.new(size, size, size)
    hb.AlwaysOnTop = true
    hb.ZIndex = 5
    hb.Transparency = transparency
    hb.Color3 = Color3.new(1, 0, 0)
    hb.Parent = part
end

local function applyHitboxes()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            updateHitbox(p.Character, p.Character:FindFirstChild("HumanoidRootPart"))
        end
    end
end

-- Setup UI Elements
createSlider(pages["Hitbox"], "Size", 2, 10, function(v)
    size = v
    applyHitboxes()
end)
createSlider(pages["Hitbox"], "Transparency", 0, 1, function(v)
    transparency = v
    applyHitboxes()
end)

-- Theme Dropdown
local themeLabel = Instance.new("TextLabel", pages["Settings"])
themeLabel.Size = UDim2.new(1, -20, 0, 30)
themeLabel.Position = UDim2.new(0, 10, 0, 10)
themeLabel.Text = "Choose Theme"
themeLabel.TextColor3 = Color3.new(1, 1, 1)
themeLabel.Font = Enum.Font.Gotham
themeLabel.BackgroundTransparency = 1

local dropdown = Instance.new("TextButton", pages["Settings"])
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Current: Red"
dropdown.BackgroundColor3 = themes[currentTheme].accent
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.Gotham

dropdown.MouseButton1Click:Connect(function()
    local keys = {}
    for k in pairs(themes) do table.insert(keys, k) end
    local idx = table.find(keys, currentTheme) or 1
    currentTheme = keys[(idx % #keys) + 1]
    dropdown.Text = "Current: " .. currentTheme
    frame.BackgroundColor3 = themes[currentTheme].bg
    title.BackgroundColor3 = themes[currentTheme].accent
    for _, child in pairs(tabButtons:GetChildren()) do
        if child:IsA("TextButton") then child.BackgroundColor3 = themes[currentTheme].accent end
    end
end)

-- Apply hitboxes initially
applyHitboxes()
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(1)
        applyHitboxes()
    end)
end)

-- Show first tab
pages["Hitbox"].Visible = true
