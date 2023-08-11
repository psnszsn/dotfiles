-- NEOVIM CONFIG
-------------------- HELPERS -------------------------------
local cmd, fn, g = vim.cmd, vim.fn, vim.g

function RELOAD(pkg)
	package.loaded[pkg] = nil
	return require(pkg)
end

require("plugins")
require("mappings")
require("options")
require("snippets")
require("lsp")
require("completion")
require("disable_builtin")
require("clipboard")

-------------------- PLUGIN SETUP --------------------------
-- g['netrw_banner'] = 0
g.loaded_netrw = 1 -- disable netrw
g.loaded_netrwPlugin = 1 --disable netrw
g.csv_no_conceal = 1
g.xml_syntax_folding = 1
g.vim_markdown_conceal = 0
g.vim_markdown_conceal_code_blocks = 0
g.embark_terminal_italics = 1
-- g['completion_enable_snippet'] = 'UltiSnips'
g.do_filetype_lua = 1
--g.did_load_filetypes = 0

-- ÃĂªŞÞŢãăºşþţ
vim.api.nvim_create_user_command(
	"FixSub",
	"set fileencoding=utf-8 | %s/Ã/Ă/ge | %s/ª/Ș/ge | %s/Þ/Ț/ge | %s/ã/ă/ge | %s/º/ș/ge | %s/þ/ț/ge",
	{}
)

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ on_visual = false })
	end,
	group = highlight_group,
	pattern = "*",
})

local colon_ln_group = vim.api.nvim_create_augroup("ColonLN", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
	callback = function()
		local bufnr = vim.fn.bufnr("%")
		local bufname = vim.api.nvim_buf_get_name(0)
		-- local bufname = "asd:"
		local filename, line = bufname:match("(.+):(%d+)$")
		-- local reg = vim.regex([[.*:[0-9]\+\(:[0-9]\+\)\=]])
		-- local m = reg:match_str("asdf:9")

		if filename and vim.fn.filereadable(filename) == 1 then
			-- vim.cmd("e " .. vim.fn.fnameescape(filename))
			vim.cmd.edit({ filename, mods = { keepalt = true } })
			vim.api.nvim_buf_delete(bufnr, {})
			vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
			vim.cmd.filetype("detect")
		end
		vim.print(filename, line)
		print("rEaDiNg bFr: ", bufname)
	end,
	group = colon_ln_group,
	pattern = "*:[0-9]*{:[0-9]*}\\=",
})

local ts = require("nvim-treesitter.configs")
ts.setup({
	ensure_installed = "all",
	highlight = { enable = true },
	incremental_selection = { enable = true },
	indent = { enable = true },
	-- ignore_install = { "zig"},
	context_commentstring = {
		enable = true,
	},
	--textobjects = {
	--	select = {
	--		enable = true,

	--		lookahead = true,

	--		keymaps = {
	--			-- You can use the capture groups defined in textobjects.scm
	--			["af"] = "@function.outer",
	--			["if"] = "@function.inner",
	--			["ac"] = "@class.outer",
	--			-- You can optionally set descriptions to the mappings (used in the desc parameter of
	--			-- nvim_buf_set_keymap) which plugins like which-key display
	--			["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
	--			-- You can also use captures from other query groups like `locals.scm`
	--			["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
	--		},
	--		-- You can choose the select mode (default is charwise 'v')
	--		--
	--		-- Can also be a function which gets passed a table with the keys
	--		-- * query_string: eg '@function.inner'
	--		-- * method: eg 'v' or 'o'
	--		-- and should return the mode ('v', 'V', or '<c-v>') or a table
	--		-- mapping query_strings to modes.
	--		selection_modes = {
	--			["@parameter.outer"] = "v", -- charwise
	--			["@function.outer"] = "V", -- linewise
	--			["@class.outer"] = "<c-v>", -- blockwise
	--		},
	--		-- If you set this to `true` (default is `false`) then any textobject is
	--		-- extended to include preceding or succeeding whitespace. Succeeding
	--		-- whitespace has priority in order to act similarly to eg the built-in
	--		-- `ap`.
	--		--
	--		-- Can also be a function which gets passed a table with the keys
	--		-- * query_string: eg '@function.inner'
	--		-- * selection_mode: eg 'v'
	--		-- and should return true of false
	--		include_surrounding_whitespace = true,
	--	},
	-- },
})

local telescope = require("telescope")
-- telescope.load_extension("lsp_handlers")
telescope.load_extension("fzf")

require("nvim-autopairs").setup({
	fast_wrap = {},
})

require("leap").add_default_mappings()
vim.keymap.del({'x', 'o'}, 'x')
vim.keymap.del({'x', 'o'}, 'X')

-- require("bufferline").setup{}
--
