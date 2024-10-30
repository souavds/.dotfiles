return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local actions = require("fzf-lua.actions")

    require("fzf-lua").register_ui_select(function(_, items)
      local min_h, max_h = 0.15, 0.70
      local h = (#items + 4) / vim.o.lines
      if h < min_h then
        h = min_h
      elseif h > max_h then
        h = max_h
      end
      return { winopts = { height = h, width = 0.60, row = 0.40 } }
    end)

    require("fzf-lua").setup({
      fzf_opts = { ["--wrap"] = true },
      defaults = {
        git_icons = false,
        file_icons = false,
        color_icons = false,
        formatter = "path.filename_first",
      },
      files = {
        cwd_prompt = false,
        prompt = "Files❯ ",
        fzf_opts = {
          ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
        },
      },
      grep = {
        rg_glob = true,
        RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
        actions = { ["ctrl-r"] = { actions.toggle_ignore } },
        fzf_opts = {
          ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-grep-history",
        },
      },
      winopts = {
        preview = {
          wrap = "wrap",
        },
      },
    })
  end,
}
