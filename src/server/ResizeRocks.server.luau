local function resizeRocks()
	local battleArena = workspace:WaitForChild("BattleArena")
	local map = battleArena:WaitForChild("Map")
	local rocksFolder = map:FindFirstChild("Rocks")
	
	if not rocksFolder then
		warn("Rocks folder not found in BattleArena.Map")
		return
	end
	
	local HEIGHT_MULTIPLIER = 3 -- Make them 3x taller
	
	print("🪨 Resizing rocks...")
	
	for _, rock in pairs(rocksFolder:GetChildren()) do
		if rock:IsA("BasePart") then
			local oldSize = rock.Size
			local newSize = Vector3.new(oldSize.X, oldSize.Y * HEIGHT_MULTIPLIER, oldSize.Z)
			
			-- Calculate position offset to keep the bottom at the same level
			-- We need to move it up by half of the added height
			local addedHeight = newSize.Y - oldSize.Y
			local offset = Vector3.new(0, addedHeight / 2, 0)
			
			rock.Size = newSize
			rock.CFrame = rock.CFrame + offset
		end
	end
	
	print("✅ Rocks resized!")
end

-- Run once
resizeRocks()
