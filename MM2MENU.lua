--// MM2-STYLE TEST GUI
--// Put this LocalScript in:
--// StarterPlayer > StarterPlayerScripts
--
--// EXPECTED:
--// ReplicatedStorage contains a RemoteFunction named:
--// GetPlayerData
--
--// Expected return format:
--//
--// {
--//     ["PlayerName"] = {
--//         Role = "Murderer",
--//         Killed = false,
--//         Dead = false
--//     }
--// }

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local ROLE_COLORS = {
	Innocent = Color3.fromRGB(50, 210, 90),
	Murderer = Color3.fromRGB(230, 55, 55),
	Sheriff = Color3.fromRGB(55, 140, 255),
	Hero = Color3.fromRGB(255, 205, 50),
}

local noclip = false
local guiLocked = false
local minimized = false

local espEnabled = {
	Innocent = false,
	Murderer = false,
	Sheriff = false,
	Hero = false,
}

local originalCollision = {}

--==================================================
-- GET PLAYER DATA
--==================================================

local GetPlayerData =
	ReplicatedStorage:FindFirstChild("GetPlayerData", true)

local MurdererName = nil
local SheriffName = nil
local HeroName = nil

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MM2TestGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(300, 350)
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(22, 23, 28)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(55, 57, 65)
stroke.Thickness = 1
stroke.Parent = frame

--==================================================
-- HEADER
--==================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
header.BorderSizePixel = 0
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -105, 1, 0)
title.Position = UDim2.fromOffset(15, 0)
title.BackgroundTransparency = 1
title.Text = "MM2  •  TEST PANEL"
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

--==================================================
-- LOCK BUTTON
--==================================================

local lockButton = Instance.new("TextButton")
lockButton.Name = "Lock"
lockButton.Size = UDim2.fromOffset(32, 32)
lockButton.Position = UDim2.new(1, -82, 0.5, -16)
lockButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
lockButton.Text = "🔓"
lockButton.TextSize = 16
lockButton.TextColor3 = Color3.new(1, 1, 1)
lockButton.BorderSizePixel = 0
lockButton.Parent = header

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(0, 7)
lockCorner.Parent = lockButton

--==================================================
-- MINIMIZE BUTTON
--==================================================

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "Minimize"
minimizeButton.Size = UDim2.fromOffset(32, 32)
minimizeButton.Position = UDim2.new(1, -42, 0.5, -16)
minimizeButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
minimizeButton.Text = "—"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 18
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 7)
minCorner.Parent = minimizeButton

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -58)
content.Position = UDim2.fromOffset(10, 53)
content.BackgroundTransparency = 1
content.Parent = frame

local movementTitle = Instance.new("TextLabel")
movementTitle.Size = UDim2.new(1, 0, 0, 25)
movementTitle.BackgroundTransparency = 1
movementTitle.Text = "MOVEMENT"
movementTitle.TextColor3 = Color3.fromRGB(150, 153, 165)
movementTitle.TextSize = 12
movementTitle.Font = Enum.Font.GothamBold
movementTitle.TextXAlignment = Enum.TextXAlignment.Left
movementTitle.Parent = content

--==================================================
-- TOGGLE CREATOR
--==================================================

local function createToggle(name, text, y)

	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 42)
	button.Position = UDim2.fromOffset(0, y)
	button.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	button.BorderSizePixel = 0
	button.Text = text .. ": OFF"
	button.TextColor3 = Color3.fromRGB(230, 230, 235)
	button.TextSize = 14
	button.Font = Enum.Font.GothamSemibold
	button.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.fromOffset(5, 22)
	indicator.Position = UDim2.fromOffset(8, 10)
	indicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	indicator.BorderSizePixel = 0
	indicator.Parent = button

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator

	return button, indicator
end

--==================================================
-- NOCLIP
--==================================================

local noclipButton, noclipIndicator =
	createToggle("Noclip", "Noclip", 30)

noclipButton.MouseButton1Click:Connect(function()

	noclip = not noclip

	if noclip then

		noclipButton.Text = "Noclip: ON"
		noclipButton.BackgroundColor3 =
			Color3.fromRGB(35, 70, 45)

		noclipIndicator.BackgroundColor3 =
			Color3.fromRGB(50, 210, 90)

		originalCollision = {}

		if player.Character then

			for _, object in ipairs(
				player.Character:GetDescendants()
			) do

				if object:IsA("BasePart") then

					originalCollision[object] =
						object.CanCollide

					object.CanCollide = false
				end
			end
		end

	else

		noclipButton.Text = "Noclip: OFF"
		noclipButton.BackgroundColor3 =
			Color3.fromRGB(34, 36, 43)

		noclipIndicator.BackgroundColor3 =
			Color3.fromRGB(80, 82, 90)

		for object, oldValue in pairs(originalCollision) do

			if object and object.Parent then
				object.CanCollide = oldValue
			end
		end

		originalCollision = {}
	end
end)

--==================================================
-- ESP SECTION
--==================================================

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, 0, 0, 25)
espTitle.Position = UDim2.fromOffset(0, 85)
espTitle.BackgroundTransparency = 1
espTitle.Text = "ROLE ESP"
espTitle.TextColor3 = Color3.fromRGB(150, 153, 165)
espTitle.TextSize = 12
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = content

local espButtons = {}

local function createESPButton(role, y)

	local button, indicator =
		createToggle(
			role .. "ESP",
			role,
			y
		)

	espButtons[role] = {
		Button = button,
		Indicator = indicator,
	}

	button.MouseButton1Click:Connect(function()

		espEnabled[role] =
			not espEnabled[role]

		if espEnabled[role] then

			button.Text =
				role .. " ESP: ON"

			button.BackgroundColor3 =
				ROLE_COLORS[role]:Lerp(
					Color3.fromRGB(20, 20, 25),
					0.65
				)

			indicator.BackgroundColor3 =
				ROLE_COLORS[role]

		else

			button.Text =
				role .. " ESP: OFF"

			button.BackgroundColor3 =
				Color3.fromRGB(34, 36, 43)

			indicator.BackgroundColor3 =
				Color3.fromRGB(80, 82, 90)
		end
	end)
end

createESPButton("Innocent", 115)
createESPButton("Murderer", 162)
createESPButton("Sheriff", 209)
createESPButton("Hero", 256)

--==================================================
-- ESP SYSTEM
--==================================================

local highlights = {}

--==================================================
-- CREATE HIGHLIGHT
--==================================================

local function CreateHighlight(target)

	if target == player then
		return
	end

	if not target.Character then
		return
	end

	local highlight =
		target.Character:FindFirstChild("RoleESP")

	if not highlight then

		highlight = Instance.new("Highlight")

		highlight.Name = "RoleESP"

		-- Allows ESP to be visible through walls.
		highlight.DepthMode =
			Enum.HighlightDepthMode.AlwaysOnTop

		highlight.FillTransparency = 0.45
		highlight.OutlineTransparency = 0

		highlight.Parent = target.Character
	end

	highlights[target] = highlight
end

--==================================================
-- ALIVE CHECK
--==================================================

local function IsAlive(target)

	if not target then
		return false
	end

	if not target.Character then
		return false
	end

	local humanoid =
		target.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return false
	end

	return humanoid.Health > 0
end

--==================================================
-- GET ROLES FROM SERVER
--==================================================

local function GetRoles()

	MurdererName = nil
	SheriffName = nil
	HeroName = nil

	if not GetPlayerData then
		return
	end

	local success, result =
		pcall(function()

			return GetPlayerData:InvokeServer()

		end)

	if not success then
		return
	end

	if type(result) ~= "table" then
		return
	end

	for name, data in pairs(result) do

		if type(data) == "table" then

			if data.Role == "Murderer" then

				MurdererName = name

			elseif data.Role == "Sheriff" then

				SheriffName = name

			elseif data.Role == "Hero" then

				HeroName = name
			end
		end
	end
end

--==================================================
-- UPDATE HIGHLIGHTS
--==================================================

local function UpdateHighlights()

	for _, target in ipairs(
		Players:GetPlayers()
	) do

		if target ~= player
			and target.Character then

			CreateHighlight(target)

			local highlight =
				target.Character:FindFirstChild("RoleESP")

			if not highlight then
				continue
			end

			local role

			-- Murderer
			if target.Name == MurdererName then

				role = "Murderer"

			-- Sheriff
			elseif target.Name == SheriffName then

				role = "Sheriff"

			-- Hero
			elseif target.Name == HeroName then

				role = "Hero"

			-- Everyone else
			else

				role = "Innocent"
			end

			-- Only display enabled ESP.
			if espEnabled[role]
				and IsAlive(target) then

				local color =
					ROLE_COLORS[role]

				highlight.FillColor = color
				highlight.OutlineColor = color

				highlight.FillTransparency = 0.45
				highlight.OutlineTransparency = 0

				highlight.DepthMode =
					Enum.HighlightDepthMode.AlwaysOnTop

				highlight.Enabled = true

			else

				highlight.Enabled = false
			end
		end
	end
end

--==================================================
-- REMOVE HIGHLIGHT
--==================================================

local function RemoveHighlight(target)

	if target.Character then

		local highlight =
			target.Character:FindFirstChild("RoleESP")

		if highlight then
			highlight:Destroy()
		end
	end

	highlights[target] = nil
end

--==================================================
-- PLAYER CONNECTIONS
--==================================================

for _, target in ipairs(
	Players:GetPlayers()
) do

	if target ~= player then

		target.CharacterAdded:Connect(
			function()

				task.wait(0.2)

				CreateHighlight(target)
				UpdateHighlights()
			end
		)

		if target.Character then
			CreateHighlight(target)
		end
	end
end

Players.PlayerAdded:Connect(function(target)

	target.CharacterAdded:Connect(
		function()

			task.wait(0.2)

			CreateHighlight(target)
			UpdateHighlights()
		end
	)
end)

Players.PlayerRemoving:Connect(function(target)

	RemoveHighlight(target)
end)

--==================================================
-- NOCLIP LOOP
--==================================================

RunService.Stepped:Connect(function()

	if not noclip then
		return
	end

	if not player.Character then
		return
	end

	for _, object in ipairs(
		player.Character:GetDescendants()
	) do

		if object:IsA("BasePart") then
			object.CanCollide = false
		end
	end
end)

--==================================================
-- RESPAWN
--==================================================

player.CharacterAdded:Connect(function(character)

	originalCollision = {}

	if noclip then

		task.wait(0.1)

		for _, object in ipairs(
			character:GetDescendants()
		) do

			if object:IsA("BasePart") then

				originalCollision[object] =
					object.CanCollide

				object.CanCollide = false
			end
		end
	end

	task.wait(0.2)

	UpdateHighlights()
end)

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)

	if guiLocked then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging or guiLocked then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		local delta =
			input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,

			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1

		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = false
	end
end)

--==================================================
-- LOCK
--==================================================

lockButton.MouseButton1Click:Connect(function()

	guiLocked = not guiLocked

	if guiLocked then

		lockButton.Text = "🔒"

		lockButton.BackgroundColor3 =
			Color3.fromRGB(55, 57, 65)

	else

		lockButton.Text = "🔓"

		lockButton.BackgroundColor3 =
			Color3.fromRGB(42, 44, 52)
	end
end)

--==================================================
-- MINIMIZE
--==================================================

minimizeButton.MouseButton1Click:Connect(function()

	minimized = not minimized

	content.Visible = not minimized

	if minimized then

		frame.Size =
			UDim2.fromOffset(300, 48)

		minimizeButton.Text = "+"

	else

		frame.Size =
			UDim2.fromOffset(300, 350)

		minimizeButton.Text = "—"
	end
end)

--==================================================
-- INITIAL ESP
--==================================================

UpdateHighlights()

--==================================================
-- ESP LOOP
--==================================================

task.spawn(function()

	while gui.Parent do

		GetRoles()
		UpdateHighlights()

		task.wait(0.25)
	end
end)