--!strict
local shared = game:GetService("ReplicatedStorage"):WaitForChild("Common")
local types = require(shared:WaitForChild("Types"):WaitForChild("UIManager"))

local page = {} :: types.PageComponentImpl
page.__index = page

--Override default transitionIn sequence
-- function page:TransitionIn()
--     print('Custom transition!')
-- end

--Override default transitionOut sequence
-- function page:TransitionOut()
--     print('Custom transition out!')
-- end

function page:OnOpen()

end

function page:OnClose()

end

function page.New(frame, manager)
    local self = setmetatable({}, page)

    self.page = frame
    self.manager = manager;

    (self.page:WaitForChild("CloseBtn") :: TextButton).MouseButton1Click:Connect(function()
        manager:OpenPage()
    end)

    return self
end

return page