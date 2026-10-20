#!/usr/bin/env bash
set -Eeuo pipefail
set +x
REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
[[ $EUID != 0 ]] || { echo 'Run this as your desktop user, without sudo.' >&2; exit 1; }
DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
desktop_dir=$(xdg-user-dir DESKTOP 2>/dev/null || true)
[[ -n $desktop_dir ]] || desktop_dir="$HOME/Desktop"
user_dirs_file="$CONFIG_DIR/user-dirs.dirs"
install -d -m 755 "$CONFIG_DIR"
if [[ -f $user_dirs_file ]] && grep -q '^XDG_DESKTOP_DIR=' "$user_dirs_file"; then
    sed -i 's|^XDG_DESKTOP_DIR=.*|XDG_DESKTOP_DIR="$HOME/"|' "$user_dirs_file"
else
    printf '\nXDG_DESKTOP_DIR="$HOME/"\n' >> "$user_dirs_file"
fi
if [[ -d $desktop_dir ]]; then
    rm -f -- "$desktop_dir/DebianZFS Help.desktop" \
        "$desktop_dir/DebianZFS Ticket.desktop"
    rmdir -- "$desktop_dir" 2>/dev/null || true
fi
install -d -m 755 "$DATA_DIR/applications"

install_entry() {
    local source_entry=$1 destination=$2 mode=$3 icon=$4 temporary
    temporary=$(mktemp)
    sed "s|^Icon=.*|Icon=$icon|" "$source_entry" > "$temporary"
    if ! cmp -s "$temporary" "$destination"; then
        install -m "$mode" "$temporary" "$destination"
    fi
    rm -f -- "$temporary"
}

for label in debianzfs-help debianzfs-ticket; do
    source_entry="$REPO_DIR/scripts/help-shortcuts/desktop-files/$label.desktop"
    icon="$REPO_DIR/scripts/help-shortcuts/pngs/$label.png"
    install_entry "$source_entry" "$DATA_DIR/applications/$label.desktop" 644 "$icon"
done
