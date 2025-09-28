return {
	'stevearc/conform.nvim',
	-- event = { "BufWritePre" },
	-- cmd = { "ConformInfo" },
	keys = {
		{
			-- Customize or remove this keymap to your liking
			'<leader>fo',
			function()
				require('conform').format { async = true, lsp_fallback = true }
			end,
			mode = '',
			desc = 'Format buffer',
		},
	},
	-- Everything in opts will be passed to setup()
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			lua = { 'stylua' },
			python = { 'ruff_format' },
			javascript = { 'prettier' },
			shtml = { 'superhtml' },
			json = { 'jq' },
			jsonc = { 'denonerd' },
			fish = { 'fish_indent' },
			terraform = { 'terraform_fmt' },
			-- zig = { "zigfmt" },
		},
		-- Set up format-on-save
		-- format_on_save = { timeout_ms = 500, lsp_fallback = true },
		-- Customize formatters
		formatters = {
			shfmt = {
				prepend_args = { '-i', '2' },
			},
			denonerd = {
				command = 'nerdctl',
				args = { 'run', '-i', 'denoland/deno:2.5.2', 'fmt', '--ext', 'jsonc', '-' },
			},
		},
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
