-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false },
})

-- 起動時に自動でプラグインをアップデート
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("lazy").sync({ show = false })
  end,
})

-- 初期化 色などはsetup引数で調整可能
local undo_glow = require('undo-glow')
undo_glow.setup()

-- u/Uでundo/redo
vim.keymap.set('n', 'u', undo_glow.undo, { desc = 'Undo with highlight' })
vim.keymap.set('n', 'U', undo_glow.redo, { desc = 'Redo with highlight' })

-- p/Pでペーストし、`]でペースト範囲の末尾へ飛ぶ
vim.keymap.set('n', 'p', function()
  undo_glow.paste_below()
  vim.cmd.normal({ args = { '`]' }, bang = true })
end, { desc = 'Paste below with highlight' })
vim.keymap.set('n', 'P', function()
  undo_glow.paste_above()
  vim.cmd.normal({ args = { '`]' }, bang = true })
end, { desc = 'Paste above with highlight' })
