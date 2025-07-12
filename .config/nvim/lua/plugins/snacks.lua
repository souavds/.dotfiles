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
      formatters = {
        file = {
          filename_first = true,
          truncate = 120,
        },
      },
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
