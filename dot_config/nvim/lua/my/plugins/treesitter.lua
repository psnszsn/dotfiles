return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		-- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
		-- parser_config.zig2 = {
		-- 	install_info = {
		-- 		url = "/home/vlad/clonez/tree-sitter-zig", -- local path or git repo
		-- 		files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
		-- 		-- optional entries:
		-- 		generate_requires_npm = false, -- if stand-alone parser without npm dependencies
		-- 		requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
		-- 	},
		-- 	filetype = "zig", -- if filetype does not match the parser name
		-- }
		require("nvim-treesitter.configs").setup {
			ensure_installed = "all",
			ignore_install = {},
			auto_install = false,
			sync_install = false,
			modules = {},

			highlight = {
				enable = true,
				disable = function(lang, buf)
					local max_filesize = 50 * 1024 -- 50 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<c-space>",
					node_incremental = "<c-space>",
					scope_incremental = "<c-s>",
					node_decremental = "<M-space>",
				},
			},
		}
	end,
}
