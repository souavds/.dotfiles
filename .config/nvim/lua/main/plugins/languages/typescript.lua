local deps = require('main.plugins.deps')

-- LSP
deps.later(function()
  deps.add({ source = 'pmizio/typescript-tools.nvim', depends = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' } })

  require('typescript-tools').setup({})
end)

-- Error translator
deps.later(function()
  deps.add({ source = 'dmmulroy/ts-error-translator.nvim' })

  require('ts-error-translator').setup()
end)
