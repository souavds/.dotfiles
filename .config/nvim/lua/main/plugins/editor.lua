local deps = require('main.plugins.deps')
local keys = require('main.core.keymaps')

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
      { mode = 'n', keys = '<leader>d', desc = '+deps' },
      { mode = 'n', keys = '<leader>f', desc = '+find' },
      { mode = 'n', keys = '<leader>g', desc = '+git' },
      { mode = 'n', keys = '<leader>t', desc = '+test' },
      { mode = 'n', keys = '<leader>tw', desc = '+test+watch' },
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
    window = {
      delay = 300,
    },
  })
end)

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

  keys.map('n', '-', '<CMD>Oil<CR>', { desc = 'File explorer' })
end)

-- Dashboard / FZF / Git browswe
deps.now(function()
  deps.add({ source = 'folke/snacks.nvim' })

  require('snacks').setup({
    gitbrowser = { enabled = true },
    picker = {
      ui_select = true,
      formatters = {
        file = {
          filename_first = true,
          truncate = 120,
        },
      },
      sources = {
        files = {
          hidden = true,
        },
        grep = {
          hidden = true,
        },
      },
    },
  })

  keys.map('n', '<leader>ff', "<CMD>lua require('snacks').picker.files()<CR>", { desc = 'Find files' })
  keys.map('n', '<leader>fb', "<CMD>lua require('snacks').picker.buffers()<CR>", { desc = 'Find buffers' })
  keys.map('n', '<leader>fh', "<CMD>lua require('snacks').picker.help()<CR>", { desc = 'Find help pages' })
  keys.map('n', '<leader>fg', "<CMD>lua require('snacks').picker.grep()<CR>", { desc = 'Find live grep' })
  keys.map('n', '<leader>fR', "<CMD>lua require('snacks').picker.resume()<CR>", { desc = 'Find resume' })
  keys.map('n', '<leader>go', "<CMD>lua require('snacks').gitbrowse()<CR>", { desc = 'Open git' })
end)
