local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Configuration
local BALLS_PER_SIDE = 5
local BALL_TEMPLATE_NAME = "Ball"
local SPAWN_HEIGHT = 2
local SPAWN_MARGIN = 5

-- Get CentralLine and arena boundaries
local centralLine = workspace:WaitForChild("BattleArena"):WaitForChild("Map"):WaitForChild("CentralLine")
local basePlate = workspace:WaitForChild("BattleArena"):WaitForChild("Map"):WaitForChild("BasePlate")

if not centralLine or not basePlate then
	warn("❌ BallSpawner: Could not find CentralLine or BasePlate!")
	return
end

-- Get ball template
local ballTemplate = ReplicatedStorage:FindFirstChild(BALL_TEMPLATE_NAME)
if not ballTemplate then
	warn("❌ BallSpawner: Ball template '" .. BALL_TEMPLATE_NAME .. "' not found in ReplicatedStorage!")
	return
end

-- Calculate arena bounds
local baseSize = basePlate.Size
local basePos = basePlate.Position

local minX = basePos.X - baseSize.X / 2 + SPAWN_MARGIN
local maxX = basePos.X + baseSize.X / 2 - SPAWN_MARGIN
local minZ = basePos.Z - baseSize.Z / 2 + SPAWN_MARGIN
local maxZ = basePos.Z + baseSize.Z / 2 - SPAWN_MARGIN

local function computeCentralPlaneNormal(): Vector3
	local cf = centralLine.CFrame
	local size = centralLine.Size
	local normal
	if size.X < size.Z then
		normal = cf.RightVector
	else
		normal = cf.LookVector
	end

	normal = Vector3.new(normal.X, 0, normal.Z)
	if normal.Magnitude < 1e-6 then
		normal = Vector3.zAxis
	else
		normal = normal.Unit
	end

	local xDot = math.abs(normal:Dot(Vector3.xAxis))
	local zDot = math.abs(normal:Dot(Vector3.zAxis))
	local alignAxis = (zDot >= xDot) and Vector3.zAxis or Vector3.xAxis
	if normal:Dot(alignAxis) < 0 then
		normal = -normal
	end

	return normal
end

local centralPlaneNormal = computeCentralPlaneNormal()

local function isOnSide(pos: Vector3, sideSign: number, margin: number): boolean
	local d = (pos - centralLine.Position):Dot(centralPlaneNormal)
	if sideSign < 0 then
		return d <= -margin
	else
		return d >= margin
	end
end

local function getRandomSpawnPosition(sideSign: number): Vector3
	local randomY = basePos.Y + baseSize.Y / 2 + SPAWN_HEIGHT
	local attempts = 0
	while attempts < 200 do
		attempts += 1
		local randomX = minX + math.random() * (maxX - minX)
		local randomZ = minZ + math.random() * (maxZ - minZ)
		local pos = Vector3.new(randomX, randomY, randomZ)
		if isOnSide(pos, sideSign, SPAWN_MARGIN) then
			return pos
		end
	end

	attempts = 0
	while attempts < 200 do
		attempts += 1
		local randomX = minX + math.random() * (maxX - minX)
		local randomZ = minZ + math.random() * (maxZ - minZ)
		local pos = Vector3.new(randomX, randomY, randomZ)
		if isOnSide(pos, sideSign, 0) then
			return pos
		end
	end

	local randomX = minX + math.random() * (maxX - minX)
	local randomZ = minZ + math.random() * (maxZ - minZ)
	local pos = Vector3.new(randomX, randomY, randomZ)
	local d = (pos - centralLine.Position):Dot(centralPlaneNormal)
	local epsilon = 0.1
	local targetD = (sideSign < 0) and (-epsilon) or (epsilon)
	pos += centralPlaneNormal * (targetD - d)
	return pos
end

-- Clear existing balls
local function clearBalls()
	for _, child in pairs(workspace:GetChildren()) do
		if child.Name:match("Team%a+_Ball_") then
			child:Destroy()
		end
	end
end

-- Function to spawn balls randomly on one side
local function spawnBallsForTeam(teamName, color)
	local sideSign = (teamName == "TeamRed") and -1 or 1

	for i = 1, BALLS_PER_SIDE do
		local ball = ballTemplate:Clone()
		local pos = getRandomSpawnPosition(sideSign)

		ball.CFrame = CFrame.new(pos)
		ball.Color = color
		ball.Parent = workspace

		-- Add a ProximityPrompt if it doesn't exist
		if not ball:FindFirstChild("ProximityPrompt") then
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Pick up"
			prompt.ObjectText = teamName .. " Ball"
			prompt.MaxActivationDistance = 10
			prompt.HoldDuration = 0
			prompt.Parent = ball
		end

		ball:SetAttribute("Team", teamName)
		ball.Name = teamName .. "_Ball_" .. i
	end
end

-- Export function for TeleportService
_G.SpawnGameBalls = function()
	clearBalls()
	spawnBallsForTeam("TeamRed", Color3.fromRGB(255, 0, 0))
	spawnBallsForTeam("TeamBlue", Color3.fromRGB(0, 0, 255))
end

-- Create WinRoundEvent for client announcements
local winRoundEvent = ReplicatedStorage:FindFirstChild("WinRoundEvent")
if not winRoundEvent then
	winRoundEvent = Instance.new("RemoteEvent")
	winRoundEvent.Name = "WinRoundEvent"
	winRoundEvent.Parent = ReplicatedStorage
end

-- Win condition configuration
local WIN_CHECK_INTERVAL = 0.5
local WIN_GRACE_PERIOD = 3
local WIN_ANNOUNCE_DELAY = 4

-- Win condition state
local gameActive = false
local currentRedPlayer = nil
local currentBluePlayer = nil
local winCheckTimer = 0
local graceTimer = 0

local function countBallsOnSide(sideSign: number): number
	local count = 0
	for _, child in pairs(workspace:GetChildren()) do
		if child:IsA("BasePart") and child:GetAttribute("Team") ~= nil then
			if isOnSide(child.Position, sideSign, 0) then
				count += 1
			end
		end
	end
	return count
end

local function endGame(winnerTeam: string)
	if not gameActive then return end
	gameActive = false

	print("🏆 " .. winnerTeam .. " WINS THE ROUND!")
	winRoundEvent:FireAllClients(winnerTeam)

	task.wait(WIN_ANNOUNCE_DELAY)

	clearBalls()

	if currentRedPlayer then
		currentRedPlayer:SetAttribute("Team", nil)
		if currentRedPlayer.Character then
			currentRedPlayer:LoadCharacter()
		end
	end
	if currentBluePlayer then
		currentBluePlayer:SetAttribute("Team", nil)
		if currentBluePlayer.Character then
			currentBluePlayer:LoadCharacter()
		end
	end

	currentRedPlayer = nil
	currentBluePlayer = nil
end

_G.StartWinCondition = function(redPlayer, bluePlayer)
	currentRedPlayer = redPlayer
	currentBluePlayer = bluePlayer
	graceTimer = WIN_GRACE_PERIOD
	winCheckTimer = 0
	gameActive = true
	print("🏆 Win condition monitoring started!")
end

RunService.Heartbeat:Connect(function(dt)
	if not gameActive then return end

	if graceTimer > 0 then
		graceTimer -= dt
		return
	end

	winCheckTimer -= dt
	if winCheckTimer > 0 then return end
	winCheckTimer = WIN_CHECK_INTERVAL

	-- TeamRed spawns on sideSign -1, TeamBlue on sideSign +1
	local redSideBalls = countBallsOnSide(-1)
	local blueSideBalls = countBallsOnSide(1)

	if redSideBalls == 0 then
		endGame("TeamRed")
	elseif blueSideBalls == 0 then
		endGame("TeamBlue")
	end
end)

print("✅ BallSpawner logic ready.")

