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
mkdir -p ~/.config/herdr
mkdir -p ~/.claude/skills
mkdir -p ~/Library/LaunchAgents
mkdir -p ~/.local/bin
mkdir -p ~/.codex/hooks
mkdir -p ~/.agents/skills

ln -sf "$DOTFILES_DIR/.zshrc"                        ~/.zshrc
ln -sf "$DOTFILES_DIR/.gitconfig"                    ~/.gitconfig
ln -sf "$DOTFILES_DIR/.gitignore_global"             ~/.gitignore_global
ln -sf "$DOTFILES_DIR/.config/wezterm"               ~/.config/wezterm
ln -sf "$DOTFILES_DIR/.config/nvim"                ~/.config/nvim
ln -sf "$DOTFILES_DIR/.config/mise"                  ~/.config/mise
ln -sf "$DOTFILES_DIR/.config/starship.toml"         ~/.config/starship.toml
ln -sf "$DOTFILES_DIR/.config/herdr/config.toml"     ~/.config/herdr/config.toml
ln -sf "$DOTFILES_DIR/bin/aw-where"                   ~/.local/bin/aw-where
ln -sf "$DOTFILES_DIR/bin/vault-mirror-repos"         ~/.local/bin/vault-mirror-repos
ln -sf /opt/homebrew/opt/hunk/libexec/skills/hunk-review ~/.claude/skills/hunk-review
ln -sfn /opt/homebrew/opt/hunk/libexec/skills/hunk-review ~/.agents/skills/hunk-review
ln -sf "$DOTFILES_DIR/shared/instructions.md"        ~/.claude/CLAUDE.md
ln -sf "$DOTFILES_DIR/shared/instructions.md"        ~/.codex/AGENTS.md
ln -sf "$DOTFILES_DIR/codex/hooks.json"              ~/.codex/hooks.json
ln -sf "$DOTFILES_DIR/codex/hooks/claude-memory.sh"  ~/.codex/hooks/claude-memory.sh
ln -sf "$DOTFILES_DIR/LaunchAgents/com.yossyi0323.aw-import-screentime.plist" ~/Library/LaunchAgents/com.yossyi0323.aw-import-screentime.plist

echo "==> Loading LaunchAgents..."
echo "  NOTE: aw-import-screentime requires manual setup first - see README.md"
launchctl load -w ~/Library/LaunchAgents/com.yossyi0323.aw-import-screentime.plist 2>/dev/null || true

echo "Done! Restart your shell to apply changes."
