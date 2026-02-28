local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

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
	local instructions = Instance.new("TextLabel")
	instructions.Name = "Instructions"
	instructions.Size = UDim2.new(0.9, 0, 0.6, 0)
	instructions.Position = UDim2.new(0.05, 0, 0.2, 0)
	instructions.BackgroundTransparency = 1
	instructions.TextColor3 = Color3.fromRGB(220, 220, 220)
	instructions.TextScaled = true
	instructions.Font = Enum.Font.Gotham
	instructions.TextXAlignment = Enum.TextXAlignment.Left
	instructions.TextYAlignment = Enum.TextYAlignment.Top
	instructions.Text = [[🎯 OBJECTIVE:
Get all 5 of your balls onto the opponent's side while keeping your own side empty!

🎮 CONTROLS:
• WASD - Move around
• SHIFT - Sprint (hold)
• E - Pick up balls (when near them)
• Mouse - Aim your slingshot
• Click Mouse- Launch the ball!

🚀 HOW TO START:
1. Stand on a RED or BLUE teleport pad in the lobby
2. Wait for another player to stand on the opposite pad
3. Both players will teleport to the arena after 5 seconds!

🏆 HOW TO WIN:
• Move all 5 of your colored balls to the opponent's side
• Make sure you have 0 balls left on your own side
• First to do this wins!]]
	instructions.Parent = mainFrame
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0.3, 0, 0.1, 0)
	closeButton.Position = UDim2.new(0.35, 0, 0.85, 0)
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

print("✅ TutorialService ready.")
