return {
  "echasnovski/mini.pick",
  version = false,
  config = function()
    local MiniPick = require("mini.pick")
    MiniPick.setup()
    vim.ui.select = MiniPick.ui_select
  end,
}
