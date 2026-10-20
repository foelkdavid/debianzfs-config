# DebianZFS config

This repository contains the user dotfiles and per-user setup scripts. The
installer places it at `~/.local/debianzfs-config`.

Run `./deploy.sh` as your desktop user. It runs each focused component under
`scripts/`. To refresh after `git pull`, run `./deploy.sh` again. Unchanged
links and generated files are left in place; existing files replaced by
managed dotfiles are backed up in `~/.local/state/debianzfs-config/backups/`.

Each component can also be run on its own:

- `scripts/dotfiles/deploy.sh` links all dotfiles, including Zsh and its login
  startup. It also installs the Zsh plugins.
- `scripts/noctalia/deploy.sh` sets up Noctalia user settings and audio/portal
  integration.
- `scripts/help-shortcuts/deploy.sh` installs the Help and Ticket launchers in
  the application menu and removes their old Desktop copies. It does not create
  a Desktop folder. It disables the XDG Desktop directory so desktop
  environment setup does not recreate it on later logins.
- `scripts/fonts/deploy.sh` installs the configured Nerd Fonts.

All scripts run as the desktop user without `sudo`. The installer handles
system packages and puts the wallpaper in `/opt/media/wall`. Set
`DEBIANZFS_SKIP_OPTIONAL_ASSETS=true` with the root `deploy.sh` to skip plugin
and font downloads during offline refreshes. The dotfiles deployment does not
create XDG user folders.

## Hyprland

Edit `~/.config/hypr/hyprland.lua` (linked to `dotfiles/hypr/hyprland.lua`).
It contains the desktop settings, startup programs, keyboard settings,
shortcuts, and window rules. The first monitor rule enables each screen at
its preferred resolution and refresh rate, places additional screens to the
right, and sets `scale = 1.0`. Increase that value to make the desktop larger.
Connector order comes from Hyprland; it does not infer the physical screen order.

Each monitor has ten workspaces. Super+1…0 selects within the focused
monitor's set; Super+Shift+1…0 moves the active window there. Super+wheel
wraps within the same set. Monitor ID 0 owns 1–10, ID 1 owns 11–20, and so on;
these IDs stay stable during a session, including hotplug and config reloads.
The workspace section uses Hyprland's Lua API without spawning `hyprctl`.
Super+arrows focuses a window by direction; adding Shift swaps windows.

Only hardware overrides are imported. The installer selects a checked-in
`dotfiles/hypr/profiles/PROFILE.lua` through the symlink
`~/.config/debian-deploy/graphics.lua`. Intel, AMD, and Nouveau need no
overrides; NVIDIA sets its driver variables; VM profiles disable expensive
effects and hardware cursors. `vm-software` additionally forces CPU rendering.
Without a selection, the common desktop defaults apply. To select manually:

```sh
mkdir -p ~/.config/debian-deploy
ln -sfnT ~/.local/debianzfs-config/dotfiles/hypr/profiles/amd.lua \
  ~/.config/debian-deploy/graphics.lua
```

Restart the session after changing GPU profiles so environment changes apply.
Refreshing this repository leaves the selected profile link in place. Older
installations with a generated `graphics.lua` can replace it with this link.

Run the host-safe callback checks with Lua 5.4:

```sh
lua5.4 tests/hyprland.lua "$PWD/dotfiles/hypr/hyprland.lua"
```
