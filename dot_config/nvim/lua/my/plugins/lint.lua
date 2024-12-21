return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require "lint"
		lint.linters_by_ft = {
			-- zig = { "compiler" },
			python = {
				"mypy",
			},
		}
	end,
}
