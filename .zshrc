export PATH="$HOME/.local/bin:$PATH"
alias c='pbcopy'
alias v='pbpaste'
export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/Brewfile"
export GHQ_ROOT="$HOME/src"

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(/opt/homebrew/bin/mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"
eval "$(starship init zsh)"

function ghq-fzf() {
  local selected_dir=$(ghq list -p | fzf --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N ghq-fzf
bindkey '^o' ghq-fzf

function br() {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" --max-depth 1 "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}

# 新規リポジトリ作成〜GitHub作成〜pushまで一撃
# usage: newrepo <name> [--private]   … ghq配下に新規作成してpush
#        newrepo [--private]          … カレントディレクトリ(moon new直後など)をそのままpush
function newrepo() {
  local name="" visibility="--public" arg user
  for arg in "$@"; do
    case "$arg" in
      --private|--public) visibility="$arg" ;;
      *) name="$arg" ;;
    esac
  done

  user=$(gh api user -q .login) || { echo "gh auth login が必要です" >&2; return 1; }

  if [ -n "$name" ]; then
    local dir="$(ghq root)/github.com/$user/$name"
    mkdir -p "$dir" && cd "$dir" || return 1
    [ -e README.md ] || echo "# $name" > README.md
  else
    name=$(basename "$PWD")
  fi

  [ -d .git ] || git init -b main
  git add -A
  git diff --cached --quiet || git commit -m "initial commit"
  gh repo create "$user/$name" "$visibility" --source=. --push
}

# moonbit
export PATH="$HOME/.moon/bin:$PATH"
