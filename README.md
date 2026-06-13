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

### 3. パッケージをインストール

```sh
brew bundle --file=~/dotfiles/Brewfile
```

### 4. シンボリックリンクを貼る

```sh
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.gitignore_global ~/.gitignore_global
ln -sf ~/dotfiles/.config/wezterm ~/.config/wezterm
ln -sf ~/dotfiles/.config/mise ~/.config/mise
```

## Brewfile の更新

インストール済みパッケージを Brewfile に反映する。

```sh
brew bundle dump --force --file=~/dotfiles/Brewfile
```
