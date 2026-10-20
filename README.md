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
  a Desktop folder.
- `scripts/fonts/deploy.sh` installs the configured Nerd Fonts.

All scripts run as the desktop user without `sudo`. The installer handles
system packages and puts the wallpaper in `/opt/media/wall`. Set
`DEBIANZFS_SKIP_OPTIONAL_ASSETS=true` with the root `deploy.sh` to skip plugin
and font downloads during offline refreshes. The dotfiles deployment does not
create XDG user folders.
