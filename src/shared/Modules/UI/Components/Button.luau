--!strict
--Handles button animations

local shared = game:GetService("ReplicatedStorage"):WaitForChild("Common")
local tween = require(shared:WaitForChild("TweenModule"))

return function(button: ImageButton | TextButton)
	local originalSize = button.Size
	local selectionSize = button.Size + UDim2.new(0, 10, 0, 10)
	local clickSize = button.Size + UDim2.new(0, 5, 0, 5)

	local currentTween: Tween? = nil

	local hoverSound = button:WaitForChild("Hover") :: Sound
	local clickSound = button:WaitForChild("Click") :: Sound

	local function cancelAnimation()
		if not currentTween then
			return
		end

		currentTween:Cancel()
		currentTween = nil
	end

	local function tweenBtn(size: UDim2)
		cancelAnimation()
		tween.TweenProperty(
			button, "Size", size,
			{ Duration = .1, EasingDirection = Enum.EasingDirection.InOut, EasingStyle = Enum.EasingStyle.Sine }
		)
	end

	button.MouseEnter:Connect(function()
		tweenBtn(selectionSize)
		hoverSound:Play()
	end)

	button.MouseLeave:Connect(function()
		tweenBtn(originalSize)
	end)

	button.MouseButton1Down:Connect(function()
		tweenBtn(clickSize)
		clickSound:Play()
	end)

	button.MouseButton1Up:Connect(function()
		tweenBtn(selectionSize)
	end)
end
