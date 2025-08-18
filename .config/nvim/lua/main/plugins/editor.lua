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

-- starter
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.starter',
  })

  local starter = require('mini.starter')

  starter.setup({
    header = "sdvauos' nvim",
    items = {
      starter.sections.sessions(5),
      starter.sections.recent_files(5, false),
      starter.sections.builtin_actions(),
    },
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.aligning('center', 'top'),
      starter.gen_hook.padding(3, 5),
    },
  })
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
      { mode = 'n', keys = '<leader>b', desc = '+buffer' },
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

-- fzf
deps.now(function()
  deps.add({ source = 'echasnovski/mini.pick' })
  deps.add({ source = 'echasnovski/mini.extra' })

  require('mini.pick').setup({})
  require('mini.extra').setup({})

  vim.ui.select = MiniPick.ui_select

  keys.map('n', '<leader>ff', '<CMD>:Pick files<CR>', { desc = 'Find files' })
  keys.map('n', '<leader>fb', '<CMD>:Pick buffers<CR>', { desc = 'Find buffers' })
  keys.map('n', '<leader>fh', '<CMD>:Pick help<CR>', { desc = 'Find help pages' })
  keys.map('n', '<leader>fg', '<CMD>:Pick grep_live<CR>', { desc = 'Find live grep' })
  keys.map('n', '<leader>fG', '<CMD>:Pick grep pattern="<cword>"<CR>', { desc = 'Find grep word' })
  keys.map('n', '<leader>fR', '<CMD>:Pick resume<CR>', { desc = 'Find resume' })
end)

-- buffer
deps.now(function()
  deps.add({ source = 'echasnovski/mini.visits' })

  require('mini.visits').setup({})

  keys.map('n', '<leader>ba', '<CMD>:lua MiniVisits.add_label("core")<CR>', { desc = 'Add file to core' })
  keys.map('n', '<leader>br', '<CMD>:lua MiniVisits.remove_label("core")<CR>', { desc = 'Remove file from core' })
  keys.map('n', '[[', function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    MiniVisits.iterate_paths('forward', vim.fn.getcwd(), { filter = 'core', sort = sort_latest, wrap = true })
  end, { desc = 'Next file in core' })
  keys.map('n', ']]', function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    MiniVisits.iterate_paths('backward', vim.fn.getcwd(), { filter = 'core', sort = sort_latest, wrap = true })
  end, { desc = 'Previous file in core' })
  keys.map('n', '<leader>bA', '<CMD>:lua MiniVisits.add_label()<CR>', { desc = 'Add file to label' })
  keys.map('n', '<leader>bR', '<CMD>:lua MiniVisits.remove_label()<CR>', { desc = 'Remove file from label' })
  keys.map(
    'n',
    '<leader>bb',
    '<CMD>:lua MiniVisits.select_path(nil, { filter = "core" })<CR>',
    { desc = 'Select all paths in core' }
  )
end)
