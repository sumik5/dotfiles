vim.opt.clipboard = "unnamedplus"

-- 以下は LS から受け取ったエラーなどの診断情報を表示するのに必要
vim.diagnostic.config()

-- Leaderキーをスペースに設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set('n', '<Leader>ee', ':NvimTreeToggle<CR>')

require("config.lazy")

require("mason").setup()
require("mason-lspconfig").setup()
