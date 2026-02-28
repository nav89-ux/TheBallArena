local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("SlingshotEvent")
local RunService = game:GetService("RunService")

local gravity = workspace.Gravity
local trajectoryPoints = {}

local maxPower = 350
local heldBall = nil

-- Function to connect to a ball's proximity prompt
local function connectBall(ball)
	local prompt = ball:FindFirstChild("ProximityPrompt")
	if prompt then
		prompt.Triggered:Connect(function()
			heldBall = ball
			event:FireServer("Mount", heldBall)
		end)
	end
end

-- Connect to all existing balls in workspace
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and obj.Name:match("_Ball_") then
		connectBall(obj)
	end
end

-- Connect to new balls that get added
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Name:match("_Ball_") then
		task.wait() -- Wait for ProximityPrompt to be added
		connectBall(obj)
	end
end)

-- Mouse Hold
mouse.Button1Down:Connect(function()
	if heldBall then
		local character = player.Character
		local root = character:WaitForChild("HumanoidRootPart")

		local mousePos = mouse.Hit.Position
		local flatTarget = Vector3.new(mousePos.X, root.Position.Y, mousePos.Z)
		local direction = (flatTarget - root.Position).Unit

		clearTrajectory()

		event:FireServer("Shoot", heldBall, direction, maxPower) -- fixed power

		heldBall = nil
	end
end)


RunService.RenderStepped:Connect(function()

	if heldBall then

		local character = player.Character
		local root = character:WaitForChild("HumanoidRootPart")

		local mousePos = mouse.Hit.Position
		local flatTarget = Vector3.new(mousePos.X, root.Position.Y, mousePos.Z)

		-- Rotate character horizontally
		root.CFrame = root.CFrame:Lerp(
			CFrame.new(root.Position, flatTarget),
			0.2
		)

		local direction = (flatTarget - root.Position).Unit

		drawLinePreview(root.Position, direction)
	end

end)



function drawLinePreview(startPos, direction)

	clearTrajectory()

	for i = 1, 50 do

		local pos = startPos + direction * (i * 2)
		local point = Instance.new("Part")
		
		point.Size = Vector3.new(0.4,0.4,0.4)
		point.Shape = Enum.PartType.Ball
		point.Anchored = true
		point.CanCollide = false
		point.Material = Enum.Material.Neon
		point.Color = Color3.fromRGB(0,255,0)
		point.Position = pos
		point.Parent = workspace

		table.insert(trajectoryPoints, point)
	end
end

function clearTrajectory()
	for _, p in pairs(trajectoryPoints) do
		p:Destroy()
	end
	trajectoryPoints = {}
end


