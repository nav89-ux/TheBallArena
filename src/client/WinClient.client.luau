local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local winRoundEvent = ReplicatedStorage:WaitForChild("WinRoundEvent")

local DISPLAY_DURATION = 4
local RED_COLOR = Color3.fromRGB(220, 50, 50)
local BLUE_COLOR = Color3.fromRGB(50, 100, 220)

local function showWinScreen(winnerTeam: string)
	local isWinner = player:GetAttribute("Team") == winnerTeam

	local isRed = winnerTeam == "TeamRed"
	local teamColor = isRed and RED_COLOR or BLUE_COLOR
	local teamLabel = isRed and "RED" or "BLUE"
	local resultText = isWinner and "YOU WIN!" or "YOU LOSE!"
	local resultColor = isWinner and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(180, 180, 180)

	-- Build screen gui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "WinScreen"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	-- Dark overlay
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Parent = screenGui

	-- Center card
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.new(0, 520, 0, 260)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.5, 0)
	card.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.Parent = screenGui

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 20)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = teamColor
	cardStroke.Thickness = 3
	cardStroke.Transparency = 1
	cardStroke.Parent = card

	-- Team banner strip
	local banner = Instance.new("Frame")
	banner.Size = UDim2.new(1, 0, 0.28, 0)
	banner.Position = UDim2.new(0, 0, 0, 0)
	banner.BackgroundColor3 = teamColor
	banner.BorderSizePixel = 0
	banner.Parent = card

	local bannerCornerTop = Instance.new("UICorner")
	bannerCornerTop.CornerRadius = UDim.new(0, 20)
	bannerCornerTop.Parent = banner

	-- Square off the bottom corners of the banner
	local bannerFix = Instance.new("Frame")
	bannerFix.Size = UDim2.new(1, 0, 0.5, 0)
	bannerFix.Position = UDim2.new(0, 0, 0.5, 0)
	bannerFix.BackgroundColor3 = teamColor
	bannerFix.BorderSizePixel = 0
	bannerFix.Parent = banner

	local bannerLabel = Instance.new("TextLabel")
	bannerLabel.Size = UDim2.new(1, 0, 1, 0)
	bannerLabel.BackgroundTransparency = 1
	bannerLabel.Text = "TEAM " .. teamLabel
	bannerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	bannerLabel.Font = Enum.Font.GothamBold
	bannerLabel.TextScaled = true
	bannerLabel.Parent = banner

	-- Result label
	local resultLabel = Instance.new("TextLabel")
	resultLabel.Size = UDim2.new(0.9, 0, 0.38, 0)
	resultLabel.AnchorPoint = Vector2.new(0.5, 0)
	resultLabel.Position = UDim2.new(0.5, 0, 0.33, 0)
	resultLabel.BackgroundTransparency = 1
	resultLabel.Text = resultText
	resultLabel.TextColor3 = resultColor
	resultLabel.Font = Enum.Font.GothamBold
	resultLabel.TextScaled = true
	resultLabel.Parent = card

	-- Subtitle
	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
	subtitleLabel.AnchorPoint = Vector2.new(0.5, 0)
	subtitleLabel.Position = UDim2.new(0.5, 0, 0.73, 0)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Text = "Returning to lobby..."
	subtitleLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextScaled = true
	subtitleLabel.Parent = card

	-- Animate in
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	overlay.BackgroundTransparency = 1
	TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.4 }):Play()

	card.BackgroundTransparency = 1
	card.Position = UDim2.new(0.5, 0, 0.6, 0)
	TweenService:Create(card, tweenInfo, {
		BackgroundTransparency = 0.05,
		Position = UDim2.new(0.5, 0, 0.5, 0),
	}):Play()

	TweenService:Create(cardStroke, TweenInfo.new(0.4), { Transparency = 0 }):Play()

	-- Animate out and destroy
	task.delay(DISPLAY_DURATION - 0.5, function()
		if not screenGui or not screenGui.Parent then return end
		local fadeOut = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(overlay, fadeOut, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(card, fadeOut, {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.4, 0),
		}):Play()
		task.wait(0.6)
		if screenGui and screenGui.Parent then
			screenGui:Destroy()
		end
	end)
end

winRoundEvent.OnClientEvent:Connect(showWinScreen)

print("✅ WinClient ready.")
