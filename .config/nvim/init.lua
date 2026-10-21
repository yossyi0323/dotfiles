vim.g.mapleader = " "

-- nvim-tree に置き換えるため netrw は読み込まない
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true
vim.opt.number = true

-- Neovim 0.12 組み込みのプラグインマネージャ。初回起動時に clone される
vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-tree/nvim-tree.lua",
})

require("nvim-tree").setup({
  view = { width = 32 },
  filters = { dotfiles = false },
  update_focused_file = { enable = true },
})

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "ファイルツリーの表示切替" })
vim.keymap.set("n", "<leader>f", "<cmd>NvimTreeFindFile<CR>", { desc = "ツリーで現在のファイルを表示" })

-- 背景を塗らず WezTerm の半透明背景をそのまま見せる。colorscheme を変えても維持する
local function clear_bg()
  for _, group in ipairs({
    "Normal", "NormalNC", "NormalFloat", "FloatBorder", "SignColumn",
    "EndOfBuffer", "LineNr", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill",
    "WinSeparator", "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeEndOfBuffer",
    "NvimTreeWinSeparator",
  }) do
    vim.api.nvim_set_hl(0, group, vim.tbl_extend("force",
      vim.api.nvim_get_hl(0, { name = group, link = false }), { bg = "NONE", ctermbg = "NONE" }))
  end
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_bg })
clear_bg()
