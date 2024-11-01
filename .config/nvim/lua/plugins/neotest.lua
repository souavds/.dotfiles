return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- adapters
    "marilari88/neotest-vitest",
    "olimorris/neotest-rspec",
    "jfpedroza/neotest-elixir",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-vitest"),
        require("neotest-rspec"),
        require("neotest-elixir"),
      },
    })
  end,
}
