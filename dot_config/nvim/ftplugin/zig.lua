if vim.b.did_ftplugin then
	-- print "DONE"
	return
end

vim.b.did_ftplugin = 1

-- print("Hello Zig!")
local opt_local = vim.opt_local

opt_local.expandtab = true
opt_local.tabstop = 8
opt_local.softtabstop = 4
opt_local.shiftwidth = 4
opt_local.suffixesadd = { '.zig', '.zir', '.zon' }

vim.cmd.compiler 'zig_build2'

opt_local.commentstring = '// %s'
-- opt_local.formatoptions-=t formatoptions+=croql
--
vim.keymap.set('n', '<leader>sl', function()
	local result = vim.system({ 'zig', 'env' }, { text = true }):wait()
	local std_dir = result.stdout:match '%.std_dir = "([^"]+)"'
	require('mini.pick').builtin.files(nil, { source = { name = 'Zig std', cwd = std_dir } })
end, { desc = 'Zig std' })

vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = { '*.zig', '*.zon' },
	group = vim.api.nvim_create_augroup('zlsfixall', { clear = true }),
	callback = function(ev)
		vim.lsp.buf.code_action {
			context = { only = { 'source.fixAll' } },
			apply = true,
		}
	end,
})
