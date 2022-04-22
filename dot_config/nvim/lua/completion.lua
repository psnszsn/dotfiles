local cmp = require("cmp")
local types = require("cmp.types")
local luasnip = require("luasnip")

-- cmp.setup({
-- 	snippet = {
-- 		expand = function(args)
-- 			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
-- 		end,
-- 	},

-- 	mapping = {
-- 		["<C-d>"] = cmp.mapping.scroll_docs(-4),
-- 		["<C-f>"] = cmp.mapping.scroll_docs(4),
-- 		["<C-Space>"] = cmp.mapping.complete(),
-- 		-- ["<C-e>"] = cmp.mapping.close(),
-- 		["<CR>"] = cmp.mapping.confirm({ select = true }),

-- 		["<C-n>"] = {
-- 			i = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }),
-- 		},
-- 		["<C-p>"] = {
-- 			i = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
-- 		},
-- 		["<C-y>"] = {
-- 			i = cmp.mapping.confirm({ select = false }),
-- 		},
-- 		["<C-e>"] = {
-- 			i = cmp.mapping.abort(),
-- 		},
-- 	},

-- 	sources = cmp.config.sources({
-- 		{ name = "luasnip" }, -- For luasnip users.
-- 		{ name = "nvim_lsp" },
-- 		-- { name = "nvim_lua" },
-- 		{ name = "buffer" },
-- 		{ name = "path" },
-- 	}),
-- })

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = "luasnip" }, -- For luasnip users.
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
	}, {}),
})
