--!strict
-- A simple terror radius script

local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")

local modules = game:GetService("ReplicatedStorage"):WaitForChild("Common")

local tween = require(modules:WaitForChild("TweenModule"))
local types = require(modules:WaitForChild("Types"):WaitForChild("TerrorRadius"))

local terrorRadius = {} :: types.TerrorRadiusImpl
terrorRadius.__index = terrorRadius

function terrorRadius:SwitchRadius(radius)
	if self.radiusSwitchTask then
		task.cancel(self.radiusSwitchTask)
	end

	self.radiusSwitchTask = task.spawn(function()
		if self.currentLayer then
			tween.MultiTween(
				self.currentLayer.sound,
				"Volume",
				0,
				0.5,
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Sine
			)
		end

		if not radius then
			return
		end

		radius.sound.Volume = 0
		radius.sound:Play()

		tween.MultiTween(
			radius.sound,
			"Volume",
			radius.sound:GetAttribute("originalVolume"),
			0.5,
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Sine
		)
	end)

	self.currentLayer = radius
end

function terrorRadius:Update()
	if not self.anchor then
		return
	end

	if not player.Character or not player.Character.PrimaryPart then
		return
	end

	local distance = (self.anchor.Position - player.Character.PrimaryPart.Position).Magnitude

	if self.chasePlaying then
		if distance > self.layers[1].distance then
			self.chasePlaying = false
		end
		return
	end

	local currentLayer, lIndex = nil, nil
	for index, layer in pairs(self.layers) do
		if layer.distance > distance then
			currentLayer = layer
			lIndex = index
		end
	end

	if not currentLayer then
		self:SwitchRadius(nil)
	elseif self.currentLayer ~= currentLayer then
		self.chasePlaying = lIndex == #self.layers
		self:SwitchRadius(currentLayer)
	end
end

function terrorRadius:SetAnchor(anchor)
	self.anchor = anchor
end

function terrorRadius.New(config)
	local self = setmetatable({}, terrorRadius)

	self.layers = config.layers
	table.sort(self.layers, function(i, j)
		return i.distance > j.distance
	end)

	self.chasePlaying = false
	self.currentLayer = nil

	self.anchor = config.anchor

	self.updateConnection = runService.Heartbeat:Connect(function()
		self:Update()
	end)

	for _, layer in pairs(self.layers) do
		layer.sound:SetAttribute("originalVolume", layer.sound.Volume)
	end

	return self
end

return terrorRadius
