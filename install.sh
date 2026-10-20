#!/usr/bin/env bash
set -Eeuo pipefail
set +x

[[ $EUID != 0 ]] || { echo 'Run this as your desktop user, without sudo.' >&2; exit 1; }
REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}
STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/debianzfs-config
BACKUP_DIR="$STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)-$$"

link_config() {
    local source_path=$1 destination=$2
    mkdir -p -- "$(dirname -- "$destination")"
    if [[ -L $destination ]] && [[ $(readlink -f -- "$destination" || true) == "$source_path" ]]; then return; fi
    if [[ -e $destination || -L $destination ]]; then
        mkdir -p -- "$BACKUP_DIR"
        mv -- "$destination" "$BACKUP_DIR/$(basename -- "$destination")"
    fi
    ln -s -- "$source_path" "$destination"
}

for config in alacritty zsh gtk-3.0 nvim hypr; do
    link_config "$REPO_DIR/dotfiles/$config" "$CONFIG_DIR/$config"
done
link_config "$REPO_DIR/dotfiles/zsh/zshrc" "$HOME/.zshrc"
link_config "$REPO_DIR/dotfiles/zsh/zprofile" "$HOME/.zprofile"

if command -v xdg-user-dirs-update >/dev/null 2>&1; then xdg-user-dirs-update; fi
if [[ ${DEBIANZFS_SKIP_OPTIONAL_ASSETS:-false} != true ]]; then
    bash "$REPO_DIR/scripts/zsh/deploy.sh"
    bash "$REPO_DIR/scripts/fonts/deploy.sh"
fi

install -d -m 755 "$HOME/.local/state/noctalia"
if [[ ! -e $HOME/.local/state/noctalia/settings.toml ]]; then
    install -m 644 "$REPO_DIR/noctalia/settings.toml" "$HOME/.local/state/noctalia/settings.toml"
fi
if [[ ! -e $CONFIG_DIR/noctalia/config.toml ]]; then
    install -d -m 755 "$CONFIG_DIR/noctalia"
    printf '%s\n' '[shell]' 'polkit_agent = true' > "$CONFIG_DIR/noctalia/config.toml"
fi

desktop_dir=$(xdg-user-dir DESKTOP 2>/dev/null || true)
[[ -n $desktop_dir ]] || desktop_dir="$HOME/Desktop"
install -d -m 755 "$desktop_dir" "$DATA_DIR/applications"
for name in help ticket; do
    case $name in help) title='DebianZFS Help'; label=debianzfs-help ;; ticket) title='DebianZFS Ticket'; label=debianzfs-ticket ;; esac
    source_entry="$REPO_DIR/scripts/help-shortcuts/desktop-files/$label.desktop"
    icon="$REPO_DIR/scripts/help-shortcuts/pngs/$label.png"
    for destination in "$desktop_dir/$title.desktop" "$DATA_DIR/applications/$label.desktop"; do
        tmp=$(mktemp)
        sed "s|^Icon=.*|Icon=$icon|" "$source_entry" > "$tmp"
        if [[ $destination == "$desktop_dir/"* ]]; then install -m 755 "$tmp" "$destination"
        else install -m 644 "$tmp" "$destination"; fi
        rm -f -- "$tmp"
    done
done

install -d -m 755 "$CONFIG_DIR/xdg-desktop-portal"
portal_config="$CONFIG_DIR/xdg-desktop-portal/hyprland-portals.conf"
if [[ -e $portal_config || -L $portal_config ]]; then
    mkdir -p -- "$BACKUP_DIR"
    mv -- "$portal_config" "$BACKUP_DIR/hyprland-portals.conf"
fi
cat > "$portal_config" <<'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=gtk
EOF
for unit in pipewire.socket pipewire-pulse.socket; do
    install -d -m 755 "$CONFIG_DIR/systemd/user/sockets.target.wants"
    ln -sfn "/usr/lib/systemd/user/$unit" "$CONFIG_DIR/systemd/user/sockets.target.wants/$unit"
done
install -d -m 755 "$CONFIG_DIR/systemd/user/pipewire.service.wants"
ln -sfn /usr/lib/systemd/user/wireplumber.service \
    "$CONFIG_DIR/systemd/user/pipewire.service.wants/wireplumber.service"

mkdir -p -- "$STATE_DIR"
printf 'Configuration linked from %s. Run this script again after git pull to update links and shortcuts.\n' "$REPO_DIR"
