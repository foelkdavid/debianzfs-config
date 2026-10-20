-- MONITORS
-- Use each screen's preferred resolution/refresh rate and arrange screens rightward.
-- Change scale here (for example, 1.25 or 1.5 makes everything larger).
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1.0 })

-- AUTOSTART
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE DBUS_SESSION_BUS_ADDRESS")
    hl.exec_cmd("Thunar --daemon")
    hl.exec_cmd("noctalia --daemon")
end)

-- ENVIRONMENT
hl.env("XCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_SIZE", "32")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "gtk")
hl.env("GTK_THEME", "Adwaita:dark")

-- LOOK AND FEEL

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in = 2,
        gaps_out = 8,
        border_size = 4,
        col = {
            active_border = "rgba(d79921ff)",
            inactive_border = "rgba(928374ff)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "master",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2.0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
        },
        blur = {
            enabled = true,
        },
    },

    animations = {
        enabled = true,
    },

    master = {
        new_status = "master",
        mfact = 0.55,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        focus_on_activate = false,
        layers_hog_keyboard_focus = false,
    },

    input = {
        kb_layout = "de,de",
        kb_variant = ",bone",
        kb_model = "",
        kb_options = "grp:ctrl_space_toggle",
        kb_rules = "",
        repeat_rate = 100,
        repeat_delay = 300,
        follow_mouse = 0,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },

    cursor = {
        inactive_timeout = 0,
        hide_on_key_press = false,
        invisible = false,
        no_hardware_cursors = 2,
        no_warps = true,
    },
})

hl.curve("easeOutQuint", {
    type = "bezier",
    points = { { 0.23, 1 }, { 0.1, 1 } },
})
hl.curve("linear", {
    type = "bezier",
    points = { { 0, 0 }, { 0.1, 1 } },
})
hl.curve("almostLinear", {
    type = "bezier",
    points = { { 0.5, 0.5 }, { 0.1, 1.0 } },
})
hl.curve("quick", {
    type = "bezier",
    points = { { 0.15, 0 }, { 0.1, 1 } },
})

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- SHORTCUTS

local mainMod = "SUPER"

-- Programs / session
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("alacritty"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("Thunar"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))

-- Screenshot
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("slurp | grim -g - - | wl-copy -t image/png"))

-- Floating / fullscreen
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Focus the window in the arrow direction
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))

-- Switch focus between monitors
hl.bind(mainMod .. " + period", hl.dsp.focus({ monitor = "+1" }))

-- Swap with the window in the arrow direction
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }))

-- Adjust the width of the master area
hl.bind(mainMod .. " + CTRL + left", hl.dsp.layout("mfact -0.05"), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.layout("mfact +0.05"), { repeating = true })

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse:274", hl.dsp.window.float())

-- WORKSPACES
-- Ten workspaces per monitor: monitor ID 0 gets 1-10, ID 1 gets 11-20, etc.
-- IDs stay stable during the session, even when another monitor disconnects.
local knownMonitors = {}
local function configureWorkspaces(disconnected)
    local connected = {}
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.name ~= disconnected then
            connected[monitor.id] = monitor
            knownMonitors[monitor.id] = monitor.name
        end
    end
    for id, name in pairs(knownMonitors) do
        for number = 1, 10 do
            hl.workspace_rule({
                workspace = tostring(id * 10 + number),
                monitor = name,
                default = number == 1,
                persistent = true,
                -- Do not create empty workspaces for disconnected screens.
                enabled = connected[id] ~= nil,
            })
        end
    end
    -- Restore workspaces that moved to another screen while theirs was unplugged.
    for _, workspace in ipairs(hl.get_workspaces()) do
        local monitor = connected[math.floor((workspace.id - 1) / 10)]
        if monitor and workspace.monitor and workspace.monitor.name ~= monitor.name then
            hl.dispatch(hl.dsp.workspace.move({ workspace = workspace.id, monitor = monitor.name }))
        end
    end
end
configureWorkspaces() -- Also runs when this file is reloaded.
hl.on("hyprland.start", configureWorkspaces)
hl.on("monitor.added", function() configureWorkspaces() end)
hl.on("monitor.removed", function(monitor) configureWorkspaces(monitor.name) end)

local function selectWorkspace(number, moveWindow)
    local monitor = hl.get_active_monitor()
    if not monitor then return end
    local workspace = monitor.id * 10 + number
    if moveWindow then
        hl.dispatch(hl.dsp.window.move({ workspace = workspace }))
    else
        hl.dispatch(hl.dsp.focus({ workspace = workspace }))
    end
end

-- Super+1...0 selects a workspace on the focused monitor; Shift moves a window.
for number = 1, 10 do
    local key = number % 10
    hl.bind(mainMod .. " + " .. key, function() selectWorkspace(number, false) end)
    hl.bind(mainMod .. " + SHIFT + " .. key, function() selectWorkspace(number, true) end)
end

-- Super+wheel wraps through the focused monitor's ten workspaces.
local function stepWorkspace(step)
    local monitor = hl.get_active_monitor()
    if not monitor or not monitor.active_workspace then return end
    selectWorkspace((monitor.active_workspace.id - 1 + step) % 10 + 1, false)
end
hl.bind(mainMod .. " + mouse_down", function() stepWorkspace(1) end)
hl.bind(mainMod .. " + mouse_up", function() stepWorkspace(-1) end)

-- WINDOW RULES
-- Ignore applications requesting maximization; tiling controls their size.
hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- HARDWARE PROFILE
-- Deployment links this to one of hypr/profiles/*.lua; no generated Lua settings.
-- Without a selected profile, the desktop defaults above apply.
local configHome = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local profile = configHome .. "/debian-deploy/graphics.lua"
local profileFile = io.open(profile, "r")
if profileFile then
    profileFile:close()
    dofile(profile)
end
