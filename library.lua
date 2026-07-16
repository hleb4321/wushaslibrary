-- wusha's lib

local plrs = game:GetService("Players")
local runs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local cg = game:GetService("CoreGui")

local lp = plrs.LocalPlayer

local lib = {
    colors = {
        window = Color3.fromRGB(18, 18, 22),
        header = Color3.fromRGB(22, 22, 27),
        tabs = Color3.fromRGB(15, 15, 19),
        surface = Color3.fromRGB(24, 24, 30),
        surfacehover = Color3.fromRGB(29, 29, 36),
        control = Color3.fromRGB(19, 19, 24),
        controlhover = Color3.fromRGB(25, 25, 31),
        border = Color3.fromRGB(43, 42, 51),
        bordersoft = Color3.fromRGB(34, 34, 41),
        text = Color3.fromRGB(232, 231, 238),
        muted = Color3.fromRGB(137, 135, 151),
        dim = Color3.fromRGB(91, 90, 103),
        accent = Color3.fromRGB(124, 77, 255),
        accent2 = Color3.fromRGB(186, 148, 255),
        red = Color3.fromRGB(196, 61, 74),
        green = Color3.fromRGB(92, 208, 148),
    },
    fonts = {
        {name = "gotham", regular = Enum.Font.Gotham, medium = Enum.Font.GothamMedium, bold = Enum.Font.GothamBold, mono = Enum.Font.RobotoMono},
        {name = "source sans", regular = Enum.Font.SourceSans, medium = Enum.Font.SourceSansSemibold, bold = Enum.Font.SourceSansBold, mono = Enum.Font.RobotoMono},
        {name = "jura", regular = Enum.Font.Jura, medium = Enum.Font.Jura, bold = Enum.Font.Jura, mono = Enum.Font.Jura},
        {name = "nunito", regular = Enum.Font.Nunito, medium = Enum.Font.Nunito, bold = Enum.Font.Nunito, mono = Enum.Font.Nunito},
        {name = "ubuntu", regular = Enum.Font.Ubuntu, medium = Enum.Font.Ubuntu, bold = Enum.Font.Ubuntu, mono = Enum.Font.Ubuntu},
        {name = "roboto", regular = Enum.Font.Roboto, medium = Enum.Font.Roboto, bold = Enum.Font.Roboto, mono = Enum.Font.RobotoMono},
        {name = "michroma", regular = Enum.Font.Michroma, medium = Enum.Font.Michroma, bold = Enum.Font.Michroma, mono = Enum.Font.Michroma},
    },
    accents = {
        {name = "violet", base = Color3.fromRGB(124, 77, 255), light = Color3.fromRGB(186, 148, 255)},
        {name = "ice", base = Color3.fromRGB(64, 145, 255), light = Color3.fromRGB(139, 205, 255)},
        {name = "rose", base = Color3.fromRGB(225, 73, 137), light = Color3.fromRGB(255, 151, 196)},
        {name = "mint", base = Color3.fromRGB(55, 194, 145), light = Color3.fromRGB(137, 242, 203)},
    },
    fontid = 1,
    accentid = 1,
    grads = {},
    conns = {},
    sliders = {},
    statusqueue = {},
    notifications = {},
    notifserial = 0,
    notifside = "right",
    unloaded = false,
    unloading = false,
    booting = true,
    binding = false,
    sliderdrag = nil,
    gui = nil,
    main = nil,
    scale = nil,
    notifholder = nil,
    notifsound = nil,
}
lib.__index = lib

local fasttw = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local normaltw = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tween(obj: Instance, info: TweenInfo, props: {[string]: any})
    local anim = ts:Create(obj, info, props)
    anim:Play()
    return anim
end

local function addCorner(parent: Instance, rad: number): UICorner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, rad)
    corner.Parent = parent
    return corner
end

local function addStroke(parent: Instance, col: Color3?, thick: number?): UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = col or lib.colors.border
    stroke.Thickness = thick or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function trackConn(conn: RBXScriptConnection): RBXScriptConnection
    table.insert(lib.conns, conn)
    return conn
end

trackConn(uis.InputChanged:Connect(function(input)
    if lib.sliderdrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        lib.sliderdrag.move(input.Position.X)
    end
end))

trackConn(uis.InputEnded:Connect(function(input)
    if lib.sliderdrag and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local done = lib.sliderdrag.done
        lib.sliderdrag = nil
        done()
    end
end))

local function addAccentGradient(parent: Instance, rot: number?): UIGradient
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, lib.colors.accent),
        ColorSequenceKeypoint.new(0.5, lib.colors.accent2),
        ColorSequenceKeypoint.new(1, lib.colors.accent),
    })
    grad.Rotation = rot or 0
    grad.Parent = parent
    table.insert(lib.grads, grad)
    return grad
end

local function createLabel(
    parent: Instance,
    text: string,
    size: UDim2,
    pos: UDim2,
    font: Enum.Font,
    txtsz: number,
    col: Color3,
    align: Enum.TextXAlignment?
): TextLabel
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = pos
    label.Text = text
    label.TextColor3 = col
    label.Font = font
    label.TextSize = txtsz
    label.TextXAlignment = align or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = parent
    return label
end

local function colorClose(first: Color3, second: Color3): boolean
    return math.abs(first.R - second.R) < 0.02
        and math.abs(first.G - second.G) < 0.02
        and math.abs(first.B - second.B) < 0.02
end

function lib:applyfont()
    local preset = self.fonts[self.fontid]
    if not self.gui then return end
    for _, obj in ipairs(self.gui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local role = obj:GetAttribute("fontRole")
            if not role then
                local name = string.lower(obj.Font.Name)
                if string.find(name, "bold") then
                    role = "bold"
                elseif string.find(name, "medium") or string.find(name, "semibold") then
                    role = "medium"
                elseif obj.Font == Enum.Font.Code then
                    role = "mono"
                else
                    role = "regular"
                end
                obj:SetAttribute("fontRole", role)
            end
            if role == "bold" then
                obj.Font = preset.bold
            elseif role == "medium" then
                obj.Font = preset.medium
            elseif role == "mono" then
                obj.Font = preset.mono
            else
                obj.Font = preset.regular
            end
        end
    end
end

function lib:applyaccent()
    local preset = self.accents[self.accentid]
    local oldbase = self.colors.accent
    local oldlight = self.colors.accent2
    if not self.gui then return end

    for _, obj in ipairs(self.gui:GetDescendants()) do
        if obj:IsA("GuiObject") then
            if colorClose(obj.BackgroundColor3, oldbase) then
                obj.BackgroundColor3 = preset.base
            elseif colorClose(obj.BackgroundColor3, oldlight) then
                obj.BackgroundColor3 = preset.light
            end
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if colorClose(obj.TextColor3, oldbase) then
                obj.TextColor3 = preset.base
            elseif colorClose(obj.TextColor3, oldlight) then
                obj.TextColor3 = preset.light
            end
        end
        if obj:IsA("UIStroke") then
            if colorClose(obj.Color, oldbase) then
                obj.Color = preset.base
            elseif colorClose(obj.Color, oldlight) then
                obj.Color = preset.light
            end
        end
        if obj:IsA("ScrollingFrame") then
            if colorClose(obj.ScrollBarImageColor3, oldbase) then
                obj.ScrollBarImageColor3 = preset.base
            elseif colorClose(obj.ScrollBarImageColor3, oldlight) then
                obj.ScrollBarImageColor3 = preset.light
            end
        end
    end

    self.colors.accent = preset.base
    self.colors.accent2 = preset.light
    local seq = ColorSequence.new({
        ColorSequenceKeypoint.new(0, preset.base),
        ColorSequenceKeypoint.new(0.5, preset.light),
        ColorSequenceKeypoint.new(1, preset.base),
    })
    for _, grad in ipairs(self.grads) do
        if grad.Parent then
            grad.Color = seq
        end
    end
end

function lib:cyclefont(dir: number): string
    self.fontid = ((self.fontid - 1 + dir) % #self.fonts) + 1
    self:applyfont()
    return self.fonts[self.fontid].name
end

function lib:cycleaccent(dir: number): string
    self.accentid = ((self.accentid - 1 + dir) % #self.accents) + 1
    self:applyaccent()
    return self.accents[self.accentid].name
end

local function notifpositions(card: GuiObject)
    if lib.notifside == "left" then
        card.AnchorPoint = Vector2.new(0, 0)
        return UDim2.new(0, 0, 0, 2), UDim2.new(0, -300, 0, 2)
    end
    card.AnchorPoint = Vector2.new(1, 0)
    return UDim2.new(1, 0, 0, 2), UDim2.new(1, 300, 0, 2)
end

function lib:setnotifside(side: string)
    self.notifside = side
    if not self.notifholder then return end
    pcall(function()
        if side == "left" then
            self.notifholder.AnchorPoint = Vector2.new(0, 0.5)
            self.notifholder.Position = UDim2.new(0, 20, 0.5, 0)
        else
            self.notifholder.AnchorPoint = Vector2.new(1, 0.5)
            self.notifholder.Position = UDim2.new(1, -20, 0.5, 0)
        end
        for _, entry in ipairs(self.notifications) do
            if not entry.removing and entry.card and entry.card.Parent then
                local target = notifpositions(entry.card)
                tween(entry.card, normaltw, {Position = target})
            end
        end
    end)
end

local function removenotif(entry)
    if entry.removing then return end
    entry.removing = true
    local _, outside = notifpositions(entry.card)
    local slide = tween(entry.card, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = outside,
        BackgroundTransparency = 0.2,
    })
    slide.Completed:Once(function()
        if not entry.slot or not entry.slot.Parent then return end
        local collapse = tween(entry.slot, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0),
        })
        collapse.Completed:Once(function()
            if entry.slot then
                entry.slot:Destroy()
            end
        end)
    end)
end

local function shownotif(data)
    while #lib.notifications >= 6 do
        local old = table.remove(lib.notifications, 1)
        removenotif(old)
    end
    lib.notifserial += 1
    local dur = data.duration and data.duration > 0 and data.duration or 3
    local slot = Instance.new("Frame")
    slot.Size = UDim2.new(1, 0, 0, 0)
    slot.BackgroundTransparency = 1
    slot.BorderSizePixel = 0
    slot.LayoutOrder = lib.notifserial
    slot.ZIndex = 60
    slot.Parent = lib.notifholder

    local card = Instance.new("Frame")
    card.Size = UDim2.fromOffset(260, 42)
    card.BackgroundColor3 = Color3.fromRGB(25, 24, 31)
    card.BackgroundTransparency = 0.04
    card.BorderSizePixel = 0
    card.ZIndex = 61
    card.Parent = slot
    addCorner(card, 7)
    addStroke(card, lib.colors.border, 1)

    local target, outside = notifpositions(card)
    card.Position = outside

    local mark = Instance.new("Frame")
    mark.Size = UDim2.fromOffset(3, 20)
    mark.Position = UDim2.fromOffset(9, 9)
    mark.BackgroundColor3 = data.color
    mark.BorderSizePixel = 0
    mark.ZIndex = 62
    mark.Parent = card
    addCorner(mark, 2)

    local text = createLabel(
        card,
        data.message,
        UDim2.new(1, -34, 0, 34),
        UDim2.fromOffset(21, 2),
        Enum.Font.GothamMedium,
        9,
        lib.colors.text
    )
    text.ZIndex = 62

    local progressbg = Instance.new("Frame")
    progressbg.Size = UDim2.new(1, -14, 0, 2)
    progressbg.Position = UDim2.new(0, 7, 1, -5)
    progressbg.BackgroundColor3 = Color3.fromRGB(43, 42, 51)
    progressbg.BorderSizePixel = 0
    progressbg.ZIndex = 62
    progressbg.Parent = card
    addCorner(progressbg, 2)

    local progress = Instance.new("Frame")
    progress.Size = UDim2.fromScale(1, 1)
    progress.BackgroundColor3 = data.color
    progress.BorderSizePixel = 0
    progress.ZIndex = 63
    progress.Parent = progressbg
    addCorner(progress, 2)

    local entry = {
        slot = slot,
        card = card,
        progress = progress,
        expire = os.clock() + dur,
        removing = false,
    }
    table.insert(lib.notifications, entry)

    tween(slot, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 46),
    })
    tween(card, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = target,
    })
    tween(progress, TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 1, 0),
    })

    if lib.notifsound then
        pcall(function()
            lib.notifsound.TimePosition = 0
            lib.notifsound:Play()
        end)
    end
end

function lib:notify(message: string, col: Color3?, duration: number?)
    if self.unloaded then return end
    table.insert(self.statusqueue, {
        message = string.lower(message),
        color = col or self.colors.green,
        duration = duration,
    })
end

local function updatestatus()
    if lib.unloaded then return end
    while #lib.statusqueue > 0 do
        shownotif(table.remove(lib.statusqueue, 1))
    end
    local now = os.clock()
    for i = #lib.notifications, 1, -1 do
        local entry = lib.notifications[i]
        if not entry.slot or not entry.slot.Parent then
            table.remove(lib.notifications, i)
        elseif not entry.removing and now >= entry.expire then
            table.remove(lib.notifications, i)
            removenotif(entry)
        end
    end
end

local function createControlSurface(parent: Instance, height: number, order: number): Frame
    local surface = Instance.new("Frame")
    surface.Size = UDim2.new(1, 0, 0, height)
    surface.BackgroundColor3 = lib.colors.control
    surface.BorderSizePixel = 0
    surface.LayoutOrder = order
    surface.Parent = parent
    addCorner(surface, 6)
    addStroke(surface, lib.colors.bordersoft, 1)
    return surface
end

local function bindSurfaceHover(surface: Frame)
    surface.MouseEnter:Connect(function()
        tween(surface, fasttw, {BackgroundColor3 = lib.colors.controlhover})
    end)
    surface.MouseLeave:Connect(function()
        tween(surface, fasttw, {BackgroundColor3 = lib.colors.control})
    end)
end

function lib:window(cfg: {[string]: any})
    cfg = cfg or {}
    local titletext = cfg.title or "wusha's lib"
    local authortext = cfg.author or "clean ui library"
    local defw = cfg.width or 590
    local defh = cfg.height or 440
    local minw = cfg.minw or 470
    local minh = cfg.minh or 330
    local togglekey = cfg.togglekey or Enum.KeyCode.RightShift

    local gui = Instance.new("ScreenGui")
    gui.Name = "WushaLibGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 1000
    gui.IgnoreGuiInset = true

    pcall(function()
        local old = cg:FindFirstChild(gui.Name)
        if old then old:Destroy() end
    end)
    local pg = lp:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild(gui.Name)
    if old then old:Destroy() end
    gui.Parent = pg
    self.gui = gui

    self.notifholder = Instance.new("Frame")
    self.notifholder.Name = "Notifications"
    self.notifholder.AnchorPoint = Vector2.new(1, 0.5)
    self.notifholder.Size = UDim2.fromOffset(280, 420)
    self.notifholder.Position = UDim2.new(1, -20, 0.5, 0)
    self.notifholder.BackgroundTransparency = 1
    self.notifholder.BorderSizePixel = 0
    self.notifholder.ClipsDescendants = false
    self.notifholder.ZIndex = 60
    self.notifholder.Parent = gui

    local notiflayout = Instance.new("UIListLayout")
    notiflayout.Padding = UDim.new(0, 6)
    notiflayout.SortOrder = Enum.SortOrder.LayoutOrder
    notiflayout.VerticalAlignment = Enum.VerticalAlignment.Center
    notiflayout.Parent = self.notifholder

    self.notifsound = Instance.new("Sound")
    self.notifsound.Name = "NotificationSound"
    self.notifsound.SoundId = "rbxassetid://18595195017"
    self.notifsound.Volume = 0.45
    self.notifsound.Parent = gui

    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.fromOffset(defw, 0)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.BackgroundColor3 = self.colors.window
    main.BackgroundTransparency = 0.08
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    addCorner(main, 9)
    addStroke(main, self.colors.border, 1)
    self.main = main

    local scale = Instance.new("UIScale")
    scale.Scale = 0.96
    scale.Parent = main
    self.scale = scale

    local topbar = Instance.new("Frame")
    topbar.Name = "TitleBar"
    topbar.Size = UDim2.new(1, 0, 0, 44)
    topbar.BackgroundColor3 = self.colors.header
    topbar.BorderSizePixel = 0
    topbar.Active = true
    topbar.ZIndex = 2
    topbar.Parent = main
    addCorner(topbar, 9)

    local topbarfill = Instance.new("Frame")
    topbarfill.Size = UDim2.new(1, 0, 0, 10)
    topbarfill.Position = UDim2.new(0, 0, 1, -10)
    topbarfill.BackgroundColor3 = self.colors.header
    topbarfill.BorderSizePixel = 0
    topbarfill.ZIndex = 2
    topbarfill.Parent = topbar

    local brandMark = Instance.new("Frame")
    brandMark.Name = "BrandMark"
    brandMark.Size = UDim2.fromOffset(4, 22)
    brandMark.Position = UDim2.fromOffset(13, 11)
    brandMark.BackgroundColor3 = self.colors.accent
    brandMark.BorderSizePixel = 0
    brandMark.ZIndex = 3
    brandMark.Parent = topbar
    addCorner(brandMark, 2)
    addAccentGradient(brandMark, 90)

    local title = createLabel(topbar, titletext, UDim2.new(1, -150, 0, 18), UDim2.fromOffset(27, 7), Enum.Font.GothamBold, 12, self.colors.text)
    title.ZIndex = 3
    local author = createLabel(topbar, authortext, UDim2.new(1, -150, 0, 14), UDim2.fromOffset(27, 23), Enum.Font.GothamMedium, 9, self.colors.dim)
    author.ZIndex = 3

    local close = Instance.new("TextButton")
    close.Name = "CloseButton"
    close.Size = UDim2.fromOffset(26, 26)
    close.Position = UDim2.new(1, -35, 0.5, -13)
    close.BackgroundColor3 = Color3.fromRGB(42, 27, 33)
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(211, 112, 123)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.BorderSizePixel = 0
    close.AutoButtonColor = false
    close.ZIndex = 4
    close.Parent = topbar
    addCorner(close, 6)
    local closestroke = addStroke(close, Color3.fromRGB(76, 41, 49), 1)

    close.MouseEnter:Connect(function()
        tween(close, fasttw, {BackgroundColor3 = self.colors.red, TextColor3 = Color3.new(1, 1, 1)})
        tween(closestroke, fasttw, {Color = self.colors.red})
    end)
    close.MouseLeave:Connect(function()
        tween(close, fasttw, {BackgroundColor3 = Color3.fromRGB(42, 27, 33), TextColor3 = Color3.fromRGB(211, 112, 123)})
        tween(closestroke, fasttw, {Color = Color3.fromRGB(76, 41, 49)})
    end)

    local topline = Instance.new("Frame")
    topline.Size = UDim2.new(1, 0, 0, 1)
    topline.Position = UDim2.new(0, 0, 1, -1)
    topline.BackgroundColor3 = self.colors.bordersoft
    topline.BorderSizePixel = 0
    topline.ZIndex = 3
    topline.Parent = topbar

    local tabsbar = Instance.new("Frame")
    tabsbar.Name = "TabBar"
    tabsbar.Size = UDim2.new(1, 0, 0, 38)
    tabsbar.Position = UDim2.fromOffset(0, 44)
    tabsbar.BackgroundColor3 = self.colors.tabs
    tabsbar.BorderSizePixel = 0
    tabsbar.ZIndex = 2
    tabsbar.Parent = main

    local tabsline = Instance.new("Frame")
    tabsline.Size = UDim2.new(1, 0, 0, 1)
    tabsline.Position = UDim2.new(0, 0, 1, -1)
    tabsline.BackgroundColor3 = self.colors.bordersoft
    tabsline.BorderSizePixel = 0
    tabsline.Parent = tabsbar

    local tabline = Instance.new("Frame")
    tabline.Name = "Indicator"
    tabline.Size = UDim2.fromOffset(62, 2)
    tabline.Position = UDim2.fromOffset(14, 36)
    tabline.BackgroundColor3 = self.colors.accent
    tabline.BorderSizePixel = 0
    tabline.ZIndex = 4
    tabline.Parent = tabsbar
    addCorner(tabline, 2)
    addAccentGradient(tabline)

    local content = Instance.new("Frame")
    content.Name = "ContentArea"
    content.Size = UDim2.new(1, -24, 1, -100)
    content.Position = UDim2.fromOffset(12, 91)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = main

    local resize = Instance.new("TextButton")
    resize.Name = "ResizeHandle"
    resize.Size = UDim2.fromOffset(22, 22)
    resize.Position = UDim2.new(1, -22, 1, -22)
    resize.BackgroundTransparency = 1
    resize.Text = ""
    resize.ZIndex = 20
    resize.Parent = main

    local resizex = createLabel(resize, "↘", UDim2.fromScale(1, 1), UDim2.new(), Enum.Font.GothamBold, 11, self.colors.dim, Enum.TextXAlignment.Center)
    resizex.TextYAlignment = Enum.TextYAlignment.Center

    local dragging, resizing = false, false
    local dragstart = Vector2.zero
    local startpos = UDim2.new()
    local dragpos = main.Position
    local resizestart = Vector2.zero
    local startsz = Vector2.zero
    local savedsz = Vector2.new(defw, defh)

    local function inputpos(input: InputObject): Vector2
        return Vector2.new(input.Position.X, input.Position.Y)
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragstart = inputpos(input)
            startpos = main.Position
        end
    end)

    resize.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizestart = inputpos(input)
            startsz = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
            tween(resizex, fasttw, {TextColor3 = self.colors.accent2})
        end
    end)

    trackConn(uis.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local mousepos = inputpos(input)
        if dragging then
            local delta = mousepos - dragstart
            dragpos = UDim2.new(startpos.X.Scale, startpos.X.Offset + delta.X, startpos.Y.Scale, startpos.Y.Offset + delta.Y)
        elseif resizing then
            local delta = mousepos - resizestart
            local width = math.max(minw, startsz.X + delta.X)
            local height = math.max(minh, startsz.Y + delta.Y)
            main.Size = UDim2.fromOffset(width, height)
            savedsz = Vector2.new(width, height)
        end
    end))

    trackConn(uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            resizing = false
            tween(resizex, fasttw, {TextColor3 = self.colors.dim})
        end
    end))

    local movingui = false
    local function openWindow()
        if self.booting or self.unloading or movingui or main.Visible then return end
        movingui = true
        main.Visible = true
        main.Size = UDim2.fromOffset(savedsz.X, 0)
        main.BackgroundTransparency = 0.08
        local anim = tween(main, normaltw, {Size = UDim2.fromOffset(savedsz.X, savedsz.Y), BackgroundTransparency = 0})
        anim.Completed:Once(function() movingui = false end)
    end

    local function closeWindow()
        if self.booting or self.unloading or movingui or not main.Visible then return end
        movingui = true
        savedsz = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
        local anim = tween(main, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromOffset(savedsz.X, 0), BackgroundTransparency = 0.08})
        anim.Completed:Once(function()
            main.Visible = false
            main.Size = UDim2.fromOffset(savedsz.X, savedsz.Y)
            main.BackgroundTransparency = 0
            movingui = false
        end)
    end

    close.MouseButton1Click:Connect(closeWindow)

    trackConn(uis.InputBegan:Connect(function(input, gpe)
        if gpe or self.binding or self.booting or self.unloading then return end
        if input.KeyCode == togglekey then
            if main.Visible then closeWindow() else openWindow() end
        end
    end))

    local warnbg = Instance.new("Frame")
    warnbg.Name = "UnloadModal"
    warnbg.Size = UDim2.fromScale(1, 1)
    warnbg.BackgroundColor3 = Color3.new(0, 0, 0)
    warnbg.BackgroundTransparency = 1
    warnbg.BorderSizePixel = 0
    warnbg.Active = true
    warnbg.Visible = false
    warnbg.ZIndex = 100
    warnbg.Parent = main

    local warnbox = Instance.new("Frame")
    warnbox.AnchorPoint = Vector2.new(0.5, 0.5)
    warnbox.Size = UDim2.fromOffset(330, 146)
    warnbox.Position = UDim2.fromScale(0.5, 0.5)
    warnbox.BackgroundColor3 = self.colors.surface
    warnbox.BackgroundTransparency = 1
    warnbox.BorderSizePixel = 0
    warnbox.ZIndex = 101
    warnbox.Parent = warnbg
    addCorner(warnbox, 9)
    local warnstroke = addStroke(warnbox, self.colors.border, 1)
    warnstroke.Transparency = 1

    local warntitle = createLabel(warnbox, "unload?", UDim2.new(1, -28, 0, 22), UDim2.fromOffset(14, 15), Enum.Font.GothamBold, 12, self.colors.text)
    warntitle.TextTransparency = 1
    warntitle.ZIndex = 102

    local warntext = createLabel(warnbox, "are u sure that u want unload?", UDim2.new(1, -28, 0, 20), UDim2.fromOffset(14, 42), Enum.Font.GothamMedium, 9, self.colors.muted)
    warntext.TextTransparency = 1
    warntext.ZIndex = 102

    local cancel = Instance.new("TextButton")
    cancel.Size = UDim2.new(0.5, -21, 0, 31)
    cancel.Position = UDim2.new(0, 14, 1, -45)
    cancel.BackgroundColor3 = self.colors.control
    cancel.BackgroundTransparency = 1
    cancel.Text = "cancel"
    cancel.TextColor3 = self.colors.muted
    cancel.TextTransparency = 1
    cancel.Font = Enum.Font.GothamBold
    cancel.TextSize = 9
    cancel.BorderSizePixel = 0
    cancel.ZIndex = 102
    cancel.Parent = warnbox
    addCorner(cancel, 6)
    local cancelstroke = addStroke(cancel, self.colors.border, 1)
    cancelstroke.Transparency = 1

    local confirm = Instance.new("TextButton")
    confirm.Size = UDim2.new(0.5, -21, 0, 31)
    confirm.Position = UDim2.new(0.5, 7, 1, -45)
    confirm.BackgroundColor3 = self.colors.red
    confirm.BackgroundTransparency = 1
    confirm.Text = "unload"
    confirm.TextColor3 = Color3.new(1, 1, 1)
    confirm.TextTransparency = 1
    confirm.Font = Enum.Font.GothamBold
    confirm.TextSize = 9
    confirm.BorderSizePixel = 0
    confirm.ZIndex = 102
    confirm.Parent = warnbox
    addCorner(confirm, 6)

    local warning = false
    function self:hidemodal()
        if not warning then return end
        warning = false
        tween(warnbg, fasttw, {BackgroundTransparency = 1})
        tween(warnbox, fasttw, {BackgroundTransparency = 1, Size = UDim2.fromOffset(310, 132)})
        tween(warnstroke, fasttw, {Transparency = 1})
        tween(warntitle, fasttw, {TextTransparency = 1})
        tween(warntext, fasttw, {TextTransparency = 1})
        tween(cancel, fasttw, {BackgroundTransparency = 1, TextTransparency = 1})
        tween(cancelstroke, fasttw, {Transparency = 1})
        local anim = tween(confirm, fasttw, {BackgroundTransparency = 1, TextTransparency = 1})
        anim.Completed:Once(function() if not warning then warnbg.Visible = false end end)
    end

    function self:showmodal()
        if warning then return end
        warning = true
        warnbg.Visible = true
        warnbox.Size = UDim2.fromOffset(310, 132)
        tween(warnbg, normaltw, {BackgroundTransparency = 0.26})
        tween(warnbox, normaltw, {BackgroundTransparency = 0, Size = UDim2.fromOffset(330, 146)})
        tween(warnstroke, normaltw, {Transparency = 0})
        tween(warntitle, normaltw, {TextTransparency = 0})
        tween(warntext, normaltw, {TextTransparency = 0})
        tween(cancel, normaltw, {BackgroundTransparency = 0, TextTransparency = 0})
        tween(cancelstroke, normaltw, {Transparency = 0})
        tween(confirm, normaltw, {BackgroundTransparency = 0, TextTransparency = 0})
    end

    cancel.MouseButton1Click:Connect(function() self:hidemodal() end)
    confirm.MouseButton1Click:Connect(function() self:unload() end)

    local gradtime = 0
    local gradtick = 0
    trackConn(runs.RenderStepped:Connect(function(dt)
        updatestatus()
        if self.unloaded then return end

        local alpha = 1 - math.exp(-28 * dt)
        for i = #self.sliders, 1, -1 do
            local state = self.sliders[i]
            if not state.fill or not state.fill.Parent then
                table.remove(self.sliders, i)
            else
                state.shown += (state.target - state.shown) * alpha
                if math.abs(state.target - state.shown) < 0.0005 then
                    state.shown = state.target
                end
                state.fill.Size = UDim2.new(state.shown, 0, 1, 0)
            end
        end

        if not main.Visible then return end
        local dx = math.abs(main.Position.X.Offset - dragpos.X.Offset)
        local dy = math.abs(main.Position.Y.Offset - dragpos.Y.Offset)
        if dragging or dx + dy > 0.15 then
            local palpha = 1 - math.exp(-32 * dt)
            main.Position = main.Position:Lerp(dragpos, palpha)
        end

        gradtick += dt
        if gradtick < 1 / 30 then return end
        gradtime += gradtick
        gradtick = 0
        local offset = math.sin(gradtime * 0.65) * 0.45
        for i = #self.grads, 1, -1 do
            local grad = self.grads[i]
            if grad.Parent then
                grad.Offset = Vector2.new(offset, 0)
            else
                table.remove(self.grads, i)
            end
        end
    end))

    task.defer(function()
        tween(scale, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1})
        local anim = tween(main, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(defw, defh), BackgroundTransparency = 0})
        anim.Completed:Once(function() self.booting = false end)
    end)

    local tabs = {}
    local pages = {}
    local activetab = nil
    local tabcount = 0
    local win = {}

    function win:tab(id: string, text: string)
        local x = tabcount * 90
        tabcount += 1

        local btn = Instance.new("TextButton")
        btn.Name = id .. "Tab"
        btn.Size = UDim2.fromOffset(90, 37)
        btn.Position = UDim2.fromOffset(x, 0)
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.TextColor3 = lib.colors.dim
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = tabsbar

        local page = Instance.new("ScrollingFrame")
        page.Name = id .. "Page"
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = lib.colors.accent
        page.ScrollBarImageTransparency = 0.15
        page.CanvasSize = UDim2.new()
        page.AutomaticCanvasSize = Enum.AutomaticSize.None
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.Visible = false
        page.Parent = content

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 2)
        padding.PaddingBottom = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 5)
        padding.Parent = page

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = page

        local function updateCanvas()
            page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.defer(updateCanvas)

        tabs[btn] = {id = id, page = page, x = x}
        pages[id] = page

        local function switch()
            if activetab == btn then return end
            if activetab then
                tween(activetab, normaltw, {TextColor3 = lib.colors.dim})
                local prev = tabs[activetab]
                if prev and prev.page then prev.page.Visible = false end
            end
            tween(btn, normaltw, {TextColor3 = lib.colors.accent2})
            tween(tabline, normaltw, {Position = UDim2.fromOffset(x + 14, 36)})
            page.Position = UDim2.fromOffset(8, 0)
            page.Visible = true
            tween(page, normaltw, {Position = UDim2.fromOffset(0, 0)})
            activetab = btn
        end

        btn.MouseButton1Click:Connect(switch)
        if tabcount == 1 then switch() end

        local tabobj = {}
        local secorder = 0

        function tabobj:section(title: string, desc: string?)
            secorder += 1
            desc = desc or ""
            local hasdesc = desc ~= ""
            local dividery = hasdesc and 48 or 40
            local bodyy = dividery + 11

            local card = Instance.new("Frame")
            card.Name = title:gsub("%s+", "") .. "Section"
            card.Size = UDim2.new(1, -2, 0, 80)
            card.BackgroundColor3 = lib.colors.surface
            card.BorderSizePixel = 0
            card.LayoutOrder = secorder
            card.ClipsDescendants = true
            card.Parent = page
            addCorner(card, 8)
            addStroke(card, lib.colors.border, 1)

            local accent = Instance.new("Frame")
            accent.Size = UDim2.fromOffset(3, hasdesc and 24 or 18)
            accent.Position = UDim2.fromOffset(12, hasdesc and 14 or 11)
            accent.BackgroundColor3 = lib.colors.accent
            accent.BorderSizePixel = 0
            accent.Parent = card
            addCorner(accent, 2)
            addAccentGradient(accent, 90)

            createLabel(card, title, UDim2.new(1, -42, 0, 16), UDim2.fromOffset(24, hasdesc and 10 or 12), Enum.Font.GothamBold, 10, lib.colors.text)
            if hasdesc then
                createLabel(card, desc, UDim2.new(1, -42, 0, 14), UDim2.fromOffset(24, 27), Enum.Font.GothamMedium, 8, lib.colors.dim)
            end

            local divider = Instance.new("Frame")
            divider.Size = UDim2.new(1, -24, 0, 1)
            divider.Position = UDim2.fromOffset(12, dividery)
            divider.BackgroundColor3 = lib.colors.bordersoft
            divider.BorderSizePixel = 0
            divider.Parent = card

            local body = Instance.new("Frame")
            body.Name = "Body"
            body.Size = UDim2.new(1, -24, 0, 0)
            body.Position = UDim2.fromOffset(12, bodyy)
            body.BackgroundTransparency = 1
            body.Parent = card

            local bodylayout = Instance.new("UIListLayout")
            bodylayout.Padding = UDim.new(0, 7)
            bodylayout.SortOrder = Enum.SortOrder.LayoutOrder
            bodylayout.Parent = body

            local function updatesec()
                local h = bodylayout.AbsoluteContentSize.Y
                body.Size = UDim2.new(1, -24, 0, h)
                card.Size = UDim2.new(1, -2, 0, bodyy + h + 13)
            end
            bodylayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatesec)
            task.defer(updatesec)

            local elemorder = 0
            local sec = {}

            function sec:button(text: string, subtitle: string, cb: () -> ())
                elemorder += 1
                subtitle = subtitle or ""
                local surface = createControlSurface(body, 42, elemorder)
                bindSurfaceHover(surface)
                createLabel(surface, text, UDim2.new(1, -130, subtitle == "" and 1 or 0, subtitle == "" and 0 or 17), subtitle == "" and UDim2.fromOffset(12, 0) or UDim2.fromOffset(12, 6), Enum.Font.GothamBold, 10, lib.colors.text)
                if subtitle ~= "" then
                    createLabel(surface, subtitle, UDim2.new(1, -130, 0, 13), UDim2.fromOffset(12, 23), Enum.Font.GothamMedium, 8, lib.colors.dim)
                end

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.fromOffset(96, 26)
                btn.Position = UDim2.new(1, -106, 0.5, -13)
                btn.BackgroundColor3 = lib.colors.accent
                btn.Text = "›"
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 18
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.Parent = surface
                addCorner(btn, 5)
                addAccentGradient(btn)

                btn.MouseEnter:Connect(function() tween(btn, fasttw, {BackgroundColor3 = lib.colors.accent2}) end)
                btn.MouseLeave:Connect(function() tween(btn, fasttw, {BackgroundColor3 = lib.colors.accent}) end)
                btn.MouseButton1Click:Connect(cb)
                return btn
            end

            function sec:toggle(text: string, subtitle: string, def: boolean, cb: ((boolean) -> ())?)
                elemorder += 1
                subtitle = subtitle or ""
                local surface = createControlSurface(body, 42, elemorder)
                bindSurfaceHover(surface)
                createLabel(surface, text, UDim2.new(1, -82, 0, 17), UDim2.fromOffset(12, 6), Enum.Font.GothamBold, 10, lib.colors.text)
                createLabel(surface, subtitle, UDim2.new(1, -82, 0, 13), UDim2.fromOffset(12, 23), Enum.Font.GothamMedium, 8, lib.colors.dim)

                local switch = Instance.new("Frame")
                switch.Size = UDim2.fromOffset(38, 20)
                switch.Position = UDim2.new(1, -50, 0.5, -10)
                switch.BackgroundColor3 = def and lib.colors.accent or Color3.fromRGB(42, 41, 50)
                switch.BorderSizePixel = 0
                switch.Parent = surface
                addCorner(switch, 10)
                local switchstroke = addStroke(switch, def and lib.colors.accent2 or Color3.fromRGB(58, 57, 67), 1)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.fromOffset(14, 14)
                knob.Position = def and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
                knob.BackgroundColor3 = def and Color3.new(1, 1, 1) or lib.colors.muted
                knob.BorderSizePixel = 0
                knob.Parent = switch
                addCorner(knob, 7)

                local hitbox = Instance.new("TextButton")
                hitbox.Size = UDim2.fromScale(1, 1)
                hitbox.BackgroundTransparency = 1
                hitbox.Text = ""
                hitbox.ZIndex = 5
                hitbox.Parent = surface

                local val = def
                local function render(newv: boolean)
                    val = newv
                    tween(switch, normaltw, {BackgroundColor3 = val and lib.colors.accent or Color3.fromRGB(42, 41, 50)})
                    tween(switchstroke, normaltw, {Color = val and lib.colors.accent2 or Color3.fromRGB(58, 57, 67)})
                    tween(knob, normaltw, {Position = val and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = val and Color3.new(1, 1, 1) or lib.colors.muted})
                end

                hitbox.MouseButton1Click:Connect(function()
                    render(not val)
                    if cb then cb(val) end
                end)

                return {
                    set = function(newv: boolean) render(newv) end,
                    get = function(): boolean return val end,
                }
            end

            function sec:bindtoggle(text: string, subtitle: string, defkey: Enum.KeyCode?, def: boolean, togglecb: ((boolean) -> ())?, keycb: ((Enum.KeyCode?) -> ())?)
                elemorder += 1
                subtitle = subtitle or ""
                local surface = createControlSurface(body, 48, elemorder)
                bindSurfaceHover(surface)
                createLabel(surface, text, UDim2.new(1, -182, 0, 17), UDim2.fromOffset(12, 7), Enum.Font.GothamBold, 10, lib.colors.text)
                createLabel(surface, subtitle, UDim2.new(1, -182, 0, 13), UDim2.fromOffset(12, 26), Enum.Font.GothamMedium, 8, lib.colors.dim)

                local function keytext(k: Enum.KeyCode?): string
                    if not k then return "none" end
                    return "[ " .. string.lower(k.Name) .. " ]"
                end

                local keybtn = Instance.new("TextButton")
                keybtn.Size = UDim2.fromOffset(76, 26)
                keybtn.Position = UDim2.new(1, -132, 0.5, -13)
                keybtn.BackgroundColor3 = Color3.fromRGB(31, 30, 38)
                keybtn.Text = keytext(defkey)
                keybtn.TextColor3 = lib.colors.accent2
                keybtn.Font = Enum.Font.GothamBold
                keybtn.TextSize = 8
                keybtn.BorderSizePixel = 0
                keybtn.AutoButtonColor = false
                keybtn.Parent = surface
                addCorner(keybtn, 5)
                local keystroke = addStroke(keybtn, Color3.fromRGB(60, 51, 83), 1)

                local switch = Instance.new("Frame")
                switch.Size = UDim2.fromOffset(38, 20)
                switch.Position = UDim2.new(1, -48, 0.5, -10)
                switch.BackgroundColor3 = def and lib.colors.accent or Color3.fromRGB(42, 41, 50)
                switch.BorderSizePixel = 0
                switch.Parent = surface
                addCorner(switch, 10)
                local switchstroke = addStroke(switch, def and lib.colors.accent2 or Color3.fromRGB(58, 57, 67), 1)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.fromOffset(14, 14)
                knob.Position = def and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
                knob.BackgroundColor3 = def and Color3.new(1, 1, 1) or lib.colors.muted
                knob.BorderSizePixel = 0
                knob.Parent = switch
                addCorner(knob, 7)

                local togglebtn = Instance.new("TextButton")
                togglebtn.Size = UDim2.fromOffset(46, 38)
                togglebtn.Position = UDim2.new(1, -52, 0.5, -19)
                togglebtn.BackgroundTransparency = 1
                togglebtn.Text = ""
                togglebtn.ZIndex = 5
                togglebtn.Parent = surface

                local enabled = def
                local key = defkey
                local waiting = false
                local bindcon = nil

                local function render(newv: boolean)
                    enabled = newv
                    tween(switch, normaltw, {BackgroundColor3 = enabled and lib.colors.accent or Color3.fromRGB(42, 41, 50)})
                    tween(switchstroke, normaltw, {Color = enabled and lib.colors.accent2 or Color3.fromRGB(58, 57, 67)})
                    tween(knob, normaltw, {Position = enabled and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = enabled and Color3.new(1, 1, 1) or lib.colors.muted})
                end

                local function finish(nextk: Enum.KeyCode?, cancelled: boolean)
                    if not cancelled then key = nextk end
                    waiting = false
                    lib.binding = false
                    keybtn.Text = keytext(key)
                    tween(keybtn, fasttw, {BackgroundColor3 = Color3.fromRGB(31, 30, 38), TextColor3 = lib.colors.accent2})
                    tween(keystroke, fasttw, {Color = Color3.fromRGB(60, 51, 83)})
                    if bindcon then bindcon:Disconnect(); bindcon = nil end
                    if not cancelled and keycb then keycb(key) end
                end

                togglebtn.MouseButton1Click:Connect(function()
                    render(not enabled)
                    if togglecb then togglecb(enabled) end
                end)

                keybtn.MouseButton1Click:Connect(function()
                    if waiting then return end
                    waiting = true
                    lib.binding = true
                    keybtn.Text = "press key"
                    tween(keybtn, fasttw, {BackgroundColor3 = lib.colors.accent, TextColor3 = Color3.new(1, 1, 1)})
                    tween(keystroke, fasttw, {Color = lib.colors.accent2})

                    bindcon = trackConn(uis.InputBegan:Connect(function(input, gpe)
                        if gpe or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if input.KeyCode == Enum.KeyCode.Escape then
                            finish(key, true)
                        elseif input.KeyCode == Enum.KeyCode.Backspace then
                            finish(nil, false)
                        else
                            finish(input.KeyCode, false)
                        end
                    end))
                end)

                return {
                    setenabled = function(newv: boolean) render(newv) end,
                    getenabled = function(): boolean return enabled end,
                    setkey = function(nextk: Enum.KeyCode?) key = nextk; keybtn.Text = keytext(key) end,
                    getkey = function(): Enum.KeyCode? return key end,
                    iswaiting = function(): boolean return waiting end,
                }
            end

            function sec:slider(text: string, minv: number, maxv: number, def: number, cb: ((number) -> ())?)
                elemorder += 1
                local surface = createControlSurface(body, 52, elemorder)
                bindSurfaceHover(surface)
                createLabel(surface, text, UDim2.new(1, -90, 0, 18), UDim2.fromOffset(12, 6), Enum.Font.GothamBold, 10, lib.colors.text)
                local valtxt = createLabel(surface, tostring(math.floor(def * 100) / 100), UDim2.fromOffset(70, 18), UDim2.new(1, -82, 0, 6), Enum.Font.GothamBold, 9, lib.colors.accent2, Enum.TextXAlignment.Right)

                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, -24, 0, 8)
                track.Position = UDim2.fromOffset(12, 33)
                track.BackgroundColor3 = Color3.fromRGB(36, 35, 44)
                track.BorderSizePixel = 0
                track.Active = true
                track.ClipsDescendants = true
                track.Parent = surface
                addCorner(track, 4)
                addStroke(track, lib.colors.bordersoft, 1)

                local pct = math.clamp((def - minv) / (maxv - minv), 0, 1)
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(pct, 0, 1, 0)
                fill.BackgroundColor3 = lib.colors.accent
                fill.BackgroundTransparency = 0.18
                fill.BorderSizePixel = 0
                fill.Parent = track
                addCorner(fill, 4)
                addAccentGradient(fill)

                local hitbox = Instance.new("TextButton")
                hitbox.Size = UDim2.new(1, 0, 1, 18)
                hitbox.Position = UDim2.fromOffset(0, -9)
                hitbox.BackgroundTransparency = 1
                hitbox.Text = ""
                hitbox.ZIndex = 5
                hitbox.Parent = track

                local val = math.clamp(def, minv, maxv)
                local state = {fill = fill, target = pct, shown = pct}
                table.insert(lib.sliders, state)

                local function updateval(newv: number)
                    val = math.clamp(newv, minv, maxv)
                    state.target = (val - minv) / (maxv - minv)
                    valtxt.Text = tostring(math.floor(val * 100) / 100)
                    if cb then cb(val) end
                end

                local function updateptr(mx: number)
                    if track.AbsoluteSize.X <= 0 then return end
                    local nextpct = math.clamp((mx - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    updateval(minv + (maxv - minv) * nextpct)
                end

                hitbox.MouseEnter:Connect(function() tween(track, fasttw, {BackgroundColor3 = Color3.fromRGB(45, 43, 55)}) end)
                hitbox.MouseLeave:Connect(function() tween(track, fasttw, {BackgroundColor3 = Color3.fromRGB(36, 35, 44)}) end)

                hitbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if lib.sliderdrag then lib.sliderdrag.done() end
                        updateptr(input.Position.X)
                        tween(fill, fasttw, {BackgroundTransparency = 0})
                        lib.sliderdrag = {
                            move = updateptr,
                            done = function() tween(fill, fasttw, {BackgroundTransparency = 0.18}) end,
                        }
                    end
                end)

                return {
                    set = function(newv: number) updateval(newv) end,
                    get = function(): number return val end,
                }
            end

            function sec:selector(text: string, subtitle: string, initval: string, prevcb: () -> string, nextcb: () -> string)
                elemorder += 1
                subtitle = subtitle or ""
                local surface = createControlSurface(body, 48, elemorder)
                bindSurfaceHover(surface)
                createLabel(surface, text, UDim2.new(1, -190, 0, 17), UDim2.fromOffset(12, 7), Enum.Font.GothamBold, 10, lib.colors.text)
                createLabel(surface, subtitle, UDim2.new(1, -190, 0, 13), UDim2.fromOffset(12, 26), Enum.Font.GothamMedium, 8, lib.colors.dim)
                local valtxt = createLabel(surface, initval, UDim2.fromOffset(90, 26), UDim2.new(1, -136, 0.5, -13), Enum.Font.GothamBold, 8, lib.colors.accent2, Enum.TextXAlignment.Center)

                local function makearrow(sym: string, xo: number): TextButton
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.fromOffset(28, 26)
                    btn.Position = UDim2.new(1, xo, 0.5, -13)
                    btn.BackgroundColor3 = Color3.fromRGB(31, 30, 38)
                    btn.Text = sym
                    btn.TextColor3 = lib.colors.muted
                    btn.Font = Enum.Font.GothamBold
                    btn.TextSize = 14
                    btn.BorderSizePixel = 0
                    btn.AutoButtonColor = false
                    btn.Parent = surface
                    addCorner(btn, 5)
                    addStroke(btn, lib.colors.border, 1)
                    return btn
                end

                local prevbtn = makearrow("‹", -174)
                local nextbtn = makearrow("›", -38)
                prevbtn.MouseButton1Click:Connect(function() valtxt.Text = prevcb() end)
                nextbtn.MouseButton1Click:Connect(function() valtxt.Text = nextcb() end)
            end

            function sec:dropdown(text: string, cfg: {[string]: any})
                elemorder += 1
                cfg = cfg or {}
                local items = cfg.list or {}
                local picked = cfg.default or (items[1] or "select...")
                local cb = cfg.callback or function() end

                local box = createControlSurface(body, 46, elemorder)
                box.ClipsDescendants = true
                createLabel(box, text, UDim2.fromOffset(108, 28), UDim2.fromOffset(12, 9), Enum.Font.GothamBold, 9, lib.colors.text)

                local pickbtn = Instance.new("TextButton")
                pickbtn.Size = UDim2.new(1, -134, 0, 28)
                pickbtn.Position = UDim2.fromOffset(122, 9)
                pickbtn.BackgroundColor3 = Color3.fromRGB(31, 30, 38)
                pickbtn.Text = picked
                pickbtn.TextColor3 = lib.colors.accent2
                pickbtn.Font = Enum.Font.GothamMedium
                pickbtn.TextSize = 9
                pickbtn.TextXAlignment = Enum.TextXAlignment.Left
                pickbtn.TextTruncate = Enum.TextTruncate.AtEnd
                pickbtn.BorderSizePixel = 0
                pickbtn.AutoButtonColor = false
                pickbtn.Parent = box
                addCorner(pickbtn, 5)
                addStroke(pickbtn, lib.colors.border, 1)

                local pickpad = Instance.new("UIPadding")
                pickpad.PaddingLeft = UDim.new(0, 9)
                pickpad.PaddingRight = UDim.new(0, 25)
                pickpad.Parent = pickbtn

                local arrow = createLabel(pickbtn, ">", UDim2.fromOffset(20, 28), UDim2.new(1, -24, 0, 0), Enum.Font.GothamBold, 12, lib.colors.accent2, Enum.TextXAlignment.Center)
                arrow.Rotation = -90

                local list = Instance.new("ScrollingFrame")
                list.Size = UDim2.new(1, -24, 0, 104)
                list.Position = UDim2.fromOffset(12, 52)
                list.BackgroundColor3 = Color3.fromRGB(16, 16, 21)
                list.BorderSizePixel = 0
                list.ScrollBarThickness = 2
                list.ScrollBarImageColor3 = lib.colors.accent
                list.CanvasSize = UDim2.new()
                list.Visible = false
                list.Parent = box
                addCorner(list, 5)
                addStroke(list, lib.colors.bordersoft, 1)

                local pad = Instance.new("UIPadding")
                pad.PaddingTop = UDim.new(0, 4)
                pad.PaddingBottom = UDim.new(0, 4)
                pad.PaddingLeft = UDim.new(0, 4)
                pad.PaddingRight = UDim.new(0, 6)
                pad.Parent = list

                local layout = Instance.new("UIListLayout")
                layout.Padding = UDim.new(0, 3)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Parent = list

                local opened = false
                local function setopen(on: boolean)
                    opened = on
                    list.Visible = on
                    tween(box, normaltw, {Size = UDim2.new(1, 0, 0, on and 168 or 46)})
                    tween(arrow, fasttw, {Rotation = on and 90 or -90})
                end

                local function drawlist()
                    for _, v in ipairs(list:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    for i, item in ipairs(items) do
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 27)
                        btn.BackgroundColor3 = picked == item and Color3.fromRGB(41, 31, 68) or Color3.fromRGB(22, 22, 28)
                        btn.Text = tostring(item)
                        btn.TextColor3 = picked == item and lib.colors.accent2 or lib.colors.muted
                        btn.Font = Enum.Font.GothamMedium
                        btn.TextSize = 8
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        btn.TextTruncate = Enum.TextTruncate.AtEnd
                        btn.BorderSizePixel = 0
                        btn.AutoButtonColor = false
                        btn.LayoutOrder = i
                        btn.Parent = list
                        addCorner(btn, 4)

                        local btnpad = Instance.new("UIPadding")
                        btnpad.PaddingLeft = UDim.new(0, 8)
                        btnpad.PaddingRight = UDim.new(0, 8)
                        btnpad.Parent = btn

                        btn.MouseButton1Click:Connect(function()
                            picked = item
                            pickbtn.Text = tostring(item)
                            setopen(false)
                            cb(item)
                        end)
                    end
                    list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
                end

                pickbtn.MouseButton1Click:Connect(function()
                    setopen(not opened)
                    if opened then drawlist() end
                end)

                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
                end)

                return {
                    get = function() return picked end,
                    refresh = function(newlist: table)
                        items = newlist or {}
                        if opened then drawlist() end
                    end,
                }
            end

            function sec:searchdropdown(text: string, cfg: {[string]: any})
                elemorder += 1
                cfg = cfg or {}
                local items = cfg.list or {}
                local picked = cfg.default or nil
                local cb = cfg.callback or function() end

                local box = createControlSurface(body, 46, elemorder)
                box.ClipsDescendants = true
                createLabel(box, text, UDim2.fromOffset(108, 28), UDim2.fromOffset(12, 9), Enum.Font.GothamBold, 9, lib.colors.text)

                local search = Instance.new("TextBox")
                search.Size = UDim2.new(1, -166, 0, 28)
                search.Position = UDim2.fromOffset(122, 9)
                search.BackgroundColor3 = Color3.fromRGB(31, 30, 38)
                search.PlaceholderText = "search..."
                search.PlaceholderColor3 = lib.colors.dim
                search.Text = picked and picked.label or ""
                search.TextColor3 = lib.colors.text
                search.Font = Enum.Font.GothamMedium
                search.TextSize = 9
                search.TextXAlignment = Enum.TextXAlignment.Left
                search.ClearTextOnFocus = false
                search.BorderSizePixel = 0
                search.Parent = box
                addCorner(search, 5)
                addStroke(search, lib.colors.border, 1)

                local searchpad = Instance.new("UIPadding")
                searchpad.PaddingLeft = UDim.new(0, 9)
                searchpad.PaddingRight = UDim.new(0, 9)
                searchpad.Parent = search

                local dropbtn = Instance.new("TextButton")
                dropbtn.Size = UDim2.fromOffset(28, 28)
                dropbtn.Position = UDim2.new(1, -36, 0, 9)
                dropbtn.BackgroundColor3 = Color3.fromRGB(31, 30, 38)
                dropbtn.Text = ">"
                dropbtn.Rotation = -90
                dropbtn.TextColor3 = lib.colors.accent2
                dropbtn.Font = Enum.Font.GothamBold
                dropbtn.TextSize = 12
                dropbtn.BorderSizePixel = 0
                dropbtn.AutoButtonColor = false
                dropbtn.Parent = box
                addCorner(dropbtn, 5)
                addStroke(dropbtn, lib.colors.border, 1)

                local list = Instance.new("ScrollingFrame")
                list.Size = UDim2.new(1, -24, 0, 126)
                list.Position = UDim2.fromOffset(12, 52)
                list.BackgroundColor3 = Color3.fromRGB(16, 16, 21)
                list.BorderSizePixel = 0
                list.ScrollBarThickness = 2
                list.ScrollBarImageColor3 = lib.colors.accent
                list.ScrollBarImageTransparency = 0.1
                list.CanvasSize = UDim2.new()
                list.Visible = false
                list.Parent = box
                addCorner(list, 5)
                addStroke(list, lib.colors.bordersoft, 1)

                local listpad = Instance.new("UIPadding")
                listpad.PaddingTop = UDim.new(0, 4)
                listpad.PaddingBottom = UDim.new(0, 4)
                listpad.PaddingLeft = UDim.new(0, 4)
                listpad.PaddingRight = UDim.new(0, 6)
                listpad.Parent = list

                local listlayout = Instance.new("UIListLayout")
                listlayout.Padding = UDim.new(0, 3)
                listlayout.SortOrder = Enum.SortOrder.LayoutOrder
                listlayout.Parent = list

                local opened = false
                local changing = false

                local function drawitems()
                    for _, v in ipairs(list:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    local q = string.lower(search.Text)
                    if picked and search.Text == picked.label then q = "" end
                    local shown = 0
                    for _, item in ipairs(items) do
                        local hay = string.lower((item.label or "") .. " " .. (item.where or ""))
                        if q == "" or string.find(hay, q, 1, true) then
                            shown += 1
                            local btn = Instance.new("TextButton")
                            btn.Size = UDim2.new(1, 0, 0, 27)
                            btn.BackgroundColor3 = picked == item and Color3.fromRGB(41, 31, 68) or Color3.fromRGB(22, 22, 28)
                            btn.Text = (item.label or "") .. (item.where and ("   ·   " .. item.where) or "")
                            btn.TextColor3 = picked == item and lib.colors.accent2 or lib.colors.muted
                            btn.Font = Enum.Font.GothamMedium
                            btn.TextSize = 8
                            btn.TextXAlignment = Enum.TextXAlignment.Left
                            btn.TextTruncate = Enum.TextTruncate.AtEnd
                            btn.BorderSizePixel = 0
                            btn.AutoButtonColor = false
                            btn.LayoutOrder = shown
                            btn.Parent = list
                            addCorner(btn, 4)

                            local pad = Instance.new("UIPadding")
                            pad.PaddingLeft = UDim.new(0, 8)
                            pad.PaddingRight = UDim.new(0, 8)
                            pad.Parent = btn

                            btn.MouseEnter:Connect(function() tween(btn, fasttw, {BackgroundColor3 = lib.colors.surfacehover}) end)
                            btn.MouseLeave:Connect(function()
                                local sel = picked == item
                                tween(btn, fasttw, {BackgroundColor3 = sel and Color3.fromRGB(41, 31, 68) or Color3.fromRGB(22, 22, 28)})
                            end)

                            btn.MouseButton1Click:Connect(function()
                                picked = item
                                changing = true
                                search.Text = item.label or ""
                                changing = false
                                opened = false
                                list.Visible = false
                                tween(box, normaltw, {Size = UDim2.new(1, 0, 0, 46)})
                                tween(dropbtn, fasttw, {Rotation = -90})
                                cb(item)
                            end)
                            if shown >= 80 then break end
                        end
                    end
                    list.CanvasSize = UDim2.fromOffset(0, math.max(0, shown * 30 + 5))
                end

                local function setopen(on: boolean)
                    opened = on
                    list.Visible = on
                    tween(box, normaltw, {Size = UDim2.new(1, 0, 0, on and 190 or 46)})
                    tween(dropbtn, fasttw, {Rotation = on and 90 or -90})
                    if on then drawitems() end
                end

                search.Focused:Connect(function()
                    setopen(true)
                    if picked then
                        search.CursorPosition = #search.Text + 1
                        search.SelectionStart = 1
                    end
                end)

                search:GetPropertyChangedSignal("Text"):Connect(function()
                    if changing then return end
                    if picked and search.Text ~= picked.label then picked = nil end
                    if not opened then setopen(true) else drawitems() end
                end)

                dropbtn.MouseButton1Click:Connect(function() setopen(not opened) end)
                listlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list.CanvasSize = UDim2.fromOffset(0, listlayout.AbsoluteContentSize.Y + 8)
                end)

                return {
                    get = function() return picked end,
                    refresh = function(newlist: table)
                        items = newlist or {}
                        if opened then drawitems() end
                    end,
                }
            end

            function sec:keyguide(gtitle: string, rows: table)
                elemorder += 1
                local h = 24 + (#rows * 18) + 8
                local surface = createControlSurface(body, h, elemorder)
                createLabel(surface, gtitle, UDim2.new(1, -24, 0, 15), UDim2.fromOffset(12, 7), Enum.Font.GothamBold, 9, lib.colors.muted)
                for idx, row in ipairs(rows) do
                    local y = 24 + (idx - 1) * 18
                    createLabel(surface, row[1], UDim2.fromOffset(160, 16), UDim2.fromOffset(12, y), Enum.Font.GothamBold, 9, lib.colors.accent2)
                    createLabel(surface, row[2], UDim2.new(1, -184, 0, 16), UDim2.fromOffset(172, y), Enum.Font.GothamMedium, 8, lib.colors.dim)
                end
                return surface
            end

            function sec:optional()
                elemorder += 1
                local holder = Instance.new("CanvasGroup")
                holder.Size = UDim2.new(1, 0, 0, 0)
                holder.BackgroundTransparency = 1
                holder.GroupTransparency = 1
                holder.BorderSizePixel = 0
                holder.ClipsDescendants = true
                holder.LayoutOrder = elemorder
                holder.Parent = body

                local inner = Instance.new("Frame")
                inner.Size = UDim2.new(1, 0, 0, 52)
                inner.BackgroundTransparency = 1
                inner.Parent = holder

                local optsec = {}
                function optsec:slider(text: string, minv: number, maxv: number, def: number, cb: ((number) -> ())?)
                    return sec:slider(text, minv, maxv, def, cb)
                end

                return holder, optsec
            end

            return sec
        end

        return tabobj
    end

    return win
end

function lib:showoptional(holder: CanvasGroup, on: boolean)
    tween(holder, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, on and 52 or 0),
        GroupTransparency = on and 0 or 1,
    })
end

function lib:unload()
    if self.unloaded or self.unloading then return end
    self.unloading = true
    if not self.main or not self.scale then return end

    local width = math.max(self.main.AbsoluteSize.X, 1)
    tween(self.scale, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0.94})
    local anim = tween(self.main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(width, 0),
        BackgroundTransparency = 0.12,
    })

    anim.Completed:Once(function()
        self.unloaded = true
        for _, conn in ipairs(self.conns) do
            if conn.Connected then conn:Disconnect() end
        end
        table.clear(self.conns)
        if self.gui then self.gui:Destroy() end
    end)
end

return lib
