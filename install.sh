#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

host="${1:-}"
case "$host" in
  ori) pkglist=pkglist.txt ;;
  cora) pkglist=hosts/cora/pkglist.txt ;;
  *) echo "usage: $0 ori|cora" >&2; exit 1 ;;
esac

sudo pacman -S --needed - < "$pkglist"

if [ -d "hosts/$host/etc" ]; then
  find "hosts/$host/etc" -type f | while read -r src; do
    sudo install -D -m 644 "$src" "/${src#hosts/$host/}"
  done
  sudo systemctl daemon-reload
fi

if command -v sshd >/dev/null; then
  sudo sshd -t
fi
