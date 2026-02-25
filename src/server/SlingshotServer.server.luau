local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("SlingshotEvent")

-- Configuration
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
		local spawnOffset = CFrame.new(0, -3, -5) 
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
		
		-- Disable animations FIRST before any pose changes
		local animate = character:FindFirstChild("Animate")
		if animate then animate.Disabled = true end
		
		-- Wait a frame for animations to fully stop
		task.wait()
		
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
		
		-- Get hand targets on the slingshot pouch
		local socket = slingshot:WaitForChild("BallSocket")
		local leftTarget = socket:WaitForChild("LeftHandTarget") :: Attachment
		local rightTarget = socket:WaitForChild("RightHandTarget") :: Attachment
		
		-- Create IK for both arms (R15)
		local leftIK = Instance.new("IKControl")
		leftIK.Name = "LeftArmHold"
		leftIK.ChainRoot = character:WaitForChild("LeftUpperArm")
		leftIK.EndEffector = character:WaitForChild("LeftHand")
		leftIK.Target = leftTarget
		leftIK.Type = Enum.IKControlType.Position
		leftIK.Weight = 1
		leftIK.Parent = character
		
		local rightIK = Instance.new("IKControl")
		rightIK.Name = "RightArmHold"
		rightIK.ChainRoot = character:WaitForChild("RightUpperArm")
		rightIK.EndEffector = character:WaitForChild("RightHand")
		rightIK.Target = rightTarget
		rightIK.Type = Enum.IKControlType.Position
		rightIK.Weight = 1
		rightIK.Parent = character
				
		-- Bend torso forward (inward at stomach) for "maximum pull" look
		local waist = character:FindFirstChild("Waist", true)
		local originalWaistC0 = nil
		if waist and waist:IsA("Motor6D") then
			originalWaistC0 = waist.C0
			-- Apply bend forward rotation to C0
			waist.C0 = originalWaistC0 * CFrame.Angles(math.rad(-30), 0, 0)
		end
		
		-- Angle legs back (character on heels, leaning back)
		local leftHip = character:FindFirstChild("LeftHip", true)
		local rightHip = character:FindFirstChild("RightHip", true)
		local originalLeftHipC0 = nil
		local originalRightHipC0 = nil
		
		if leftHip and leftHip:IsA("Motor6D") then
			originalLeftHipC0 = leftHip.C0
			-- Apply backward tilt to C0
			leftHip.C0 = originalLeftHipC0 * CFrame.Angles(math.rad(20), 0, 0)
		end
		if rightHip and rightHip:IsA("Motor6D") then
			originalRightHipC0 = rightHip.C0
			rightHip.C0 = originalRightHipC0 * CFrame.Angles(math.rad(20), 0, 0)
		end
		
		-- Track for cleanup
		local session = activeSessions[player] or {}
		session.model = slingshot
		session.leftIK = leftIK
		session.rightIK = rightIK
		session.animateScript = animate
		session.waist = waist
		session.originalWaistC0 = originalWaistC0
		session.leftHip = leftHip
		session.originalLeftHipC0 = originalLeftHipC0
		session.rightHip = rightHip
		session.originalRightHipC0 = originalRightHipC0
		activeSessions[player] = session

	elseif action == "Shoot" then

		local character = player.Character
		if not character then return end

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

		-- Delay cleanup for visual follow-through
		task.delay(0.5, function()
			local session = activeSessions[player]
			if session then
				if session.model then session.model:Destroy() end
				if session.leftIK then session.leftIK:Destroy() end
				if session.rightIK then session.rightIK:Destroy() end
				if session.waist and session.originalWaistC0 then 
					session.waist.C0 = session.originalWaistC0 
				end
				if session.leftHip and session.originalLeftHipC0 then 
					session.leftHip.C0 = session.originalLeftHipC0 
				end
				if session.rightHip and session.originalRightHipC0 then 
					session.rightHip.C0 = session.originalRightHipC0 
				end
				if session.animateScript then session.animateScript.Disabled = false end
				activeSessions[player] = nil
			end
			
			-- 2. Unlock Character
			if player and player.Character then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = 16
					humanoid.JumpPower = 50
					humanoid.AutoRotate = true
				end
			end
		end)

	end
end)