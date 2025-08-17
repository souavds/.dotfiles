local M = {}

M.map = vim.keymap.set

M.map('n', '<leader>o', ':update<CR> :source<CR>', { desc = 'Update and source' })
M.map('n', '<leader>w', ':write<CR>', { desc = 'Save' })
M.map('n', '<leader>q', ':quit<CR>', { desc = 'Quit' })

M.map('n', '<esc>', ':noh<CR>', { silent = true, desc = 'Remove search highlighting, dismiss popups' })

-- Text manipulation
M.map('n', '<A-j>', ':m .+1<CR>==', { silent = true, noremap = true, desc = 'Move line down' })
M.map('n', '<A-k>', ':m .-2<CR>==', { silent = true, noremap = true, desc = 'Move line up' })
M.map('v', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true, noremap = true, desc = 'Move selection down' })
M.map('v', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true, noremap = true, desc = 'Move selection up' })
M.map('x', 'J', ":m '>+1<CR>gv=gv", { silent = true, noremap = true, desc = 'Move visual block down' })
M.map('x', 'K', ":m '<-2<CR>gv=gv", { silent = true, noremap = true, desc = 'Move visual block up' })
M.map('x', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true, noremap = true, desc = 'Move visual block down' })
M.map('x', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true, noremap = true, desc = 'Move visual block up' })
M.map('v', 'p', '"_dP', { silent = true, noremap = true, desc = 'Paste without replacing selection' })
M.map('v', '<', '<gv^', { silent = true, noremap = true, desc = 'Shift selection left' })
M.map('v', '>', '>gv^', { silent = true, noremap = true, desc = 'Shift selection right' })

return M
