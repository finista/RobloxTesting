--!strict
-- UI manager module that handles page loading and menu

local shared = game:GetService("ReplicatedStorage"):WaitForChild("Common")
local types = require(shared:WaitForChild("Types"):WaitForChild("UIManager"))
local tween = require(shared:WaitForChild("TweenModule"))

local components = script.Parent:WaitForChild("Components")
local pagesModules = script.Parent:WaitForChild("Pages")

local buttonComponent = require(components:WaitForChild("Button"))

local manager = {} :: types.ManagerImpl
manager.__index = manager

local POSITIONS = {
	MENU = {
		OPEN = UDim2.new(0.345, 0, 0.842, 0),
		CLOSED = UDim2.new(0.345, 0, 1.1, 0),
	},

	TOGGLE_BTN = {
		OPEN = UDim2.new(0.5, 0, 0.796, 0),
		CLOSED = UDim2.new(0.5, 0, 0.954, 0),
	},
}

function manager:RunWithDB(func, ...)
	-- Runs the given function with debounce to prevent animtation conflicts and etc
	if self.db then
		return
	end

	self.db = true

	local success, error = pcall(func, table.unpack({ ... }))
	if not success then
		warn(`{debug.info(func, "n")} failed, error: {error or "No error given."}`)
	end

	self.db = false
end

function manager:LoadButtons()
	-- Loads menu buttons and attaches them to their respective pages
	for _, button in pairs(self.menuFrame:WaitForChild("Buttons"):GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		buttonComponent(button :: ImageButton)


		-- Attach page open handler
		local pageName = button:GetAttribute("Page")
		button.MouseButton1Click:Connect(function()
			if self.currentPage == pageName then
				self:RunWithDB(self.OpenPage, self)
				return
			end

			self:RunWithDB(self.OpenPage, self, pageName)
		end)
	end
end

function manager:LoadPageComponents()
	-- Loads all the page components

	for _, page in pairs(self.pages:GetChildren()) do
		local module = pagesModules:WaitForChild(page.Name, 5) :: ModuleScript?
		if not module then
			warn(`Page {page.Name} is missing a component module.`)
			continue
		end

		xpcall(function()
			local result = require(module) :: types.PageComponent
			assert(result.New, "Component missing .New() method")

			self.pageComponents[page.Name] = result.New(page :: Frame, self)
		end, function(err)
			warn(`Failed to load page component {module.Name}, error: {err}`)
		end)
	end
end

function manager:Initialize()
	-- Resets all UI element's positions and loads the components
	self.menuFrame.Position = POSITIONS.MENU.CLOSED
	self.menuToggle.Position = POSITIONS.TOGGLE_BTN.CLOSED

	self.transitionFrame.Visible = false
	self.menuToggle.Rotation = 0

	for _, page in pairs(self.pages:GetChildren()) do
		(page :: Frame).Visible = false
	end

	self:LoadButtons()
	self:LoadPageComponents()

	self.menuToggle.MouseButton1Click:Connect(function()
		self:RunWithDB(self.ToggleMenu, self, not self.menuOpen)
	end)
end

function manager:ToggleMenu(state)
	if self.menuOpen == state then
		return
	end

	local target = state and "OPEN" or "CLOSED"
	local tweenConfig = {
		Duration = 0.2,
		EasingStyle = Enum.EasingStyle.Sine,
		EasingDirection = Enum.EasingDirection.InOut,
	}

	tween.TweenMany({
		{ Instance = self.menuFrame, Property = "Position", TargetValue = POSITIONS.MENU[target] },
		{ Instance = self.menuToggle, Property = "Position", TargetValue = POSITIONS.TOGGLE_BTN[target] },
		{ Instance = self.menuToggle, Property = "Rotation", TargetValue = state and 180 or 0 },
	}, tweenConfig)
	
	self.menuOpen = state
	task.wait(.2)
end

function manager:TransitionPage(page, state)
	-- Default transition function if the page component lacks TransitionIn or TransitionOut
	if not page then
		warn("TransitionPage: Page is nil")
		return
	end
	if page.AnchorPoint ~= Vector2.new(0.5, 0.5) then
		warn(`Page {page.Name}'s anchor point is not set to .5 .5, transition animation could break.`)
	end

	self.transitionFrame.Position = page.Position
	self.transitionFrame.Visible = true

	if state then
		self.transitionFrame.Size = UDim2.new(page.Size.X.Scale, 0, 0, 0)
		self.transitionFrame.BackgroundTransparency = 0

		local sizeTween = tween.TweenProperty(
			self.transitionFrame,
			"Size",
			page.Size,
			{ Duration = 0.3, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out }
		)
		sizeTween.Completed:Wait()

		page.Visible = true
		local transparencyTween = tween.TweenProperty(
			self.transitionFrame,
			"BackgroundTransparency",
			1,
			{ Duration = 0.2, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out }
		)
		transparencyTween.Completed:Wait()
	else
		self.transitionFrame.Size = page.Size
		self.transitionFrame.BackgroundTransparency = 1

		tween.TweenProperty(
			self.transitionFrame,
			"BackgroundTransparency",
			0,
			{ Duration = 0.2, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out }
		).Completed:Wait()

		page.Visible = false
		tween.TweenProperty(
			self.transitionFrame,
			"Size",
			UDim2.new(page.Size.X.Scale, 0, 0, 0),
			{ Duration = 0.3, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out }
		).Completed:Wait()
	end

	self.transitionFrame.Visible = false
end

function manager:OpenPage(name)
	-- Switches to or opens the given page

	if self.currentPage then
		local component = self.pageComponents[self.currentPage]
		assert(component, `Page {name} is missing a component module.`)

		if component["TransitionOut"] then
			component.TransitionOut(component)
		else
			self:TransitionPage(self.pages:FindFirstChild(self.currentPage) :: Frame, false)
		end

		if component["OnClose"] then
			component.OnClose(component)
		end
	end

	self.currentPage = name

	if name then
		local component = self.pageComponents[name]
		assert(component, `Page {name} is missing a component module.`)

		if component["TransitionIn"] then
			component.TransitionIn(component)
		else
			self:TransitionPage(self.pages:FindFirstChild(name) :: Frame, true)
		end

		if component["OnOpen"] then
			component.OnOpen(component)
		end
	end
end

function manager.New(UI)
	local self = setmetatable({}, manager) :: types.Manager

	self.UI = UI
	self.menuFrame = self.UI:WaitForChild("MenuFrame") :: Frame
	self.menuToggle = self.UI:WaitForChild("MenuToggle") :: ImageButton
	self.pages = self.UI:WaitForChild("Pages") :: Folder
	self.transitionFrame = self.UI:WaitForChild("Transition") :: Frame

	self.menuOpen = false
	self.currentPage = nil
	self.pageComponents = {}

	self:Initialize()

	return self
end

return manager
