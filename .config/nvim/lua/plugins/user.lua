return {
  -- 背景を塗らず WezTerm の半透明背景をそのまま見せる
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
    },
  },

  -- スタート画面の LazyVim のアスキーアートを出さない。
  -- header = "" だと空行と余白が残るので、header のセクションごと外す。
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
