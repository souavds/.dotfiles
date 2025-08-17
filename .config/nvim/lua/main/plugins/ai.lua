local deps = require('main.plugins.deps')

deps.later(function()
  deps.add({
    source = 'zbirenbaum/copilot.lua',
    hooks = { post_install = function() vim.cmd('Copilot') end },
  })

  require('copilot').setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
  })
end)
