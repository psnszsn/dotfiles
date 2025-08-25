return {
	'saghen/blink.cmp',
	dependencies = {
		'L3MON4D3/LuaSnip',
		version = 'v2.*',
		config = function()
			local luasnip = require 'luasnip'
			-- require("luasnip.loaders.from_vscode").lazy_load()
			luasnip.config.setup {}
			require 'my.snippets'
		end,
	},

	version = '1.*',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = 'enter' },

		completion = {
			menu = { border = 'none' },
			list = { selection = { preselect = false, auto_insert = true } },
			-- documentation = {
			-- 	auto_show = false,
			-- },
		},
		snippets = { preset = 'luasnip' },
		fuzzy = { implementation = 'lua' },

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer' },
		},
	},
	opts_extend = { 'sources.default' },
}
