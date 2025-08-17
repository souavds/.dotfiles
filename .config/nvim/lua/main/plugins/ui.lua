local deps = require('main.plugins.deps')

-- colorscheme
deps.now(function()
  deps.add({
    source = 'folke/tokyonight.nvim',
  })

  vim.cmd('colorscheme tokyonight-night')
end)

-- icons
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.icons',
  })
  require('mini.icons').setup()
end)

-- notify
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.notify',
  })
  require('mini.notify').setup({
    window = { config = { border = 'rounded' } },
  })
  vim.notify = MiniNotify.make_notify()
end)

-- patterns
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.hipatterns',
  })

  local hipatterns = require('mini.hipatterns')

  hipatterns.setup({
    highlighters = {
      fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
      hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
      todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
      note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- statusline
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.statusline',
  })

  require('mini.statusline').setup({})
end)

-- clue
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.clue',
  })

  local miniclue = require('mini.clue')
  miniclue.setup({
    triggers = {
      -- Leader triggers
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },
      { mode = 'v', keys = '<leader>' },

      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },

      -- `g` key
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },

      -- Marks
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },

      -- Registers
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },

      -- Window commands
      { mode = 'n', keys = '<C-w>' },

      -- `z` key
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },
    },
    clues = {
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })
end)
