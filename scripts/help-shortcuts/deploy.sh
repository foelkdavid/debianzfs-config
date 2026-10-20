#!/usr/bin/env bash
set -Eeuo pipefail
set +x
REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
[[ $EUID != 0 ]] || { echo 'Run this as your desktop user, without sudo.' >&2; exit 1; }
DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}
desktop_dir=$(xdg-user-dir DESKTOP 2>/dev/null || true)
[[ -n $desktop_dir ]] || desktop_dir="$HOME/Desktop"
install -d -m 755 "$desktop_dir" "$DATA_DIR/applications"

install_entry() {
    local source_entry=$1 destination=$2 mode=$3 icon=$4 temporary
    temporary=$(mktemp)
    sed "s|^Icon=.*|Icon=$icon|" "$source_entry" > "$temporary"
    if ! cmp -s "$temporary" "$destination"; then
        install -m "$mode" "$temporary" "$destination"
    fi
    rm -f -- "$temporary"
}

for item in 'help|DebianZFS Help|debianzfs-help' 'ticket|DebianZFS Ticket|debianzfs-ticket'; do
    IFS='|' read -r unused title label <<< "$item"
    source_entry="$REPO_DIR/scripts/help-shortcuts/desktop-files/$label.desktop"
    icon="$REPO_DIR/scripts/help-shortcuts/pngs/$label.png"
    install_entry "$source_entry" "$desktop_dir/$title.desktop" 755 "$icon"
    install_entry "$source_entry" "$DATA_DIR/applications/$label.desktop" 644 "$icon"
done
