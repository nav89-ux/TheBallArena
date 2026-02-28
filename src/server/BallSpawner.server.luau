local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local BALLS_PER_SIDE = 5
local BALL_TEMPLATE_NAME = "Ball"
local SPAWN_HEIGHT = 2
local SPAWN_MARGIN = 5

print("🔍 BallSpawner: Starting...")

-- Get CentralLine and arena boundaries
local centralLine = workspace:WaitForChild("BattleArena"):WaitForChild("Map"):WaitForChild("CentralLine")
local basePlate = workspace:WaitForChild("BattleArena"):WaitForChild("Map"):WaitForChild("BasePlate")

if not centralLine or not basePlate then
	warn("❌ BallSpawner: Could not find CentralLine or BasePlate!")
	return
end

print("✅ BallSpawner: Found CentralLine and BasePlate")

-- Get ball template
local ballTemplate = ReplicatedStorage:FindFirstChild(BALL_TEMPLATE_NAME)
if not ballTemplate then
	warn("❌ BallSpawner: Ball template '" .. BALL_TEMPLATE_NAME .. "' not found in ReplicatedStorage!")
	warn("Available items in ReplicatedStorage:")
	for _, child in pairs(ReplicatedStorage:GetChildren()) do
		print("  - " .. child.Name)
	end
	return
end

print("✅ BallSpawner: Found ball template")

-- Calculate arena bounds
local centralLineZ = centralLine.Position.Z
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
			warn("⚠️ BallSpawner: Had to relax CentralLine margin to place a ball on the requested side.")
			return pos
		end
	end

	warn("⚠️ BallSpawner: Could not sample a valid point on the requested side; forcing position across CentralLine.")
	local randomX = minX + math.random() * (maxX - minX)
	local randomZ = minZ + math.random() * (maxZ - minZ)
	local pos = Vector3.new(randomX, randomY, randomZ)
	local d = (pos - centralLine.Position):Dot(centralPlaneNormal)
	local epsilon = 0.1
	local targetD = (sideSign < 0) and (-epsilon) or (epsilon)
	pos += centralPlaneNormal * (targetD - d)
	return pos
end

-- Function to spawn balls randomly on one side of the CentralLine plane
local function spawnBallsInSection(isTeamA)
	local teamName = isTeamA and "TeamA" or "TeamB"
	local sideSign = isTeamA and -1 or 1

	for i = 1, BALLS_PER_SIDE do
		local ball = ballTemplate:Clone()
		local pos = getRandomSpawnPosition(sideSign)

		ball.CFrame = CFrame.new(pos)
		ball.Parent = workspace

		-- Add a ProximityPrompt if it doesn't exist
		if not ball:FindFirstChild("ProximityPrompt") then
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Pick up"
			prompt.ObjectText = "Ball"
			prompt.MaxActivationDistance = 10
			prompt.HoldDuration = 0
			prompt.Parent = ball
		end

		ball:SetAttribute("Team", teamName)
		ball.Name = teamName .. "_Ball_" .. i
	end
end

-- Spawn balls on both sides of CentralLine
spawnBallsInSection(true)  -- TeamA side
spawnBallsInSection(false) -- TeamB side

print("✅ Ball spawning complete: " .. BALLS_PER_SIDE .. " balls randomly placed on each side of CentralLine")
