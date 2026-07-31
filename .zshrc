export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
alias c='pbcopy'
alias v='pbpaste'
export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/Brewfile"
export GHQ_ROOT="$HOME/src"

# zsh補完システムを有効化(brew製コマンドgh/git等の補完もここで生きる)
autoload -Uz compinit && compinit

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

# --- g: 個人gitコマンド群のディスパッチャ ---
# g new <name> [--public] … 新規リポジトリをghq配下に作成し、GitHub作成〜pushまで一撃(デフォルトprivate)
# g new [--public]        … カレントディレクトリ(moon new直後など)をghq配下に移動してpush
# g save [メッセージ]       … git add -A → commit → push を一撃(メッセージ省略時は "wip")
# g <その他>               … そのまま git に流す(g status, g log なども使える)
function g() {
  case "$1" in
    new)  shift; _g_new "$@" ;;
    save) shift; _g_save "$@" ;;
    help) if [ $# -eq 1 ]; then _g_help; else git "$@"; fi ;;
    "")   git status -sb ;;
    *)    git "$@" ;;
  esac
}
compdef g=git  # g にgitの補完を継承させる(g checkout <TAB> などが効く)

function _g_help() {
  cat <<'EOF'
g — 個人gitコマンド集 (dotfiles/.zshrc で定義)

  g new <name> [--public]    新規リポジトリをghq配下に作成 → GitHub作成 → push → その場にcd
  g new [--public]           カレントディレクトリをghq配下に移動 → commit → GitHub作成 → push
                             (デフォルトはprivate。公開したいときだけ --public)
                             (moon new などツールがディレクトリを作った直後に使う)
  g save [メッセージ]         git add -A → commit → push を一撃 (メッセージ省略時は "wip")
  g help                     このヘルプを表示 (g help commit などは git help に流れる)
  g                          git status -sb
  g <その他>                 そのまま git に流す (g log, g diff, g push など)

  git自体のヘルプ: g --help (コマンド一覧) / g help <コマンド> (マニュアル)
EOF
}

function _g_save() {
  git add -A || return 1
  if git diff --cached --quiet; then
    echo "変更なし(コミットするものがありません)"
    return 0
  fi
  git commit -m "${1:-wip}" && git push
}

function _g_new() {
  local name="" visibility="--private" arg user
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
    local dir="$(ghq root)/github.com/$user/$name"
    if [ "$PWD" != "$dir" ]; then
      if [ -e "$dir" ]; then
        echo "移動先 $dir が既に存在します" >&2
        return 1
      fi
      mkdir -p "${dir:h}" && mv "$PWD" "$dir" && cd "$dir" || return 1
      echo "→ $dir に移動しました"
    fi
  fi

  [ -d .git ] || git init -b main
  git add -A
  git diff --cached --quiet || git commit -m "initial commit"
  gh repo create "$user/$name" "$visibility" --source=. --push
}

# --- awake/asleep: フタを閉じてもスリープさせない(リモート操作用) ---
# awake  … スリープを完全に無効化(フタを閉じてもリモートから触れる)。要sudo
# asleep … 通常のスリープ動作に戻す。要sudo
# 注意: awake中はカバンに入れると熱がこもるので、持ち運ぶ前に asleep すること
function awake() {
  sudo pmset disablesleep 1 || return 1
  echo "スリープ無効化: フタを閉じても動き続けます(戻すには asleep)"
}

function asleep() {
  sudo pmset disablesleep 0 || return 1
  echo "スリープ有効化: 通常の動作に戻しました"
}

# moonbit
export PATH="$HOME/.moon/bin:$PATH"
