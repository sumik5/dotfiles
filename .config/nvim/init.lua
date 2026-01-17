vim.opt.clipboard = "unnamedplus"

--LS から受け取ったエラーなどの診断情報を表示するのに必要
--vim.diagnostic.config({ severity_sort = true })
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})

-- Leaderキーをスペースに設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.conceallevel = 2

require("config.lazy")

require('mason').setup()
require('mason-lspconfig').setup({
    automatic_enable = true
})

-- telescope ---------------------------------------------------------------------------------

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- undo-grow ---------------------------------------------------------------------------------

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

-- gitsigns  ---------------------------------------------------------------------------------

require('gitsigns').setup {}

require("nvim-treesitter").setup({})

--vim.api.nvim_create_autocmd('FileType', {
--  pattern = { '<filetype>' },
--  callback = function() vim.treesitter.start() end,
--})
