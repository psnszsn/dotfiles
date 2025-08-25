require 'my.nested'

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system {
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	require 'my.plugins.cmp',
	require 'my.plugins.treesitter',
	require 'my.plugins.gitsigns',
	require 'my.plugins.lint',
	require 'my.plugins.conform',
	require 'my.plugins.mini',
	-- require("my.plugins.debugprint"),

	{ 'j-hui/fidget.nvim', opts = {} },

	{ 'folke/which-key.nvim', opts = {} },
	{ 'sindrets/diffview.nvim', opts = {} },
	{
		'folke/flash.nvim',
		event = 'VeryLazy',
		---@type Flash.Config
		opts = {},
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
			{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		},
	},
	-- {
	-- 	'ggandor/leap.nvim',
	-- 	config = function()
	-- 		-- require('leap').create_default_mappings()
	-- 		vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
	-- 		vim.keymap.set({ 'n', 'x', 'o' }, '<C-s>', '<Plug>(leap-backward)')
	-- 		vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)')
	-- 	end,
	-- 	dependencies = { 'tpope/vim-repeat' },
	-- },
	{
		'rebelot/kanagawa.nvim',
		priority = 1000,
		config = function()
			vim.cmd.colorscheme 'kanagawa-dragon'
		end,
	},
	{
		'nvim-lualine/lualine.nvim',
		opts = {
			options = {
				icons_enabled = false,
				component_separators = '|',
				section_separators = '',
			},
		},
	},
	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		config = function()
			local hooks = require 'ibl.hooks'
			hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
			-- hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
			require('ibl').setup {
				indent = {
					char = '┊',
				},
			}
		end,
	},
	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		opts = {},
	},
	{ 'nvim-treesitter/nvim-treesitter-context' },
	{
		'stevearc/oil.nvim',
		opts = {},
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	},
	{
		'toppair/peek.nvim',
		event = { 'VeryLazy' },
		build = 'deno task --quiet build:fast',
		config = function()
			require('peek').setup()
			vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
			vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
		end,
	},
}, {})

require 'my.options'
require 'my.keymaps'
require 'my.lsp'
require 'my.disable_builtin'
require 'my.bazel'
require 'my.weburl'
require 'my.term'
require 'my.rmcomment'
require 'my.bufdelete'

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})

local colon_ln_group = vim.api.nvim_create_augroup('ColonLN', { clear = true })
vim.api.nvim_create_autocmd('BufNewFile', {
	callback = function()
		local bufnr = vim.fn.bufnr '%'
		local bufname = vim.api.nvim_buf_get_name(0)
		-- local bufname = "asd:"
		local filename, line = bufname:match '(.+):(%d+)$'
		-- local reg = vim.regex([[.*:[0-9]\+\(:[0-9]\+\)\=]])
		-- local m = reg:match_str("asdf:9")

		if filename and vim.fn.filereadable(filename) == 1 then
			-- vim.cmd("e " .. vim.fn.fnameescape(filename))
			vim.cmd.edit { filename, mods = { keepalt = true } }
			vim.api.nvim_buf_delete(bufnr, {})
			vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
			vim.cmd.filetype 'detect'
		end
		vim.print(filename, line)
		print('rEaDiNg bFr: ', bufname)
	end,
	group = colon_ln_group,
	pattern = '*:[0-9]*{:[0-9]*}\\=',
})

-- ÃĂªŞÞŢãăºşþţ
vim.api.nvim_create_user_command(
	'FixSub',
	'set fileencoding=utf-8 | %s/Ã/Ă/ge | %s/ª/Ș/ge | %s/Þ/Ț/ge | %s/ã/ă/ge | %s/º/ș/ge | %s/þ/ț/ge',
	{}
)

vim.filetype.add {
	extension = {
		zon = 'zig',
	},
}
vim.filetype.add {
	pattern = {
		['/tmp/arh%-cli.*'] = 'markdown',
	},
}

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
	group = vim.api.nvim_create_augroup('Lint', { clear = true }),
	callback = function()
		require('lint').try_lint()
	end,
})

vim.api.nvim_create_user_command('GitPager', function()
	require('my.pager').run()
end, { desc = 'enable git pager mode' })

vim.api.nvim_create_user_command('Doas', function()
	require('my.doas').doas()
end, {})
