#!/usr/bin/env bash
set -Eeuo pipefail
set +x

[[ $EUID != 0 ]] || { echo 'Run this as your desktop user, without sudo.' >&2; exit 1; }
REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}
BACKUP_DIR="$STATE_DIR/debianzfs-config/backups/$(date +%Y%m%d-%H%M%S)-$$"

install -d -m 755 "$STATE_DIR/noctalia"
if [[ ! -e $STATE_DIR/noctalia/settings.toml ]]; then
    install -m 644 "$REPO_DIR/noctalia/settings.toml" "$STATE_DIR/noctalia/settings.toml"
fi
if [[ ! -e $CONFIG_DIR/noctalia/config.toml ]]; then
    install -d -m 755 "$CONFIG_DIR/noctalia"
    printf '%s\n' '[shell]' 'polkit_agent = true' > "$CONFIG_DIR/noctalia/config.toml"
fi

portal_dir="$CONFIG_DIR/xdg-desktop-portal"
portal_config="$portal_dir/hyprland-portals.conf"
portal_tmp=$(mktemp)
trap 'rm -f -- "$portal_tmp"' EXIT
cat > "$portal_tmp" <<'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=gtk
EOF
if ! cmp -s "$portal_tmp" "$portal_config"; then
    if [[ -e $portal_config || -L $portal_config ]]; then
        install -d -m 755 "$BACKUP_DIR"
        mv -- "$portal_config" "$BACKUP_DIR/hyprland-portals.conf"
    fi
    install -d -m 755 "$portal_dir"
    install -m 644 "$portal_tmp" "$portal_config"
fi

ensure_link() {
    local source_path=$1 destination=$2
    [[ -L $destination && $(readlink -- "$destination") == "$source_path" ]] ||
        ln -sfn -- "$source_path" "$destination"
}
for unit in pipewire.socket pipewire-pulse.socket; do
    install -d -m 755 "$CONFIG_DIR/systemd/user/sockets.target.wants"
    ensure_link "/usr/lib/systemd/user/$unit" "$CONFIG_DIR/systemd/user/sockets.target.wants/$unit"
done
install -d -m 755 "$CONFIG_DIR/systemd/user/pipewire.service.wants"
ensure_link /usr/lib/systemd/user/wireplumber.service \
    "$CONFIG_DIR/systemd/user/pipewire.service.wants/wireplumber.service"

printf 'Noctalia settings and user services configured.\n'
