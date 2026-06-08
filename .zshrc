export PATH="$HOME/.local/bin:$PATH"
alias c='pbcopy'
export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/Brewfile"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(/opt/homebrew/bin/mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"



