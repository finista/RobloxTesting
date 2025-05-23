export type Point = {
    part: BasePart,
    attachment: Attachment,
}

export type RunConfig = {
    actor: BasePart,
    looped: boolean?,
    startNode: number?,
    speed: number?,
    positionResponsiveness: number?,
    orientationResponsiveness: number?,
}

export type PathMoveImpl = {
    __index: PathMoveImpl,
    New: () -> PathMove,
    LoadPathFrom: (self: PathMove, container: Instance) -> (),
    ClearPath: (self: PathMove) -> (),
    Run: (self: PathMove, config: RunConfig) -> (),
    Stop: (self: PathMove) -> (),
    SetSpeed: (self: PathMove, speed: number) -> (),
    Update: (self: PathMove) -> (),
}

export type PathMove = typeof(setmetatable({} :: {
    path: {[number]: Point},
    actor: BasePart?,
    currentNode: number,
    running: boolean,
    looped: boolean,
    alignOrientation: AlignOrientation?,
    alignPosition: AlignPosition?,
    updateConnection: RBXScriptConnection?
}, {} :: PathMoveImpl))

return {}