return {
  "stevearc/conform.nvim",
  config = function()
    local conform = require("conform")
    conform.setup({
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = {
        timeout_ms = 500,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        elixir = { "mix" },
        eelixir = { "mix" },
        heex = { "mix" },
        surface = { "mix" },
        jsonc = { "biome", "prettierd", "prettier", stop_after_first = true },
        json = { "biome", "prettierd", "prettier", stop_after_first = true },
        javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
        typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
      },
      formatters = {
        biome = {
          command = "biome",
          args = {
            "format",
            "--stdin-file-path",
            "$FILENAME",
            "--format-with-errors=true",
          },
          stdin = true,
          cwd = require("conform.util").root_file({ "biome.json" }),
        },
        prettier = {
          command = "prettier",
          args = {
            "--stdin-filepath",
            "$FILENAME",
            "--parser",
            "json",
          },
          stdin = true,
        },
      },
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function(args)
        conform.format({
          bufnr = args.buf,
          lsp_format = "fallback",
        })
      end,
    })
  end,
}
