# WezTerm 設定

## ファイル構成

```
.config/wezterm/
├── wezterm.lua   # メイン設定
├── keybinds.lua  # キーバインド定義
└── keybinds.md   # キーバインド一覧（このドキュメント参照）
```

## 主な設定

### 外観

| 設定 | 値 |
|---|---|
| フォント | Menlo / Hiragino Kaku Gothic ProN / Monaco / Courier New |
| フォントサイズ | 12.0 |
| 背景透過 | 0.6（ぼかし強度 20） |
| タイトルバー | 非表示（RESIZE モード） |
| タブバー | タブが1つのときは非表示 |

### ファイラー

`Leader + e` で [broot](https://github.com/Canop/broot) を左側 25% の幅でトグル表示します。

### Leader キー

`Ctrl + q`（タイムアウト: 2000ms）

すべての Leader 系ショートカットはこのキーを先に押して起動します。

## キーバインド

詳細は [keybinds.md](./keybinds.md) を参照してください。

主なカテゴリ:
- **ワークスペース** — 作成・切り替え・リネーム
- **タブ** — 開閉・移動・並べ替え
- **ペイン** — 分割・移動・リサイズ・ズーム
- **コピーモード** — Vim 風カーソル操作・範囲選択・コピー
- **broot** — `Leader + e` でファイラーをトグル
