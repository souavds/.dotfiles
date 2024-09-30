return {
  "echasnovski/mini.files",
  version = false,
  config = function()
    require("mini.files").setup({
      windows = {
        max_number = 2,
        preview = true,
        width_focus = 45,
        width_nofocus = 40,
        width_preview = 60,
      },
    })
  end,
}
