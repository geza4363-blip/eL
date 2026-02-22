if getgenv().IndoSearchLoaded then return end
getgenv().IndoSearchLoaded = true

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- Hapus lama
if playerGui:FindFirstChild("IndoSearchHub") then
	playerGui.IndoSearchHub:Destroy()
end

-- =========================
-- LOAD DATABASE INDONESIA
-- =========================

local raw = game:HttpGet("https://raw.githubusercontent.com/agusmakmun/wordlist-bahasa-indonesia/master/indonesia-wordlist.txt")

local wordDatabase = {}
for word in string.gmatch(raw, "[^\r\n]+") do
	table.insert(wordDatabase, string.lower(word))
end

print("Database loaded:", #wordDatabase)

-- =========================
-- GUI
-- =========================

local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "IndoSearchHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,420,0,320)
frame.Position = UDim2.new(0.5,-210,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(28,28,32)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(70,70,80)

local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(38,38,44)
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.Text = "Indonesian Dictionary (60K+)"
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local minimize = Instance.new("TextButton", top)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-70,0,5)
minimize.Text = "—"
minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundColor3 = Color3.fromRGB(70,70,80)
minimize.BorderSizePixel = 0
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0,8)

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(200,70,70)
close.BorderSizePixel = 0
Instance.new("UICorner", close).CornerRadius = UDim.new(0,8)

local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1,-30,1,-70)
content.Position = UDim2.new(0,15,0,55)
content.BackgroundTransparency = 1

local search = Instance.new("TextBox", content)
search.Size = UDim2.new(1,0,0,38)
search.BackgroundColor3 = Color3.fromRGB(50,50,60)
search.TextColor3 = Color3.new(1,1,1)
search.PlaceholderText = "Ketik kata..."
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.ClearTextOnFocus = false
search.BorderSizePixel = 0
Instance.new("UICorner", search).CornerRadius = UDim.new(0,10)

local results = Instance.new("ScrollingFrame", content)
results.Size = UDim2.new(1,0,1,-50)
results.Position = UDim2.new(0,0,0,50)
results.CanvasSize = UDim2.new(0,0,0,0)
results.ScrollBarImageTransparency = 0.5
results.BackgroundTransparency = 1
results.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", results)
layout.Padding = UDim.new(0,6)

local currentItems = {}

local function clearResults()
	for _,v in ipairs(currentItems) do
		v:Destroy()
	end
	currentItems = {}
end

local function update(text)
	text = string.lower(string.gsub(text,"^%s*(.-)%s*$","%1"))
	clearResults()

	if text == "" then
		results.CanvasSize = UDim2.new(0,0,0,0)
		return
	end

	local count = 0

	for _,word in ipairs(wordDatabase) do
		if string.sub(word,1,#text) == text then
			count += 1

			local item = Instance.new("Frame", results)
			item.Size = UDim2.new(1,-5,0,28)
			item.BackgroundColor3 = Color3.fromRGB(55,55,65)
			item.BorderSizePixel = 0
			Instance.new("UICorner", item).CornerRadius = UDim.new(0,6)

			local label = Instance.new("TextLabel", item)
			label.Size = UDim2.new(1,-10,1,0)
			label.Position = UDim2.new(0,8,0,0)
			label.BackgroundTransparency = 1
			label.Text = word
			label.Font = Enum.Font.Gotham
			label.TextSize = 13
			label.TextColor3 = Color3.new(1,1,1)
			label.TextXAlignment = Enum.TextXAlignment.Left

			table.insert(currentItems,item)

			if count >= 50 then break end -- batasi 50 hasil biar ringan
		end
	end

	results.CanvasSize = UDim2.new(0,0,0,count*34)
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	update(search.Text)
end)

-- Minimize
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	content.Visible = not minimized
	frame.Size = minimized and UDim2.new(0,420,0,40) or UDim2.new(0,420,0,320)
end)

-- Close
close.MouseButton1Click:Connect(function()
	gui:Destroy()
	getgenv().IndoSearchLoaded = nil
end)
