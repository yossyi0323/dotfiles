#!/bin/bash
# Codex SessionStart hook: Claude Code と同じ指示・メモリで Codex を動かすための文脈を注入する。
# ~/.claude/CLAUDE.md は ~/.codex/AGENTS.md の symlink で読まれるので、ここでは
# Claude 固有の読み替えと、cwd に対応する Claude のプロジェクトメモリを渡す。

cwd=$(jq -r '.cwd // empty' 2>/dev/null)
[ -z "$cwd" ] && cwd=$PWD

# Claude はプロジェクトディレクトリの英数字以外を "-" に置換してメモリの置き場所にする
memdir_for() { echo "$HOME/.claude/projects/$(printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g')/memory"; }

memdir=$(memdir_for "$cwd")
if [ ! -f "$memdir/MEMORY.md" ]; then
  root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  [ -n "$root" ] && memdir=$(memdir_for "$root")
fi

cat <<MSG
# Claude Code と共通の設定で動く

このユーザーは Claude Code と Codex を併用している。AGENTS.md として読み込まれた ~/.claude/CLAUDE.md
（およびリポジトリの CLAUDE.md）は Codex にもそのまま適用される。Claude 固有の機能名は Codex の対応機能で読み替える:
AskUserQuestion → ユーザーへの質問, Agent/サブエージェント → Codex のサブエージェント, Skill → Codex のスキル,
claude.ai の MCP コネクタ (Gmail/Calendar/Drive/Slack/Linear/Supabase/Vercel/Mermaid) → 同名の Codex プラグイン,
Co-Authored-By などの Claude 用コミット署名は付けない。「別セッションの起動」節は Claude Code 専用なので Codex では使わない。

## メモリ（Claude Code と共有）

メモリディレクトリ: $memdir
1ファイル1事実。frontmatter は name / description / metadata.type (user|feedback|project|reference)。
feedback/project は本文の後に **Why:** と **How to apply:** を書く。関連メモリは [[name]] でリンク。
書いたら MEMORY.md に \`- [Title](file.md) — 一行の要約\` を1行足す。既存ファイルで足りるなら更新し、重複を作らない。
個々のファイルは関連しそうなときに読む。以下は現時点の MEMORY.md:

MSG

if [ -f "$memdir/MEMORY.md" ]; then
  cat "$memdir/MEMORY.md"
else
  echo "(このプロジェクトのメモリはまだ無い。書くときは上のディレクトリを作って置く)"
fi
