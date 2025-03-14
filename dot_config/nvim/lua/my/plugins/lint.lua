return {
	'mfussenegger/nvim-lint',
	config = function()
		local lint = require 'lint'
		lint.linters.revive.args = {
			'-formatter',
			'json',
			'-config',
			vim.env.HOME .. '/.config/revive.toml',
		}
		lint.linters_by_ft = {
			-- zig = { "compiler" },
			-- python = {
			-- 	'mypy',
			-- },
			go = {
				'revive',
			},
		}
	end,
}
