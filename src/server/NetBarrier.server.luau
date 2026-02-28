local function createBarrier(netPart)
	if not netPart then return end
	if not netPart:IsA("BasePart") then return end
	
	print("🛡️ Creating barrier for " .. netPart.Name)
	
	local barrier = Instance.new("Part")
	barrier.Name = netPart.Name .. "_Barrier"
	barrier.Transparency = 1 -- Invisible
	barrier.Anchored = true
	barrier.CanCollide = true
	barrier.CastShadow = false
	
	-- Make it slightly thicker than the visual net to catch fast balls
	local size = netPart.Size
	-- Assuming the net is thin on the Z or X axis. We'll add thickness to the thinnest dimension.
	-- Or just make it a box that covers the net.
	
	-- If it's a meshpart, the size might be weird. Let's assume we want to thicken the local Z axis (depth) if it's a standard plane-like net.
	-- However, without knowing the orientation, it's safer to just slightly expand all dimensions, or specifically the one that looks "thin" (< 1 stud).
	
	local thickness = 2 -- Ensure at least 2 studs thick for physics reliability
	
	local newSize = Vector3.new(
		math.max(size.X, size.X < size.Z and thickness or 0),
		size.Y,
		math.max(size.Z, size.Z < size.X and thickness or 0)
	)
	
	-- If both are thin, just thicken both (unlikely for a net plane, but safe)
	if size.X < 1 and size.Z < 1 then
		newSize = Vector3.new(thickness, size.Y, thickness)
	end
	
	barrier.Size = newSize
	barrier.CFrame = netPart.CFrame
	barrier.Parent = netPart.Parent
	
	-- Disable collisions on the original net to prevent fighting/double collisions if desired, 
	-- but keeping it enabled is fine if the barrier covers it.
	-- netPart.CanCollide = false 
end

local function setupBarriers()
	local map = workspace:WaitForChild("BattleArena"):WaitForChild("Map")
	
	-- Try to find Net1 and Net2
	local net1 = map:FindFirstChild("Net1")
	local net2 = map:FindFirstChild("Net2")
	
	if net1 then createBarrier(net1) end
	if net2 then createBarrier(net2) end
	
	-- Also watch for them if they are streamed in or added later
	map.ChildAdded:Connect(function(child)
		if child.Name == "Net1" or child.Name == "Net2" then
			createBarrier(child)
		end
	end)
end

setupBarriers()
