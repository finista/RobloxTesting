--!strict

-- Module used to make a part follow a certain path
-- Used for stuff like trams and etc.

local runService = game:GetService("RunService")

local modules = game:GetService("ServerScriptService"):WaitForChild("Server")
local types = require(modules:WaitForChild("Types"):WaitForChild("PathMove"))

local path = {} :: types.PathMoveImpl
path.__index = path

function path:LoadPathFrom(container: Instance)
	for _, point in pairs(container:GetChildren()) do
		if not point:IsA("BasePart") then
			continue
		end

		local beam = point:FindFirstChild("Beam") :: Beam
		if beam then
			beam.Enabled = false
		end

		point.Transparency = 1

		self.path[#self.path + 1] = {
			part = point,
			attachment = point:WaitForChild("Attachment") :: Attachment,
		}
	end
end

function path:ClearPath()
	table.clear(self.path)
end

function path:Update()
	if not self.running then
		return
	end

	if not self.actor or not self.alignOrientation or not self.alignPosition then
		return
	end

	local target = self.path[self.currentNode + 1]
	local current = self.path[self.currentNode]

	local distance = (target.attachment.WorldPosition - self.actor.Position).Magnitude
    
	self.alignPosition.Attachment1 = target.attachment
    self.alignOrientation.Attachment1 = (current or target).attachment
    
	if distance < 2 then
		if not self.path[self.currentNode + 2] then
			if self.looped then
				self.currentNode = 0
				return
			end

            self.alignOrientation.Attachment1 = target.attachment
			self:Stop()

			return
		end

		self.currentNode += 1
	end
end

function path:SetSpeed(speed)
	if not self.actor or not self.alignPosition then
		warn("Cant set speed as there is no current actor present.")
		return
	end

	self.alignPosition.MaxVelocity = speed
end

function path:Run(config)
	self.actor = config.actor

	self.alignOrientation = config.actor:WaitForChild("AlignO") :: AlignOrientation
	self.alignPosition = config.actor:WaitForChild("AlignP") :: AlignPosition

	self.currentNode = config.startNode or 0
	self.looped = config.looped or false

    if config.speed then
        self:SetSpeed(config.speed)
    end

	(self.alignOrientation :: AlignOrientation).Responsiveness = config.orientationResponsiveness or 20
	(self.alignPosition :: AlignPosition).Responsiveness = config.positionResponsiveness or 200

	self.running = true
end

function path:Stop()
    if not self.running then
        return
    end

    self.running = false

    self.actor = nil
    self.alignOrientation = nil
    self.alignPosition = nil
end

function path.New()
	local self = setmetatable({}, path)

	self.path = {}

	self.actor = nil
	self.alignOrientation = nil
	self.alignPosition = nil

	self.currentNode = 1
	self.running = false
	self.looped = false

	self.updateConnection = runService.Heartbeat:Connect(function()
		self:Update()
	end)

	return self
end

return path
