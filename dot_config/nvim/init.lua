vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.filetype.add({ extension = { zig2 = "zig2" } })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	require("my.plugins.lsp"),
	require("my.plugins.cmp"),
	require("my.plugins.telescope"),
	require("my.plugins.treesitter"),
	require("my.plugins.gitsigns"),
	require("my.plugins.lint"),
	require("my.plugins.conform"),
	require("my.plugins.mini"),
	-- require("my.plugins.debugprint"),

	{ "folke/which-key.nvim", opts = {} },
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("kanagawa-dragon")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				icons_enabled = false,
				component_separators = "|",
				section_separators = "",
			},
		},
	},
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {
		indent = {
			char = "┊",
		},
	} },
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	{ "nvim-treesitter/nvim-treesitter-context" },
	{
		"stevearc/oil.nvim",
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
}, {})

require("my.options")
require("my.keymaps")
require("my.lsp")
require("my.disable_builtin")
require("my.clipboard")

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
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

-- ÃĂªŞÞŢãăºşþţ
vim.api.nvim_create_user_command(
	"FixSub",
	"set fileencoding=utf-8 | %s/Ã/Ă/ge | %s/ª/Ș/ge | %s/Þ/Ț/ge | %s/ã/ă/ge | %s/º/ș/ge | %s/þ/ț/ge",
	{}
)

vim.filetype.add({
	extension = {
		zon = "zig",
	},
})
