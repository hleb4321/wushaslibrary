# wusha's lib

a simple and clean ui library for roblox (luau). features a cool animations notifications buttons etc lol

### how to install and use / example

```lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/hleb4321/wushaslibrary/refs/heads/main/library.lua"))()

local win = lib:window({
    title = "wusha's hub",
    author = "by wusha",
    width = 590,
    height = 440,
    togglekey = Enum.KeyCode.RightShift,
})

local tab = win:tab("main", "MAIN")
local sec = tab:section("controls", "example elements")

sec:button("click me", "simple button", function()
    lib:notify("button clicked!", Color3.fromRGB(124, 77, 255), 2)
end)

sec:toggle("enable feature", "on/off switch", false, function(on)
    print("toggle:", on)
end)

sec:bindtoggle("keybind feature", "bindable switch", Enum.KeyCode.E, true, function(on)
    print("bind state:", on)
end, function(key)
    print("new key:", key)
end)

sec:slider("speed", 16, 150, 16, function(val)
    print("slider val:", val)
end)

sec:selector("font", "changes ui font", "gotham", function()
    return lib:cyclefont(-1)
end, function()
    return lib:cyclefont(1)
end)

sec:selector("accent", "changes color theme", "violet", function()
    return lib:cycleaccent(-1)
end, function()
    return lib:cycleaccent(1)
end)

local drop = sec:dropdown("items", {
    list = {"item 1", "item 2", "item 3"},
    default = "item 1",
    callback = function(item)
        print("picked:", item)
    end,
})

local sdrop = sec:searchdropdown("search list", {
    list = {
        {label = "player 1", where = "workspace"},
        {label = "player 2", where = "workspace"},
    },
    callback = function(item)
        print("found:", item.label)
    end,
})

sec:keyguide("binds", {
    {"right shift", "toggle window"},
    {"e", "action bind"},
})

sec:button("unload gui", "removes ui from screen", function()
    win:showmodal()
end)
```

### методы

- `lib:window(cfg)` - create main window
- `win:tab(id, label)` - add tab
- `tab:section(title, desc)` - create section
- `sec:button(text, sub, cb)` - button
- `sec:toggle(text, sub, def, cb)` - toggle
- `sec:bindtoggle(text, sub, defkey, def, togglecb, keycb)` - bind-toggle
- `sec:slider(text, min, max, def, cb)` - slider
- `sec:selector(text, sub, init, prevcb, nextcb)` - selector
- `sec:dropdown(text, cfg)` - dropdown
- `sec:searchdropdown(text, cfg)` - searchable dropdown
- `sec:keyguide(title, rows)` - keybind table
- `sec:optional()` - collapsible block (returns `holder, optsec`)
- `lib:notify(msg, color, time)` - show notification
- `lib:setnotifside(side)` - notification side (`right` / `left`)
- `win:showmodal()` - open unload window
- `lib:unload()` - unload library
  
