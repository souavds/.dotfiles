return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<M-a>", function()
      harpoon:list():add()
    end)
    vim.keymap.set("n", "<M-e>", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    -- Set <space>1..<space>5 be my shortcuts to moving to the files
    for _, idx in ipairs({ 1, 2, 3, 4, 5 }) do
      vim.keymap.set("n", string.format("<M-%d>", idx), function()
        harpoon:list():select(idx)
      end)
    end

    vim.keymap.set("n", "<M-p>", function()
      harpoon:list():prev()
    end)
    vim.keymap.set("n", "<M-n>", function()
      harpoon:list():next()
    end)
  end,
}
