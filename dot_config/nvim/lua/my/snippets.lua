local ls = require "luasnip"
local extras = require "luasnip.extras"
local snippet = ls.s
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

ls.config.set_config {
	history = true,
	updateevents = "TextChanged,TextChangedI",
}

ls.add_snippets(nil, {
	all = {
		snippet("simple", t "wow, you were right!"),

		snippet({ trig = "date" }, {
			f(function()
				return string.format(string.gsub(vim.bo.commentstring, "%%s", " %%s"), os.date())
			end, {}),
		}),
		snippet({ trig = "haiku" }, {
			f(function()
				-- stylua: ignore
				local adj = { "autumn", "hidden", "bitter", "misty", "silent", "empty",
					"dry", "dark", "summer", "icy", "delicate", "quiet", "white", "cool",
					"spring", "winter", "patient", "twilight", "dawn", "crimson", "wispy",
					"weathered", "blue", "billowing", "broken", "cold", "damp", "falling",
					"frosty", "green", "long", "late", "lingering", "bold", "little", "morning",
					"muddy", "old", "red", "rough", "still", "small", "sparkling", "thrumming",
					"shy", "wandering", "withered", "wild", "black", "young", "holy", "solitary",
					"fragrant", "aged", "snowy", "proud", "floral", "restless", "divine",
					"polished", "ancient", "purple", "lively", "nameless" }
				-- stylua: ignore
				local noun = { "waterfall", "river", "breeze", "moon", "rain", "wind", "sea", "morning",
					"snow", "lake", "sunset", "pine", "shadow", "leaf", "dawn", "glitter", "forest",
					"hill", "cloud", "meadow", "sun", "glade", "bird", "brook", "butterfly",
					"bush", "dew", "dust", "field", "fire", "flower", "firefly", "feather", "grass",
					"haze", "mountain", "night", "pond", "darkness", "snowflake", "silence",
					"sound", "sky", "shape", "surf", "thunder", "violet", "water", "wildflower",
					"wave", "water", "resonance", "sun", "log", "dream", "cherry", "tree", "fog",
					"frost", "voice", "paper", "frog", "smoke", "star" }

				return string.format("%s %s", adj[math.random(1, #adj)], noun[math.random(1, #noun)])
			end, {}),
		}),
	},
	sh = {
		snippet("shebang", fmt("#!/bin/sh\n{}", { i(0) })),
	},
	python = {
		snippet("shebang", fmt("#!/usr/bin/env python\n{}", { i(0) })),
	},
	markdown = {
		snippet(
			"link",
			fmt("[{}]({})", {
				i(1, "name"),
				i(2, "url"),
			})
		),
	},
	zig = {
		snippet(
			"main",
			t {
				'const std = @import("std");',
				"",
				"pub fn main() void {",
				"    const stdout = std.io.getStdOut().writer();",
				'    try stdout.print("Hello, {s}!\\n", .{"world"});',
				"}",
			}
		),

		snippet(
			"gpa",
			t {
				"var gpa = std.heap.GeneralPurposeAllocator(.{}){};",
				"defer std.debug.assert(!gpa.deinit());",
				"",
				"const allocator = gpa.allocator();",
			}
		),
		snippet("imps", t 'const std = @import("std");'),

		snippet("panic", t '@panic("TODO")'),

		snippet(
			"fn",
			fmta("fn <>(<>) void{\n    <>\n}", {
				i(1, "name"),
				c(2, { t "comptime T: type", t "" }),
				i(3, "body"),
			})
		),

		snippet(
			"info",
			fmta('std.log.info("<>", .{<>});', {
				c(1, { t "{}", t "{s}", t "{any}" }),
				i(2, "vars"),
			})
		),

		snippet(
			"info_var",
			fmta('std.log.info("<>={}", .{<>});', {
				i(1, "var_name"),
				extras.rep(1),
			})
		),
		snippet(
			"print",
			fmta('std.debug.print("<>\\n", .{<>});', {
				c(1, { t "{}", t "{s}", t "{any}" }),
				i(2, "vars"),
			})
		),
	},
})

-- shorcut to source my luasnips file again, which will reload my snippets
-- vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/my/snippets.lua<CR>")
