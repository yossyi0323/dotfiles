export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/Brewfile"
export GHQ_ROOT="$HOME/src"

# zsh補完システムを有効化(brew製コマンドgh/git等の補完もここで生きる)
autoload -Uz compinit && compinit

# Homebrewのprefixを検出(macOS Apple Silicon: /opt/homebrew, Linux/WSL: /home/linuxbrew/.linuxbrew)
if [[ -d /opt/homebrew ]]; then
  HOMEBREW_PREFIX=/opt/homebrew
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
fi
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"
eval "$(starship init zsh)"

#@ ghq | 素のghqのラッパー。get/create のあとに vault-mirror-repos を呼ぶ
#@+ Obsidian vault の src/ 配下に、ghqと同じ host/owner/repo のメモ置き場を自動で作る。
#@+ 他のサブコマンド (list, root, ...) は素のghqにそのまま流す。
function ghq() {
  command ghq "$@" || return $?
  case "$1" in
    get|create) vault-mirror-repos ;;
  esac
}

#@ Ctrl+O | ghq管理下のリポジトリをfzfで選んでcd (コマンドではなくキーバインド)
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

# --- g: 個人gitコマンド群のディスパッチャ ---
#@ g new <name> [--public] | 新規リポジトリをghq配下に作成→GitHub作成→push→その場にcd
#@+ デフォルトは private。公開したいときだけ --public を付ける。
#@+ 引数なし (g new) だとカレントディレクトリをghq配下に移動してから同じ処理をする。
#@+ moon new などツールがディレクトリを作った直後に使う用。
#@ g save [message] | git add -A → commit → push を一撃 (メッセージ省略時は "wip")
#@+ ステージ後に差分がなければ何もせず終了する。
#@ g help | g のサブコマンド一覧 (helpme g と同じ。g help commit などは git help に流れる)
#@ g | 引数なしだと git status -sb
#@ g <git-args> | 未知のサブコマンドは素の git に流す (g log, g diff, g push ...)
function g() {
  case "$1" in
    new)  shift; _g_new "$@" ;;
    save) shift; _g_save "$@" ;;
    help) if [ $# -eq 1 ]; then helpme g; else git "$@"; fi ;;
    "")   git status -sb ;;
    *)    git "$@" ;;
  esac
}
compdef g=git  # g にgitの補完を継承させる(g checkout <TAB> などが効く)

#@ gwt | リポジトリ本体(メインworktree)のルートにcd
#@ gwt <branch> | そのブランチのworktreeにcd (無ければ作ってからcd)
#@+ 置き場所は <リポジトリ>.worktrees/<ブランチ名> (ghq root 配下)。
#@+ ghq list に載るので Ctrl+O でも直接飛べる (Ctrl+O → pwc の流れがそのまま使える)。
#@+ ローカルに無いブランチ名を渡した場合、origin に同名があればそれを追跡し、
#@+ 無ければ現在のHEADから新規ブランチを作る。
function gwt() {
  local main
  main=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0, 10); exit}')
  if [[ -z "$main" ]]; then
    print -r -- "gwt: gitリポジトリの中で実行してください" >&2
    return 1
  fi

  if (( $# == 0 )); then
    cd "$main"
    return
  fi

  local branch="$1" existing
  # 既にそのブランチのworktree(本体含む)があるならそこへ移動するだけ
  existing=$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
    /^worktree /{ wt = substr($0, 10) }
    /^branch /  { if ($2 == b) { print wt; exit } }')
  if [[ -n "$existing" ]]; then
    cd "$existing"
    return
  fi

  local dir="${main}.worktrees/$branch"
  if [[ -e "$dir" ]]; then
    print -r -- "gwt: $dir が既にあります (worktreeとして登録されていません)" >&2
    return 1
  fi
  mkdir -p "${dir:h}" || return 1

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dir" "$branch" || return 1
  elif git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
    git fetch origin "$branch" || return 1
    git worktree add --track -b "$branch" "$dir" "origin/$branch" || return 1
  else
    git worktree add -b "$branch" "$dir" || return 1
  fi
  cd "$dir"
}

# gwt のブランチ名補完(ローカル + origin。origin/ は外して重複を除く)
function _gwt() {
  local -a branches
  branches=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes/origin 2>/dev/null | sed 's|^origin/||' | grep -v '^HEAD$' | sort -u)"})
  compadd -- $branches
}
compdef _gwt gwt

#@ pwc | カレントディレクトリの絶対パスをクリップボードにコピー (pwd | pbcopy)
function pwc() {
  print -rn -- "$PWD" | pbcopy && print -r -- "コピーしました: $PWD"
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
  vault-mirror-repos  # vault側にこのリポジトリのメモ置き場を作る
}

# --- awake/asleep: フタを閉じてもスリープさせない(リモート操作用) ---
#@ awake | スリープを完全に無効化 (フタを閉じてもリモートから触れる。要sudo)
#@+ 注意: awake中にカバンに入れると熱がこもるので、持ち運ぶ前に asleep すること。
#@ asleep | 通常のスリープ動作に戻す (要sudo)
function awake() {
  sudo pmset disablesleep 1 || return 1
  echo "スリープ無効化: フタを閉じても動き続けます(戻すには asleep)"
}

function asleep() {
  sudo pmset disablesleep 0 || return 1
  echo "スリープ有効化: 通常の動作に戻しました"
}

# --- helpme: 自作コマンドの一覧・詳細を出す ---
# 一覧の実体は .zshrc 内の "#@" 注釈。ヘルプ本文を別に持たないので実装とズレない。
#@ helpme [command] | 自作コマンドの一覧を表示 (引数を渡すとそのコマンドの詳細)
#@+ 一覧は ~/dotfiles/.zshrc の "#@" 注釈から生成している。
#@+ コマンドを追加したら、定義の真上に "#@ 使い方 | 説明" を1行足せばここに載る。
#@+ 補足を続けたいときは "#@+ 補足" を足す (この行自体がその例)。
function helpme() {
  local src="$HOME/dotfiles/.zshrc"
  if [[ ! -r "$src" ]]; then
    print -r -- "helpme: $src が読めません" >&2
    return 1
  fi

  if (( $# == 0 )); then
    print -r -- "自作コマンド一覧 ($src)"
    print -r -- ""
    awk '
      /^#@ / {
        line = substr($0, 4)
        n = index(line, " | ")
        if (n == 0) printf "  %s\n", line
        else        printf "  %-26s %s\n", substr(line, 1, n - 1), substr(line, n + 3)
      }
    ' "$src"
    print -r -- ""
    print -r -- "  詳細: helpme <コマンド名>  (例: helpme g new)"
    return 0
  fi

  local query="$*" out
  out=$(awk -v q="$query" '
    /^#@ / {
      line = substr($0, 4)
      n = index(line, " | ")
      usage = (n == 0) ? line : substr(line, 1, n - 1)
      desc  = (n == 0) ? ""   : substr(line, n + 3)
      hit = (usage == q || index(usage, q " ") == 1)
      if (hit) {
        printf "  %s\n", usage
        if (desc != "") printf "      %s\n", desc
      }
      next
    }
    /^#@\+ / { if (hit) printf "      %s\n", substr($0, 5); next }
    { hit = 0 }
  ' "$src")

  if [[ -z "$out" ]]; then
    print -r -- "helpme: '$query' に該当する自作コマンドはありません (一覧は helpme)" >&2
    return 1
  fi
  print -r -- "$out"
}

# moonbit
export PATH="$HOME/.moon/bin:$PATH"
