vim.cmd('syntax on')
vim.cmd('set number')
vim.cmd('command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument')
