return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  init = function()
    vim.g.markview_blink_loaded = true
  end,
  dependencies = {
    "saghen/blink.lib",
    "saghen/blink.cmp",
  },
};
