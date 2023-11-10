vim.g.mapleader = ","

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>qa", vim.cmd.qa)
vim.keymap.set("n", "<leader>q", vim.cmd.q)
vim.keymap.set("n", "<leader>s", vim.cmd.w)
vim.cmd [[ imap <leader>s <ESC>:w<CR> ]]

vim.keymap.set('n', '<leader>h', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<leader>j', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<leader>k', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<leader>l', '<C-w>l', { noremap = true })
vim.keymap.set('n', '<leader>p', '<ESC>:Prettier<CR>', { noremap = true })

vim.keymap.set("n", "<F5>", vim.cmd.UndotreeToggle)

vim.keymap.set("n", "<leader>gs", ':vertical Git<CR>')
vim.keymap.set('n', '<leader>gpu', ':Git push<CR>')
vim.keymap.set('n', '<leader>gfa', ':Git add %<CR>')

vim.keymap.set('n', '<CR>', ':nohlsearch<CR>')
