-- EXECUTOR / AUTO-FARM SCRIPT
-- Pathfind + MoveTo, ignoring transparent / non-collide parts, no spam jumping at finish

local url = "https://raw.githubusercontent.com/hr7ss/JuttUI/refs/heads/main/main9.lua"
local Library = loadstring(game:HttpGet(url))()

local Window = Library:CreateWindow({ Name = "My Executor UI" })
local MainTab = Window:CreateTab("Main")

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local FieldPositions = Library.FieldPositions  -- from library

---------------------------------------------------------------------
-- Config
---------------------------------------------------------------------
local DIST_DONE = 8        -- distance from field center where we consider "arrived"

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function getCharacterStuff()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end
    return char, hum, hrp
end

local function isPassThroughPart(part)
    if not part:IsA("BasePart") then return true end
    if part.CanCollide == false then return true end
    if part.Transparency > 0.5 then return true end
    return false
end

local function smartRaycast(origin, direction, extraIgnore)
    local ignoreList = { LocalPlayer.Character }
    if extraIgnore then
        for _, inst in ipairs(extraIgnore) do
            table.insert(ignoreList, inst)
        end
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local remainingDir = direction
    local currentOrigin = origin

    while remainingDir.Magnitude > 0 do
        params.FilterDescendantsInstances = ignoreList
        local result = Workspace:Raycast(currentOrigin, remainingDir, params)
        if not result then
            return nil
        end

        if isPassThroughPart(result.Instance) then
            table.insert(ignoreList, result.Instance)
            local usedDist = (result.Position - currentOrigin).Magnitude
            if usedDist >= remainingDir.Magnitude then
                return nil
            end
            local dirUnit = remainingDir.Unit
            currentOrigin = result.Position + dirUnit * 0.01
            remainingDir = dirUnit * (remainingDir.Magnitude - usedDist - 0.01)
        else
            return result
        end
    end

    return nil
end

local function getGroundPosition(pos)
    local result = smartRaycast(pos + Vector3.new(0, 50, 0), Vector3.new(0, -200, 0))
    if result then
        return result.Position
    else
        return pos
    end
end

---------------------------------------------------------------------
-- Simple step-by-step walker (fallback when NoPath)
---------------------------------------------------------------------
local function walkDirectTo(goalPos, autofarmEnabledRef)
    local MAX_STEPS = 60
    local STEP_DIST = 8

    for _ = 1, MAX_STEPS do
        if not autofarmEnabledRef() then break end

        local _, humanoid, hrp = getCharacterStuff()
        if not (humanoid and hrp) then return end

        local currentPos = hrp.Position
        local diff = goalPos - currentPos
        local dist = diff.Magnitude

        -- Already close enough -> stop, NO jump
        if dist <= DIST_DONE then
            break
        end

        local dir = diff.Unit
        local step = math.min(STEP_DIST, dist)
        local nextPos = currentPos + dir * step

        -- obstacle check in front, ignoring transparent / non-collide
        local hit = smartRaycast(currentPos, dir * step)
        if hit then
            -- try sidestep right if something solid is there
            local right = Vector3.new(dir.Z, 0, -dir.X).Unit
            nextPos = currentPos + right * step
        end

        nextPos = getGroundPosition(nextPos)

        humanoid:MoveTo(nextPos)
        local reached = humanoid.MoveToFinished:Wait(3)

        -- If we didn't reach AND we're still pretty far, try a jump
        if not reached then
            local newPos = hrp.Position
            local newDist = (goalPos - newPos).Magnitude
            if newDist > DIST_DONE then
                humanoid.Jump = true
            else
                -- close enough after all
                break
            end
        end
    end
end

---------------------------------------------------------------------
-- Pathfind to a field (with walker fallback, no teleport, no finish-spam jump)
---------------------------------------------------------------------
local autofarmEnabled = false
local currentFieldName = "Dandelion Field"

local function goToField(fieldName)
    local targetCF = FieldPositions[fieldName]
    if not targetCF then
        warn("No CFrame set for field:", fieldName)
        return
    end

    local _, humanoid, hrp = getCharacterStuff()
    if not (humanoid and hrp) then
        warn("No humanoid/HRP")
        return
    end

    local goalPos  = getGroundPosition(targetCF.Position)
    local startPos = getGroundPosition(hrp.Position)

    -- If we're already at the field, do nothing (prevents re-jumping)
    if (startPos - goalPos).Magnitude <= DIST_DONE then
        return
    end

    local path = PathfindingService:CreatePath({
        AgentRadius = 4,
        AgentHeight = 6,
        AgentCanJump = true,
    })

    path:ComputeAsync(startPos, goalPos)
    print("Path status to", fieldName, "=", path.Status)

    if path.Status ~= Enum.PathStatus.Success then
        warn("Path failed to " .. fieldName .. ": " .. path.Status.Name .. " - using direct walker fallback")
        walkDirectTo(goalPos, function() return autofarmEnabled end)
        return
    end

    local waypoints = path:GetWaypoints()

    for _, waypoint in ipairs(waypoints) do
        if not autofarmEnabled then break end

        local _, hum, hroot = getCharacterStuff()
        if not (hum and hroot) then return end

        -- If already close enough to goal, stop immediately (no more jumping)
        if (hroot.Position - goalPos).Magnitude <= DIST_DONE then
            break
        end

        if waypoint.Action == Enum.PathWaypointAction.Jump then
            hum.Jump = true
        end

        local before = hroot.Position
        hum:MoveTo(waypoint.Position)

        local reached = hum.MoveToFinished:Wait(4)
        local movedDist = (hroot.Position - before).Magnitude

        if not reached or movedDist < 1 then
            -- Only jump to unstuck if still far from goal
            if (hroot.Position - goalPos).Magnitude > DIST_DONE then
                hum.Jump = true
                warn("Stuck on waypoint while pathing to", fieldName)
            end
            break
        end
    end
end

---------------------------------------------------------------------
-- UI: selector + toggle
---------------------------------------------------------------------
local fieldList = {}
for name in pairs(FieldPositions) do
    table.insert(fieldList, name)
end
table.sort(fieldList)

local fieldSelector = MainTab:AddSelector({
  
