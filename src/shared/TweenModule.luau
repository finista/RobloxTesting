--!strict
local TweenService = game:GetService("TweenService")
local module = {}

export type TweenConfig = {
	Duration: number?,
	EasingStyle: Enum.EasingStyle?,
	EasingDirection: Enum.EasingDirection?,
}

local function createTweenInfo(config: TweenConfig?): TweenInfo
	return TweenInfo.new(
		config and config.Duration or 0.3,
		config and config.EasingStyle or Enum.EasingStyle.Quad,
		config and config.EasingDirection or Enum.EasingDirection.Out
	)
end

function module.TweenProperty(instance: Instance, property: string, targetValue: any, config: TweenConfig?): Tween
	if not instance then
		error("Instance is nil", 2)
	end
	if not property or type(property) ~= "string" then
		error("Property must be a non-empty string", 2)
	end
	if targetValue == nil then
		error("TargetValue is nil", 2)
	end

	local tweenInfo = createTweenInfo(config)
	local propertyTable = { [property] = targetValue }
	local tween = TweenService:Create(instance, tweenInfo, propertyTable)
	tween:Play()
	return tween
end

function module.TweenModel(model: Model, targetCFrame: CFrame, config: TweenConfig?): Tween
	if not model then
		error("Model is nil", 2)
	end
	local primaryPart = model.PrimaryPart
	if not primaryPart then
		error("Model has no PrimaryPart", 2)
	end

	local tweenInfo = createTweenInfo(config)
	local tween = TweenService:Create(primaryPart, tweenInfo, { CFrame = targetCFrame })
	tween:Play()
	return tween
end

function module.TweenMany(
	tweens: { { Instance: Instance, Property: string, TargetValue: any } },
	config: TweenConfig?
): { Tween }
	if not tweens or type(tweens) ~= "table" then
		error("Tweens must be a non-empty table", 2)
	end

	local tweenInfo = createTweenInfo(config)
	local createdTweens = {}

	for i, tweenData in ipairs(tweens) do
		if not tweenData.Instance then
			warn(`TweenMany: Skipping index {i} due to nil Instance`)
			continue
		end
		if not tweenData.Property or type(tweenData.Property) ~= "string" then
			warn(`TweenMany: Skipping index {i} due to invalid Property`)
			continue
		end
		if tweenData.TargetValue == nil then
			warn(`TweenMany: Skipping index {i} due to nil TargetValue`)
			continue
		end

		local propertyTable = { [tweenData.Property] = tweenData.TargetValue }
		local tween = TweenService:Create(tweenData.Instance, tweenInfo, propertyTable)
		tween:Play()
		table.insert(createdTweens, tween)
	end

	return createdTweens
end

return module
