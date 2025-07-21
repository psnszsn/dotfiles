if vim.b.did_ftplugin then
	return
end

vim.b.did_ftplugin = 1

vim.opt_local.tabstop = 4
vim.opt_local.commentstring = '// %s'
