local deps = require('main.plugins.deps')

-- Formatting
deps.later(function()
  deps.add({ source = 'stevearc/conform.nvim' })

  local conform = require('conform')

  conform.setup({
    default_format_opts = {
      lsp_format = 'fallback',
    },
    format_on_save = { timeout_ms = 500 },
    formatters_by_ft = {
      lua = { 'stylua' },
    },
  })

  vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function(args)
      conform.format({
        bufnr = args.buf,
        lsp_format = 'fallback',
      })
    end,
  })
end)

-- Linting
