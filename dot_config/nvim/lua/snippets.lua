local ls = require("luasnip")
local snippet = ls.s
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local events = require("luasnip.util.events")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")

ls.config.set_config({
	history = true,
	updateevents = "TextChanged,TextChangedI",
})

ls.snippets = {
	all = {
		snippet("simple", t("wow, you were right!")),

		-- date -> Tue 16 Nov 2021 09:43:49 AM EST
		snippet({ trig = "date" }, {
			f(function()
				return string.format(string.gsub(vim.bo.commentstring, "%%s", " %%s"), os.date())
			end, {}),
		}),
	},
	zig = {
		snippet(
			"print",
			fmta('std.debug.print("<>\\n"), .{<>});', {
				c(1, { t("{}"), t("{s}"), t("{any}") }),
				i(2, "vars"),
			})
		),
	},
}

vim.keymap.inoremap({
	"<c-k>",
	function()
		if ls.expand_or_jumpable() then
			ls.expand_or_jump()
		end
	end,
	{ silent = true },
})

vim.keymap.inoremap({
	"<c-j>",
	function()
		if ls.jumpable(-1) then
			ls.jump(-1)
		end
	end,
	{ silent = true },
})

vim.keymap.inoremap({
	"<c-l>",
	function()
		if ls.choice_active() then
			ls.change_choice(1)
		end
	end,
})

-- shorcut to source my luasnips file again, which will reload my snippets
-- vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/luasnip.lua<CR>")
