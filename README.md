# dotfiles

## セットアップ

### 1. Homebrew をインストール

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/homebrew/install/HEAD/install.sh)"
```

### 2. リポジトリをクローン

```sh
git clone https://github.com/yossyi0323/dotfiles.git ~/dotfiles
```

### 3. セットアップを実行

```sh
~/dotfiles/install.sh
```

パッケージのインストールとシンボリックリンクの作成を自動で行う。

## 自作コマンド

`.zshrc` で定義している自作コマンドは `helpme` で一覧できる。

```sh
helpme          # 一覧(説明付き)
helpme g new    # 個別の詳細
```

一覧はヘルプ本文を別に持たず、`.zshrc` 内の `#@` 注釈から生成している。コマンドを追加したら、定義の真上に1行足せばそのまま載る。

```sh
#@ 使い方 | 短い説明
#@+ 補足説明(複数行書ける。helpme <コマンド名> のときだけ表示される)
```

使い方の部分は桁揃えのため ASCII で書く(日本語は説明側に書く)。

## Brewfile の更新

インストール済みパッケージを Brewfile に反映する。

```sh
brew bundle dump --force --file=~/dotfiles/Brewfile
```

## 手動インストールが必要なアプリ

Homebrew では管理できないため、手動でインストールすること。

| アプリ | 入手先 |
| --- | --- |
| Kindle | Mac App Store |

activitywatch は Intel-only ビルドのため Rosetta 2 が必要。一度入れると公式のアンインストール手段が無いため、自動化はせず手動でインストールする。

```sh
softwareupdate --install-rosetta --agree-to-license
```

## Codex を Claude Code と同じ設定で動かす

Claude Code と Codex を併用している。指示・メモリ・スキル・権限の考え方を Codex 側にも揃える。

| Claude Code | Codex | 方法 |
| --- | --- | --- |
| `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | symlink (`install.sh`) |
| リポジトリの `CLAUDE.md` | 同じファイル | `project_doc_fallback_filenames = ["CLAUDE.md"]` |
| `~/.claude/projects/*/memory/` | 同じディレクトリを読み書き | SessionStart フック `codex/hooks/claude-memory.sh` |
| `~/.claude/skills/hunk-review` | `~/.agents/skills/hunk-review` | symlink (`install.sh`) |
| auto モード | `approvals_reviewer = "auto_review"` | `config.toml` |
| `effortLevel: high` | `model_reasoning_effort = "high"` | `config.toml` |
| claude.ai コネクタ | Codex プラグイン | gmail / google-calendar / google-drive / slack / linear / supabase / vercel / mermaid-diagrams |

`~/.codex/config.toml` は Codex アプリがバージョン番号やパスを書き換えるため symlink にせず、以下を手で入れる:

```toml
model_reasoning_effort = "high"
approval_policy = "on-request"
approvals_reviewer = "auto_review"
sandbox_mode = "workspace-write"
project_doc_fallback_filenames = ["CLAUDE.md"]

[features]
hooks = true

[sandbox_workspace_write]
network_access = true
```

リポジトリ内のディレクトリ名を `.codex/` にしないこと。dotfiles 自体が Codex の信頼済みプロジェクトなので、`.codex/hooks.json` だとプロジェクト用フックとしても読まれ、ここで作業するときにメモリが二重に渡される。

手動ステップ:

1. Codex CLI で `/hooks` を開き、`claude-memory.sh` を信頼する。Codex はフックの中身のハッシュで信頼を記録するので、未承認のフックや中身を変えたフックは実行されない（＝メモリが渡らない）。スクリプトを編集したらもう一度承認が必要
2. プラグインのうち Linear / Mermaid は Codex アプリ側で各サービスへのログインが必要

## iPhone Screen Time の ActivityWatch 連携 (aw-import-screentime)

以下は `install.sh` では自動化できないため手動セットアップが必要。

1. リポジトリをクローンして `uv sync`
   ```sh
   git clone https://github.com/ActivityWatch/aw-import-screentime.git ~/src/github.com/ActivityWatch/aw-import-screentime
   cd ~/src/github.com/ActivityWatch/aw-import-screentime && uv sync
   ```
2. iOS/macOS 両方で「デバイス間で共有」(Screen Time の設定)をON にする
3. **システム設定 → プライバシーとセキュリティ → フルディスクアクセス** で、uv が管理する python バイナリを許可する(`~/.local/share/uv/python/cpython-*/bin/python3.13` 相当。バージョンは変わりうるので `readlink -f .venv/bin/python` で確認)
   - これをやらないと `~/Library/Biome/sync/sync.db` が読めず `unable to open database file` エラーで launchd ジョブが起動失敗する
4. `install.sh` で `LaunchAgents/com.yossyi0323.aw-import-screentime.plist` がシンボリックリンク＆ロードされ、以後は常駐して自動同期される
   - 手動でロードし直す場合: `launchctl load -w ~/Library/LaunchAgents/com.yossyi0323.aw-import-screentime.plist`
   - ログ: `~/Library/Logs/aw-import-screentime.log` / `.err.log`

## iPhone のリアルタイム在席通知 (aw-phone-heartbeat)

`aw-where` は「今 Mac の前にいるか / スマホを触っているか」を判定するコマンド(`bin/aw-where`)。
Mac 側は ActivityWatch の afk/window バケットを見るので即時だが、スマホ側は Screen Time
インポートだけだと Apple が Screen Time DB に書き込むタイミング(数分〜十数分おき)の分だけ遅れる。

そこで iOS ショートカットのオートメーションから iCloud Drive に1行のファイルを書かせ、
`aw-where` がそれを優先して読む。遅延は iCloud 同期ぶん(数秒〜1分程度)まで縮む。
ショートカットは iPhone 側の GUI 操作でしか作れないため手動セットアップ。

書き込み先: `~/Library/Mobile Documents/com~apple~CloudDocs/aw-phone-heartbeat.txt`
内容: `open <アプリ名>` または `closed <アプリ名>` の1行のみ(毎回上書き)

### iPhone 側の手順

1. ショートカット App → 「ショートカット」タブで新規作成。名前は `phone-heartbeat-open`
   1. アクション「テキスト」を追加し、本文に `open ` と入れる(末尾にショートカット入力の
      アプリ名変数を続けると、どのアプリを開いたか分かる)
   2. アクション「ファイルを保存」を追加。保存先を iCloud Drive の最上位、
      ファイル名を `aw-phone-heartbeat.txt`、**「保存先を尋ねる」をOFF**、
      **「既存ファイルを上書き」をON** にする
2. 同じ手順で `closed ` 版のショートカット `phone-heartbeat-closed` を作る
3. 「オートメーション」タブ → 新規 → **App** を選択
   - 対象アプリ: 普段使うものを複数選ぶ(YouTube, Chrome, X など)
   - 「開かれたとき」→ `phone-heartbeat-open` を実行、**「実行前に尋ねる」をOFF**
   - もう1つ作って「閉じられたとき」→ `phone-heartbeat-closed`、同じくOFF
4. Mac 側で確認する

   ```sh
   aw-where            # phone 行の source が heartbeat になっていればOK
   ```

heartbeat ファイルが無い場合は自動で Screen Time にフォールバックするので、
セットアップしなくても `aw-where` 自体は動く。
