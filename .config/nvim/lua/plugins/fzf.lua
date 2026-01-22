return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local fzf = require("fzf-lua")

    -- ★ PATH 問題対策：fzf_bin を固定する
    fzf.setup({
      fzf_bin = os.getenv("HOME") .. "/.local/share/mise/shims/fzf",
    })

    -- ★ markdown で @ → ファイル挿入
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        vim.keymap.set("i", "@", function()
          local selected_path = nil
          fzf.files({
            file_icons = false,
            git_icons = false,
            actions = {
              ["default"] = function(selected, opts)
                if selected and selected[1] then
                  local file = require("fzf-lua.path").entry_to_file(selected[1], opts)
                  selected_path = file and file.path or nil
                end
              end
            },
            winopts = {
              on_close = function()
                vim.schedule(function()
                  if selected_path then
                    vim.api.nvim_put({ "@" .. selected_path }, "", false, true)
                  else
                    vim.api.nvim_put({ "@" }, "", false, true)
                  end
                  vim.defer_fn(function()
                    vim.cmd("startinsert!")
                  end, 10)
                end)
              end
            }
          })
        end, { buffer = ev.buf, noremap = true })
      end,
    })
  end
}

