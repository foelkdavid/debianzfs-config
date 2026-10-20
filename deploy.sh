#!/usr/bin/env bash
set -Eeuo pipefail
set +x

[[ $EUID != 0 ]] || { echo 'Run this as your desktop user, without sudo.' >&2; exit 1; }
REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

for component in dotfiles noctalia help-shortcuts; do
    bash "$REPO_DIR/scripts/$component/deploy.sh"
done

if [[ ${DEBIANZFS_SKIP_OPTIONAL_ASSETS:-false} != true ]]; then
    bash "$REPO_DIR/scripts/fonts/deploy.sh"
fi

printf 'DebianZFS configuration deployed from %s.\n' "$REPO_DIR"
