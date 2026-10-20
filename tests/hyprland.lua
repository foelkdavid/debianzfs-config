-- Run with: lua5.4 tests/hyprland.lua /absolute/path/to/hyprland.lua
-- Exercises callbacks without a running compositor or touching the user's session.
local config = assert(arg[1])
local monitors, workspaces, active, bindings, events, rules, dispatched, settings
local function dispatcher(kind)
    return function(spec)
        return function()
            dispatched[#dispatched + 1] = { kind = kind, spec = spec }
        end
    end
end
local function merge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = target[key] or {}
            merge(target[key], value)
        else
            target[key] = value
        end
    end
end
local function load()
    bindings, events, rules, dispatched, settings = {}, {}, {}, {}, {}
    hl = {
        monitor = function(spec)
            assert(spec.output == "" and spec.mode == "preferred")
            assert(spec.position == "auto-right" and spec.scale == 1)
        end,
        config = function(spec) merge(settings, spec) end,
        env = function() end, curve = function() end, animation = function() end,
        window_rule = function(spec) assert(not spec.monitor and not spec.workspace) end,
        exec_cmd = function() end,
        bind = function(key, callback) assert(not bindings[key]); bindings[key] = callback end,
        on = function(event, callback) events[event] = callback end,
        get_monitors = function() return monitors end,
        get_workspaces = function() return workspaces end,
        get_active_monitor = function() return active end,
        -- Hyprland 0.55.2 returns nothing; rules are replaced by workspace ID.
        workspace_rule = function(spec) rules[tonumber(spec.workspace)] = spec end,
        dispatch = function(callback) callback() end,
        dsp = {
            exec_cmd = dispatcher("exec"), exit = dispatcher("exit"),
            focus = dispatcher("focus"), layout = dispatcher("layout"),
            workspace = { move = dispatcher("workspace.move") },
            window = {
                close = dispatcher("close"), float = dispatcher("float"),
                fullscreen = dispatcher("fullscreen"), swap = dispatcher("swap"),
                drag = dispatcher("drag"), resize = dispatcher("resize"),
                move = dispatcher("window.move"),
            },
        },
    }
    dofile(config)
end
local function press(key, kind, workspace)
    dispatched = {}
    bindings["SUPER + " .. key]()
    if not kind then assert(#dispatched == 0); return end
    assert(#dispatched == 1 and dispatched[1].kind == kind)
    assert(dispatched[1].spec.workspace == workspace)
end
local function checkMonitor(monitor)
    for number = 1, 10 do
        local rule = rules[monitor.id * 10 + number]
        assert(rule.monitor == monitor.name and rule.enabled and rule.persistent)
        assert(rule.default == (number == 1))
        press(tostring(number % 10), "focus", monitor.id * 10 + number)
        press("SHIFT + " .. number % 10, "window.move", monitor.id * 10 + number)
    end
end

local first = { id = 0, name = "eDP-1", active_workspace = { id = 1 } }
local second = { id = 1, name = "DP-1", active_workspace = { id = 11 } }
local third = { id = 2, name = "HDMI-A-1", active_workspace = { id = 21 } }
monitors, workspaces, active = {}, {}, nil
load() -- Initial parsing can happen before there are any monitors.
press("1")
press("mouse_down")
monitors, active = { first }, first
events["hyprland.start"]()
checkMonitor(first)
monitors = { first, second }
events["monitor.added"](second)
active = second
checkMonitor(second)
monitors = { third, first, second } -- Enumeration order must not change allocations.
events["monitor.added"](third)
active = third
checkMonitor(third)

-- Wheel wraps at the ends of this monitor's range.
press("mouse_up", "focus", 30)
third.active_workspace.id = 30
press("mouse_down", "focus", 21)

-- Removal may be emitted while the departing monitor is still in the list.
events["monitor.removed"](first)
for number = 1, 10 do assert(not rules[number].enabled) end
checkMonitor(third)
monitors = { second, third }
workspaces = { { id = 1, monitor = second } }
dispatched = {}
monitors = { third, first, second }
events["monitor.added"](first)
assert(#dispatched == 1 and dispatched[1].kind == "workspace.move")
assert(dispatched[1].spec.workspace == 1 and dispatched[1].spec.monitor == "eDP-1")
active = first
checkMonitor(first)

workspaces = {}
load() -- Reload preserves allocations and binds; no startup-only discovery.
assert(#dispatched == 0, "bindings must not dispatch while parsing")
for _, monitor in ipairs(monitors) do active = monitor; checkMonitor(monitor) end
for _, direction in ipairs({ "left", "right", "up", "down" }) do
    dispatched = {}
    bindings["SUPER + " .. direction]()
    assert(dispatched[1].kind == "focus" and dispatched[1].spec.direction == direction)
    bindings["SUPER + SHIFT + " .. direction]()
    assert(dispatched[2].kind == "swap" and dispatched[2].spec.direction == direction)
end
assert(settings.input.kb_layout == "de,de" and settings.input.kb_variant == ",bone")
print("PASS: monitor setup, per-monitor bindings, hotplug, reconnect, reload, and directional shortcuts")
