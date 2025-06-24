vim.lsp.enable {
	'luals',
	'zls',
}
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
	callback = function(event)
		vim.keymap.set('n', 'gs', function()
			vim.lsp.buf.definition()
		end, { buffer = event.buf })

		vim.keymap.set(
			'n',
			'<leader>ds',
			require('telescope.builtin').lsp_document_symbols,
			{ buffer = event.buf, desc = '[D]ocument [S]ymbols' }
		)
	end,
})

vim.diagnostic.config {
	-- Use the default configuration
	-- virtual_lines = true,

	-- Alternatively, customize specific options
	virtual_lines = {
		-- Only show virtual line diagnostics for the current cursor line
		current_line = true,
	},
}
