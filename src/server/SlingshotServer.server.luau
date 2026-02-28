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
		
		-- Ensure the slingshot itself doesn't collide with anything (especially the ball)
		for _, part in pairs(slingshot:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.Anchored = false -- It will be welded to player
			end
		end
		
		-- 3. Position Slingshot relative to Player
		-- Slingshot Frame placed further forward ("Grounded")
		-- Lowering Y to -3.5 to ensure it touches the ground (Root is usually ~3 studs up)
		local SLINGSHOT_DIST = 8
		local spawnOffset = CFrame.new(0, -3.5, -SLINGSHOT_DIST) 
		slingshot:PivotTo(root.CFrame * spawnOffset)
		
		-- 4. Weld Slingshot to Player (so it aims with you)
		if slingshot.PrimaryPart then
			local slingWeld = Instance.new("WeldConstraint")
			slingWeld.Part0 = root
			slingWeld.Part1 = slingshot.PrimaryPart
			slingWeld.Parent = slingshot.PrimaryPart
		else
			warn("BigSlingshot Model is missing a PrimaryPart! Set the 'Base' as PrimaryPart.")
		end

		-- 5. Handle Ball and Socket (Pulled Back Position)
		ball.Parent = workspace 
		ball.Anchored = false
		ball.CanCollide = false
		
		-- Disable animations
		local animate = character:FindFirstChild("Animate")
		if animate then animate.Disabled = true end
		task.wait()
		
		local ballSocket = slingshot:FindFirstChild("BallSocket")
		local PULL_DIST = 2.5 -- Close to player (held)
		
		if ballSocket then
			-- Break all welds on BallSocket so we can move it independently of the frame
			ballSocket:BreakJoints()
			
			-- Position BallSocket relative to player (Pulled back state)
			-- Lowering Y by -1 to match the "holding down" look
			ballSocket.CFrame = root.CFrame * CFrame.new(0, -1, -PULL_DIST)
			
			local socketWeld = Instance.new("WeldConstraint")
			socketWeld.Part0 = root
			socketWeld.Part1 = ballSocket
			socketWeld.Parent = ballSocket
			
			-- Move ball to socket
			ball.CFrame = ballSocket.CFrame
			
			local ballWeld = Instance.new("WeldConstraint")
			ballWeld.Part0 = ballSocket
			ballWeld.Part1 = ball
			ballWeld.Parent = ball
			
			-- 6. Create Visual Elastics (Beams)
			-- Try to find tips or use offsets
			local leftTip = slingshot:FindFirstChild("LeftTip")
			local rightTip = slingshot:FindFirstChild("RightTip")
			
			-- Helper to create attachment if tip part exists, or estimate
			local function getTipAttachment(name, offsetDir)
				local tipPart = slingshot:FindFirstChild(name)
				local att = Instance.new("Attachment")
				if tipPart then
					att.Parent = tipPart
				else
					-- Estimate based on PrimaryPart (Base)
					-- Assuming Y-shape: Up and Left/Right
					if slingshot.PrimaryPart then
						att.Parent = slingshot.PrimaryPart
						-- Estimated offset: Up 4, Side 1.5 (Adjust based on model)
						att.Position = Vector3.new(offsetDir * 1.5, 5, 0)
					end
				end
				return att
			end
			
			local attLeft = getTipAttachment("LeftTip", -1)
			local attRight = getTipAttachment("RightTip", 1)
			
			-- Socket attachments (where bands connect to pouch)
			local attSocketL = Instance.new("Attachment", ballSocket)
			attSocketL.Position = Vector3.new(-0.5, 0, 0)
			local attSocketR = Instance.new("Attachment", ballSocket)
			attSocketR.Position = Vector3.new(0.5, 0, 0)
			
			-- Create Beams
			local function createBand(att0, att1)
				local beam = Instance.new("Beam")
				beam.Attachment0 = att0
				beam.Attachment1 = att1
				beam.FaceCamera = true
				beam.Width0 = 0.2
				beam.Width1 = 0.2
				beam.Color = ColorSequence.new(Color3.fromRGB(200, 180, 140)) -- Tan/Rubber color
				beam.Parent = ballSocket
				return beam
			end
			
			createBand(attLeft, attSocketL)
			createBand(attRight, attSocketR)
			
		else
			warn("BallSocket part not found in BigSlingshot!")
			-- Fallback: Maintain the "low hold" position even without socket
			ball.CFrame = root.CFrame * CFrame.new(0, -1, -PULL_DIST)
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
		-- Break any existing welds
		for _, w in pairs(ball:GetChildren()) do
			if w:IsA("WeldConstraint") or w:IsA("Weld") then
				w:Destroy()
			end
		end
		
		ball.Parent = workspace
		ball.Anchored = false
		ball.CanCollide = false -- Keep false while setting up constraints
		
		print("🏀 Shooting Ball. Size: " .. tostring(ball.Size))
		print("🚀 Direction: " .. tostring(direction))
		
		-- Create NoCollisionConstraint between ball and character
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				local noCollide = Instance.new("NoCollisionConstraint")
				noCollide.Part0 = ball
				noCollide.Part1 = part
				noCollide.Parent = ball
			end
		end
		
		-- DEBUG: Visual Ray of the shooting direction
		local ray = Instance.new("Part")
		ray.Size = Vector3.new(0.2, 0.2, 5)
		ray.Anchored = true
		ray.CanCollide = false
		ray.Color = Color3.fromRGB(255, 0, 0)
		ray.Material = Enum.Material.Neon
		ray.CFrame = CFrame.new(ball.Position, ball.Position + direction) * CFrame.new(0, 0, -2.5)
		ray.Parent = workspace
		game.Debris:AddItem(ray, 1) -- Remove after 1 second
		
		-- Set NetworkOwner to server
		ball:SetNetworkOwner(nil)
		
		-- Enable collision NOW that constraints are in place
		ball.CanCollide = true
		
		-- Apply Velocity
		ball.AssemblyLinearVelocity = direction * power
		
		-- Optional: Add a slight upward arc if desired, but for now we keep it linear
		-- ball.AssemblyLinearVelocity += Vector3.new(0, 10, 0)

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