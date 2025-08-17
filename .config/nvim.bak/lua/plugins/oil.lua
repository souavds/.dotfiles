return {
  "stevearc/oil.nvim",
  config = function()
    require("oil").setup({
      view_options = {
        show_hidden = true,
      },
      float = {
        max_width = 100,
        max_height = 40,
      },
    })
  end,
}
