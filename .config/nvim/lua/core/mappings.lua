-- Helper --
local keymap = function(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

local keymap_leader = function(mode, suffix, rhs, opts)
  keymap(mode, "<leader>" .. suffix, rhs, opts)
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
  clues = {
    { mode = "n", keys = "<leader>b", desc = "+Buffer" },
    { mode = "n", keys = "<leader>e", desc = "+Explore" },
    { mode = "n", keys = "<leader>f", desc = "+Find" },
    { mode = "n", keys = "<leader>g", desc = "+Git" },
    { mode = "n", keys = "<leader>gb", desc = "+Blame" },
    { mode = "n", keys = "<leader>l", desc = "+LSP" },
    { mode = "n", keys = "<leader>p", desc = "+Deps" },
  },
}

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
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

-- Plugins --
-- Fuzzy (f) --
Map.leader.n("ff", "<CMD>Pick files<CR>", { desc = "Find file (FND)" })
Map.leader.n("fb", "<CMD>Pick buffers<CR>", { desc = "Find buffers (FND)" })
Map.leader.n("fh", "<CMD>Pick help<CR>", { desc = "Find help tags (FND)" })
Map.leader.n("fg", "<CMD>Pick grep_live<CR>", { desc = "Live grep (FND)" })
Map.leader.n("fG", "<CMD>Pick grep pattern='<cword>'<CR>", { desc = "Grep current word (FND)" })
Map.leader.n("fr", "<CMD>Pick resume<CR>", { desc = "Resume find (FND)" })
Map.leader.n("fld", "<CMD>Pick lsp scope='definition'<CR>", { desc = "Definition (FND_LSP)" })
Map.leader.n("flr", "<CMD>Pick lsp scope='references'<CR>", { desc = "References (FND_LSP)" })
Map.leader.n("flD", "<CMD>Pick lsp scope='declaration'<CR>", { desc = "Declaration (FND_LSP)" })
Map.leader.n("flt", "<CMD>Pick lsp scope='type_definition'<CR>", { desc = "Type definition (FND_LSP)" })

-- LSP (l) --
--- some mappings available at plugins.lsp
Map.OnLspAttach = function(bufnr)
  Map.leader.n(
    "ls",
    "<CMD>:lua vim.lsp.buf.signature_help()<CR>",
    { desc = "Signature information (LSP)", buffer = bufnr }
  )
  Map.leader.n("ld", "<CMD>:lua vim.diagnostic.open_float()<CR>", { desc = "Diagnostic popup (LSP)", buffer = bufnr })
  Map.leader.n("lj", "<CMD>:lua vim.diagnostic.goto_next()<CR>", { desc = "Next diagnostic (LSP)", buffer = bufnr })
  Map.leader.n("lk", "<CMD>:lua vim.diagnostic.goto_prev()<CR>", { desc = "Prev diagnostic (LSP)", buffer = bufnr })
  Map.leader.n("lgd", "<CMD>:lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition (LSP)", buffer = bufnr })
  Map.leader.n("lh", "<CMD>:lua vim.lsp.buf.hover()<CR>", { desc = "Cursor symbol information (LSP)", buffer = bufnr })
  Map.leader.n("lr", "<CMD>:lua vim.lsp.buf.rename()<CR>", { desc = "Rename file (LSP)", buffer = bufnr })
  Map.leader.n("lca", "<CMD>:lua vim.lsp.buf.code_action()<CR>", { desc = "Cursor code Action (LSP)", buffer = bufnr })
  Map.leader.n("lf", "<CMD>:lua vim.lsp.buf.format()<CR>", { desc = "Format file (LSP)", buffer = bufnr })
end

-- Git (g) --
Map.leader.n("gg", "<CMD>LazyGit<CR>", { desc = "Open LazyGit (GIT)" })
Map.leader.n("gbl", "<CMD>Gitsigns blame_line full=true<CR>", { desc = "Blame line (GIT)" })
Map.leader.n("gbt", "<CMD>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle blame line (GIT)" })

-- Explorer (e) --
Map.leader.n("ed", "<CMD>:lua MiniFiles.open()<CR>", { desc = "Open directory (EXP)" })
Map.leader.n("ef", "<CMD>:lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>", { desc = "Open file directory (EXP)" })

-- Buffer (b) --
-- TODO

-- Visits (v) --
-- TODO

-- Package Manager (p) --
Map.leader.n("pp", "<CMD>Lazy<CR>", { desc = "Open Deps (PKG)" })
Map.leader.n("pi", "<CMD>Lazy install<CR>", { desc = "Deps install (PKG)" })
Map.leader.n("pu", "<CMD>Lazy update<CR>", { desc = "Deps update (PKG)" })
Map.leader.n("pc", "<CMD>Lazy clean<CR>", { desc = "Deps clean (PKG)" })
Map.leader.n("ps", "<CMD>Lazy sync<CR>", { desc = "Deps sync (PKG)" })

return Map
