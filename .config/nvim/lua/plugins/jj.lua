return {
  "nicolasgb/jj.nvim",
  version = "*", -- 最新の安定版を使用
  lazy = true,
  dependencies = {
    "sindrets/diffview.nvim", -- diffバックエンドとして使用
    "folke/snacks.nvim",      -- picker（status/file_history）に使用
  },
  cmd = { "J", "Jdiff", "Jvdiff", "Jhdiff" },
  keys = {
    -- 基本操作
    { "<leader>jj", function() require("jj.cmd").status() end, desc = "jj: status" },
    { "<leader>jl", function() require("jj.cmd").log() end, desc = "jj: log" },
    { "<leader>jL", function() require("jj.cmd").log({ revisions = "'all()'" }) end, desc = "jj: log (all)" },
    { "<leader>jd", function() require("jj.cmd").describe() end, desc = "jj: describe" },
    { "<leader>jn", function() require("jj.cmd").new() end, desc = "jj: new" },
    { "<leader>je", function() require("jj.cmd").edit() end, desc = "jj: edit" },
    { "<leader>js", function() require("jj.cmd").squash() end, desc = "jj: squash" },
    { "<leader>ju", function() require("jj.cmd").undo() end, desc = "jj: undo" },
    { "<leader>jr", function() require("jj.cmd").rebase() end, desc = "jj: rebase" },
    { "<leader>ja", function() require("jj.cmd").abandon() end, desc = "jj: abandon" },

    -- リモート操作
    { "<leader>jf", function() require("jj.cmd").fetch() end, desc = "jj: fetch" },
    { "<leader>jp", function() require("jj.cmd").push() end, desc = "jj: push" },
    { "<leader>jo", function() require("jj.cmd").open_pr() end, desc = "jj: open PR" },
    { "<leader>jO", function() require("jj.cmd").open_pr({ list_bookmarks = true }) end, desc = "jj: open PR (bookmark選択)" },

    -- Bookmark操作
    { "<leader>jbc", function() require("jj.cmd").bookmark_create() end, desc = "jj: bookmark create" },
    { "<leader>jbd", function() require("jj.cmd").bookmark_delete() end, desc = "jj: bookmark delete" },
    { "<leader>jbm", function() require("jj.cmd").bookmark_move() end, desc = "jj: bookmark move" },

    -- Diff
    { "<leader>jD", function() require("jj.diff").diff_current({ rev = "@-", layout = "vertical" }) end, desc = "jj: diff current (vertical)" },

    -- Picker（snacks.nvim経由）
    { "<leader>jps", function() require("jj.picker").status() end, desc = "jj: picker status" },
    { "<leader>jph", function() require("jj.picker").file_history() end, desc = "jj: picker file history" },

    -- Annotate (blame)
    { "<leader>jga", function() require("jj.annotate").file() end, desc = "jj: annotate file" },
    { "<leader>jgA", function() require("jj.annotate").line() end, desc = "jj: annotate line" },
  },
  config = function()
    require("jj").setup({
      -- Diffバックエンドにdiffviewを使用
      diff = {
        backend = "diffview",
      },

      -- Describeエディタ設定（bufferモードをデフォルト使用）
      cmd = {
        describe = {
          editor = {
            type = "buffer",
            keymaps = {
              close = { "<C-c>", "q" }
            }
          }
        },
        -- Log画面でeditした後にlog自動クローズ
        log = {
          close_on_edit = true
        },
      },

      -- ハイライト設定（デフォルト値を使用）
      highlights = {
        editor = {
          added = { fg = "#3fb950", ctermfg = "Green" },
          modified = { fg = "#56d4dd", ctermfg = "Cyan" },
          deleted = { fg = "#f85149", ctermfg = "Red" },
          renamed = { fg = "#d29922", ctermfg = "Yellow" },
        },
        log = {
          selected = { bg = "#3d2c52", ctermbg = "DarkMagenta" },
          targeted = { fg = "#5a9e6f", ctermfg = "Green" },
        }
      },
    })
  end,
}
