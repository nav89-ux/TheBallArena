local Players = game:GetService("Players")

local function onCharacterAdded(character)
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	-- Wait for the Lobby model to be available in Workspace
	local lobby = workspace:WaitForChild("Lobby", 10)
	if not lobby then
		warn("Lobby model not found in Workspace!")
		return
	end

	-- Find SpawnLocations within the Lobby
	local spawnLocations = {}
	for _, child in pairs(lobby:GetChildren()) do
		if child:IsA("SpawnLocation") then
			table.insert(spawnLocations, child)
		end
	end

	if #spawnLocations > 0 then
		-- Pick a random spawn location from the lobby
		local randomSpawn = spawnLocations[math.random(1, #spawnLocations)]
		
		-- Teleport character to the spawn location
		-- We add a small offset to avoid spawning inside the part
		local rootPart = character:WaitForChild("HumanoidRootPart")
		rootPart.CFrame = randomSpawn.CFrame * CFrame.new(0, 3, 0)
	else
		warn("No SpawnLocations found inside the Lobby model!")
	end
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
	
	-- If character already exists (rare but possible on join)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle existing players (for studio testing/hot reloading)
for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
