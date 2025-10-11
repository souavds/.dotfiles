local deps = require('main.plugins.deps')
local events = require('main.core.events')
local keys = require('main.core.keymaps')

-- installer
deps.later(function()
  deps.add({ source = 'mason-org/mason.nvim' })
  require('mason').setup({
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
  })
end)

-- cmp
deps.later(function()
  deps.add({
    source = 'saghen/blink.cmp',
    depends = { 'fang2hou/blink-copilot', 'rafamadriz/friendly-snippets', 'L3MON4D3/LuaSnip' },
    monitor = 'main',
    checkout = 'v1.6.0',
  })

  require('blink.cmp').setup({
    keymap = { preset = 'default' },
    appearance = {
      nerd_font_variant = 'mono',
      kind_icons = {
        Copilot = '',
        Text = '󰉿',
        Method = '󰊕',
        Function = '󰊕',
        Constructor = '󰒓',

        Field = '󰜢',
        Variable = '󰆦',
        Property = '󰖷',

        Class = '󱡠',
        Interface = '󱡠',
        Struct = '󱡠',
        Module = '󰅩',

        Unit = '󰪚',
        Value = '󰦨',
        Enum = '󰦨',
        EnumMember = '󰦨',

        Keyword = '󰻾',
        Constant = '󰏿',

        Snippet = '󱄽',
        Color = '󰏘',
        File = '󰈔',
        Reference = '󰬲',
        Folder = '󰉋',
        Event = '󱐋',
        Operator = '󰪚',
        TypeParameter = '󰬛',
      },
    },
    completion = {
      keyword = { range = 'full' },
      list = { selection = { auto_insert = false } },
      menu = { border = 'rounded' },
      documentation = { auto_show = true, auto_show_delay_ms = 100, window = { border = 'rounded' } },
    },
    signature = { enabled = true, window = { border = 'rounded' } },
    snippets = {
      preset = 'luasnip',
    },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
        },
      },
    },
  })

  vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities(nil, true) })
end)

-- lsp
deps.later(function()
  deps.add({ source = 'neovim/nvim-lspconfig' })
  deps.add({
    source = 'mason-org/mason-lspconfig.nvim',
    depends = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
  })
  deps.add({
    source = 'WhoIsSethDaniel/mason-tool-installer.nvim',
    depends = { 'mason-org/mason.nvim' },
  })

  local lsp_servers = {
    'lua_ls',
    'cssls',
    'tailwindcss',
    'expert',
  }

  local formatters_linters = {
    'stylua',
    'eslint_d',
    'prettierd',
    'prettier',
    'biome',
  }

  local ensure_installed = {}

  vim.list_extend(ensure_installed, lsp_servers)
  vim.list_extend(ensure_installed, formatters_linters)
  require('mason-lspconfig').setup({
    ensure_installed = lsp_servers,
  })
  require('mason-tool-installer').setup({
    ensure_installed = ensure_installed,
  })

  vim.lsp.enable(lsp_servers)
  vim.diagnostic.config({
    underline = false,
    update_in_insert = false,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.HINT] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
      },
    },
  })

  events.autocmd('LspAttach', {
    callback = function(args)
      local bufnr = args.buf

      keys.map(
        'n',
        '<leader>ld',
        '<CMD>:Pick lsp scope="definition"<CR>',
        { buffer = bufnr, desc = 'Find definitions' }
      )
      keys.map('n', '<leader>lr', '<CMD>:Pick lsp scope="references"<CR>', { buffer = bufnr, desc = 'Find references' })
      keys.map('n', '<leader>lh', '<CMD>:lua vim.lsp.buf.hover()<CR>', {
        buffer = bufnr,
        desc = 'Show hover information',
      })
      keys.map('n', '<leader>ll', '<CMD>:lua vim.diagnostic.open_float(0, { scope = "line" })<CR>', {
        buffer = bufnr,
        desc = 'Show line diagnostics',
      })
      keys.map('n', '<leader>lcr', '<CMD>:lua vim.lsp.buf.rename()<CR>', { buffer = bufnr, desc = 'Rename symbol' })
      keys.map({ 'n', 'x' }, '<leader>lca', '<CMD>:lua require("tiny-code-action").code_action()<CR>', {
        buffer = bufnr,
        desc = 'Code actions',
      })
    end,
  })
end)

-- lazydev
deps.later(function()
  deps.add({ source = 'folke/lazydev.nvim', depends = { 'saghen/blink.cmp' } })

  require('lazydev').setup({
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  })
end)
