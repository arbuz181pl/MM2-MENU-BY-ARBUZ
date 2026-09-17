--//==================================================
--// MM2 MENU BY ARBUZ v0.1alpha
--//==================================================
--// LocalScript
--// StarterPlayer > StarterPlayerScripts
--//==================================================

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
local infinityJump = false
local flingOnTouch = false

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
-- PLAYER DATA
--==================================================

local GetPlayerData =
	ReplicatedStorage:FindFirstChild("GetPlayerData", true)

local MurdererName
local SheriffName
local HeroName

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MM2MenuByArbuz"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--==================================================
-- MAIN FRAME
--==================================================

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(280, 330)
frame.Position = UDim2.new(0.5, -140, 0.5, -165)
frame.BackgroundColor3 = Color3.fromRGB(22, 23, 28)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(55, 57, 65)
frameStroke.Thickness = 1
frameStroke.Parent = frame

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

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -82, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "MM2 MENU BY ARBUZ v0.1alpha"
title.TextColor3 = Color3.fromRGB(245, 245, 250)

title.TextSize = 12

title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.TextScaled = false
title.TextTruncate = Enum.TextTruncate.None
title.Parent = header

--==================================================
-- LOCK BUTTON
--==================================================

local lockButton = Instance.new("TextButton")
lockButton.Name = "Lock"
lockButton.Size = UDim2.fromOffset(30, 30)
lockButton.Position = UDim2.new(1, -70, 0.5, -15)
lockButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
lockButton.Text = "🔓"
lockButton.TextSize = 15
lockButton.TextColor3 = Color3.new(1, 1, 1)
lockButton.Font = Enum.Font.GothamBold
lockButton.BorderSizePixel = 0
lockButton.AutoButtonColor = false
lockButton.Parent = header

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(0, 7)
lockCorner.Parent = lockButton

--==================================================
-- MINIMIZE BUTTON
--==================================================

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "Minimize"
minimizeButton.Size = UDim2.fromOffset(30, 30)
minimizeButton.Position = UDim2.new(1, -35, 0.5, -15)
minimizeButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
minimizeButton.Text = "—"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 17
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.BorderSizePixel = 0
minimizeButton.AutoButtonColor = false
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 7)
minimizeCorner.Parent = minimizeButton

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -58)
content.Position = UDim2.fromOffset(10, 53)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(80, 82, 90)
content.ScrollBarImageTransparency = 0.15
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.CanvasSize = UDim2.new(0, 0, 0, 350)
content.Parent = frame

--==================================================
-- SECTION TITLE
--==================================================

local movementTitle = Instance.new("TextLabel")
movementTitle.Name = "MovementTitle"
movementTitle.Size = UDim2.new(1, 0, 0, 20)
movementTitle.BackgroundTransparency = 1
movementTitle.Text = "MOVEMENT"
movementTitle.TextColor3 = Color3.fromRGB(150, 153, 165)
movementTitle.TextSize = 11
movementTitle.Font = Enum.Font.GothamBold
movementTitle.TextXAlignment = Enum.TextXAlignment.Left
movementTitle.Parent = content

--==================================================
-- TOGGLE CREATOR
--==================================================

local function createToggle(name, text, y)

	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 36)
	button.Position = UDim2.fromOffset(0, y)

	button.BackgroundColor3 =
		Color3.fromRGB(34, 36, 43)

	button.BorderSizePixel = 0

	-- Permanent text.
	button.Text = text

	button.TextColor3 =
		Color3.fromRGB(230, 230, 235)

	button.TextSize = 13
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.fromOffset(5, 20)
	indicator.Position = UDim2.fromOffset(8, 8)
	indicator.BackgroundColor3 =
		Color3.fromRGB(80, 82, 90)
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
	createToggle(
		"Noclip",
		"Noclip",
		25
	)

noclipButton.MouseButton1Click:Connect(function()

	noclip = not noclip

	if noclip then

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

		noclipButton.BackgroundColor3 =
			Color3.fromRGB(34, 36, 43)

		noclipIndicator.BackgroundColor3 =
			Color3.fromRGB(80, 82, 90)

		for object, oldValue in pairs(
			originalCollision
		) do

			if object and object.Parent then
				object.CanCollide = oldValue
			end
		end

		originalCollision = {}
	end
end)

--==================================================
-- INFINITY JUMP
--==================================================

local infinityJumpButton, infinityJumpIndicator =
	createToggle(
		"InfinityJump",
		"Infinity Jump",
		68
	)

infinityJumpButton.MouseButton1Click:Connect(function()

	infinityJump = not infinityJump

	if infinityJump then

		infinityJumpButton.BackgroundColor3 =
			Color3.fromRGB(35, 70, 45)

		infinityJumpIndicator.BackgroundColor3 =
			Color3.fromRGB(50, 210, 90)

	else

		infinityJumpButton.BackgroundColor3 =
			Color3.fromRGB(34, 36, 43)

		infinityJumpIndicator.BackgroundColor3 =
			Color3.fromRGB(80, 82, 90)
	end
end)

--==================================================
-- INFINITY JUMP INPUT
--==================================================

UserInputService.JumpRequest:Connect(function()

	if not infinityJump then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid:ChangeState(
			Enum.HumanoidStateType.Jumping
		)
	end
end)

--==================================================
-- FLING ON TOUCH
--==================================================

local flingButton, flingIndicator =
	createToggle(
		"FlingOnTouch",
		"Fling On Touch",
		111
	)

flingButton.MouseButton1Click:Connect(function()

	flingOnTouch = not flingOnTouch

	if flingOnTouch then

		flingButton.BackgroundColor3 =
			Color3.fromRGB(70, 45, 35)

		flingIndicator.BackgroundColor3 =
			Color3.fromRGB(230, 100, 55)

	else

		flingButton.BackgroundColor3 =
			Color3.fromRGB(34, 36, 43)

		flingIndicator.BackgroundColor3 =
			Color3.fromRGB(80, 82, 90)
	end
end)

--==================================================
-- FLING TOUCH SYSTEM
--==================================================

local flingDebounce = {}

local function flingCharacter(character)

	if not flingOnTouch then
		return
	end

	if not character then
		return
	end

	local targetPlayer =
		Players:GetPlayerFromCharacter(character)

	if not targetPlayer then
		return
	end

	if targetPlayer == player then
		return
	end

	if flingDebounce[targetPlayer] then
		return
	end

	flingDebounce[targetPlayer] = true

	local targetRoot =
		character:FindFirstChild("HumanoidRootPart")

	if targetRoot then

		local myCharacter =
			player.Character

		local myRoot =
			myCharacter
			and myCharacter:FindFirstChild(
				"HumanoidRootPart"
			)

		if myRoot then

			local direction =
				(targetRoot.Position - myRoot.Position)

			if direction.Magnitude < 0.1 then
				direction = Vector3.new(0, 1, 0)
			else
				direction = direction.Unit
			end

			targetRoot.AssemblyLinearVelocity =
				direction * 120
				+ Vector3.new(0, 70, 0)
		end
	end

	task.delay(0.5, function()
		flingDebounce[targetPlayer] = nil
	end)
end

local function connectFlingCharacter(character)

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if root then

		root.Touched:Connect(function(hit)

			if not flingOnTouch then
				return
			end

			local targetCharacter =
				hit:FindFirstAncestorOfClass("Model")

			if targetCharacter then
				flingCharacter(targetCharacter)
			end
		end)
	end
end

local function setupOwnTouch()

	local character = player.Character

	if not character then
		return
	end

	connectFlingCharacter(character)
end

player.CharacterAdded:Connect(function()

	task.wait(0.5)

	setupOwnTouch()
end)

if player.Character then
	setupOwnTouch()
end

--==================================================
-- ESP TITLE
--==================================================

local espTitle = Instance.new("TextLabel")
espTitle.Name = "ESPTitle"
espTitle.Size = UDim2.new(1, 0, 0, 20)
espTitle.Position = UDim2.fromOffset(0, 155)
espTitle.BackgroundTransparency = 1
espTitle.Text = "ROLE ESP"
espTitle.TextColor3 =
	Color3.fromRGB(150, 153, 165)
espTitle.TextSize = 11
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment =
	Enum.TextXAlignment.Left
espTitle.Parent = content

local espButtons = {}

--==================================================
-- ESP BUTTON
--==================================================

local function createESPButton(role, y)

	local button, indicator =
		createToggle(
			role .. "ESP",
			role .. " ESP",
			y
		)

	espButtons[role] = {
		Button = button,
		Indicator = indicator
	}

	button.MouseButton1Click:Connect(function()

		espEnabled[role] =
			not espEnabled[role]

		-- Never changes.
		button.Text = role .. " ESP"

		if espEnabled[role] then

			button.BackgroundColor3 =
				ROLE_COLORS[role]:Lerp(
					Color3.fromRGB(20, 20, 25),
					0.65
				)

			indicator.BackgroundColor3 =
				ROLE_COLORS[role]

		else

			button.BackgroundColor3 =
				Color3.fromRGB(34, 36, 43)

			indicator.BackgroundColor3 =
				Color3.fromRGB(80, 82, 90)
		end
	end)
end

createESPButton("Innocent", 180)
createESPButton("Murderer", 222)
createESPButton("Sheriff", 264)
createESPButton("Hero", 306)

--==================================================
-- ESP SYSTEM
--==================================================

local highlights = {}

local function CreateHighlight(target)

	if target == player then
		return
	end

	if not target.Character then
		return
	end

	local highlight =
		target.Character:FindFirstChild(
			"RoleESP"
		)

	if not highlight then

		highlight = Instance.new("Highlight")
		highlight.Name = "RoleESP"

		highlight.FillTransparency = 0.45
		highlight.OutlineTransparency = 0

		highlight.DepthMode =
			Enum.HighlightDepthMode.AlwaysOnTop

		highlight.Parent =
			target.Character
	end

	highlights[target] = highlight
end

--==================================================
-- ALIVE
--==================================================

local function IsAlive(target)

	if not target then
		return false
	end

	local character =
		target.Character

	if not character then
		return false
	end

	local humanoid =
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid then
		return false
	end

	return humanoid.Health > 0
end

--==================================================
-- GET ROLES
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
-- UPDATE ESP
--==================================================

local function UpdateHighlights()

	for _, target in ipairs(
		Players:GetPlayers()
	) do

		if target ~= player
			and target.Character then

			CreateHighlight(target)

			local highlight =
				target.Character:FindFirstChild(
					"RoleESP"
				)

			if not highlight then
				continue
			end

			local role

			if target.Name == MurdererName then

				role = "Murderer"

			elseif target.Name == SheriffName then

				role = "Sheriff"

			elseif target.Name == HeroName then

				role = "Hero"

			else

				role = "Innocent"
			end

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
			target.Character:FindFirstChild(
				"RoleESP"
			)

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

	local character =
		player.Character

	if not character then
		return
	end

	for _, object in ipairs(
		character:GetDescendants()
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
-- DRAG MENU
--==================================================

local dragging = false
local dragStart
local dragStartPosition

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
		dragStartPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if guiLocked then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		local delta =
			input.Position - dragStart

		frame.Position = UDim2.new(
			dragStartPosition.X.Scale,
			dragStartPosition.X.Offset + delta.X,

			dragStartPosition.Y.Scale,
			dragStartPosition.Y.Offset + delta.Y
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

	if minimized then

		content.Visible = false

		frame.Size =
			UDim2.fromOffset(280, 48)

		minimizeButton.Text = "+"

	else

		content.Visible = true

		frame.Size =
			UDim2.fromOffset(280, 330)

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