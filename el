-- FEEDER AUTO - FIX AUTO JOIN SETIAP MATCH

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Remote
local SubmitWord = ReplicatedStorage.Remotes.SubmitWord
local BillboardUpdate = ReplicatedStorage.Remotes.BillboardUpdate
local TypeSound = ReplicatedStorage.Remotes.TypeSound
local MatchUI = ReplicatedStorage.Remotes.MatchUI
local BillboardEnd = ReplicatedStorage.Remotes.BillboardEnd

-- State
local matchActive = false
local isMyTurn = false

-- =========================================================
-- AUTO JOIN (SAMA PERSIS)
-- =========================================================
local function findJoinPrompts()
    local prompts = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local promptText = (obj.ObjectText or ""):lower()
            local actionText = (obj.ActionText or ""):lower()
            
            if promptText:find("join") or promptText:find("gabung") or 
               promptText:find("main") or promptText:find("meja") or
               actionText:find("join") or actionText:find("gabung") or
               actionText:find("main") or actionText:find("meja") then
                table.insert(prompts, obj)
            end
            
            if obj.Parent then
                local parentName = obj.Parent.Name:lower()
                if parentName:find("meja") or parentName:find("table") or parentName:find("kursi") then
                    table.insert(prompts, obj)
                end
            end
        end
    end
    return prompts
end

local function autoJoin()
    local prompts = findJoinPrompts()
    for _, prompt in ipairs(prompts) do
        pcall(function() prompt.PromptTriggered:Fire(LocalPlayer) end)
        pcall(function() prompt.Triggered:Fire(LocalPlayer) end)
        wait(0.1)
    end
    if #prompts > 0 then print("✅ Join triggered") end
end

-- =========================================================
-- LOOP AUTO JOIN (DIPERBAIKI)
-- =========================================================
spawn(function()
    while true do
        -- LANGSUNG JOIN TERUS, gak peduli state
        autoJoin()
        wait(1) -- coba tiap 1 detik
    end
end)

-- =========================================================
-- SPAM 5x
-- =========================================================
local function spamXxx()
    if not isMyTurn then return end
    
    for i = 1, 5 do
        if not isMyTurn then break end
        
        pcall(function() TypeSound:FireServer() end)
        pcall(function() BillboardUpdate:FireServer("x") end)
        wait(0.03)
        
        pcall(function() TypeSound:FireServer() end)
        pcall(function() BillboardUpdate:FireServer("xx") end)
        wait(0.03)
        
        pcall(function() TypeSound:FireServer() end)
        pcall(function() BillboardUpdate:FireServer("xxx") end)
        wait(0.03)
        
        pcall(function() SubmitWord:FireServer("xxx") end)
        print("📤 Spam #" .. i)
        
        if i < 5 then wait(0.1) end
    end
    
    if BillboardEnd then
        pcall(function() BillboardEnd:FireServer() end)
    end
end

-- =========================================================
-- MATCH HANDLER
-- =========================================================
MatchUI.OnClientEvent:Connect(function(cmd)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        print("🎮 Match dimulai")
    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        print("🎮 Match selesai - Auto join lanjut")
    elseif cmd == "StartTurn" then
        isMyTurn = true
        wait(0.3)
        spamXxx()
    elseif cmd == "EndTurn" then
        isMyTurn = false
    end
end)

print("✅ FEEDER READY - Auto join tiap 1 detik")
