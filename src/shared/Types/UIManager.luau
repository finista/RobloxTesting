export type ManagerImpl = {
	__index: ManagerImpl;
	New: (UI: ScreenGui) -> Manager;
	LoadButtons: (self: Manager) -> ();
    Initialize: (self: Manager) -> ();
    LoadPageComponents: (self: Manager) -> ();
    RunWithDB: (self: Manager, func: (...any) -> (...any), ...any) -> ();
    ToggleMenu: (self: Manager, state: boolean) -> ();
    OpenPage: (self: Manager, name: string?) -> ();
    TransitionPage: (self: Manager, page: Frame, state: boolean) -> ();
}

export type Manager = typeof(setmetatable({} :: {
	UI: ScreenGui;
	menuFrame: Frame;
    menuToggle: ImageButton;
    pages: Folder;
    transitionFrame: Frame;
    pageComponents: {[string]: PageComponent};
    currentPage: string?;
	menuOpen: boolean;
    db: boolean;
}, {} :: ManagerImpl))

export type PageComponentImpl = {
    __index: PageComponentImpl;
    New: (page: Frame, manager: Manager) -> (PageComponent);
    TransitionOut: ((self: PageComponent) -> ())?;
    TransitionIn: ((self: PageComponent) -> ())?;
    OnClose: ((self: PageComponent) -> ())?;
    OnOpen: ((self: PageComponent) -> ())?;
    [string]: any;
}

export type PageComponent = typeof(setmetatable({} :: {
    page: Frame;
    manager: Manager;
    [string]: any;
}, {} :: PageComponentImpl))

return {}