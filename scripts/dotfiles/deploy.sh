#!/usr/bin/env bash
set -Eeuo pipefail
set +x

[[ $EUID != 0 ]] || { echo 'Run this as your desktop user, without sudo.' >&2; exit 1; }
REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}
BACKUP_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/debianzfs-config/backups/$(date +%Y%m%d-%H%M%S)-$$

link_config() {
    local source_path=$1 destination=$2
    mkdir -p -- "$(dirname -- "$destination")"
    if [[ -L $destination && $(readlink -f -- "$destination" || true) == "$source_path" ]]; then return; fi
    if [[ -e $destination || -L $destination ]]; then
        mkdir -p -- "$BACKUP_DIR"
        mv -- "$destination" "$BACKUP_DIR/$(basename -- "$destination")"
    fi
    ln -s -- "$source_path" "$destination"
}

for config in alacritty gtk-3.0 hypr nvim zsh; do
    link_config "$REPO_DIR/dotfiles/$config" "$CONFIG_DIR/$config"
done
link_config "$REPO_DIR/dotfiles/zsh/zshrc" "$HOME/.zshrc"
link_config "$REPO_DIR/dotfiles/zsh/zprofile" "$HOME/.zprofile"

if [[ ${DEBIANZFS_SKIP_OPTIONAL_ASSETS:-false} != true ]]; then
    plugin_dir="$DATA_DIR/zsh/plugins"
    work_dir=$(mktemp -d)
    trap 'rm -rf -- "$work_dir"' EXIT
    install -d -m 755 "$plugin_dir"
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if [[ ! -d $plugin_dir/$plugin ]]; then
            git clone --depth 1 "https://github.com/zsh-users/$plugin.git" "$work_dir/$plugin"
            mv -- "$work_dir/$plugin" "$plugin_dir/$plugin"
        fi
    done
    if [[ ! -d $plugin_dir/gitfast ]]; then
        git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$work_dir/ohmyzsh"
        cp -R -- "$work_dir/ohmyzsh/plugins/gitfast" "$plugin_dir/gitfast"
    fi
fi

printf 'Dotfiles linked from %s/dotfiles.\n' "$REPO_DIR"
