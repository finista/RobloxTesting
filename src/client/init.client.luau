require(game.ReplicatedStorage:WaitForChild("Common"):WaitForChild("Modules"):WaitForChild("MovableAttachment")).New()

local uimanager = require(game.ReplicatedStorage:WaitForChild("Common"):WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("Manager"))
local ui = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("MenuUI")

uimanager.New(ui)