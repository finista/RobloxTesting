export type LoadingManagerImpl = {
    __index: LoadingManagerImpl,
    New: () -> LoadingManager,
    ReadData: (self: LoadingManager, arg1: string) -> ()
}

export type LoadingManager = typeof(setmetatable({} :: {
    data: {string}
}, {} :: LoadingManagerImpl))

return {}