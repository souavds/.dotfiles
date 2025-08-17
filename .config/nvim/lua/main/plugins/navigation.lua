local deps = require('main.plugins.deps')

-- Explorer
deps.now(function()
  deps.add({
    source = 'stevearc/oil.nvim',
    depends = {
      'echasnovski/mini.icons',
    },
  })

  require('oil').setup({
    view_options = {
      show_hidden = true,
    },
    float = {
      max_width = 100,
      max_height = 40,
    },
  })

  vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'File explorer [EX]' })
end)
