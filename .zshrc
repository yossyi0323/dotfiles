
export PATH="$HOME/.local/bin:$PATH"
alias c='pbcopy'

# Brewfileの自動アップデート（zsh終了時に実行）
update_brewfile() {
  # 念のためdotfilesディレクトリが存在するかチェック
  if [ -d "$HOME/dotfiles" ]; then
    # バックグラウンドで静かにdumpを実行（エラー出力は捨てる）
    brew bundle dump --global --force 2>/dev/null &
  fi
}

# zshのフック関数機能を有効化（add-zsh-hook を使うために必須）
autoload -Uz add-zsh-hook

# zshが終了する直前に実行される特殊なフック関数に登録
add-zsh-hook zshexit update_brewfile

export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/Brewfile"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

