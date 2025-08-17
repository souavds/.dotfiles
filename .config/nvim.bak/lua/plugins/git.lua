return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  config = function()
    vim.keymap.set("n", "<leader>gs", "<CMD>:Neogit<CR>", { silent = true, noremap = true, desc = "Neogit" })
  end,
}
