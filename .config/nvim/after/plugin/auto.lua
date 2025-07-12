vim.cmd [[
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
]]

-- HTML file config
vim.cmd [[
augroup HTMLFileType
	autocmd!
	autocmd FileType html setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd FileType html setlocal formatoptions+=t
    autocmd FileType html setlocal textwidth=110
    autocmd BufRead,BufNewFile *.html setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
augroup END
]]

vim.cmd [[
augroup JSFileType
	autocmd!
	autocmd FileType javascript setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd FileType javascript setlocal formatoptions+=t
    autocmd BufRead,BufNewFile *.js setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
    autocmd BufRead,BufNewFile *.jsx setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
augroup END
]]

vim.cmd [[
augroup TSFileType
	autocmd!
	autocmd FileType typescript setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd FileType typescript setlocal formatoptions+=t
    autocmd BufRead,BufNewFile *.ts setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
    autocmd BufRead,BufNewFile *.tsx setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
augroup END
]]

vim.cmd [[
augroup AstroFileType
	autocmd!
    autocmd FileType astro setlocal formatoptions+=t
    autocmd BufRead,BufNewFile *.astro setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
augroup END
]]
