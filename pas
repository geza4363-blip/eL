-- =========================================================
-- FEEDER AUTO - INSTANT REJOIN + SPAM 5X GUARANTEED
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
    warn("❌ Remotes tidak ditemukan")
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
local spamActive = false
local spamCount = 0
local justLeftMatch = false

-- =========================================================
-- AUTO JOIN (NEAREST + INSTANT RETRY)
-- =========================================================
local function autoJoin()
    if not autoJoinEnabled then return false end
    if matchActive then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local nearestPrompt = nil
    local shortestDistance = math.huge
    
    -- Find nearest prompt
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parent = obj.Parent
            if parent then
                local distance = (parent.Position - humanoidRootPart.Position).Magnitude
                if distance < shortestDistance and distance < 50 then
                    nearestPrompt = obj
                    shortestDistance = distance
                end
            end
        end
    end
    
    if nearestPrompt then
        local success = pcall(function()
            fireproximityprompt(nearestPrompt)
        end)
        
        if success then
            print(string.format("✅ Joined (%.1fm)", shortestDistance))
            return true
        end
    end
    
    return false
end

-- INSTANT REJOIN AFTER MATCH
task.spawn(function()
    while true do
        if autoJoinEnabled and not matchActive then
            -- Burst join attempts when just left match
            if justLeftMatch then
                for i = 1, 10 do
                    autoJoin()
                    task.wait(0.1)
                end
                justLeftMatch = false
            else
                autoJoin()
            end
        end
        task.wait(0.5) -- Normal check
    end
end)

-- =========================================================
-- SPAM 5X GUARANTEED
-- =========================================================
local function spam5x()
    if not isMyTurn or not matchActive or not feedEnabled then 
        return 
    end
    
    if spamActive then return end
    spamActive = true
    
    local word = "xxx"
    
    print("🚀 Spam 5x dimulai")
    
    task.spawn(function()
        for i = 1, 5 do
            -- Check if still our turn
            if not isMyTurn or not matchActive then
                print(string.format("⏹️ Stopped at spam %d (turn ended)", i))
                spamActive = false
                return
            end
            
            -- Type fast
            pcall(function() 
                TypeSound:FireServer() 
                BillboardUpdate:FireServer("x")
            end)
            task.wait(0.03)
            
            pcall(function() 
                TypeSound:FireServer() 
                BillboardUpdate:FireServer("xx")
            end)
            task.wait(0.03)
            
            pcall(function() 
                TypeSound:FireServer() 
                BillboardUpdate:FireServer("xxx")
            end)
            task.wait(0.05)
            
            -- Submit
            pcall(function() 
                SubmitWord:FireServer(word) 
            end)
            
            spamCount = spamCount + 1
            print(string.format("📤 Spam %d/5 sent", i))
            
            -- Delay between spams
            if i < 5 then
                task.wait(0.2)
            end
        end
        
        print("✅ Spam 5x complete!")
        spamActive = false
        
        if BillboardEnd then
            pcall(function() BillboardEnd:FireServer() end)
        end
    end)
end

-- =========================================================
-- GUI CLEAN
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FeederGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(200, 180)
frame.Position = UDim2.new(0.5, -100, 0, 20)
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

-- Top Bar
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
title.Text = "🍼 FEEDER x5"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = topBar

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.fromOffset(10, 45)
status.BackgroundTransparency = 1
status.Text = "🔍 Mencari match...\nTotal: 0x"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Parent = frame

-- Auto Join Button
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -20, 0, 35)
autoBtn.Position = UDim2.fromOffset(10, 90)
autoBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
autoBtn.Text = "Auto Join: ON"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 13
autoBtn.Parent = frame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 8)
autoCorner.Parent = autoBtn

-- Manual Join Button
local joinBtn = Instance.new("TextButton")
joinBtn.Size = UDim2.new(1, -20, 0, 35)
joinBtn.Position = UDim2.fromOffset(10, 135)
joinBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
joinBtn.Text = "Join Now"
joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
joinBtn.Font = Enum.Font.GothamBold
joinBtn.TextSize = 13
joinBtn.Parent = frame

local joinCorner = Instance.new("UICorner")
joinCorner.CornerRadius = UDim.new(0, 8)
joinCorner.Parent = joinBtn

-- =========================================================
-- BUTTON EVENTS
-- =========================================================
autoBtn.MouseButton1Click:Connect(function()
    autoJoinEnabled = not autoJoinEnabled
    
    if autoJoinEnabled then
        autoBtn.Text = "Auto Join: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        autoBtn.Text = "Auto Join: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

joinBtn.MouseButton1Click:Connect(function()
    joinBtn.Text = "Joining..."
    autoJoin()
    task.wait(1)
    joinBtn.Text = "Join Now"
end)

-- =========================================================
-- MATCH EVENTS
-- =========================================================
if MatchUI then
    MatchUI.OnClientEvent:Connect(function(cmd)
        if cmd == "ShowMatchUI" then
            matchActive = true
            isMyTurn = false
            spamActive = false
            justLeftMatch = false
            status.Text = "✅ Dalam Match\nTotal: " .. spamCount .. "x"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            
        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
            spamActive = false
            justLeftMatch = true -- TRIGGER INSTANT REJOIN
            spamCount = 0
            status.Text = "🔍 Match selesai, rejoining...\nTotal: 0x"
            status.TextColor3 = Color3.fromRGB(255, 200, 100)
            print("🔄 Match ended, instant rejoin activated!")
            
        elseif cmd == "StartTurn" then
            isMyTurn = true
            status.Text = "⚡ Your Turn - Spamming!\nTotal: " .. spamCount .. "x"
            task.wait(0.3)
            spam5x()
            
        elseif cmd == "EndTurn" then
            isMyTurn = false
            spamActive = false
            status.Text = "⏳ Opponent Turn\nTotal: " .. spamCount .. "x"
        end
    end)
end

-- =========================================================
-- DRAG SUPPORT
-- =========================================================
local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                     input.UserInputType == Enum.UserInputType.Touch) then
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
print("🍼 FEEDER x5 LOADED")
print("=================================")
print("✅ Instant rejoin after match")
print("✅ Guaranteed 5x spam per turn")
print("✅ Mobile friendly")
print("=================================")
