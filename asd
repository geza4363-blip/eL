-- =========================================================
-- FEEDER OTOMATIS - MOBILE FRIENDLY
-- =========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- =========================================================
-- REMOTES
-- =========================================================
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then 
    warn("Remotes tidak ditemukan")
    return 
end

local SubmitWord = remotes:FindFirstChild("SubmitWord")
local BillboardUpdate = remotes:FindFirstChild("BillboardUpdate")
local TypeSound = remotes:FindFirstChild("TypeSound")
local MatchUI = remotes:FindFirstChild("MatchUI")
local BillboardEnd = remotes:FindFirstChild("BillboardEnd")

-- =========================================================
-- STATE
-- =========================================================
local matchActive = false
local isMyTurn = false
local autoJoinEnabled = true
local feedEnabled = true

-- =========================================================
-- FUNCTIONS
-- =========================================================
local function autoJoin()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local success = pcall(function()
                fireproximityprompt(obj)
            end)
            
            if success then
                print("Joined match!")
                return true
            end
        end
    end
    return false
end

local function ketikXxx()
    if not isMyTurn then return end
    if not feedEnabled then return end
    if not SubmitWord or not BillboardUpdate or not TypeSound then return end
    
    task.spawn(function()
        local word = "xxx"
        local current = ""
        
        for i = 1, #word do
            current = current .. word:sub(i, i)
            
            pcall(function()
                TypeSound:FireServer()
                BillboardUpdate:FireServer(current)
            end)
            
            task.wait(0.1)
        end
        
        task.wait(0.2)
        
        pcall(function()
            SubmitWord:FireServer(word)
        end)
        
        if BillboardEnd then
            pcall(function()
                BillboardEnd:FireServer()
            end)
        end
        
        print("xxx terkirim")
    end)
end

-- =========================================================
-- GUI MOBILE FRIENDLY
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FeederGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220, 180)
frame.Position = UDim2.new(0.5, -110, 0, 20)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 90)
stroke.Thickness = 2
stroke.Parent = frame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 15)
topFix.Position = UDim2.new(0, 0, 1, -15)
topFix.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
topFix.BorderSizePixel = 0
topFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 1)
title.BackgroundTransparency = 1
title.Text = "🍼 FEEDER AUTO"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = topBar

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.fromOffset(10, 45)
status.BackgroundTransparency = 1
status.Text = "⏳ Mencari Match..."
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local autoJoinBtn = Instance.new("TextButton")
autoJoinBtn.Size = UDim2.new(1, -20, 0, 35)
autoJoinBtn.Position = UDim2.fromOffset(10, 75)
autoJoinBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
autoJoinBtn.Text = "Auto Join: ON"
autoJoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoJoinBtn.Font = Enum.Font.GothamBold
autoJoinBtn.TextSize = 13
autoJoinBtn.Parent = frame

local autoJoinCorner = Instance.new("UICorner")
autoJoinCorner.CornerRadius = UDim.new(0, 8)
autoJoinCorner.Parent = autoJoinBtn

local feedBtn = Instance.new("TextButton")
feedBtn.Size = UDim2.new(1, -20, 0, 35)
feedBtn.Position = UDim2.fromOffset(10, 115)
feedBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
feedBtn.Text = "Auto Feed: ON"
feedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
feedBtn.Font = Enum.Font.GothamBold
feedBtn.TextSize = 13
feedBtn.Parent = frame

local feedCorner = Instance.new("UICorner")
feedCorner.CornerRadius = UDim.new(0, 8)
feedCorner.Parent = feedBtn

local manualJoinBtn = Instance.new("TextButton")
manualJoinBtn.Size = UDim2.new(1, -20, 0, 25)
manualJoinBtn.Position = UDim2.fromOffset(10, 155)
manualJoinBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
manualJoinBtn.Text = "Join Now"
manualJoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
manualJoinBtn.Font = Enum.Font.GothamBold
manualJoinBtn.TextSize = 12
manualJoinBtn.Parent = frame

local manualCorner = Instance.new("UICorner")
manualCorner.CornerRadius = UDim.new(0, 6)
manualCorner.Parent = manualJoinBtn

-- =========================================================
-- EVENTS
-- =========================================================
autoJoinBtn.MouseButton1Click:Connect(function()
    autoJoinEnabled = not autoJoinEnabled
    
    if autoJoinEnabled then
        autoJoinBtn.Text = "Auto Join: ON"
        autoJoinBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        autoJoinBtn.Text = "Auto Join: OFF"
        autoJoinBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

feedBtn.MouseButton1Click:Connect(function()
    feedEnabled = not feedEnabled
    
    if feedEnabled then
        feedBtn.Text = "Auto Feed: ON"
        feedBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        feedBtn.Text = "Auto Feed: OFF"
        feedBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

manualJoinBtn.MouseButton1Click:Connect(function()
    manualJoinBtn.Text = "Joining..."
    autoJoin()
    task.wait(1)
    manualJoinBtn.Text = "Join Now"
end)

if MatchUI then
    MatchUI.OnClientEvent:Connect(function(cmd)
        if cmd == "ShowMatchUI" then
            matchActive = true
            isMyTurn = false
            status.Text = "✅ Dalam Match"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            
        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
            status.Text = "⏳ Mencari Match..."
            status.TextColor3 = Color3.fromRGB(200, 200, 200)
            
        elseif cmd == "StartTurn" then
            isMyTurn = true
            status.Text = "✅ Your Turn - Feeding..."
            task.wait(0.3)
            ketikXxx()
            
        elseif cmd == "EndTurn" then
            isMyTurn = false
            status.Text = "⏳ Opponent Turn"
        end
    end)
end

-- =========================================================
-- AUTO JOIN LOOP
-- =========================================================
task.spawn(function()
    while task.wait(5) do
        if autoJoinEnabled and not matchActive then
            autoJoin()
        end
    end
end)

-- =========================================================
-- DRAG FOR MOBILE
-- =========================================================
local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("=================================")
print("FEEDER AUTO LOADED (MOBILE)")
print("=================================")
print("- Auto Join: ON")
print("- Auto Feed: ON")
print("- Drag GUI untuk move")
print("=================================")
