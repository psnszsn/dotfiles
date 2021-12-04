if vim.b.did_ftplugin then
	print "DONE"
	return
end
vim.b.did_ftplugin = 1

local opt_local = vim.opt_local

opt_local.expandtab = true
opt_local.tabstop = 8
opt_local.softtabstop = 4
opt_local.shiftwidth = 4
opt_local.suffixesadd = { ".zig", ".zir" }



opt_local.commentstring="// %s"
-- opt_local.formatoptions-=t formatoptions+=croql
