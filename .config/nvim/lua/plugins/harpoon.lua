return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local Map = require("core.mappings")

    Map.leader.n("ha", function()
      harpoon:list():add()
    end, { desc = "Add (HRP)" })

    Map.leader.n("he", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Toggle (HRP)" })

    for _, idx in ipairs({ 1, 2, 3, 4, 5 }) do
      Map.mode.n(string.format("<A-%d>", idx), function()
        harpoon:list():select(idx)
      end)
    end

    Map.mode.n("<A-p>", function()
      harpoon:list():prev()
    end, { desc = "Previous item (HRP)" })
    Map.mode.n("<A-n>", function()
      harpoon:list():next()
    end, { desc = "Next item (HRP)" })
  end,
}
