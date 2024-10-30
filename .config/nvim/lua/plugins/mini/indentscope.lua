return {
  "echasnovski/mini.indentscope",
  version = false,
  config = function()
    require("mini.indentscope").setup({
      options = {
        try_as_border = true,
      },
      draw = {
        delay = 0,
        animation = require("mini.indentscope").gen_animation.none(),
      },
    })
  end,
}
