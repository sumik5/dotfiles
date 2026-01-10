vim.opt.clipboard = "unnamedplus"

-- 以下は LS から受け取ったエラーなどの診断情報を表示するのに必要
vim.diagnostic.config()

-- Leaderキーをスペースに設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true



vim.keymap.set('n', '<Leader>ee', ':NvimTreeToggle<CR>')

require("config.lazy")

require("mason").setup()
require("mason-lspconfig").setup()

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
