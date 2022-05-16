-- NEOVIM CONFIG
-------------------- HELPERS -------------------------------
local cmd, fn, g = vim.cmd, vim.fn, vim.g

function _G.put(...)
	local objects = {}
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		table.insert(objects, vim.inspect(v))
	end

	print(table.concat(objects, "\n"))
	return ...
end

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
g.csv_no_conceal = 1
g.xml_syntax_folding = 1
g.vim_markdown_conceal = 0
g.vim_markdown_conceal_code_blocks = 0
g.embark_terminal_italics = 1
-- g['completion_enable_snippet'] = 'UltiSnips'
g.do_filetype_lua = 1
g.did_load_filetypes = 0


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
})

local telescope = require("telescope")
telescope.load_extension("lsp_handlers")

require("nvim-autopairs").setup({
	fast_wrap = {},
})
