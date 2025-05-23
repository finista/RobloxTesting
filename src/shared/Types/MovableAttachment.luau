export type LoadedRegion = {
    basePart: BasePart,
    config: Folder,
    regionPart: BasePart,
    enabled: BoolValue
}

export type AttachmentImpl = {
    __index: AttachmentImpl,
    New: () -> (Attachment),
    LoadRegion: (self: Attachment, object: BasePart) -> (),
    UnloadRegion: (self: Attachment, object: BasePart) -> (),
    Render: (self: Attachment) -> (),
    Unload: (self: Attachment) -> (),
    Update: (self: Attachment) -> (),
}

export type Attachment = typeof(setmetatable({} :: {
    loadedRegions: {[BasePart]: LoadedRegion},
    currentRegion: LoadedRegion?,
    lastCFrame: CFrame?,
    lastRefresh: number,
    addedConnection: RBXScriptConnection?,
    removedConnection: RBXScriptConnection?,
    updateConnection: RBXScriptConnection?
}, {} :: AttachmentImpl))

return {}