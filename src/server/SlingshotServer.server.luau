local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("SlingshotEvent")

event.OnServerEvent:Connect(function(player, action, ball, direction, power)

	if action == "Mount" then

		local character = player.Character
		local humanoid = character:WaitForChild("Humanoid")
		local root = character:WaitForChild("HumanoidRootPart")
		
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.AutoRotate = false
		
		local head = character:FindFirstChild("Head")

		ball.Parent = character
		ball.Anchored = false
		ball.CanCollide = false

		local offset = CFrame.new(0, -1, -10)
		ball.CFrame = head.CFrame * offset

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = head
		weld.Part1 = ball
		weld.Parent = ball

	elseif action == "Shoot" then

		local weld = ball:FindFirstChildOfClass("WeldConstraint")
		if weld then
			weld:Destroy()
		end
		
		ball.Anchored = false
		ball.CanCollide = true
		ball.Parent = workspace
		
		local humanoid = player.Character:FindFirstChild("Humanoid")
		local root = player.Character:FindFirstChild("HumanoidRootPart")

		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		humanoid.AutoRotate = true

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
		bodyVelocity.Velocity = direction * power
		
		bodyVelocity.Parent = ball
		
		game.Debris:AddItem(bodyVelocity, 0.3)
	end
end)