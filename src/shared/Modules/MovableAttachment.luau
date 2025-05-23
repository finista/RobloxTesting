--!strict
-- Module used to attach a player to a moving part so they don't slide off of it

local collectionService = game:GetService("CollectionService")
local runService = game:GetService("RunService")

local modules = game:GetService("ReplicatedStorage"):WaitForChild("Common")
local player = game:GetService("Players").LocalPlayer

local constants = require(modules:WaitForChild("Constants"))
local types = require(modules:WaitForChild("Types"):WaitForChild("MovableAttachment"))

local attachment = {} :: types.AttachmentImpl
attachment.__index = attachment

function attachment:LoadRegion(object)
	local configFolder = object:FindFirstChild("AttachmentConfig") :: Folder
	assert(configFolder, `Cannot load attachment for {object.Name} because AttachmentConfig is missing.`)

	local regionPart = configFolder:FindFirstChild("RegionPart") :: ObjectValue
	assert(regionPart and regionPart.Value, `{object.Name}: RegionPart is missing or it's value is nil.`)

	local enabledVal = configFolder:FindFirstChild("Enabled") :: BoolValue
	assert(enabledVal, `{object.Name}: Enabled is missing.`)

	self.loadedRegions[object] = {
		basePart = object,
		config = configFolder,
		regionPart = regionPart.Value :: BasePart,
		enabled = enabledVal,
	}
end

function attachment:UnloadRegion(object)
	if not self.loadedRegions[object] then
		warn(`{object.Name} is not loaded.`)
		return
	end

	self.loadedRegions[object] = nil
end

function attachment:Render()
    if not player.Character or not player.Character.PrimaryPart then
        return
    end

    if tick() - self.lastRefresh > .1 then
        self:Update()
        self.lastRefresh = tick()
    end

	if not self.currentRegion or not self.lastCFrame then
		return
	end

	local currentCFrame = self.currentRegion.basePart.CFrame
	local relative = currentCFrame * self.lastCFrame:Inverse()

	player.Character.PrimaryPart.CFrame = relative * player.Character.PrimaryPart.CFrame

	local camera = workspace.CurrentCamera
    if camera then
        camera.CFrame = relative * camera.CFrame
    end

	self.lastCFrame = currentCFrame
end

function attachment:Update()
    if self.currentRegion then
        local parts = workspace:GetPartsInPart(self.currentRegion.regionPart)
        if not table.find(parts, player.Character.PrimaryPart) then
            self.currentRegion = nil
            self.lastCFrame = nil

            print("Player left region.")
        end

        return
    end

    for _, region in pairs(self.loadedRegions) do
        local parts = workspace:GetPartsInPart(region.regionPart)
        if table.find(parts, player.Character.PrimaryPart) then
            self.currentRegion = region
            self.lastCFrame = region.basePart.CFrame

            print(`Player entered {region.basePart.Name}`)

            return
        end
    end 
end

function attachment.New()
	local self = setmetatable({}, attachment)

	self.loadedRegions = {}
	self.currentRegion = nil

    self.lastRefresh = 0
	self.lastCFrame = nil

	for _, region in pairs(collectionService:GetTagged(constants.MOVABLE_ATTACHMENT_TAG)) do
		self:LoadRegion(region)
	end

	self.addedConnection = collectionService
		:GetInstanceAddedSignal(constants.MOVABLE_ATTACHMENT_TAG)
		:Connect(function(obj)
			self:LoadRegion(obj)
		end)

	self.removedConnection = collectionService
		:GetInstanceRemovedSignal(constants.MOVABLE_ATTACHMENT_TAG)
		:Connect(function(obj)
			self:UnloadRegion(obj)
		end)

	self.updateConnection = runService.RenderStepped:Connect(function()
		self:Render()
	end)

    print("MovableAttachment loaded.")

	return self
end

function attachment:Unload()
	if self.addedConnection then
		self.addedConnection:Disconnect()
	end

	if self.removedConnection then
		self.removedConnection:Disconnect()
	end

	if self.updateConnection then
		self.updateConnection:Disconnect()
	end

	table.clear(self.loadedRegions)
end

return attachment
