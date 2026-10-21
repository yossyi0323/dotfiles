-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 起動時にファイルツリー (Space e と同じもの) を開く。ファイル指定時はカーソルをファイル側に残す
-- このファイルは引数なしだと VimEnter 後 (VeryLazy) に、ファイル指定時は起動途中に読まれるので両方に対応する
local function open_explorer()
  -- `nvim .` だと snacks がディレクトリを開いた時点で explorer を出しているので重ねて呼ばない
  if #Snacks.picker.get({ source = "explorer" }) > 0 then
    return
  end
  local file = vim.fn.argv(0)
  Snacks.explorer({ focus = (file == "" or vim.fn.isdirectory(file) == 1) and "list" or false })
end
if vim.v.vim_did_enter == 1 then
  vim.schedule(open_explorer)
else
  vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = vim.schedule_wrap(open_explorer) })
end
