local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local NoclipConfig = require(ServerStorage:WaitForChild("NoclipConfig"))

local lastSafePositions = {}
local violationCounters = {}

local function IsInsideWall(character, rootPart)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	params.CollisionGroup = NoclipConfig.WALL_COLLISION_GROUP

	local boxSize = Vector3.new(0.8, 1.8, 0.8)
	local overlappingParts = workspace:GetPartBoundsInBox(rootPart.CFrame, boxSize, params)

	for _, part in ipairs(overlappingParts) do
		if part.CanCollide and part.Size.X > 1 and part.Size.Y > 1 and part.Size.Z > 1 then
			return true
		end
	end

	return false
end

local function IsWallBypassed(startPos, endPos, character)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude 
	rayParams.FilterDescendantsInstances = {character}
	rayParams.CollisionGroup = NoclipConfig.WALL_COLLISION_GROUP

	local direction = endPos - startPos
	local rayResultForward = workspace:Raycast(startPos, direction, rayParams)
	if rayResultForward and rayResultForward.Instance.CanCollide then 
		if (rayResultForward.Position - startPos).Magnitude > NoclipConfig.SURFACE_BUFFER and (rayResultForward.Position - endPos).Magnitude > NoclipConfig.SURFACE_BUFFER then
			return true 
		end
	end

	local backwardDirection = startPos - endPos
	local rayResultBackward = workspace:Raycast(endPos, backwardDirection, rayParams)
	if rayResultBackward and rayResultBackward.Instance.CanCollide then
		if (rayResultBackward.Position - endPos).Magnitude > NoclipConfig.SURFACE_BUFFER and (rayResultBackward.Position - startPos).Magnitude > NoclipConfig.SURFACE_BUFFER then
			return true
		end
	end

	return false
end

RunService.Heartbeat:Connect(function(deltaTime)
	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local hrp = character.HumanoidRootPart
			local currentPos = hrp.Position

			-- Ignore physics-heavy launches to prevent false-positives
			if hrp.AssemblyLinearVelocity.Magnitude > 120 then
				continue
			end

			if not violationCounters[player] then
				violationCounters[player] = 0
			end

			local isFlagged = false

			if IsInsideWall(character, hrp) then
				isFlagged = true
			end

			local lastPos = lastSafePositions[player]
			if lastPos and not isFlagged then
				local distance = (currentPos - lastPos).Magnitude
				local allowedDistance = NoclipConfig.MAX_SPEED_LIMIT * deltaTime

				if distance > allowedDistance then
					if IsWallBypassed(lastPos, currentPos, character) then
						isFlagged = true
					end
				end
			end

			if isFlagged then
				violationCounters[player] = violationCounters[player] + 1

				if violationCounters[player] >= NoclipConfig.MAX_VIOLATIONS then
					warn("Anti-Noclip: " .. player.Name .. " exceeded violation limit.")
					
					-- Handle data cleanup first to ensure no leaks if kicked
					local kickPos = lastPos
					player:Kick("Wall hacking detected")
					
					if NoclipConfig.TELEPORT_BACK and kickPos then
						hrp.CFrame = CFrame.new(kickPos)
					end
				end
				continue
			else
				violationCounters[player] = math.max(0, violationCounters[player] - 0.2)
			end

			lastSafePositions[player] = currentPos
		end
	end
end)

-- [[ MEMORY CLEANUP SECURITY ]]
Players.PlayerRemoving:Connect(function(player)
	lastSafePositions[player] = nil
	violationCounters[player] = nil
end)
