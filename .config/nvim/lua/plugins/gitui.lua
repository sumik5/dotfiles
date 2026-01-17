return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        direction = "float", -- 浮動ウィンドウで表示
        float_opts = {
          border = "curved",
        },
      })

      -- gitui 起動用の関数を定義
      local Terminal = require("toggleterm.terminal").Terminal
      local gitui = Terminal:new({
        cmd = "gitui",
        hidden = true,
        direction = "float",
        -- 閉じた時にバッファを削除
        on_open = function(term)
          vim.cmd("startinsert!")
          -- ターミナル内でのキー操作設定（任意）
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
      })

      function _gitui_toggle()
        gitui:toggle()
      end

      -- キーマッピング (例: <leader>gg)
      vim.keymap.set("n", "<leader>gu", "<cmd>lua _gitui_toggle()<CR>", { desc = "GitUI (Float)" })
    end,
  },
}
