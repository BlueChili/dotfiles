vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.cursorline = true

vim.opt.incsearch = true
vim.opt.history = 10000

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.backspace = '2'		-- more powerful backspacing
vim.opt.tabstop = 4		-- 2 spaces -> tabstops on file read
vim.opt.softtabstop = 4  		-- tabs map to 2 spaces on EDITING mode
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.colorcolumn = '80'

vim.opt.termguicolors = true

vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.g.user_emmet_leader_key = "<leader>e"

vim.cmd [[ let g:netrw_preview = 1 ]]


-- vim.cmd [[ let g:prettier#autoformat = 1 ]]
