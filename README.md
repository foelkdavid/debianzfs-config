# DebianZFS user configuration

This repository contains the user-facing configuration and maintenance scripts
for DebianZFS. The installer pins it as a Git submodule, then installs it at
`~/.local/debianzfs-config`. The live image uses the same files.

Run `./install.sh` as the desktop user to link the dotfiles and install the
help and ticket shortcuts. Existing symlinks are replaced on each run; real
files are saved under `~/.local/state/debianzfs-config/backups/` before they
are replaced. After updating the checkout with `git pull`, rerun the script.

The scripts in `scripts/` can also be run individually. The installer owns
system packages and privileged wallpaper placement; this repository owns
per-user configuration and the shortcut assets.
