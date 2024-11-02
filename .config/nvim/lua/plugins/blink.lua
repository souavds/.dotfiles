return {
  "saghen/blink.cmp",
  enabled = true,
  lazy = false,
  version = "v0.*",
  dependencies = { "saghen/blink.compat", "rafamadriz/friendly-snippets" },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = "default",
    highlight = {
      use_nvim_cmp_as_default = true,
    },
    nerd_font_variant = "mono",
    accept = {
      auto_brackets = { enabled = true },
    },
    trigger = {
      signature_help = {
        enabled = true,
      },
    },
    windows = {
      autocomplete = {
        border = "rounded",
        draw = "reversed",
        -- Blink highlight not yet supported by colorschemes
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
      },
      documentation = {
        auto_show = true,
        border = "rounded",
      },
      signature_help = {
        border = "rounded",
      },
    },
  },
}
