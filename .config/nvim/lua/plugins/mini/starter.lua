return {
  "echasnovski/mini.starter",
  version = false,
  config = function()
    require("mini.starter").setup({
      items = {
        { name = "Lazy 󰒲", action = ":Lazy", section = "Actions " },
        { name = "Open blank file 󰯉", action = ":enew", section = "Actions " },
        { name = "Find files ", action = "lua MiniPick.builtin.files()", section = "Actions " },
        { name = "Recent files ", action = "lua MiniExtra.pickers.oldfiles()", section = "Actions " },
        { name = "Quit 󱍢", action = ":q!", section = "Actions " },
      },
    })
  end,
}
