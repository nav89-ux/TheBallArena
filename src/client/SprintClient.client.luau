local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local WALK_SPEED = 16
local RUN_SPEED = 30
local TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local isRunning = false

-- Function to update walk speed
local function updateSpeed(targetSpeed)
	if not humanoid then return end
	
	-- Safety: Do not change speed if we are frozen (speed is 0)
	-- This prevents breaking out of the Slingshot lock
	if humanoid.WalkSpeed <= 0.1 and targetSpeed > 0 then
		return 
	end
	
	-- Use Tween for smooth transition
	local tween = TweenService:Create(humanoid, TWEEN_INFO, {WalkSpeed = targetSpeed})
	tween:Play()
end

-- Handle Input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = true
		updateSpeed(RUN_SPEED)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = false
		updateSpeed(WALK_SPEED)
	end
end)

-- Handle Character Respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	
	-- Reset state
	isRunning = false
	humanoid.WalkSpeed = WALK_SPEED
end)
