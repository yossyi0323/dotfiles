#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Homebrew packages..."
brew update
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "==> Registering login items..."
if ! osascript -e 'tell application "System Events" to get the name of every login item' | grep -q "ActivityWatch"; then
  osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/ActivityWatch.app", hidden:false}'
fi

echo "==> Creating symlinks..."
mkdir -p ~/.config/broot
mkdir -p ~/.config/herdr
mkdir -p ~/.claude/skills

ln -sf "$DOTFILES_DIR/.zshrc"                        ~/.zshrc
ln -sf "$DOTFILES_DIR/.gitconfig"                    ~/.gitconfig
ln -sf "$DOTFILES_DIR/.gitignore_global"             ~/.gitignore_global
ln -sf "$DOTFILES_DIR/.config/wezterm"               ~/.config/wezterm
ln -sf "$DOTFILES_DIR/.config/mise"                  ~/.config/mise
ln -sf "$DOTFILES_DIR/.config/broot/conf.hjson"      ~/.config/broot/conf.hjson
ln -sf "$DOTFILES_DIR/.config/starship.toml"         ~/.config/starship.toml
ln -sf "$DOTFILES_DIR/.config/herdr/config.toml"     ~/.config/herdr/config.toml
ln -sf /opt/homebrew/opt/hunk/libexec/skills/hunk-review ~/.claude/skills/hunk-review

echo "Done! Restart your shell to apply changes."
