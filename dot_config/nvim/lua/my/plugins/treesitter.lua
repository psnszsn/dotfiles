return {
	'nvim-treesitter/nvim-treesitter',
	dependencies = {
		'nvim-treesitter/nvim-treesitter-context',
		{ 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
	},
	branch = 'main',
	lazy = false,
	build = ':TSUpdate',
	config = function()
		local treesitter = require 'nvim-treesitter'
		treesitter.install {
			'c',
			'javascript',
			'lua',
			'markdown',
			'markdown_inline',
			'python',
			'query',
			'rust',
			'superhtml',
			'vim',
			'vimdoc',
			'zig',
		}
	end,
}
