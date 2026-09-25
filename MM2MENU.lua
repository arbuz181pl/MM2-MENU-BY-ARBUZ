--//==================================================
--// MM2 MENU BY ARBUZ v0.9BETA
--//==================================================
--// LocalScript
--// StarterPlayer > StarterPlayerScripts
--//==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

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
local flingThirdParty = false
local flyEnabled = false
local autoNotifyRoles = false
local autoKillAll = false
local autoGunTP = false
local autoSendMurdererChat = false

local antiVoidEnabled = false
local antiFlingEnabled = false

local flySpeed = 1

local speedhackEnabled = false
local speedhackSpeed = 16

local guiLocked = false
local minimized = false
local menuVisible = true

local espEnabled = {
	Innocent = false,
	Murderer = false,
	Sheriff = false,
	Hero = false,
}

local originalCollision = {}

--==================================================
-- AUTO CHAT MURDERER VARIABLES
--==================================================

local lastChatSentMurderer = nil
local roundActive = false
local chatSendCooldown = 0

--==================================================
-- FLY VARIABLES
--==================================================

local flyPanelOpen = false
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyCharacter = nil
local flyHumanoid = nil
local flyRoot = nil

local flyControls = { f = 0, b = 0, l = 0, r = 0, up = 0, down = 0 }
local lastFlyControls = { f = 0, b = 0, l = 0, r = 0, up = 0, down = 0 }
local flyCurrentSpeed = 0
local flyMaxSpeed = 50

--==================================================
-- FLING ON TOUCH VARIABLES
--==================================================

local flingTouchActive = false
local flingTouchThread = nil

--==================================================
-- ANTI VOID / ANTI FLING VARIABLES
--==================================================

local VOID_Y_THRESHOLD = -50
local antiVoidCooldown = false

local ANTI_FLING_MAX_SPEED = 200
local ANTI_FLING_MAX_ANGULAR = 500
local lastSafePosition = nil
local lastSafeUpdate = 0

pcall(function()
	if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
		local detection = Instance.new("Decal")
		detection.Name = "juisdfj0i32i0eidsuf0iok"
		detection.Parent = ReplicatedStorage
	end
end)

--==================================================
-- PLAYER DATA (safe lookup — won't error if missing)
--==================================================

local GetPlayerData = nil
pcall(function()
	GetPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
end)

local MurdererName
local SheriffName
local HeroName

local lastNotifiedMurderer = nil
local lastNotifiedSheriff = nil
local lastNotifiedHero = nil

--==================================================
-- NOTIFICATION UTILITY
--==================================================

local function sendNotification(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 5
		})
	end)
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MM2MenuByArbuz"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = false
gui.Enabled = true
gui.DisplayOrder = 100
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
frame.Visible = true
frame.Active = true
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
header.Active = true
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "MM2 MENU BY ARBUZ v0.9BETA"
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 2
title.Parent = header

--==================================================
-- CLOSE BUTTON
--==================================================

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.new(1, -105, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
closeButton.Text = "✕"
closeButton.TextSize = 14
closeButton.TextColor3 = Color3.fromRGB(255, 200, 200)
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Active = true
closeButton.ZIndex = 5
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeButton

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
lockButton.Active = true
lockButton.ZIndex = 5
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
minimizeButton.Active = true
minimizeButton.ZIndex = 5
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 7)
minimizeCorner.Parent = minimizeButton

--==================================================
-- REOPEN BUTTON
--==================================================

local reopenButton = Instance.new("TextButton")
reopenButton.Name = "Reopen"
reopenButton.Size = UDim2.fromOffset(50, 50)
reopenButton.Position = UDim2.new(0, 15, 0.5, -25)
reopenButton.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
reopenButton.BorderSizePixel = 0
reopenButton.Text = "MM2"
reopenButton.TextColor3 = Color3.fromRGB(245, 245, 250)
reopenButton.TextSize = 13
reopenButton.Font = Enum.Font.GothamBold
reopenButton.AutoButtonColor = false
reopenButton.Active = true
reopenButton.Visible = false
reopenButton.ZIndex = 50
reopenButton.Parent = gui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(1, 0)
reopenCorner.Parent = reopenButton

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = Color3.fromRGB(80, 82, 90)
reopenStroke.Thickness = 2
reopenStroke.Parent = reopenButton

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -58)
content.Position = UDim2.fromOffset(10, 53)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 5
content.ScrollBarImageColor3 = Color3.fromRGB(75, 77, 85)
content.CanvasSize = UDim2.fromOffset(0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.Parent = frame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content

local currentLayoutOrder = 0
local function getLayoutOrder()
	currentLayoutOrder = currentLayoutOrder + 1
	return currentLayoutOrder
end

--==================================================
-- SECTION TITLE CREATOR
--==================================================

local function createSectionTitle(text)
	local label = Instance.new("TextLabel")
	label.Name = text .. "Header"
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(150, 153, 165)
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = getLayoutOrder()
	label.Parent = content
	return label
end

--==================================================
-- MOVEMENT SETTINGS
--==================================================

createSectionTitle("MOVEMENT SETTINGS")

local function createToggle(name, text)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 36)
	button.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(230, 230, 235)
	button.TextSize = 13
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.LayoutOrder = getLayoutOrder()
	button.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.fromOffset(5, 20)
	indicator.Position = UDim2.fromOffset(8, 8)
	indicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	indicator.BorderSizePixel = 0
	indicator.Parent = button

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator

	return button, indicator
end

-- NOCLIP
local noclipButton, noclipIndicator = createToggle("Noclip", "Noclip")

noclipButton.MouseButton1Click:Connect(function()
	noclip = not noclip
	if noclip then
		noclipButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		noclipIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
		originalCollision = {}

		if player.Character then
			for _, object in ipairs(player.Character:GetDescendants()) do
				if object:IsA("BasePart") then
					originalCollision[object] = object.CanCollide
					object.CanCollide = false
				end
			end
		end
	else
		noclipButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		noclipIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)

		for object, oldValue in pairs(originalCollision) do
			if object and object.Parent then
				object.CanCollide = oldValue
			end
		end
		originalCollision = {}
	end
end)

-- FLY BUTTON
local flyButton, flyIndicator = createToggle("Fly", "Fly")

-- FLY PANEL
local flyPanel = Instance.new("Frame")
flyPanel.Name = "FlyPanel"
flyPanel.Size = UDim2.fromOffset(210, 220)
flyPanel.Position = UDim2.new(0.5, 150, 0.5, -110)
flyPanel.BackgroundColor3 = Color3.fromRGB(22, 23, 28)
flyPanel.BorderSizePixel = 0
flyPanel.Visible = false
flyPanel.ZIndex = 20
flyPanel.Parent = gui

local flyPanelCorner = Instance.new("UICorner")
flyPanelCorner.CornerRadius = UDim.new(0, 12)
flyPanelCorner.Parent = flyPanel

local flyPanelStroke = Instance.new("UIStroke")
flyPanelStroke.Color = Color3.fromRGB(55, 57, 65)
flyPanelStroke.Thickness = 1
flyPanelStroke.Parent = flyPanel

-- FLY PANEL HEADER
local flyHeader = Instance.new("Frame")
flyHeader.Name = "Header"
flyHeader.Size = UDim2.new(1, 0, 0, 42)
flyHeader.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
flyHeader.BorderSizePixel = 0
flyHeader.ZIndex = 21
flyHeader.Parent = flyPanel

local flyHeaderCorner = Instance.new("UICorner")
flyHeaderCorner.CornerRadius = UDim.new(0, 12)
flyHeaderCorner.Parent = flyHeader

local flyTitle = Instance.new("TextLabel")
flyTitle.Name = "Title"
flyTitle.Size = UDim2.new(1, -20, 1, 0)
flyTitle.Position = UDim2.fromOffset(10, 0)
flyTitle.BackgroundTransparency = 1
flyTitle.Text = "FLY"
flyTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
flyTitle.TextSize = 13
flyTitle.Font = Enum.Font.GothamBold
flyTitle.TextXAlignment = Enum.TextXAlignment.Left
flyTitle.TextYAlignment = Enum.TextYAlignment.Center
flyTitle.ZIndex = 22
flyTitle.Parent = flyHeader

-- FLY ENABLE BUTTON
local flyEnableButton = Instance.new("TextButton")
flyEnableButton.Name = "Enable"
flyEnableButton.Size = UDim2.new(1, -20, 0, 36)
flyEnableButton.Position = UDim2.fromOffset(10, 52)
flyEnableButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
flyEnableButton.BorderSizePixel = 0
flyEnableButton.Text = "Enable Fly"
flyEnableButton.TextColor3 = Color3.fromRGB(230, 230, 235)
flyEnableButton.TextSize = 13
flyEnableButton.Font = Enum.Font.GothamSemibold
flyEnableButton.AutoButtonColor = false
flyEnableButton.ZIndex = 21
flyEnableButton.Parent = flyPanel

local flyEnableCorner = Instance.new("UICorner")
flyEnableCorner.CornerRadius = UDim.new(0, 8)
flyEnableCorner.Parent = flyEnableButton

local flyEnableIndicator = Instance.new("Frame")
flyEnableIndicator.Name = "Indicator"
flyEnableIndicator.Size = UDim2.fromOffset(5, 20)
flyEnableIndicator.Position = UDim2.fromOffset(8, 8)
flyEnableIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
flyEnableIndicator.BorderSizePixel = 0
flyEnableIndicator.ZIndex = 22
flyEnableIndicator.Parent = flyEnableButton

local flyEnableIndicatorCorner = Instance.new("UICorner")
flyEnableIndicatorCorner.CornerRadius = UDim.new(1, 0)
flyEnableIndicatorCorner.Parent = flyEnableIndicator

-- FLY SPEED LABEL
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Name = "SpeedLabel"
flySpeedLabel.Size = UDim2.new(1, -20, 0, 20)
flySpeedLabel.Position = UDim2.fromOffset(10, 98)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Speed: 1"
flySpeedLabel.TextColor3 = Color3.fromRGB(150, 153, 165)
flySpeedLabel.TextSize = 11
flySpeedLabel.Font = Enum.Font.GothamBold
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.ZIndex = 21
flySpeedLabel.Parent = flyPanel

-- FLY SPEED MINUS
local flyMinus = Instance.new("TextButton")
flyMinus.Name = "Minus"
flyMinus.Size = UDim2.fromOffset(36, 32)
flyMinus.Position = UDim2.fromOffset(10, 123)
flyMinus.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
flyMinus.BorderSizePixel = 0
flyMinus.Text = "-"
flyMinus.TextColor3 = Color3.fromRGB(235, 235, 240)
flyMinus.TextSize = 18
flyMinus.Font = Enum.Font.GothamBold
flyMinus.AutoButtonColor = false
flyMinus.ZIndex = 21
flyMinus.Parent = flyPanel

local flyMinusCorner = Instance.new("UICorner")
flyMinusCorner.CornerRadius = UDim.new(0, 7)
flyMinusCorner.Parent = flyMinus

-- FLY SPEED BOX
local flySpeedBox = Instance.new("TextBox")
flySpeedBox.Name = "Speed"
flySpeedBox.Size = UDim2.new(1, -96, 0, 32)
flySpeedBox.Position = UDim2.fromOffset(52, 123)
flySpeedBox.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
flySpeedBox.BorderSizePixel = 0
flySpeedBox.Text = "1"
flySpeedBox.TextColor3 = Color3.fromRGB(235, 235, 240)
flySpeedBox.TextSize = 12
flySpeedBox.Font = Enum.Font.GothamSemibold
flySpeedBox.ClearTextOnFocus = false
flySpeedBox.ZIndex = 21
flySpeedBox.Parent = flyPanel

local flySpeedBoxCorner = Instance.new("UICorner")
flySpeedBoxCorner.CornerRadius = UDim.new(0, 7)
flySpeedBoxCorner.Parent = flySpeedBox

-- FLY SPEED PLUS
local flyPlus = Instance.new("TextButton")
flyPlus.Name = "Plus"
flyPlus.Size = UDim2.fromOffset(36, 32)
flyPlus.Position = UDim2.new(1, -46, 0, 123)
flyPlus.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
flyPlus.BorderSizePixel = 0
flyPlus.Text = "+"
flyPlus.TextColor3 = Color3.fromRGB(235, 235, 240)
flyPlus.TextSize = 18
flyPlus.Font = Enum.Font.GothamBold
flyPlus.AutoButtonColor = false
flyPlus.ZIndex = 21
flyPlus.Parent = flyPanel

local flyPlusCorner = Instance.new("UICorner")
flyPlusCorner.CornerRadius = UDim.new(0, 7)
flyPlusCorner.Parent = flyPlus

-- FLY UP & DOWN
local flyUp = Instance.new("TextButton")
flyUp.Name = "Up"
flyUp.Size = UDim2.fromOffset(85, 32)
flyUp.Position = UDim2.fromOffset(10, 168)
flyUp.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
flyUp.BorderSizePixel = 0
flyUp.Text = "UP"
flyUp.TextColor3 = Color3.fromRGB(230, 230, 235)
flyUp.TextSize = 12
flyUp.Font = Enum.Font.GothamBold
flyUp.AutoButtonColor = false
flyUp.ZIndex = 21
flyUp.Parent = flyPanel

local flyUpCorner = Instance.new("UICorner")
flyUpCorner.CornerRadius = UDim.new(0, 7)
flyUpCorner.Parent = flyUp

local flyDown = Instance.new("TextButton")
flyDown.Name = "Down"
flyDown.Size = UDim2.fromOffset(85, 32)
flyDown.Position = UDim2.new(1, -95, 0, 168)
flyDown.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
flyDown.BorderSizePixel = 0
flyDown.Text = "DOWN"
flyDown.TextColor3 = Color3.fromRGB(230, 230, 235)
flyDown.TextSize = 12
flyDown.Font = Enum.Font.GothamBold
flyDown.AutoButtonColor = false
flyDown.ZIndex = 21
flyDown.Parent = flyPanel

local flyDownCorner = Instance.new("UICorner")
flyDownCorner.CornerRadius = UDim.new(0, 7)
flyDownCorner.Parent = flyDown

local function updateFlySpeed(value)
	value = tonumber(value)
	if not value then value = flySpeed end
	value = math.clamp(math.floor(value), 1, 500)
	flySpeed = value
	flySpeedLabel.Text = "Speed: " .. tostring(flySpeed)
	flySpeedBox.Text = tostring(flySpeed)
end

flyMinus.MouseButton1Click:Connect(function() updateFlySpeed(flySpeed - 1) end)
flyPlus.MouseButton1Click:Connect(function() updateFlySpeed(flySpeed + 1) end)
flySpeedBox.FocusLost:Connect(function() updateFlySpeed(flySpeedBox.Text) end)

local function stopFly()
	flyEnabled = false
	if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
	if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
	flyCurrentSpeed = 0

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
			for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
				pcall(function() humanoid:SetStateEnabled(state, true) end)
			end
			humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
		end
		local animate = character:FindFirstChild("Animate")
		if animate then animate.Disabled = false end
	end

	flyEnableButton.Text = "Enable Fly"
	flyEnableButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	flyEnableIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	flyButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	flyIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
end

local function startFly()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	stopFly()
	flyEnabled = true
	flyCharacter = character
	flyHumanoid = humanoid
	flyRoot = root

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.P = 90000
	flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyBodyGyro.CFrame = root.CFrame
	flyBodyGyro.Parent = root

	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
	flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBodyVelocity.Parent = root

	humanoid.PlatformStand = true
	local animate = character:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(0)
	end

	for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
		pcall(function() humanoid:SetStateEnabled(state, false) end)
	end
	humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

	flyEnableButton.Text = "Disable Fly"
	flyEnableButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
	flyEnableIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
	flyButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
	flyIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
end

flyEnableButton.MouseButton1Click:Connect(function()
	if flyEnabled then stopFly() else startFly() end
end)

flyButton.MouseButton1Click:Connect(function()
	flyPanelOpen = not flyPanelOpen
	flyPanel.Visible = flyPanelOpen
	if flyPanelOpen then
		flyButton.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
	else
		if flyEnabled then
			flyButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
			flyIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
		else
			flyButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
			flyIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.W then flyControls.f = 1
	elseif input.KeyCode == Enum.KeyCode.S then flyControls.b = -1
	elseif input.KeyCode == Enum.KeyCode.A then flyControls.l = -1
	elseif input.KeyCode == Enum.KeyCode.D then flyControls.r = 1
	elseif input.KeyCode == Enum.KeyCode.Space then flyControls.up = 1
	elseif input.KeyCode == Enum.KeyCode.LeftControl then flyControls.down = -1
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then flyControls.f = 0
	elseif input.KeyCode == Enum.KeyCode.S then flyControls.b = 0
	elseif input.KeyCode == Enum.KeyCode.A then flyControls.l = 0
	elseif input.KeyCode == Enum.KeyCode.D then flyControls.r = 0
	elseif input.KeyCode == Enum.KeyCode.Space then flyControls.up = 0
	elseif input.KeyCode == Enum.KeyCode.LeftControl then flyControls.down = 0
	end
end)

RunService.RenderStepped:Connect(function()
	if not flyEnabled or not flyBodyVelocity or not flyBodyGyro then return end
	local character = player.Character
	if not character then stopFly() return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not humanoid or not root or not camera then return end

	local mobileMove = humanoid.MoveDirection
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local up = Vector3.new(0, 1, 0)

	local keyboardForward = flyControls.f + flyControls.b
	local keyboardRight = flyControls.l + flyControls.r
	local keyboardVertical = flyControls.up + flyControls.down

	local horizontalLook = Vector3.new(look.X, 0, look.Z)
	local horizontalRight = Vector3.new(right.X, 0, right.Z)
	if horizontalLook.Magnitude > 0 then horizontalLook = horizontalLook.Unit end
	if horizontalRight.Magnitude > 0 then horizontalRight = horizontalRight.Unit end

	local mobileForward, mobileRight = 0, 0
	if mobileMove.Magnitude > 0 then
		mobileForward = mobileMove:Dot(horizontalLook)
		mobileRight = mobileMove:Dot(horizontalRight)
	end

	local forward = math.clamp(keyboardForward + mobileForward, -1, 1)
	local rightAmount = math.clamp(keyboardRight + mobileRight, -1, 1)
	local vertical = math.clamp(keyboardVertical, -1, 1)
	local moving = math.abs(forward) > 0.01 or math.abs(rightAmount) > 0.01 or math.abs(vertical) > 0.01

	if moving then
		flyCurrentSpeed = flyCurrentSpeed + 0.5 + (flyCurrentSpeed / math.max(flyMaxSpeed, 1))
		if flyCurrentSpeed > flyMaxSpeed then flyCurrentSpeed = flyMaxSpeed end
	else
		if flyCurrentSpeed ~= 0 then
			flyCurrentSpeed = flyCurrentSpeed - 1
			if flyCurrentSpeed < 0 then flyCurrentSpeed = 0 end
		end
	end

	local direction = look * forward + right * rightAmount + up * vertical
	if direction.Magnitude > 0 then
		direction = direction.Unit
		flyBodyVelocity.Velocity = direction * flyCurrentSpeed
		lastFlyControls.f = forward
		lastFlyControls.b = 0
		lastFlyControls.l = rightAmount
		lastFlyControls.r = 0
		lastFlyControls.up = vertical
		lastFlyControls.down = 0
	elseif flyCurrentSpeed ~= 0 then
		local lastDirection = look * (lastFlyControls.f + lastFlyControls.b) + right * (lastFlyControls.l + lastFlyControls.r) + up * (lastFlyControls.up + lastFlyControls.down)
		if lastDirection.Magnitude > 0 then
			flyBodyVelocity.Velocity = lastDirection.Unit * flyCurrentSpeed
		else
			flyBodyVelocity.Velocity = Vector3.zero
		end
	else
		flyBodyVelocity.Velocity = Vector3.zero
	end

	flyBodyGyro.CFrame = camera.CFrame * CFrame.Angles(-math.rad(forward * 50 * flyCurrentSpeed / math.max(flyMaxSpeed, 1)), 0, 0)
	humanoid.PlatformStand = true
end)

flyUp.MouseButton1Down:Connect(function() flyControls.up = 1 end)
flyUp.MouseButton1Up:Connect(function() flyControls.up = 0 end)
flyDown.MouseButton1Down:Connect(function() flyControls.down = -1 end)
flyDown.MouseButton1Up:Connect(function() flyControls.down = 0 end)

-- INFINITY JUMP
local infinityJumpButton, infinityJumpIndicator = createToggle("InfinityJump", "Infinity Jump")

infinityJumpButton.MouseButton1Click:Connect(function()
	infinityJump = not infinityJump
	if infinityJump then
		infinityJumpButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		infinityJumpIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
	else
		infinityJumpButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		infinityJumpIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end
end)

UserInputService.JumpRequest:Connect(function()
	if not infinityJump then return end
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

--==================================================
-- FLING 3RD PARTY
--==================================================

local flingThirdPartyButton, flingThirdPartyIndicator = createToggle("FlingOnTouch", "Fling 3rd party")

flingThirdPartyButton.MouseButton1Click:Connect(function()
	flingThirdParty = not flingThirdParty
	if flingThirdParty then
		flingThirdPartyButton.BackgroundColor3 = Color3.fromRGB(70, 45, 35)
		flingThirdPartyIndicator.BackgroundColor3 = Color3.fromRGB(230, 100, 55)
		local success, err = pcall(function()
			loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Ultimate-Fling-GUI-41909"))()
		end)
		if not success then
			sendNotification("MM2 Menu", "Failed to load 3rd party fling script.")
		end
	else
		flingThirdPartyButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		flingThirdPartyIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end
end)

--==================================================
-- FLING ON TOUCH
--==================================================

local function flingOnTouchLoop()
	local lp = player
	local c, hrp, vel, movel = nil, nil, nil, 0.1

	while flingTouchActive do
		RunService.Heartbeat:Wait()
		c = lp.Character
		hrp = c and c:FindFirstChild("HumanoidRootPart")

		if hrp then
			vel = hrp.Velocity
			hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
			RunService.RenderStepped:Wait()
			hrp.Velocity = vel
			RunService.Stepped:Wait()
			hrp.Velocity = vel + Vector3.new(0, movel, 0)
			movel = -movel
		end
	end
end

local flingOnTouchButton, flingOnTouchIndicator = createToggle("FlingOnTouchIntegrated", "Fling On Touch")

flingOnTouchButton.MouseButton1Click:Connect(function()
	flingOnTouch = not flingOnTouch
	if flingOnTouch then
		flingOnTouchButton.BackgroundColor3 = Color3.fromRGB(70, 45, 35)
		flingOnTouchIndicator.BackgroundColor3 = Color3.fromRGB(230, 100, 55)
		flingTouchActive = true
		flingTouchThread = coroutine.create(flingOnTouchLoop)
		coroutine.resume(flingTouchThread)
	else
		flingOnTouchButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		flingOnTouchIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
		flingTouchActive = false
	end
end)

-- SPEEDHACK
local speedhackButton, speedhackIndicator = createToggle("Speedhack", "Speedhack")

local speedhackRow = Instance.new("Frame")
speedhackRow.Name = "SpeedhackRow"
speedhackRow.Size = UDim2.new(1, 0, 0, 32)
speedhackRow.BackgroundTransparency = 1
speedhackRow.LayoutOrder = getLayoutOrder()
speedhackRow.Parent = content

local speedhackMinus = Instance.new("TextButton")
speedhackMinus.Name = "Minus"
speedhackMinus.Size = UDim2.fromOffset(36, 32)
speedhackMinus.Position = UDim2.fromOffset(0, 0)
speedhackMinus.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
speedhackMinus.BorderSizePixel = 0
speedhackMinus.Text = "-"
speedhackMinus.TextColor3 = Color3.fromRGB(235, 235, 240)
speedhackMinus.TextSize = 18
speedhackMinus.Font = Enum.Font.GothamBold
speedhackMinus.AutoButtonColor = false
speedhackMinus.Parent = speedhackRow

local speedhackMinusCorner = Instance.new("UICorner")
speedhackMinusCorner.CornerRadius = UDim.new(0, 7)
speedhackMinusCorner.Parent = speedhackMinus

local speedhackBox = Instance.new("TextBox")
speedhackBox.Name = "Speed"
speedhackBox.Size = UDim2.fromOffset(50, 32)
speedhackBox.Position = UDim2.fromOffset(42, 0)
speedhackBox.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
speedhackBox.BorderSizePixel = 0
speedhackBox.Text = "16"
speedhackBox.TextColor3 = Color3.fromRGB(235, 235, 240)
speedhackBox.TextSize = 12
speedhackBox.Font = Enum.Font.GothamSemibold
speedhackBox.ClearTextOnFocus = false
speedhackBox.Parent = speedhackRow

local speedhackBoxCorner = Instance.new("UICorner")
speedhackBoxCorner.CornerRadius = UDim.new(0, 7)
speedhackBoxCorner.Parent = speedhackBox

local speedhackPlus = Instance.new("TextButton")
speedhackPlus.Name = "Plus"
speedhackPlus.Size = UDim2.fromOffset(36, 32)
speedhackPlus.Position = UDim2.fromOffset(100, 0)
speedhackPlus.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
speedhackPlus.BorderSizePixel = 0
speedhackPlus.Text = "+"
speedhackPlus.TextColor3 = Color3.fromRGB(235, 235, 240)
speedhackPlus.TextSize = 18
speedhackPlus.Font = Enum.Font.GothamBold
speedhackPlus.AutoButtonColor = false
speedhackPlus.Parent = speedhackRow

local speedhackPlusCorner = Instance.new("UICorner")
speedhackPlusCorner.CornerRadius = UDim.new(0, 7)
speedhackPlusCorner.Parent = speedhackPlus

local speedhackValueLabel = Instance.new("TextLabel")
speedhackValueLabel.Name = "SpeedLabel"
speedhackValueLabel.Size = UDim2.new(1, -145, 0, 32)
speedhackValueLabel.Position = UDim2.fromOffset(145, 0)
speedhackValueLabel.BackgroundTransparency = 1
speedhackValueLabel.Text = "WalkSpeed"
speedhackValueLabel.TextColor3 = Color3.fromRGB(150, 153, 165)
speedhackValueLabel.TextSize = 11
speedhackValueLabel.Font = Enum.Font.GothamBold
speedhackValueLabel.TextXAlignment = Enum.TextXAlignment.Left
speedhackValueLabel.Parent = speedhackRow

local function updateSpeedhack(value)
	value = tonumber(value)
	if not value then value = speedhackSpeed end
	value = math.clamp(math.floor(value), 1, 500)
	speedhackSpeed = value
	speedhackBox.Text = tostring(speedhackSpeed)
end

speedhackMinus.MouseButton1Click:Connect(function() updateSpeedhack(speedhackSpeed - 1) end)
speedhackPlus.MouseButton1Click:Connect(function() updateSpeedhack(speedhackSpeed + 1) end)
speedhackBox.FocusLost:Connect(function() updateSpeedhack(speedhackBox.Text) end)

speedhackButton.MouseButton1Click:Connect(function()
	speedhackEnabled = not speedhackEnabled
	if speedhackEnabled then
		speedhackButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		speedhackIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.WalkSpeed = speedhackSpeed end
		end
	else
		speedhackButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		speedhackIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.WalkSpeed = 16 end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not speedhackEnabled then return end
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.WalkSpeed = speedhackSpeed end
end)

--==================================================
-- ROLE ESP SETTINGS
--==================================================

createSectionTitle("ROLE ESP SETTINGS")

local espButtons = {}

local function createESPButton(role)
	local button, indicator = createToggle(role .. "ESP", role .. " ESP")
	espButtons[role] = { Button = button, Indicator = indicator }

	button.MouseButton1Click:Connect(function()
		espEnabled[role] = not espEnabled[role]
		button.Text = role .. " ESP"
		if espEnabled[role] then
			button.BackgroundColor3 = ROLE_COLORS[role]:Lerp(Color3.fromRGB(20, 20, 25), 0.65)
			indicator.BackgroundColor3 = ROLE_COLORS[role]
		else
			button.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
			indicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
		end
	end)
end

createESPButton("Innocent")
createESPButton("Murderer")
createESPButton("Sheriff")
createESPButton("Hero")

--==================================================
-- NOTIFIER SETTINGS
--==================================================

createSectionTitle("NOTIFIER SETTINGS")

local function getFormattedRoleText(roleName, userName)
	if not userName then return roleName .. ": None" end
	local targetPlayer = Players:FindFirstChild(userName)
	if targetPlayer then
		return roleName .. ": " .. targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
	end
	return roleName .. ": " .. userName
end

local function notifyAllRoles()
	local mText = getFormattedRoleText("Murderer", MurdererName)
	local sText = getFormattedRoleText("Sheriff", SheriffName)
	local hText = getFormattedRoleText("Hero", HeroName)
	sendNotification("MM2 Roles", mText .. "\n" .. sText .. "\n" .. hText)
end

local notifyRolesButton = Instance.new("TextButton")
notifyRolesButton.Name = "NotifyRoles"
notifyRolesButton.Size = UDim2.new(1, 0, 0, 36)
notifyRolesButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
notifyRolesButton.BorderSizePixel = 0
notifyRolesButton.Text = "Notify Roles"
notifyRolesButton.TextColor3 = Color3.fromRGB(230, 230, 235)
notifyRolesButton.TextSize = 13
notifyRolesButton.Font = Enum.Font.GothamSemibold
notifyRolesButton.AutoButtonColor = false
notifyRolesButton.LayoutOrder = getLayoutOrder()
notifyRolesButton.Parent = content

local notifyCorner = Instance.new("UICorner")
notifyCorner.CornerRadius = UDim.new(0, 8)
notifyCorner.Parent = notifyRolesButton

notifyRolesButton.MouseButton1Click:Connect(function()
	notifyAllRoles()
end)

local autoNotifyButton, autoNotifyIndicator = createToggle("AutoNotifyRound", "Auto Notify Round")

autoNotifyButton.MouseButton1Click:Connect(function()
	autoNotifyRoles = not autoNotifyRoles
	if autoNotifyRoles then
		autoNotifyButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		autoNotifyIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
	else
		autoNotifyButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		autoNotifyIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end
end)

--==================================================
-- AUTO SEND MURDERER IN CHAT
--==================================================

local autoMurdererChatButton, autoMurdererChatIndicator = createToggle("AutoMurdererChat", "Auto Send Murderer In Chat")

autoMurdererChatButton.MouseButton1Click:Connect(function()
	autoSendMurdererChat = not autoSendMurdererChat
	if autoSendMurdererChat then
		autoMurdererChatButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		autoMurdererChatIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
		lastChatSentMurderer = nil
	else
		autoMurdererChatButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		autoMurdererChatIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
		lastChatSentMurderer = nil
	end
end)

--==================================================
-- SPAWN & LOBBY PROTECTION UTILITIES
--==================================================

local function isPlayerInSpawn(target)
	if not target or not target.Character then return true end

	local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyMap")
	if lobby and target.Character:IsDescendantOf(lobby) then
		return true
	end

	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return true end

	for _, spawnObject in ipairs(workspace:GetDescendants()) do
		if spawnObject:IsA("SpawnLocation") or (spawnObject:IsA("BasePart") and spawnObject.Name == "SpawnPoint") then
			if (targetRoot.Position - spawnObject.Position).Magnitude < 35 then
				return true
			end
		end
	end

	return false
end

--==================================================
-- MURDERER SETTINGS
--==================================================

createSectionTitle("MURDERER SETTINGS")

local function getKnife()
	local character = player.Character
	if not character then return nil end

	local knife = character:FindFirstChild("Knife")
	if not knife then
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			knife = backpack:FindFirstChild("Knife")
			if knife then knife.Parent = character end
		end
	end
	return knife
end

local function attackTarget(target)
	if not target or target == player or not target.Character then return end
	if isPlayerInSpawn(target) then return end

	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if targetRoot and myRoot then
		local knife = getKnife()
		if knife then
			myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.5)
			knife:Activate()
		end
	end
end

local function killAllPlayers()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then
			local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 and not isPlayerInSpawn(target) then
				attackTarget(target)
				task.wait(0.12)
			end
		end
	end
end

local function killTargetByName(name)
	if not name then return end
	local target = Players:FindFirstChild(name)
	if target then
		attackTarget(target)
	end
end

local autoKillButton, autoKillIndicator = createToggle("AutoKillAll", "Auto Kill All")

autoKillButton.MouseButton1Click:Connect(function()
	autoKillAll = not autoKillAll
	if autoKillAll then
		autoKillButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		autoKillIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
	else
		autoKillButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		autoKillIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end
end)

local function createActionButton(name, text)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 36)
	button.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(230, 230, 235)
	button.TextSize = 13
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.LayoutOrder = getLayoutOrder()
	button.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	return button
end

local killAllButton = createActionButton("KillAllNow", "Kill All Now")
killAllButton.MouseButton1Click:Connect(function()
	killAllPlayers()
end)

local killSheriffButton = createActionButton("KillSheriffNow", "Kill Sheriff Now")
killSheriffButton.MouseButton1Click:Connect(function()
	killTargetByName(SheriffName)
end)

local killHeroButton = createActionButton("KillHeroNow", "Kill Hero Now")
killHeroButton.MouseButton1Click:Connect(function()
	killTargetByName(HeroName)
end)

--==================================================
-- SHERIFF SETTINGS
--==================================================

createSectionTitle("SHERIFF SETTINGS")

local function getGun()
	local character = player.Character
	if not character then return nil end

	local gun = character:FindFirstChild("Gun")
	if not gun then
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			gun = backpack:FindFirstChild("Gun")
			if gun then gun.Parent = character end
		end
	end
	return gun
end

local function shootMurderer()
	if not MurdererName then
		sendNotification("MM2 Menu", "Murderer not found yet!")
		return
	end

	local target = Players:FindFirstChild(MurdererName)
	if not target or not target.Character then return end
	if isPlayerInSpawn(target) then
		sendNotification("MM2 Menu", "Murderer is in spawn/lobby!")
		return
	end

	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if targetRoot and myRoot then
		local gun = getGun()
		if gun then
			myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
			task.wait(0.05)

			local shootRemote = gun:FindFirstChild("Shoot") or ReplicatedStorage:FindFirstChild("Shoot", true)
			if shootRemote and shootRemote:IsA("RemoteEvent") then
				shootRemote:FireServer(targetRoot.CFrame, targetRoot.Position)
			else
				gun:Activate()
			end
		else
			sendNotification("MM2 Menu", "You do not have a Gun equipped!")
		end
	end
end

local killMurdererButton = createActionButton("KillMurdererNow", "Kill Murderer Now")
killMurdererButton.MouseButton1Click:Connect(function()
	shootMurderer()
end)

--==================================================
-- TELEPORT SETTINGS
--==================================================

createSectionTitle("TELEPORT SETTINGS")

local function teleportToGun()
	local character = player.Character
	if not character then return false end
	local myRoot = character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return false end

	local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("Gun", true)
	if gunDrop then
		if gunDrop:IsA("BasePart") then
			myRoot.CFrame = gunDrop.CFrame + Vector3.new(0, 3, 0)
			return true
		elseif gunDrop:IsA("Model") then
			local primary = gunDrop.PrimaryPart or gunDrop:FindFirstChildOfClass("BasePart")
			if primary then
				myRoot.CFrame = primary.CFrame + Vector3.new(0, 3, 0)
				return true
			end
		end
	end
	return false
end

local autoGunButton, autoGunIndicator = createToggle("AutoGunTP", "Auto Teleport To Gun")

autoGunButton.MouseButton1Click:Connect(function()
	autoGunTP = not autoGunTP
	if autoGunTP then
		autoGunButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		autoGunIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
	else
		autoGunButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		autoGunIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end
end)

local spawnTeleportButton = createActionButton("SpawnTeleport", "Teleport To Spawn")
spawnTeleportButton.MouseButton1Click:Connect(function()
	local character = player.Character
	if not character then return end
	local myRoot = character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
	if spawnLocation then
		myRoot.CFrame = spawnLocation.CFrame + Vector3.new(0, 3, 0)
		return
	end

	local spawnPoint = workspace:FindFirstChild("Spawn", true)
	if spawnPoint and spawnPoint:IsA("BasePart") then
		myRoot.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
	end
end)

local gunTeleportButton = createActionButton("GunTeleport", "Teleport To Gun")
gunTeleportButton.MouseButton1Click:Connect(function()
	if not teleportToGun() then
		sendNotification("MM2 Menu", "No dropped gun found on the map!")
	end
end)

local playerTeleportButton = createActionButton("PlayerTeleport", "Teleport To Player")
local killSelectedButton = createActionButton("KillSelectedPlayer", "Kill Selected Player")

local selectedPlayer = nil

local playerDropdown = Instance.new("TextButton")
playerDropdown.Name = "PlayerDropdown"
playerDropdown.Size = UDim2.new(1, 0, 0, 36)
playerDropdown.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
playerDropdown.BorderSizePixel = 0
playerDropdown.Text = "Select Player"
playerDropdown.TextColor3 = Color3.fromRGB(230, 230, 235)
playerDropdown.TextSize = 12
playerDropdown.Font = Enum.Font.GothamSemibold
playerDropdown.AutoButtonColor = false
playerDropdown.LayoutOrder = getLayoutOrder()
playerDropdown.Parent = content

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 8)
dropdownCorner.Parent = playerDropdown

local dropdownOpen = false

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, 0, 0, 120)
playerList.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
playerList.BorderSizePixel = 0
playerList.Visible = false
playerList.ClipsDescendants = true
playerList.CanvasSize = UDim2.fromOffset(0, 0)
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ScrollingDirection = Enum.ScrollingDirection.Y
playerList.ScrollBarThickness = 5
playerList.ScrollBarImageColor3 = Color3.fromRGB(75, 77, 85)
playerList.LayoutOrder = getLayoutOrder()
playerList.Parent = content

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 8)
playerListCorner.Parent = playerList

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.SortOrder = Enum.SortOrder.Name
playerListLayout.Parent = playerList

local function refreshPlayerList()
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local option = Instance.new("TextButton")
			option.Name = target.Name
			option.Size = UDim2.new(1, -10, 0, 30)
			option.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
			option.BorderSizePixel = 0
			option.Text = target.DisplayName .. " (@" .. target.Name .. ")"
			option.TextColor3 = Color3.fromRGB(230, 230, 235)
			option.TextSize = 12
			option.Font = Enum.Font.GothamSemibold
			option.AutoButtonColor = false
			option.Parent = playerList

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = option

			option.MouseButton1Click:Connect(function()
				selectedPlayer = target
				playerDropdown.Text = "Selected: " .. target.Name
				dropdownOpen = false
				playerList.Visible = false
				playerList.CanvasPosition = Vector2.new(0, 0)
			end)
		end
	end

	task.defer(function()
		playerList.CanvasSize = UDim2.fromOffset(0, playerListLayout.AbsoluteContentSize.Y + 5)
	end)
end

playerDropdown.MouseButton1Click:Connect(function()
	dropdownOpen = not dropdownOpen
	if dropdownOpen then
		refreshPlayerList()
		playerList.Visible = true
	else
		playerList.Visible = false
		playerList.CanvasPosition = Vector2.new(0, 0)
	end
end)

playerTeleportButton.MouseButton1Click:Connect(function()
	if not selectedPlayer or not selectedPlayer.Character then return end
	local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
	local character = player.Character
	if character and targetRoot then
		local myRoot = character:FindFirstChild("HumanoidRootPart")
		if myRoot then myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0) end
	end
end)

killSelectedButton.MouseButton1Click:Connect(function()
	if selectedPlayer then attackTarget(selectedPlayer) end
end)

Players.PlayerAdded:Connect(function() if dropdownOpen then refreshPlayerList() end end)
Players.PlayerRemoving:Connect(function(target)
	if selectedPlayer == target then
		selectedPlayer = nil
		playerDropdown.Text = "Select Player"
	end
	if dropdownOpen then refreshPlayerList() end
end)

local murdererTeleport = createActionButton("TeleportMurderer", "Teleport To Murderer")
local sheriffTeleport = createActionButton("TeleportSheriff", "Teleport To Sheriff")
local heroTeleport = createActionButton("TeleportHero", "Teleport To Hero")

local function teleportToPlayerByName(name)
	if not name then return end
	local target = Players:FindFirstChild(name)
	if not target or not target.Character then return end
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local character = player.Character
	if character and targetRoot then
		local myRoot = character:FindFirstChild("HumanoidRootPart")
		if myRoot then myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0) end
	end
end

murdererTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(MurdererName) end)
sheriffTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(SheriffName) end)
heroTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(HeroName) end)

--==================================================
-- UTILITY SETTINGS
--==================================================

createSectionTitle("UTILITY SETTINGS")

local antiVoidButton, antiVoidIndicator = createToggle("AntiVoid", "Anti Fall Down (Void)")
local antiFlingButton, antiFlingIndicator = createToggle("AntiFling", "Anti Fling")

antiVoidButton.MouseButton1Click:Connect(function()
	antiVoidEnabled = not antiVoidEnabled
	if antiVoidEnabled then
		antiVoidButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		antiVoidIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
	else
		antiVoidButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		antiVoidIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end
end)

antiFlingButton.MouseButton1Click:Connect(function()
	antiFlingEnabled = not antiFlingEnabled
	if antiFlingEnabled then
		antiFlingButton.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
		antiFlingIndicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
	else
		antiFlingButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		antiFlingIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end
end)

local function resetAllToggles()
	if noclip then
		noclip = false
		noclipButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		noclipIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
		for object, oldValue in pairs(originalCollision) do
			if object and object.Parent then
				object.CanCollide = oldValue
			end
		end
		originalCollision = {}
	end

	if flyEnabled then stopFly() end
	flyPanelOpen = false
	flyPanel.Visible = false

	if infinityJump then
		infinityJump = false
		infinityJumpButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		infinityJumpIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end

	if flingThirdParty then
		flingThirdParty = false
		flingThirdPartyButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		flingThirdPartyIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end

	if flingOnTouch then
		flingOnTouch = false
		flingTouchActive = false
		flingOnTouchButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		flingOnTouchIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end

	if speedhackEnabled then
		speedhackEnabled = false
		speedhackButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		speedhackIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.WalkSpeed = 16 end
		end
	end

	for role, state in pairs(espEnabled) do
		if state then
			espEnabled[role] = false
			if espButtons[role] then
				espButtons[role].Button.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
				espButtons[role].Indicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
			end
		end
	end

	if autoNotifyRoles then
		autoNotifyRoles = false
		autoNotifyButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		autoNotifyIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end

	if autoSendMurdererChat then
		autoSendMurdererChat = false
		autoMurdererChatButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		autoMurdererChatIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
		lastChatSentMurderer = nil
	end

	if autoKillAll then
		autoKillAll = false
		autoKillButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		autoKillIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end

	if autoGunTP then
		autoGunTP = false
		autoGunButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		autoGunIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end

	if antiVoidEnabled then
		antiVoidEnabled = false
		antiVoidButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		antiVoidIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end

	if antiFlingEnabled then
		antiFlingEnabled = false
		antiFlingButton.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
		antiFlingIndicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	end

	sendNotification("MM2 Menu", "All features turned off")
end

local turnOffAllButton = Instance.new("TextButton")
turnOffAllButton.Name = "TurnOffAll"
turnOffAllButton.Size = UDim2.new(1, 0, 0, 36)
turnOffAllButton.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
turnOffAllButton.BorderSizePixel = 0
turnOffAllButton.Text = "TURN OFF ALL"
turnOffAllButton.TextColor3 = Color3.fromRGB(255, 200, 200)
turnOffAllButton.TextSize = 13
turnOffAllButton.Font = Enum.Font.GothamBold
turnOffAllButton.AutoButtonColor = false
turnOffAllButton.LayoutOrder = getLayoutOrder()
turnOffAllButton.Parent = content

local turnOffCorner = Instance.new("UICorner")
turnOffCorner.CornerRadius = UDim.new(0, 8)
turnOffCorner.Parent = turnOffAllButton

turnOffAllButton.MouseButton1Click:Connect(resetAllToggles)

--==================================================
-- ESP SYSTEM
--==================================================

local highlights = {}

local function CreateHighlight(target)
	if target == player or not target.Character then return end

	local highlight = target.Character:FindFirstChild("RoleESP")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "RoleESP"
		highlight.FillTransparency = 0.45
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = target.Character
	end
	highlights[target] = highlight
end

local function IsAlive(target)
	if not target or not target.Character then return false end
	local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0
end

local function GetRoles()
	MurdererName = nil
	SheriffName = nil
	HeroName = nil

	if not GetPlayerData then return end

	local success, result = pcall(function() return GetPlayerData:InvokeServer() end)
	if not success or type(result) ~= "table" then return end

	for name, data in pairs(result) do
		if type(data) == "table" then
			local role = data.Role
			if role == "Murderer" then MurdererName = tostring(name)
			elseif role == "Sheriff" then SheriffName = tostring(name)
			elseif role == "Hero" then HeroName = tostring(name) end
		elseif type(data) == "string" then
			if data == "Murderer" then MurdererName = tostring(name)
			elseif data == "Sheriff" then SheriffName = tostring(name)
			elseif data == "Hero" then HeroName = tostring(name) end
		end
	end

	for key, data in pairs(result) do
		if typeof(key) == "Instance" and key:IsA("Player") then
			local role = type(data) == "table" and data.Role or (type(data) == "string" and data or nil)
			if role == "Murderer" then MurdererName = key.Name
			elseif role == "Sheriff" then SheriffName = key.Name
			elseif role == "Hero" then HeroName = key.Name end
		end
	end

	for _, target in ipairs(Players:GetPlayers()) do
		local role = target:GetAttribute("Role")
		if role == "Murderer" then MurdererName = target.Name
		elseif role == "Sheriff" then SheriffName = target.Name
		elseif role == "Hero" then HeroName = target.Name end
	end

	if autoNotifyRoles then
		if (MurdererName and MurdererName ~= lastNotifiedMurderer)
			or (SheriffName and SheriffName ~= lastNotifiedSheriff)
			or (HeroName and HeroName ~= lastNotifiedHero) then
			lastNotifiedMurderer = MurdererName
			lastNotifiedSheriff = SheriffName
			lastNotifiedHero = HeroName
			notifyAllRoles()
		end
	end
end

--==================================================
-- ESP HIGHLIGHT UPDATE
-- When player dies: reset color to green (Innocent) regardless of role
--==================================================

local function UpdateHighlights()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then
			CreateHighlight(target)
			local highlight = target.Character:FindFirstChild("RoleESP")
			if not highlight then continue end

			local role
			if MurdererName and target.Name == MurdererName then role = "Murderer"
			elseif SheriffName and target.Name == SheriffName then role = "Sheriff"
			elseif HeroName and target.Name == HeroName then role = "Hero"
			else role = "Innocent" end

			-- If player is dead, force green (Innocent) highlight regardless of role
			if not IsAlive(target) then
				-- Only show the dead-green highlight if Innocent ESP is on
				if espEnabled.Innocent then
					local deadColor = ROLE_COLORS.Innocent
					highlight.FillColor = deadColor
					highlight.OutlineColor = deadColor
					highlight.FillTransparency = 0.65
					highlight.OutlineTransparency = 0
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Enabled = true
				else
					highlight.Enabled = false
				end
			else
				-- Alive player — use role-based color
				if espEnabled[role] then
					local color = ROLE_COLORS[role]
					highlight.FillColor = color
					highlight.OutlineColor = color
					highlight.FillTransparency = 0.45
					highlight.OutlineTransparency = 0
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Enabled = true
				else
					highlight.Enabled = false
				end
			end
		end
	end
end

local function RemoveHighlight(target)
	if target.Character then
		local highlight = target.Character:FindFirstChild("RoleESP")
		if highlight then highlight:Destroy() end
	end
	highlights[target] = nil
end

for _, target in ipairs(Players:GetPlayers()) do
	if target ~= player then
		target.CharacterAdded:Connect(function()
			task.wait(0.2)
			CreateHighlight(target)
			UpdateHighlights()
		end)
		if target.Character then CreateHighlight(target) end
	end
end

Players.PlayerAdded:Connect(function(target)
	target.CharacterAdded:Connect(function()
		task.wait(0.2)
		CreateHighlight(target)
		UpdateHighlights()
	end)
end)

Players.PlayerRemoving:Connect(function(target) RemoveHighlight(target) end)

--==================================================
-- AUTO CHAT MURDERER SENDER
--==================================================

local function sendChatMessage(message)
	local sent = false

	pcall(function()
		local TCS = game:GetService("TextChatService")
		if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
			local channels = TCS:FindFirstChild("TextChannels")
			if channels then
				local general = channels:FindFirstChild("RBXGeneral")
				if general then
					general:SendAsync(message)
					sent = true
				end
			end
		end
	end)

	if sent then return true end

	pcall(function()
		StarterGui:SetCore("ChatSendMessage", message)
		sent = true
	end)

	return sent
end

local function checkAutoSendMurderer()
	if not autoSendMurdererChat then return end

	local murdererDetected = MurdererName ~= nil

	if murdererDetected and not roundActive then
		roundActive = true
		lastChatSentMurderer = nil
	end

	if not murdererDetected and roundActive then
		roundActive = false
		lastChatSentMurderer = nil
		return
	end

	if not murdererDetected then return end

	if lastChatSentMurderer == MurdererName then return end

	local now = tick()
	if now - chatSendCooldown < 1 then return end

	local targetPlayer = Players:FindFirstChild(MurdererName)
	local displayText = MurdererName
	if targetPlayer then
		displayText = targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
	end

	local message = "Murderer is: " .. displayText
	if sendChatMessage(message) then
		lastChatSentMurderer = MurdererName
		chatSendCooldown = now
	end
end

--==================================================
-- NOCLIP LOOP
--==================================================

RunService.Stepped:Connect(function()
	if not noclip or not player.Character then return end
	for _, object in ipairs(player.Character:GetDescendants()) do
		if object:IsA("BasePart") then object.CanCollide = false end
	end
end)

--==================================================
-- ANTI VOID LOOP
--==================================================

RunService.Heartbeat:Connect(function()
	if not antiVoidEnabled or antiVoidCooldown then return end
	if flyEnabled then return end
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if root.Position.Y < VOID_Y_THRESHOLD then
		antiVoidCooldown = true

		local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
		local safePosition = nil

		if spawnLocation then
			safePosition = spawnLocation.Position + Vector3.new(0, 5, 0)
		else
			for _, target in ipairs(Players:GetPlayers()) do
				if target ~= player and target.Character then
					local tr = target.Character:FindFirstChild("HumanoidRootPart")
					if tr and tr.Position.Y > VOID_Y_THRESHOLD then
						safePosition = tr.Position + Vector3.new(0, 5, 0)
						break
					end
				end
			end
		end

		if safePosition then
			root.CFrame = CFrame.new(safePosition)
			root.Velocity = Vector3.zero
		else
			root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
			root.Velocity = Vector3.zero
		end

		task.wait(0.5)
		antiVoidCooldown = false
	end
end)

--==================================================
-- ANTI FLING LOOP
--==================================================

RunService.Heartbeat:Connect(function()
	if not antiFlingEnabled then return end
	if flyEnabled then return end
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local now = tick()
	local velocity = root.AssemblyLinearVelocity
	local speed = velocity.Magnitude

	if speed < 100 and root.Position.Y > -50 then
		lastSafePosition = root.CFrame
		lastSafeUpdate = now
	end

	if speed > ANTI_FLING_MAX_SPEED then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.RotVelocity = Vector3.zero

		if lastSafePosition and (now - lastSafeUpdate) < 5 then
			root.CFrame = lastSafePosition
		end
	end

	local angular = root.AssemblyAngularVelocity.Magnitude
	if angular > ANTI_FLING_MAX_ANGULAR then
		root.AssemblyAngularVelocity = Vector3.zero
		root.RotVelocity = Vector3.zero
	end
end)

--==================================================
-- RESPAWN HANDLERS
--==================================================

player.CharacterAdded:Connect(function(character)
	stopFly()
	flyControls.f = 0
	flyControls.b = 0
	flyControls.l = 0
	flyControls.r = 0
	flyControls.up = 0
	flyControls.down = 0

	lastFlyControls.f = 0
	lastFlyControls.b = 0
	lastFlyControls.l = 0
	lastFlyControls.r = 0
	lastFlyControls.up = 0
	lastFlyControls.down = 0

	originalCollision = {}
	lastSafePosition = nil
	antiVoidCooldown = false

	if noclip then
		task.wait(0.1)
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				originalCollision[object] = object.CanCollide
				object.CanCollide = false
			end
		end
	end

	task.wait(0.2)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		if speedhackEnabled then humanoid.WalkSpeed = speedhackSpeed end
	end
	UpdateHighlights()
end)

--==================================================
-- DRAG MENU
--==================================================

local dragging = false
local dragStart
local dragStartPosition

header.InputBegan:Connect(function(input)
	if guiLocked then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		dragStartPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging or guiLocked then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			dragStartPosition.X.Scale, dragStartPosition.X.Offset + delta.X,
			dragStartPosition.Y.Scale, dragStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--==================================================
-- LOCK / MINIMIZE / CLOSE / REOPEN
--==================================================

local function showMenu()
	menuVisible = true
	frame.Visible = true
	reopenButton.Visible = false
end

local function hideMenu()
	menuVisible = false
	frame.Visible = false
	flyPanel.Visible = false
	flyPanelOpen = false
	reopenButton.Visible = true
end

lockButton.MouseButton1Click:Connect(function()
	guiLocked = not guiLocked
	if guiLocked then
		lockButton.Text = "🔒"
		lockButton.BackgroundColor3 = Color3.fromRGB(55, 57, 65)
	else
		lockButton.Text = "🔓"
		lockButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
	end
end)

minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		content.Visible = false
		frame.Size = UDim2.fromOffset(280, 48)
		minimizeButton.Text = "+"
	else
		content.Visible = true
		frame.Size = UDim2.fromOffset(280, 330)
		minimizeButton.Text = "—"
	end
end)

closeButton.MouseButton1Click:Connect(function()
	hideMenu()
	sendNotification("MM2 Menu", "Menu closed. Click 'MM2' or press Right Shift to reopen.")
end)

closeButton.MouseEnter:Connect(function()
	closeButton.BackgroundColor3 = Color3.fromRGB(180, 55, 55)
end)

closeButton.MouseLeave:Connect(function()
	closeButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
end)

reopenButton.MouseButton1Click:Connect(function()
	showMenu()
end)

-- Failsafe keybind to toggle menu (Right Shift)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if menuVisible then
			hideMenu()
		else
			showMenu()
		end
	end
end)

-- Make reopen button draggable
local reopenDragging = false
local reopenDragStart
local reopenDragStartPosition

reopenButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		reopenDragging = true
		reopenDragStart = input.Position
		reopenDragStartPosition = reopenButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not reopenDragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - reopenDragStart
		reopenButton.Position = UDim2.new(
			reopenDragStartPosition.X.Scale, reopenDragStartPosition.X.Offset + delta.X,
			reopenDragStartPosition.Y.Scale, reopenDragStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		reopenDragging = false
	end
end)

--==================================================
-- INITIAL SETUP & LOOPS
--==================================================

GetRoles()
UpdateHighlights()

task.spawn(function()
	while gui.Parent do
		pcall(function()
			GetRoles()
			UpdateHighlights()

			if autoKillAll and MurdererName == player.Name then
				killAllPlayers()
			end

			if autoGunTP then
				teleportToGun()
			end

			checkAutoSendMurderer()
		end)

		task.wait(0.25)
	end
end)