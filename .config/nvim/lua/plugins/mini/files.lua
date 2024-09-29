return {
  "echasnovski/mini.files",
  version = false,
  config = function()
    local MiniFiles = require("mini.files")
    MiniFiles.setup({
      windows = {
        max_number = 2,
        preview = true,
        width_focus = 45,
        width_nofocus = 40,
        width_preview = 60,
      },
    })

    -- Open parent directory in current window
    vim.keymap.set("n", "-", function()
      MiniFiles.open(vim.bo.buftype ~= "nofile" and vim.api.nvim_buf_get_name(0) or nil, true)
    end, { desc = "Open parent directory" })
    vim.keymap.set("n", "<leader>-", function()
      MiniFiles.open()
    end, { desc = "Open root directory" })
  end,
}
