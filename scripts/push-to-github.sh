#!/bin/zsh

set -euo pipefail

REPO_DIR="/Users/xiaoshu/Desktop/test/BabeGame"
REMOTE_URL="git@github.com:luowenxi76-coder/BabeGame.git"

cd "$REPO_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This folder is not a git repository yet." >&2
  exit 1
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

git push -u origin main
