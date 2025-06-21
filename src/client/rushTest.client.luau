local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local maxTokens = 5
local currentTokens = maxTokens
local isRushing = false
local isInBumpWindow = false
local isFatigued = false
local bumpWindowTime = 2 -- Time to chain another rush after bumping
local fatigueTime = 5 -- Fatigue duration
local rushDuration = 3 -- Rush lasts up to 3 seconds
local rushSpeed = 50 -- Speed in studs per second
local turnSpeed = math.rad(90) -- 90 degrees per second turn limit
local knockbackSpeed = 20 -- Speed of knockback
local knockbackDuration = 0.2 -- How long knockback lasts

local currentRushDirection
local bodyVelocity

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {character}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function enterFatigue()
    isFatigued = true
    humanoid.WalkSpeed = 0
    task.spawn(function()
        task.wait(fatigueTime)
        isFatigued = false
        currentTokens = maxTokens
        humanoid.WalkSpeed = 16
    end)
end

local function handleCollision()
    isRushing = false
    bodyVelocity:Destroy()

    -- Apply knockback
    local knockbackVelocity = Instance.new("BodyVelocity")
    knockbackVelocity.Velocity = -currentRushDirection * knockbackSpeed
    knockbackVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    knockbackVelocity.Parent = hrp
    task.wait(knockbackDuration)
    knockbackVelocity:Destroy()

    -- Consume a token
    currentTokens = currentTokens - 1

    -- Enter bump window with slow movement
    humanoid.WalkSpeed = 5
    isInBumpWindow = true
    task.spawn(function()
        task.wait(bumpWindowTime)
        isInBumpWindow = false
        humanoid.WalkSpeed = 16
        enterFatigue()
    end)
end

local function endRush()
    isRushing = false
    bodyVelocity:Destroy()
    enterFatigue()
end

local function startRush()
    if isFatigued or currentTokens <= 0 then return end
    currentTokens = currentTokens - 1 -- Consume a token to start rush
    isRushing = true

    -- Set initial rush direction based on camera (horizontal only)
    currentRushDirection = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit

    -- Apply forward velocity
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = currentRushDirection * rushSpeed
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = hrp

    local startTime = tick()
    local connection

    -- Update direction and check duration each frame
    connection = RunService.Heartbeat:Connect(function(dt)
        if tick() - startTime > rushDuration then
            endRush()
            connection:Disconnect()
            return
        end

        local rayLength = rushSpeed * dt * 2 -- Look ahead based on speed
        local rayDirection = currentRushDirection * rayLength
        local raycastResult = workspace:Raycast(hrp.Position, rayDirection, raycastParams)
        if raycastResult then
            handleCollision()
            connection:Disconnect()
            return
        end

        -- Update direction with restricted turn rate
        local desiredDirection = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
        local angle = math.acos(math.clamp(currentRushDirection:Dot(desiredDirection), -1, 1))
        if angle > 0 then
            local maxRotation = turnSpeed * dt
            if angle < maxRotation then
                currentRushDirection = desiredDirection
            else
                local cross = currentRushDirection:Cross(desiredDirection)
                if cross.Magnitude > 1e-5 then
                    local axis = cross.Unit
                    local rotationCFrame = CFrame.fromAxisAngle(axis, maxRotation)
                    currentRushDirection = (rotationCFrame * currentRushDirection).Unit
                else
                    currentRushDirection = desiredDirection
                end
            end
        end
        bodyVelocity.Velocity = currentRushDirection * rushSpeed
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + currentRushDirection)
    end)
end

-- Handle 'E' key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        if isInBumpWindow and currentTokens > 0 then
            isInBumpWindow = false
            startRush()
        elseif not isRushing and not isFatigued and currentTokens > 0 then
            startRush()
        end
    end
end)