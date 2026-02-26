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

-- Function to spawn balls randomly in a section
local function spawnBallsInSection(isTeamA)
	local teamName = isTeamA and "TeamA" or "TeamB"
	local zMin, zMax
	
	if isTeamA then
		zMin = minZ
		zMax = centralLineZ - SPAWN_MARGIN
	else
		zMin = centralLineZ + SPAWN_MARGIN
		zMax = maxZ
	end
	
	for i = 1, BALLS_PER_SIDE do
		local ball = ballTemplate:Clone()
		
		-- Random position within the section
		local randomX = minX + math.random() * (maxX - minX)
		local randomZ = zMin + math.random() * (zMax - zMin)
		local randomY = basePos.Y + baseSize.Y / 2 + SPAWN_HEIGHT
		
		ball.CFrame = CFrame.new(randomX, randomY, randomZ)
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
