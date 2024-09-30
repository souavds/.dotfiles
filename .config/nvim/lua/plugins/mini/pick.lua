return {
  "echasnovski/mini.pick",
  version = false,
  config = function()
    local MiniPick = require("mini.pick")
    MiniPick.setup()
    vim.ui.select = MiniPick.ui_select

    vim.keymap.set("n", "<leader>ff", function()
      MiniPick.builtin.files({ tool = "rg" })
    end, { desc = "Find file" })

    vim.keymap.set("n", "<leader>fg", function()
      MiniPick.builtin.grep_live({ tool = "rg" })
    end, { desc = "Live grep" })

    vim.keymap.set("n", "<leader>fb", function()
      MiniPick.builtin.buffers()
    end, { desc = "Find buffers" })

    vim.keymap.set("n", "<leader>fh", function()
      MiniPick.builtin.help()
    end, { desc = "Find help tags" })
  end,
}
