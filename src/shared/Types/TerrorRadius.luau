export type RadiusLayer = {
    distance: number,
    sound: Sound
}

export type Config = {
    layers: {RadiusLayer},
    chase: Sound,
    anchor: BasePart?
}

export type TerrorRadiusImpl = {
    __index: TerrorRadiusImpl,
    New: (config: Config) -> (TerrorRadius),
    Update: (self: TerrorRadius) -> (),
    SetAnchor: (self: TerrorRadius, anchor: BasePart) -> (),
    SwitchRadius: (self: TerrorRadius, radius: RadiusLayer?) -> ()
}

export type TerrorRadius = typeof(setmetatable({} :: {
    layers: {RadiusLayer},
    chasePlaying: boolean,
    currentLayer: RadiusLayer?,
    anchor: BasePart?,
    radiusSwitchTask: thread?
}, {} :: TerrorRadiusImpl))

return {}