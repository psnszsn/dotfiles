local ls = require("luasnip")
local snippet = ls.s
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

ls.config.set_config({
	history = true,
	updateevents = "TextChanged,TextChangedI",
})

ls.add_snippets(nil, {
	all = {
		snippet("simple", t("wow, you were right!")),

		snippet({ trig = "date" }, {
			f(function()
				return string.format(string.gsub(vim.bo.commentstring, "%%s", " %%s"), os.date())
			end, {}),
		}),
	},
	sh = {
		snippet("shebang", fmt("#!/bin/sh\n{}", { i(0) })),
	},
	python = {
		snippet("shebang", fmt("#!/usr/bin/env python\n{}", { i(0) })),
	},
	zig = {
		snippet(
			"main",
			t({
				'const std = @import("std");',
				"",
				"pub fn main() void {",
				"    const stdout = std.io.getStdOut().writer();",
				'    try stdout.print("Hello, {s}!\\n", .{"world"});',
				"}",
			})
		),

		snippet(
			"gpa",
			t({
				"var gpa = std.heap.GeneralPurposeAllocator(.{}){};",
				"defer std.debug.assert(!gpa.deinit());",
				"",
				"const allocator = gpa.allocator();",
			})
		),
		snippet("imps", t('const std = @import("std");')),

		snippet(
			"fn",
			fmta("fn <>(<>) void{\n    <>\n}", {
				i(1, "name"),
				c(2, { t("comptime T: type"), t("") }),
				i(3, "body"),
			})
		),

		snippet(
			"info",
			fmta('std.log.info("<>", .{<>});', {
				c(1, { t("{}"), t("{s}"), t("{any}") }),
				i(2, "vars"),
			})
		),
		snippet(
			"print",
			fmta('std.debug.print("<>\\n", .{<>});', {
				c(1, { t("{}"), t("{s}"), t("{any}") }),
				i(2, "vars"),
			})
		),
	},
})

-- shorcut to source my luasnips file again, which will reload my snippets
vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/my/snippets.lua<CR>")
