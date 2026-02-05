return {
  "gbprod/yanky.nvim",
  dependencies = { "folke/snacks.nvim", },
  config = function()
    local yanky = require("yanky")
    yanky.setup({})

    function yanky_paste_snacks()
      local yanks = require("yanky.history").all()
      ---@type snacks.picker.Item[]
      local items = {}
      Snacks.picker({
        finder = function ()
          for i, ynk in ipairs(yanks) do
            local lines = vim.split(ynk.regcontents or "", "\n", { plain = true })
            ---@type snacks.picker.Item
            local item = { idx = i, score = 0,
              text  = lines[1] or "",
              lines = lines,
            }
            table.insert(items, item)
          end
          return items
        end,

        preview = function(ctx)
          local bufnr = ctx.buf
          local item = ctx.item

          vim.bo[bufnr].modifiable = true     -- バッファを書き込み可能にする
          vim.api.nvim_set_option_value("foldenable", false, { scope = "local", win = win })
          vim.api.nvim_set_option_value("wrap", true, { scope = "local", win = win })

          local display_lines = {}
          if item and item.lines then
            vim.list_extend(display_lines, item.lines)
          else
            table.insert(display_lines, "No content")
          end

          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, display_lines)
          -- vim.bo[bufnr].modifiable = false   -- 必要なら書き込み不可に戻す
        end,

        ---@type snacks.picker.Action.spec
        confirm = function(picker, item)
          picker:close()
          vim.api.nvim_put(item.lines or {}, "c", true, true)
        end,

        format = "text",
      })
    end

    vim.keymap.set('n', '<leader>p', yanky_paste_snacks, { desc = 'Yank History' })
  end,
}
