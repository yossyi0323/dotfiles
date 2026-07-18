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
