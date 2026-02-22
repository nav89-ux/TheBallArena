local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("SlingshotEvent")

-- Configuration
local ANIMATION_ID = "rbxassetid://116900221715996"
local SLINGSHOT_TEMPLATE_NAME = "BigSlingshot" 

-- Store active slingshot sessions per player
local activeSessions = {} 

event.OnServerEvent:Connect(function(player, action, ball, direction, power)

	if action == "Mount" then

		local character = player.Character
		if not character then return end

		local humanoid = character:WaitForChild("Humanoid")
		local root = character:WaitForChild("HumanoidRootPart")
		
		-- 1. Lock Character Movement
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.AutoRotate = false -- Important: Client handles rotation
		
		-- 2. Spawn the Big Slingshot
		local slingshotTemplate = ReplicatedStorage:FindFirstChild(SLINGSHOT_TEMPLATE_NAME)
		if not slingshotTemplate then
			warn("CRITICAL: '" .. SLINGSHOT_TEMPLATE_NAME .. "' model not found in ReplicatedStorage!")
			return
		end
		
		local slingshot = slingshotTemplate:Clone()
		slingshot.Parent = workspace
		
		-- 3. Position Slingshot relative to Player
		-- Adjust these numbers to fit your specific model size
		-- (0, -3, -3) usually puts it on the ground (hip height ~3) and slightly forward
		local spawnOffset = CFrame.new(0, -3, -2) 
		slingshot:PivotTo(root.CFrame * spawnOffset)
		
		-- 4. Weld Slingshot to Player (so it aims with you)
		-- We assume the model has a PrimaryPart (the Base)
		if slingshot.PrimaryPart then
			local slingWeld = Instance.new("WeldConstraint")
			slingWeld.Part0 = root
			slingWeld.Part1 = slingshot.PrimaryPart
			slingWeld.Parent = slingshot.PrimaryPart
		else
			warn("BigSlingshot Model is missing a PrimaryPart! Set the 'Base' as PrimaryPart.")
		end

		-- 5. Position and Weld the Ball
		ball.Parent = workspace -- Keep independent so it doesn't get destroyed with model
		ball.Anchored = false
		ball.CanCollide = false
		
		local ballSocket = slingshot:FindFirstChild("BallSocket")
		if ballSocket then
			ball.CFrame = ballSocket.CFrame
			
			local ballWeld = Instance.new("WeldConstraint")
			ballWeld.Part0 = ballSocket
			ballWeld.Part1 = ball
			ballWeld.Parent = ball
		else
			warn("BallSocket part not found in BigSlingshot! Please add a part named 'BallSocket'.")
			-- Fallback position
			ball.CFrame = root.CFrame * CFrame.new(0, 0, -5)
		end

		-- 6. Play "Hold" Animation
		local animator = humanoid:FindFirstChild("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
		
		local animation = Instance.new("Animation")
		animation.AnimationId = ANIMATION_ID
		
		local track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action -- FORCE the animation to override others
		track.Looped = true
		track:Play()
				
		-- 7. Store Session Data
		activeSessions[player] = {
			model = slingshot,
			track = track
		}

	elseif action == "Shoot" then

		local character = player.Character
		if not character then return end

		-- 1. Cleanup Session (Destroy Slingshot, Stop Animation)
		local session = activeSessions[player]
		if session then
			if session.model then
				session.model:Destroy()
			end
			if session.track then
				session.track:Stop()
			end
			activeSessions[player] = nil
		end
		
		-- 2. Unlock Character
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			humanoid.AutoRotate = true
		end

		-- 3. Launch Ball
		-- Break any existing welds (like the one to the slingshot)
		for _, w in pairs(ball:GetChildren()) do
			if w:IsA("WeldConstraint") or w:IsA("Weld") then
				w:Destroy()
			end
		end
		
		ball.Anchored = false
		ball.CanCollide = true
		ball.Parent = workspace
		
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
		bodyVelocity.Velocity = direction * power
		
		bodyVelocity.Parent = ball
		
		game.Debris:AddItem(bodyVelocity, 0.3)
	end
end)