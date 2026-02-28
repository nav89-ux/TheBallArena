local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OPEN_TUTORIAL_EVENT_NAME = "OpenTutorialEvent"

local openTutorialEvent = ReplicatedStorage:FindFirstChild(OPEN_TUTORIAL_EVENT_NAME)
if not openTutorialEvent then
	openTutorialEvent = Instance.new("RemoteEvent")
	openTutorialEvent.Name = OPEN_TUTORIAL_EVENT_NAME
	openTutorialEvent.Parent = ReplicatedStorage
end

local function findBoardModel(): Instance?
	local board = workspace:FindFirstChild("NoticeBoard")
	if board then
		return board
	end
	return workspace:FindFirstChild("NoticeBoard", true)
end

local function getBoardPart(board: Instance): BasePart?
	if board:IsA("BasePart") then
		return board
	end
	if board:IsA("Model") then
		if board.PrimaryPart then
			return board.PrimaryPart
		end
		return board:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function ensurePrompt(part: BasePart)
	local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "How to play"
		prompt.ObjectText = "Notice Board"
		prompt.MaxActivationDistance = 12
		prompt.HoldDuration = 0
		prompt.RequiresLineOfSight = false
		prompt.Parent = part
	else
		prompt.ActionText = "How to play"
		prompt.ObjectText = "Notice Board"
	end

	prompt.Triggered:Connect(function(player)
		openTutorialEvent:FireClient(player)
	end)
end

local function ensureSurfaceGui(part: BasePart)
	local surfaceGui = part:FindFirstChild("HowToPlaySurfaceGui")
	if surfaceGui and surfaceGui:IsA("SurfaceGui") then
		return
	end

	surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "HowToPlaySurfaceGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.AlwaysOnTop = true
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 60
	surfaceGui.Parent = part

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Parent = surfaceGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.25, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "HOW TO PLAY"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.Parent = frame

	local icons = Instance.new("TextLabel")
	icons.Size = UDim2.new(1, 0, 0.40, 0)
	icons.Position = UDim2.new(0, 0, 0.28, 0)
	icons.BackgroundTransparency = 1
	icons.Text = "🎯   🎮   🚀   🏆"
	icons.TextColor3 = Color3.fromRGB(255, 255, 255)
	icons.TextScaled = true
	icons.Font = Enum.Font.GothamBold
	icons.Parent = frame

	local hint = Instance.new("TextLabel")
	hint.Size = UDim2.new(1, 0, 0.30, 0)
	hint.Position = UDim2.new(0, 0, 0.68, 0)
	hint.BackgroundTransparency = 1
	hint.Text = "Walk up and press E"
	hint.TextColor3 = Color3.fromRGB(220, 220, 220)
	hint.TextScaled = true
	hint.Font = Enum.Font.GothamBold
	hint.Parent = frame
end

local function setup()
	local board = findBoardModel()
	if not board then
		warn("NoticeBoardService: Could not find 'NoticeBoard' in Workspace.")
		return
	end

	local part = getBoardPart(board)
	if not part then
		warn("NoticeBoardService: Found 'NoticeBoard' but no BasePart to attach UI/prompt.")
		return
	end

	ensurePrompt(part)
	ensureSurfaceGui(part)
	print("✅ NoticeBoardService ready.")
end

setup()
