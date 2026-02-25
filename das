-- FEEDER AUTO - MOBILE EDITION (TANPA F3)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Remotes
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then 
    print("❌ Remotes tidak ditemukan")
    return 
end

local SubmitWord = remotes:FindFirstChild("SubmitWord")
local BillboardUpdate = remotes:FindFirstChild("BillboardUpdate")
local TypeSound = remotes:FindFirstChild("TypeSound")
local MatchUI = remotes:FindFirstChild("MatchUI")
local BillboardEnd = remotes:FindFirstChild("BillboardEnd")

-- State
local matchActive = false
local isMyTurn = false
local spamActive = false

-- AUTO JOIN
local function autoJoin()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function() obj.PromptTriggered:Fire(LocalPlayer) end)
            pcall(function() obj.Triggered:Fire(LocalPlayer) end)
            print("✅ Join clicked")
            return true
        end
    end
    return false
end

-- Loop auto join (setiap 1 detik)
spawn(function()
    while true do
        if not matchActive then
            autoJoin()
        end
        wait(1)
    end
end)

-- SPAM XXX 5X
local function spamXxx()
    if not isMyTurn or not matchActive or spamActive then return end
    
    spamActive = true
    print("🚀 Mulai spam 5x")
    
    for i = 1, 5 do
        if not isMyTurn then break end
        
        pcall(function() TypeSound:FireServer() end)
        pcall(function() BillboardUpdate:FireServer("x") end)
        wait(0.05)
        
        pcall(function() TypeSound:FireServer() end)
        pcall(function() BillboardUpdate:FireServer("xx") end)
        wait(0.05)
        
        pcall(function() TypeSound:FireServer() end)
        pcall(function() BillboardUpdate:FireServer("xxx") end)
        wait(0.05)
        
        pcall(function() SubmitWord:FireServer("xxx") end)
        print("✅ Spam #" .. i .. " terkirim")
        
        if i < 5 then wait(0.1) end
    end
    
    spamActive = false
    if BillboardEnd then pcall(function() BillboardEnd:FireServer() end) end
end

-- Match event
if MatchUI then
    MatchUI.OnClientEvent:Connect(function(cmd)
        if cmd == "ShowMatchUI" then
            matchActive = true
            isMyTurn = false
        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
            spamActive = false
        elseif cmd == "StartTurn" then
            isMyTurn = true
            wait(0.3)
            spamXxx()
        elseif cmd == "EndTurn" then
            isMyTurn = false
            spamActive = false
        end
    end)
end

-- GUI SEDERHANA (untuk mobile)
local gui = Instance.new("ScreenGui")
gui.Name = "FeederMobile"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 80)
frame.Position = UDim2.new(0, 10, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -10, 1, -10)
btn.Position = UDim2.new(0, 5, 0, 5)
btn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
btn.Text = "JOIN MANUAL"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = btn

btn.MouseButton1Click:Connect(function()
    btn.Text = "JOINING..."
    autoJoin()
    wait(0.5)
    btn.Text = "JOIN MANUAL"
end)

print("=================================")
print("🍼 FEEDER MOBILE SIAP")
print("=================================")
print("✅ Auto join tiap 1 detik")
print("✅ Spam 5x per giliran")
print("✅ Tekan tombol JOIN di layar")
print("=================================")
