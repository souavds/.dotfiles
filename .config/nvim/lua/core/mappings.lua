-- Helper --
local keymap = function(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

local keymap_leader = function(mode, suffix, rhs, opts)
  keymap(mode, "<leader>" .. suffix, rhs, opts)
end

local function close_floating()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end

local create_mode_table = function(fn)
  return {
    n = function(lhs, rhs, opts)
      fn("n", lhs, rhs, opts)
    end,
    i = function(lhs, rhs, opts)
      fn("i", lhs, rhs, opts)
    end,
    v = function(lhs, rhs, opts)
      fn("v", lhs, rhs, opts)
    end,
    x = function(lhs, rhs, opts)
      fn("x", lhs, rhs, opts)
    end,
    t = function(lhs, rhs, opts)
      fn("t", lhs, rhs, opts)
    end,
    c = function(lhs, rhs, opts)
      fn("c", lhs, rhs, opts)
    end,
  }
end
-- Helper --

local Map = {
  mode = create_mode_table(keymap),
  leader = create_mode_table(keymap_leader),
  OnLspAttach = nil,
}

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
Map.mode.n("<esc>", function()
  close_floating()
  vim.cmd(":noh")
end, { silent = true, desc = "Remove Search Highlighting, Dismiss Popups" })

-- Better window navigation
Map.mode.n("<C-h>", "<C-w>h", { silent = true, noremap = true })
Map.mode.n("<C-j>", "<C-w>j", { silent = true, noremap = true })
Map.mode.n("<C-k>", "<C-w>k", { silent = true, noremap = true })
Map.mode.n("<C-l>", "<C-w>l", { silent = true, noremap = true })

-- Resize with arrows
Map.mode.n("<C-Up>", ":resize -2<CR>", { silent = true, noremap = true })
Map.mode.n("<C-Down>", ":resize +2<CR>", { silent = true, noremap = true })
Map.mode.n("<C-Left>", ":vertical resize -2<CR>", { silent = true, noremap = true })
Map.mode.n("<C-Right>", ":vertical resize +2<CR>", { silent = true, noremap = true })

-- Navigate buffers
Map.mode.n("<S-l>", ":bnext<CR>", { silent = true, noremap = true })
Map.mode.n("<S-h>", ":bprevious<CR>", { silent = true, noremap = true })

-- Move text up and down
Map.mode.n("<A-j>", ":m .+1<CR>==", { silent = true, noremap = true })
Map.mode.n("<A-k>", ":m .-2<CR>==", { silent = true, noremap = true })

-- Fuzzy --
Map.leader.n("ff", "<CMD>lua require('snacks').picker.files()<CR>", { desc = "Find files (FND)" })
Map.leader.n("fb", "<CMD>lua require('snacks').picker.buffers()<CR>", { desc = "Find buffers (FND)" })
Map.leader.n("fh", "<CMD>lua require('snacks').picker.helptags()<CR>", { desc = "Find help tags (FND)" })
Map.leader.n("fg", "<CMD>lua require('snacks').picker.grep()<CR>", { desc = "Find live grep (FND)" })
Map.leader.n("fR", "<CMD>lua require('snacks').picker.resume()<CR>", { desc = "Find resume (FND)" })

-- LSP --
Map.OnLspAttach = function(bufnr)
  Map.mode.n(
    "gd",
    "<CMD>lua require('snacks').picker.lsp_definitions()<CR>",
    { desc = "Go to definitions (LSP)", buffer = bufnr }
  )
  Map.mode.n(
    "gr",
    "<CMD>lua require('snacks').picker.lsp_references()<CR>",
    { desc = "Go to references (LSP)", buffer = bufnr }
  )
  Map.mode.n("gD", "<CMD>lua vim.lsp.buf.declaration()<CR>", { desc = "Go to declaration (LSP)", buffer = bufnr })
  Map.mode.n(
    "gT",
    "<CMD>lua vim.lsp.buf.type_definition()<CR>",
    { desc = "Go to type definition (LSP)", buffer = bufnr }
  )
  Map.mode.n("K", "<CMD>lua vim.lsp.buf.hover()<CR>", { desc = "Symbol information (LSP)", buffer = bufnr })
  Map.leader.n("cr", "<CMD>lua vim.lsp.buf.rename()<CR>", { desc = "Rename (LSP)", buffer = bufnr })
  Map.leader.n("ca", "<CMD>lua vim.lsp.buf.code_action()<CR>", { desc = "Code Action (LSP)", buffer = bufnr })
  Map.leader.n(
    "wd",
    "<CMD>lua require('snacks').picker.lsp_document_symbols()<CR>",
    { desc = "Document symbols", buffer = bufnr }
  )
  Map.leader.n(
    "cl",
    "<CMD>lua vim.diagnostic.open_float(0, { scope = 'line', border = 'rounded' })<CR>",
    { desc = "Line diagnostic (LSP)", buffer = bufnr }
  )

  -- Map.leader.n(
  --   "ls",
  --   "<CMD>:lua vim.lsp.buf.signature_help()<CR>",
  --   { desc = "Signature information (LSP)", buffer = bufnr }
  -- )
  -- Map.leader.n("ld", "<CMD>:lua vim.diagnostic.open_float()<CR>", { desc = "Diagnostic popup (LSP)", buffer = bufnr })
  -- Map.leader.n("lj", "<CMD>:lua vim.diagnostic.goto_next()<CR>", { desc = "Next diagnostic (LSP)", buffer = bufnr })
  -- Map.leader.n("lk", "<CMD>:lua vim.diagnostic.goto_prev()<CR>", { desc = "Prev diagnostic (LSP)", buffer = bufnr })
  -- Map.leader.n("lf", "<CMD>:lua vim.lsp.buf.format()<CR>", { desc = "Format file (LSP)", buffer = bufnr })
end

-- AI (a) --
Map.leader.n("aa", "<CMD>CodeCompanionChat toggle<CR>", { desc = "Code Companion Chat (AI)" })

-- Git (g) --
Map.leader.n("gg", "<CMD>lua Snacks.lazygit()<CR>", { desc = "Open LazyGit (GIT)" })
Map.leader.n("gbb", "<CMD>Gitsigns blame_line full=true<CR>", { desc = "Blame line (GIT)" })
Map.leader.n("gbt", "<CMD>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle blame line (GIT)" })
Map.leader.n("goo", "<CMD>lua Snacks.gitbrowse()<CR>", { desc = "Git browse (GIT)" })

-- Explorer (-) --
Map.mode.n("-", "<CMD>Oil<CR>", { desc = "Open parent directory (EXP)" })

-- Buffer --
Map.leader.n("b", "<CMD>Grapple toggle<CR>", { desc = "Grapple toggle tag (BUF)" })
Map.leader.n("B", "<CMD>Grapple toggle_tags<CR>", { desc = "Grapple open tags window (BUF)" })
Map.leader.n("n", "<CMD>Grapple cycle_tags next<CR>", { desc = "Grapple cycle next tag (BUF)" })
Map.leader.n("p", "<CMD>Grapple cycle_tags prev<CR>", { desc = "Grapple cycle previous tag (BUF)" })

-- Testing (t) --
Map.leader.n("too", "<CMD>lua require('neotest').output.open()<CR>", { desc = "Open test result (TEST)" })
Map.leader.n("tos", "<CMD>lua require('neotest').summary.toggle()<CR>", { desc = "Toggle test summary (TEST)" })
Map.leader.n("tt", "<CMD>lua require('neotest').run.run()<CR>", { desc = "Test nearest (TEST)" })
Map.leader.n("tf", "<CMD>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", { desc = "Test file (TEST)" })
Map.leader.n("ts", "<CMD>lua require('neotest').run.stop()<CR>", { desc = "Stop test (TEST)" })
Map.leader.n("tww", "<CMD>lua require('neotest').watch.watch()<CR>", { desc = "Watch nearest test (TEST)" })
Map.leader.n(
  "twf",
  "<CMD>lua require('neotest').watch.watch(vim.fn.expand('%'))<CR>",
  { desc = "Watch test file (TEST)" }
)
Map.leader.n("tws", "<CMD>lua require('neotest').watch.stop()<CR>", { desc = "Stop watch test (TEST)" })

-- Package Manager (p) --
Map.leader.n("L", "<CMD>Lazy<CR>", { desc = "Open deps (PKG)" })

-- Insert --
-- Press jk fast to exit insert mod
Map.mode.i("jk", "<ESC>", { silent = true, noremap = true })
Map.mode.i("kj", "<ESC>", { silent = true, noremap = true })

-- Visual --
-- Stay in indent mode
Map.mode.v("<", "<gv^", { silent = true, noremap = true })
Map.mode.v(">", ">gv^", { silent = true, noremap = true })

-- Move text up and down
Map.mode.v("<A-j>", ":m '>+1<CR>gv=gv", { silent = true, noremap = true })
Map.mode.v("<A-k>", ":m '<-2<CR>gv=gv", { silent = true, noremap = true })
Map.mode.v("p", '"_dP')

-- Visual Block --
-- Move text up and down
Map.mode.x("J", ":m '>+1<CR>gv=gv", { silent = true, noremap = true })
Map.mode.x("K", ":m '<-2<CR>gv=gv", { silent = true, noremap = true })
Map.mode.x("<A-j>", ":m '>+1<CR>gv=gv", { silent = true, noremap = true })
Map.mode.x("<A-k>", ":m '<-2<CR>gv=gv", { silent = true, noremap = true })

return Map
