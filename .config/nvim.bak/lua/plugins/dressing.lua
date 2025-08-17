return {
  "stevearc/dressing.nvim",
  opts = {},
  config = function()
    require("dressing").setup({
      input = {
        prefer_width = 50,
        max_width = { 140, 0.9 },
      },
      select = {
        backend = { "fzf_lua", "builtin" },
      },
    })
  end,
}
