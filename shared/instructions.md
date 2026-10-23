# Global instructions (all projects)

This file loads for every session regardless of working directory. Use it for standing rules that apply across projects — the per-project `memory/` directories under `~/.claude/projects/*/memory/` are scoped to whichever directory a session started in, so anything genuinely cross-cutting belongs here instead, not just in whichever project happened to be open when it was taught.

## 二度と使わない言葉

ユーザーが明示的に「2度と言わないでほしい」と指定した語。言い換えて同じことを言うのも不可。

- **「とりあえず効く」「効く」** — 動いた/有効になった、の意味では使わない。何がどう変わったのかを具体的に書く。
- **「結線」** — 配線・接続の比喩として使わない。何と何をどうつないだのかを具体的に書く。
- **「とりあえず」** — 曖昧なエクスキューズとして使わない。暫定なら、何が未完で次に何をするのかを明示する。
- **「根っこ」** — 原因や本質を指す比喩として使わない。「根本」「本質的には」などの言い換えも同様。何が原因なのかを直接書く。

## 物理的な状況の確認（ActivityWatch）— 必要なときだけ

**毎ターンは実行しない。** ターミナルで対話している最中は、ユーザーが Mac の前にいるのは
自明（CLI に打ち込んでいる本人がいる）なので、確認する価値がない。チェックが答えを変えない
場面で `aw-where` を叩くのは、ユーザーが明示的に嫌だと言ったノイズ。

実行してよいのは、居場所が出力の形を実際に変える場面だけ:
- こちらから能動的に話しかける / 通知・リマインドを出すとき（相手が席にいるか分からない）
- 返答が途切れて時間が経ち、スマホに移ったかどうかで返し方を変えたいとき
- ユーザー自身が居場所・活動ログ・時間の使い方について聞いてきたとき
- 「今日何してた」の再構成など、ログがそもそも調査対象のとき

迷ったら実行しない。聞き返すのではなく、Mac の前にいる前提で普通に返す。

```sh
aw-where          # 人が読む形式
aw-where --json   # 機械処理用
```

`~/dotfiles/bin/aw-where`。ActivityWatch の afk/window バケットと、iPhone 側の heartbeat
（iOS ショートカットが iCloud Drive に書くファイル。無ければ Screen Time にフォールバック）を見て、
1行目に `where: AT_MAC | LOCKED | ON_PHONE | AWAY` を出す。ActivityWatch の生 API を
直接叩く必要はない（叩くならタイムスタンプは UTC なので +9h して JST にしてから「今」と比較する）。

出力に応じた振る舞い:
- **AT_MAC** — Mac の前にいる。長い出力・コード・ファイルパス・コマンド提示をしてよい。
  同時にスマホも触っている場合は phone 行に出るので、込み入った話は後回しにする。
- **ON_PHONE** — スマホを触っている。短文で返す。コードブロック・ファイルパス・
  「このコマンドを実行して」は出さない。読むだけで完結する内容にする。
- **LOCKED / AWAY** — 席を外している。すぐの返事は期待しない前提で、短く用件だけ置く。

精度の限界: heartbeat がある場合の遅延は iCloud 同期ぶん（数秒〜1分）。heartbeat が無く
`source: ScreenTime` になっている場合は、Apple が Screen Time DB に書くのが数分〜十数分
まとめてなので、その分だけ必ず遅れる。「今まさにスマホを触っている」の判定には弱いので、
ON_PHONE が ScreenTime 由来のときは断定しない。セットアップ手順は dotfiles の README.md。

## Git: personal repos owned by this user (yossyi0323)

For repos this user solely owns — `~/dotfiles`, `self-management`, etc. — once an edit's content has been evident from the conversation (discussed, shown, or explicitly requested), just do the full cycle: edit → commit → push, no confirmation step at any point, then report after the fact ("pushしておきました"). Do not ask "コミットしますか?" or "pushしますか?" first — the user has explicitly said this is unwanted friction on their own repos.

- The line is **main/protected branch vs. feature/dev branch**, not "personal vs. project repo." Direct pushes to `main` still warrant normal care in repos with a PR-gated process (e.g. `self-management` follows Issue → branch → PR → review per its own CLAUDE.md). Pushing to a feature/fix branch is just as free as dotfiles — no confirmation needed.
- Scope guard: this autonomy applies only when the user (yossyi0323) is the actual owner — never extend it to someone else's personal/dotfiles repo just because it looks the same pattern (their explicit words: "他人のdotfilesとかにもやるなよ！？当たり前だけど").
- Full history/rationale: see `feedback_git_commit_push_repo_scope` in the `self-management` project's memory.

## Dotfiles (`~/dotfiles`)

Public repo, no secrets. When installing a new CLI/tool/LaunchAgent/config for this user on this Mac, register it in `~/dotfiles` in the same turn as the change (Brewfile entry, `.config/<tool>/` + symlink in `install.sh`, or a `LaunchAgents/*.plist` + symlink+load in `install.sh`), commit, and push — see the git-push rule above. Don't wait to be asked. Manual/GUI-only steps that can't be scripted (e.g. macOS Full Disk Access grants) go in `README.md` as a numbered step with the reason, so the failure mode is documented instead of rediscovered.

## Investigating "what did I do" / activity review

When asked to reconstruct or summarize past activity for some time period, don't rely on any single source (especially not just Obsidian notes, which are frequently left blank). Cross-check:
- **ActivityWatch** — local REST API `http://localhost:5600/api/0/buckets/` (trailing slash needed). Buckets on this Mac: `aw-watcher-afk_*` (away/present), `aw-watcher-window_*` (per-app/title timeline), `aw-import-screentime_ios_*` (iPhone Screen Time, imported by a separate always-running watcher — see below).
- **Gmail** (`search_threads` with `after:`/`before:` date queries) — receipts/notifications independently pin down timing.
- **Obsidian vault** notes as a secondary source, not the primary one.

The iPhone Screen Time sync depends on `aw-import-screentime watch` actually running continuously — it's registered as LaunchAgent `com.yossyi0323.aw-import-screentime` (see `~/dotfiles/LaunchAgents/`), which requires Full Disk Access granted to the uv-managed python binary (`~/.local/share/uv/python/cpython-*/bin/python3.13` — path changes with uv's python version, re-check via `readlink -f .venv/bin/python` in the `aw-import-screentime` checkout if sync goes stale again).

## When a preference feels like it "should" already be known

If the user says "I told you this before" about something not in the current project's memory, treat that as true rather than as a false claim — check sibling project memory dirs (`ls ~/.claude/projects/*/memory/`) before concluding it's genuinely new. Memory being project-scoped means a real prior instruction can legitimately be invisible from wherever the current session happens to be. Cross-cutting instructions found this way should get pulled up into this file so the gap doesn't recur.

## 別セッションの起動（Remote Control 付き）

エージェントセッションの中からでも新しいセッションは起動できる。TTY がないので
`claude --remote-control` 単体はハングするが、`--bg` と併用すればデタッチして即戻る。

```sh
cd <起動したいディレクトリ> && claude --bg --remote-control
```

- 起動直後に短い id（例 `7e9d0203`）が出る。これが `attach` / `logs` / `stop` / `rm` の引数
- Remote Control が効いているかは `claude logs <id>` で確認する。
  `/remote-control is active · ... https://claude.ai/code/session_XXXX` の行が出ていれば、
  その URL からスマホや他デバイスで同じセッションを続けられる
- 一覧は **`claude agents --json`**。素の `claude agents` は stdout が TTY でないと失敗する
- `--remote-control <name>` に名前を positional で渡しても反映されなかった（セッション名が
  短い id のまま）。名前を付けたいときは `--remote-control-session-name-prefix <prefix>` を使う
- 起動済みセッションへは `ListAgents` で見えるので `SendMessage` で指示を投げられる

## リポジトリ配置 (ghq / `~/src`)

ghq root は `~/src`、配置は `~/src/<host>/<owner>/<repo>`。生きた一覧は `ghq list` が正で、
以下は「それぞれが何であるか」の対応表。`g new` / `ghq get` でリポジトリが増えたらここに1行足す。

Obsidian 側には `obsidian-vault/src/<host>/<owner>/<repo>/` に同じ階層のメモ置き場があり、
`vault-mirror-repos`（`ghq get` / `g new` から自動で呼ばれる）が作る。各リポジトリでの
作業メモはそこに書く。

### 自分のもの（`github.com/yossyi0323/`）

| repo | 何であるか |
|---|---|
| `self-management` | Google カレンダーの Plan / Do を読み書きする Next.js アプリ。自分のアプリの中では一番動いているもの。Issue → ブランチ → PR → レビューの運用がリポジトリ内の `CLAUDE.md` に書いてあるので、触る前に必ず読む。最終コミット 2026-09-10、`fix/issue-129` に出たまま |
| `my-assistant` | push 型の秘書（Go）。Obsidian の Periodic Notes / Notes と カレンダーの Plan / Do を AI が横断して読み、「次はこれ」と声をかけてくる。実装は入り口だけで、README が実質の仕様書 |
| `mytime` | 分単位で計画・実行・記録をする時間管理ツールの構想。README だけでコードはない（README 自身が「構想段階」と書いている） |
| `obsidian-vault` | Obsidian の vault 本体。`README.md` と `Obsidian Vault Structure.md` に全体像がまとまっているので、vault を探すときはまずそこ |
| `dotfiles` | この Mac の設定。実体は `~/dotfiles` で、`~/src/github.com/yossyi0323/dotfiles` はそこへのシンボリックリンク |
| `decision` | ディシジョンテーブルのツール（Go）。YAML のスキーマと TSV / CSV / Markdown の表を読んで検証し、Go コードを生成する |
| `App` | 個人開発のモノレポ（`RestaurantApp`, `ParallelCalendar`, `cooking-cycle`, `GAS`, `Tools`, `experiments`）。2026-06 以降止まっている。`App/SelfManagement` は `self-management` の元の置き場で、現役はスタンドアロン側 |
| `gogrid` | Go のジェネリクスで簡易キーバリューテーブルを書いた練習。2コミット |
| `topcoat-playground` | Rust の TopCoat（GUI）+ SQLite で TODO アプリを書いたお試し |
| `moon-sample` | MoonBit のサンプルを少し触ったもの |
| `lng` | `go.mod` だけの空リポジトリ。名前を押さえただけで中身はない |

### 他人のもの

| repo | 何であるか |
|---|---|
| `ActivityWatch/aw-import-screentime` | iPhone の Screen Time を ActivityWatch に取り込むツール。自分のコミットはない（upstream をそのまま clone）。LaunchAgent `com.yossyi0323.aw-import-screentime` で常駐させて実際に使っている |
| `vuejs/vitepress` | 参照用に置いてある upstream の clone。手は入れていない |

### worktree

`gwt <branch>` が作る worktree は `<リポジトリ>.worktrees/<ブランチ名>`（ghq root 配下なので
`ghq list` にも載る）。`self-management-worktrees/`（ハイフン）は古い命名の残骸で、中身は空。

## 本人の時間を奪わない・依頼はきちんと説明する

2026-10-23 のmy-assistant反映で、「反映して」と言われた後に、許可待ちで止まる待機コマンドを出し、遅れの原因を確かめずに間違った説明をし、「続けてよいですか」と聞き直した。本人の言葉：「人間の時間を奪うな」「俺に何かしてほしければちゃんと説明して依頼してくれればやるから」。

- 実行の許可をもらった作業は、最後まで聞き直さずに進める。
- 状態の確認は1回で終わるコマンドで行う。許可が要りそうな長い待機ループを出さない。
- 止まった・遅れたときは、原因を確かめてから説明する。推測を事実として言わない。
- 自分の権限でできない操作に当たったら、回避策を探して時間を使わず、すぐ本人に依頼する。依頼には、何のために・何が起きるか・打つコマンドそのもの・終わったら何と返せばよいかを書く。
- 画面での操作を頼むときは、その設定画面を直接開けるURLを最初から書く。「〇〇の設定画面で」のように場所だけを言葉で伝えない。
