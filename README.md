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
