return {
  "folke/snacks.nvim",
  enabled = true,
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    dashboard = { enabled = true },
    gitbrowse = { enabled = true },
    picker = {
      ui_select = true,
      sources = {
        files = {
          hidden = true,
        },
        grep = {
          hidden = true,
        },
      },
    },
  },
}
