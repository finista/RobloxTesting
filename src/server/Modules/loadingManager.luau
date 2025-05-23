--!strict
local types = require(game.ServerScriptService.Server.Types.loadingManager)

local manager = {} :: types.LoadingManagerImpl
manager.__index = manager

function manager.New()
    local self = setmetatable({}, manager)

    self.data = {"Hello"}

    return self
end

function manager:ReadData(arg1)
    print(arg1)
end

return manager