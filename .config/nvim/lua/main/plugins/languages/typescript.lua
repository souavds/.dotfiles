local deps = require('main.plugins.deps')

-- lsp
deps.later(function()
  deps.add({ source = 'pmizio/typescript-tools.nvim', depends = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' } })

  require('typescript-tools').setup({})
end)

-- error translator
deps.later(function()
  deps.add({ source = 'dmmulroy/ts-error-translator.nvim' })

  require('ts-error-translator').setup()
end)

-- autotag
deps.later(function()
  deps.add({ source = 'windwp/nvim-ts-autotag' })

  require('nvim-ts-autotag').setup({
    opts = {
      nable_close = true,
      enable_rename = true,
      enable_close_on_slash = true,
    },
  })
end)
