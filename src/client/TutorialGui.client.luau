local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function createTutorialGui(player)
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Main frame
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TutorialGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "TutorialFrame"
	mainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
	mainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BackgroundTransparency = 0.1
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.15, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🏀 THE BALL ARENA - HOW TO PLAY"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame
	
	-- Instructions text
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "Content"
	contentFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
	contentFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = mainFrame
	
	local pageTitle = Instance.new("TextLabel")
	pageTitle.Name = "PageTitle"
	pageTitle.Size = UDim2.new(1, 0, 0.18, 0)
	pageTitle.Position = UDim2.new(0, 0, 0, 0)
	pageTitle.BackgroundTransparency = 1
	pageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	pageTitle.TextScaled = true
	pageTitle.Font = Enum.Font.GothamBold
	pageTitle.Parent = contentFrame
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.Size = UDim2.new(1, 0, 0.22, 0)
	iconLabel.Position = UDim2.new(0, 0, 0.18, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	iconLabel.TextScaled = true
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = contentFrame
	
	local pageBody = Instance.new("TextLabel")
	pageBody.Name = "Body"
	pageBody.Size = UDim2.new(1, 0, 0.34, 0)
	pageBody.Position = UDim2.new(0, 0, 0.40, 0)
	pageBody.BackgroundTransparency = 1
	pageBody.TextColor3 = Color3.fromRGB(220, 220, 220)
	pageBody.TextScaled = true
	pageBody.Font = Enum.Font.Gotham
	pageBody.TextXAlignment = Enum.TextXAlignment.Center
	pageBody.TextYAlignment = Enum.TextYAlignment.Center
	pageBody.Parent = contentFrame
	
	local diagramFrame = Instance.new("Frame")
	diagramFrame.Name = "Diagram"
	diagramFrame.Size = UDim2.new(1, 0, 0.26, 0)
	diagramFrame.Position = UDim2.new(0, 0, 0.74, 0)
	diagramFrame.BackgroundTransparency = 1
	diagramFrame.Parent = contentFrame
	
	local function clearDiagram()
		for _, child in ipairs(diagramFrame:GetChildren()) do
			child:Destroy()
		end
	end
	
	local function makeBall(parent: Instance, position: UDim2, color: Color3)
		local ball = Instance.new("Frame")
		ball.Size = UDim2.new(0, 18, 0, 18)
		ball.Position = position
		ball.BackgroundColor3 = color
		ball.BorderSizePixel = 0
		ball.Parent = parent
		local ballCorner = Instance.new("UICorner")
		ballCorner.CornerRadius = UDim.new(1, 0)
		ballCorner.Parent = ball
		return ball
	end
	
	local function renderObjectiveDiagram()
		clearDiagram()
		local left = Instance.new("Frame")
		left.Size = UDim2.new(0.48, 0, 1, 0)
		left.Position = UDim2.new(0, 0, 0, 0)
		left.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		left.BackgroundTransparency = 0.2
		left.BorderSizePixel = 0
		left.Parent = diagramFrame
		local leftCorner = Instance.new("UICorner")
		leftCorner.CornerRadius = UDim.new(0, 10)
		leftCorner.Parent = left
		
		local right = Instance.new("Frame")
		right.Size = UDim2.new(0.48, 0, 1, 0)
		right.Position = UDim2.new(0.52, 0, 0, 0)
		right.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		right.BackgroundTransparency = 0.2
		right.BorderSizePixel = 0
		right.Parent = diagramFrame
		local rightCorner = Instance.new("UICorner")
		rightCorner.CornerRadius = UDim.new(0, 10)
		rightCorner.Parent = right
		
		local leftLabel = Instance.new("TextLabel")
		leftLabel.Size = UDim2.new(1, 0, 0.3, 0)
		leftLabel.Position = UDim2.new(0, 0, 0, 0)
		leftLabel.BackgroundTransparency = 1
		leftLabel.Text = "YOUR SIDE"
		leftLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		leftLabel.TextScaled = true
		leftLabel.Font = Enum.Font.GothamBold
		leftLabel.Parent = left
		
		local rightLabel = Instance.new("TextLabel")
		rightLabel.Size = UDim2.new(1, 0, 0.3, 0)
		rightLabel.Position = UDim2.new(0, 0, 0, 0)
		rightLabel.BackgroundTransparency = 1
		rightLabel.Text = "THEIR SIDE"
		rightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		rightLabel.TextScaled = true
		rightLabel.Font = Enum.Font.GothamBold
		rightLabel.Parent = right
		
		local winText = Instance.new("TextLabel")
		winText.Size = UDim2.new(1, 0, 0.28, 0)
		winText.Position = UDim2.new(0, 0, 0.72, 0)
		winText.BackgroundTransparency = 1
		winText.Text = "KEEP THIS EMPTY"
		winText.TextColor3 = Color3.fromRGB(255, 200, 120)
		winText.TextScaled = true
		winText.Font = Enum.Font.GothamBold
		winText.Parent = left
		
		for i = 1, 5 do
			makeBall(right, UDim2.new(0, 12 + (i - 1) * 20, 0.55, 0), Color3.fromRGB(255, 170, 0))
		end
	end
	
	local function renderControlsDiagram()
		clearDiagram()
		local keys = Instance.new("Frame")
		keys.Size = UDim2.new(1, 0, 1, 0)
		keys.Position = UDim2.new(0, 0, 0, 0)
		keys.BackgroundTransparency = 1
		keys.Parent = diagramFrame
		
		local function keycap(text: string, pos: UDim2, size: UDim2)
			local cap = Instance.new("Frame")
			cap.Size = size
			cap.Position = pos
			cap.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			cap.BorderSizePixel = 0
			cap.Parent = keys
			local capCorner = Instance.new("UICorner")
			capCorner.CornerRadius = UDim.new(0, 8)
			capCorner.Parent = cap
			local capText = Instance.new("TextLabel")
			capText.Size = UDim2.new(1, 0, 1, 0)
			capText.BackgroundTransparency = 1
			capText.Text = text
			capText.TextColor3 = Color3.fromRGB(255, 255, 255)
			capText.TextScaled = true
			capText.Font = Enum.Font.GothamBold
			capText.Parent = cap
		end
		
		keycap("W", UDim2.new(0.42, 0, 0.05, 0), UDim2.new(0.16, 0, 0.35, 0))
		keycap("A", UDim2.new(0.24, 0, 0.42, 0), UDim2.new(0.16, 0, 0.35, 0))
		keycap("S", UDim2.new(0.42, 0, 0.42, 0), UDim2.new(0.16, 0, 0.35, 0))
		keycap("D", UDim2.new(0.60, 0, 0.42, 0), UDim2.new(0.16, 0, 0.35, 0))
		keycap("SHIFT", UDim2.new(0.02, 0, 0.05, 0), UDim2.new(0.20, 0, 0.35, 0))
		keycap("E", UDim2.new(0.78, 0, 0.05, 0), UDim2.new(0.20, 0, 0.35, 0))
	end
	
	local function renderStartDiagram()
		clearDiagram()
		local padLeft = Instance.new("Frame")
		padLeft.Size = UDim2.new(0, 46, 0, 46)
		padLeft.Position = UDim2.new(0.22, -23, 0.5, -23)
		padLeft.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		padLeft.BorderSizePixel = 0
		padLeft.Parent = diagramFrame
		local padLeftCorner = Instance.new("UICorner")
		padLeftCorner.CornerRadius = UDim.new(1, 0)
		padLeftCorner.Parent = padLeft
		
		local padRight = Instance.new("Frame")
		padRight.Size = UDim2.new(0, 46, 0, 46)
		padRight.Position = UDim2.new(0.78, -23, 0.5, -23)
		padRight.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
		padRight.BorderSizePixel = 0
		padRight.Parent = diagramFrame
		local padRightCorner = Instance.new("UICorner")
		padRightCorner.CornerRadius = UDim.new(1, 0)
		padRightCorner.Parent = padRight
		
		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0.3, 0, 1, 0)
		arrow.Position = UDim2.new(0.35, 0, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Text = "➡️"
		arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
		arrow.TextScaled = true
		arrow.Font = Enum.Font.GothamBold
		arrow.Parent = diagramFrame
	end
	
	local function renderWinDiagram()
		clearDiagram()
		local goal = Instance.new("TextLabel")
		goal.Size = UDim2.new(1, 0, 1, 0)
		goal.Position = UDim2.new(0, 0, 0, 0)
		goal.BackgroundTransparency = 1
		goal.Text = "5 BALLS OVER THERE ✅\n0 BALLS HERE ✅"
		goal.TextColor3 = Color3.fromRGB(200, 255, 200)
		goal.TextScaled = true
		goal.Font = Enum.Font.GothamBold
		goal.Parent = diagramFrame
	end
	
	local pages = {
		{
			title = "GET THE BALLS OVER",
			icon = "🎯",
			body = "Move ALL 5 balls to the other side.\nKeep YOUR side empty.",
			render = renderObjectiveDiagram,
		},
		{
			title = "MOVE + PICKUP",
			icon = "🎮",
			body = "WASD to move. SHIFT to sprint.\nPress E near a ball to pick it up.",
			render = renderControlsDiagram,
		},
		{
			title = "START THE MATCH",
			icon = "🚀",
			body = "Stand on a RED or BLUE pad.\nWhen both pads have a player, you teleport.",
			render = renderStartDiagram,
		},
		{
			title = "WIN",
			icon = "🏆",
			body = "First player to clear their side\nand move 5 balls over wins!",
			render = renderWinDiagram,
		},
	}
	
	local navFrame = Instance.new("Frame")
	navFrame.Name = "Nav"
	navFrame.Size = UDim2.new(0.9, 0, 0.09, 0)
	navFrame.Position = UDim2.new(0.05, 0, 0.78, 0)
	navFrame.BackgroundTransparency = 1
	navFrame.Parent = mainFrame
	
	local backButton = Instance.new("TextButton")
	backButton.Name = "Back"
	backButton.Size = UDim2.new(0.22, 0, 1, 0)
	backButton.Position = UDim2.new(0, 0, 0, 0)
	backButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	backButton.Text = "<"
	backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	backButton.TextScaled = true
	backButton.Font = Enum.Font.GothamBold
	backButton.Parent = navFrame
	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(0, 8)
	backCorner.Parent = backButton
	
	local nextButton = Instance.new("TextButton")
	nextButton.Name = "Next"
	nextButton.Size = UDim2.new(0.22, 0, 1, 0)
	nextButton.Position = UDim2.new(0.78, 0, 0, 0)
	nextButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	nextButton.Text = ">"
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextScaled = true
	nextButton.Font = Enum.Font.GothamBold
	nextButton.Parent = navFrame
	local nextCorner = Instance.new("UICorner")
	nextCorner.CornerRadius = UDim.new(0, 8)
	nextCorner.Parent = nextButton
	
	local dotsFrame = Instance.new("Frame")
	dotsFrame.Name = "Dots"
	dotsFrame.Size = UDim2.new(0.5, 0, 1, 0)
	dotsFrame.Position = UDim2.new(0.25, 0, 0, 0)
	dotsFrame.BackgroundTransparency = 1
	dotsFrame.Parent = navFrame
	
	local dotsLayout = Instance.new("UIListLayout")
	dotsLayout.FillDirection = Enum.FillDirection.Horizontal
	dotsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dotsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	dotsLayout.Padding = UDim.new(0, 8)
	dotsLayout.Parent = dotsFrame
	
	local dots = {}
	for i = 1, #pages do
		local dot = Instance.new("Frame")
		dot.Name = "Dot" .. i
		dot.Size = UDim2.new(0, 10, 0, 10)
		dot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
		dot.BorderSizePixel = 0
		dot.Parent = dotsFrame
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = dot
		dots[i] = dot
	end
	
	local currentPage = 1
	local function showPage(index: number)
		currentPage = math.clamp(index, 1, #pages)
		local page = pages[currentPage]
		pageTitle.Text = page.title
		iconLabel.Text = page.icon
		pageBody.Text = page.body
		
		for i, dot in ipairs(dots) do
			if i == currentPage then
				dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			else
				dot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
			end
		end
		
		backButton.Visible = currentPage > 1
		nextButton.Visible = currentPage < #pages
		
		if page.render then
			page.render()
		else
			clearDiagram()
		end
	end
	
	backButton.MouseButton1Click:Connect(function()
		showPage(currentPage - 1)
	end)
	
	nextButton.MouseButton1Click:Connect(function()
		showPage(currentPage + 1)
	end)
	
	showPage(1)
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0.3, 0, 0.1, 0)
	closeButton.Position = UDim2.new(0.35, 0, 0.88, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.Text = "GOT IT!"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextScaled = true
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = mainFrame
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton
	
	-- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	
	-- Auto-close after 30 seconds
	task.delay(30, function()
		if screenGui and screenGui.Parent then
			screenGui:Destroy()
		end
	end)
end

-- LocalScript: only run for the local player
local player = Players.LocalPlayer
task.wait(2)
if not player:GetAttribute("Team") then
	createTutorialGui(player)
end

local openTutorialEvent = ReplicatedStorage:FindFirstChild("OpenTutorialEvent")
if openTutorialEvent and openTutorialEvent:IsA("RemoteEvent") then
	openTutorialEvent.OnClientEvent:Connect(function()
		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui and playerGui:FindFirstChild("TutorialGui") then
			return
		end
		createTutorialGui(player)
	end)
end

print("✅ TutorialService ready.")
