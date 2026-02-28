local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Configuration
local TELEPORT_TIME = 5
local RED_TEAM_NAME = "TeamRed"
local BLUE_TEAM_NAME = "TeamBlue"

-- References
local lobby = workspace:WaitForChild("Lobby")
local arena = workspace:WaitForChild("BattleArena")
local map = arena:WaitForChild("Map")
local centralLine = map:WaitForChild("CentralLine")

-- Helper to create pads if they don't exist
local function setupPads()
	local function createPad(name, color, position)
		local existing = lobby:FindFirstChild(name)
		if existing then return existing end
		
		local pad = Instance.new("Part")
		pad.Name = name
		pad.Size = Vector3.new(8, 0.5, 8) -- Slightly larger for easier standing
		pad.Position = position
		pad.Color = color
		pad.Material = Enum.Material.Neon
		pad.Anchored = true
		pad.CanCollide = true
		pad.Parent = lobby
		
		local selection = Instance.new("SelectionBox")
		selection.Adornee = pad
		selection.Color3 = color
		selection.LineThickness = 0.1
		selection.Parent = pad
		
		return pad
	end

	local lobbyPos = lobby.PrimaryPart and lobby.PrimaryPart.Position or lobby:GetPivot().Position
	local redPad = createPad("RedTeleportPad", Color3.fromRGB(255, 0, 0), lobbyPos + Vector3.new(-12, -2.75, 0))
	local bluePad = createPad("BlueTeleportPad", Color3.fromRGB(0, 0, 255), lobbyPos + Vector3.new(12, -2.75, 0))
	
	return redPad, bluePad
end

local redPad, bluePad = setupPads()

-- Helper to create the floating countdown text
local function setupCountdownText()
	local displayPart = Instance.new("Part")
	displayPart.Name = "CountdownDisplay"
	displayPart.Size = Vector3.new(4, 4, 1)
	displayPart.Transparency = 1
	displayPart.CanCollide = false
	displayPart.Anchored = true
	
	-- Position between the pads, higher up
	local midPoint = (redPad.Position + bluePad.Position) / 2
	displayPart.Position = midPoint + Vector3.new(0, 8, 0)
	displayPart.Parent = lobby
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CountdownGui"
	billboard.Size = UDim2.new(10, 0, 10, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = displayPart
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.LuckiestGuy
	label.TextScaled = true
	label.Text = ""
	label.Parent = billboard
	
	-- Add a glow effect
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0
	pointLight.Range = 15
	pointLight.Color = Color3.fromRGB(255, 255, 0)
	pointLight.Parent = displayPart
	
	return label, pointLight
end

local countdownLabel, countdownLight = setupCountdownText()

-- State
local redPlayer = nil
local bluePlayer = nil
local countdownTime = 0
local isTeleporting = false

local function getPlayerOnPad(pad)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	-- Optional: Filter out everything but characters if needed
	
	local parts = workspace:GetPartBoundsInBox(pad.CFrame * CFrame.new(0, 2, 0), pad.Size + Vector3.new(0, 4, 0), overlapParams)
	for _, part in pairs(parts) do
		local character = part.Parent
		if character and character:FindFirstChild("Humanoid") then
			local player = Players:GetPlayerFromCharacter(character)
			if player then return player end
		end
	end
	return nil
end

local function teleportPlayers()
	if isTeleporting or not redPlayer or not bluePlayer then return end
	isTeleporting = true

	-- Capture before any async yields (Heartbeat may nil these after players leave pads)
	local capturedRed = redPlayer
	local capturedBlue = bluePlayer

	print("🚀 TELEPORTING STARTED")
	countdownLabel.Text = "GO!"
	countdownLight.Brightness = 10
	countdownLight.Color = Color3.fromRGB(0, 255, 0)
	
	capturedRed:SetAttribute("Team", RED_TEAM_NAME)
	capturedBlue:SetAttribute("Team", BLUE_TEAM_NAME)
	
	if _G.SpawnGameBalls then
		_G.SpawnGameBalls()
	else
		warn("SpawnGameBalls global function not found!")
	end
	
	local function teleportToSide(player, sideSign)
		local character = player.Character
		if not character then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		
		local spawnPos = centralLine.Position + (centralLine.CFrame.RightVector * (sideSign * 30)) + Vector3.new(0, 5, 0)
		root.CFrame = CFrame.new(spawnPos, centralLine.Position)
	end
	
	teleportToSide(capturedRed, -1)
	teleportToSide(capturedBlue, 1)
	
	task.wait(1)
	isTeleporting = false
	countdownTime = 0
	countdownLabel.Text = ""
	countdownLight.Brightness = 0

	if _G.StartWinCondition then
		_G.StartWinCondition(capturedRed, capturedBlue)
	else
		warn("StartWinCondition global function not found!")
	end
end

RunService.Heartbeat:Connect(function(dt)
	if isTeleporting then return end
	
	local currentRed = getPlayerOnPad(redPad)
	local currentBlue = getPlayerOnPad(bluePad)
	
	if currentRed and currentBlue and currentRed ~= currentBlue then
		redPlayer = currentRed
		bluePlayer = currentBlue
		countdownTime += dt
		
		-- Visual feedback
		local timeLeft = math.ceil(TELEPORT_TIME - countdownTime)
		countdownLabel.Text = tostring(timeLeft)
		countdownLabel.TextColor3 = Color3.fromHSV((os.clock() % 1), 1, 1) -- Rainbow effect
		countdownLight.Brightness = 5 + (math.sin(os.clock() * 10) * 2)
		countdownLight.Color = countdownLabel.TextColor3
		
		local progress = math.clamp(countdownTime / TELEPORT_TIME, 0, 1)
		redPad.Transparency = 0.5 * (1 - progress)
		bluePad.Transparency = 0.5 * (1 - progress)
		
		if countdownTime >= TELEPORT_TIME then
			teleportPlayers()
		end
	else
		-- Reset
		if countdownTime > 0 then
			print("❌ Countdown reset - players moved off pads")
		end
		countdownTime = 0
		redPlayer = nil
		bluePlayer = nil
		redPad.Transparency = 0
		bluePad.Transparency = 0
		countdownLabel.Text = ""
		countdownLight.Brightness = 0
	end
end)

print("✅ TeleportService (Heartbeat logic) ready.")

