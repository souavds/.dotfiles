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

-- extra
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.extra',
  })

  require('mini.extra').setup({})
end)

-- comment
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.comment',
  })

  require('mini.comment').setup({})
end)

-- autopairs
deps.now(function()
  deps.add({
    source = 'echasnovski/mini.pairs',
  })

  require('mini.pairs').setup({})
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
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),

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
      { mode = 'n', keys = '<leader>l', desc = '+lsp' },
      { mode = 'n', keys = '<leader>lc', desc = '+lsp+code_actions' },
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
  deps.add({
    source = 'ibhagwan/fzf-lua',
    depends = { 'echasnovski/mini.icons' },
  })

  local fzf_lua = require('fzf-lua')
  local actions = require('fzf-lua.actions')

  fzf_lua.setup({
    keymap = {
      builtin = {
        ['<C-/>'] = 'toggle-help',
        ['<C-a>'] = 'toggle-fullscreen',
        ['<C-i>'] = 'toggle-preview',
      },
      fzf = {
        ['alt-s'] = 'toggle',
        ['alt-a'] = 'toggle-all',
        ['ctrl-i'] = 'toggle-preview',
      },
    },
    winopts = {
      border = 'rounded',
      height = 0.5,
      width = 0.4,
      preview = {
        scrollbar = false,
        layout = 'vertical',
        vertical = 'up:40%',
      },
    },
    files = {
      winopts = {
        preview = { hidden = true },
      },
    },
    helptags = {
      actions = {
        ['enter'] = actions.help_vert,
      },
    },
  })

  fzf_lua.register_ui_select(function(opts)
    opts.winopts = {
      height = 0.5,
      width = 0.4,
    }

    if opts.kind then opts.winopts.title = string.format(' %s', opts.kind) end

    return opts
  end)

  keys.map('n', '<leader>ff', fzf_lua.files, { desc = 'Find files' })
  keys.map('n', '<leader>fb', fzf_lua.buffers, { desc = 'Find buffers' })
  keys.map('n', '<leader>fh', fzf_lua.help_tags, { desc = 'Find help pages' })
  keys.map('n', '<leader>fg', fzf_lua.live_grep, { desc = 'Find live grep' })
  keys.map('n', '<leader>fG', fzf_lua.grep_cword, { desc = 'Find grep word' })
  keys.map('n', '<leader>fd', fzf_lua.lsp_document_diagnostics, { desc = 'Find document diagnostics' })
  keys.map('n', '<leader>fo', fzf_lua.oldfiles, { desc = 'Find old files' })
  keys.map('n', '<leader>fR', fzf_lua.resume, { desc = 'Find resume' })
end)

-- code action
deps.later(function()
  deps.add({ source = 'rachartier/tiny-code-action.nvim', depends = { 'nvim-lua/plenary.nvim', 'ibhagwan/fzf-lua' } })

  require('tiny-code-action').setup()
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
