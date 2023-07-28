-------------------- PLUGINS -------------------------------
-- require("packer").startup(function(use)
-- 	-- Packer can manage itself
-- 	use("wbthomason/packer.nvim")

-- 	use("lambdalisue/suda.vim")
-- 	use("ojroques/vim-oscyank")
-- 	-- use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'}

-- 	use("shaunsingh/nord.nvim")
-- 	use("embark-theme/vim")
-- 	use("rebelot/kanagawa.nvim")
-- 	use("bluz71/vim-nightfly-guicolors")

--     use {
--       'stevearc/oil.nvim',
--       config = function() require('oil').setup() end
--     }

-- end)

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

	"tpope/vim-commentary",
	"tpope/vim-fugitive",
	"tpope/vim-repeat",
	"tpope/vim-sensible",
	"tpope/vim-surround",

	"lambdalisue/suda.vim",
	"windwp/nvim-autopairs",
	"ggandor/leap.nvim",
	"itchyny/lightline.vim",

	"lukas-reineke/indent-blankline.nvim",
	{ "catppuccin/nvim", name = "catppuccin" },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"jose-elias-alvarez/null-ls.nvim",
		},
	},
	{
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			-- 'rafamadriz/friendly-snippets',
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
		},
	},

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		cond = function()
			return vim.fn.executable("make") == 1
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		build = ":TSUpdate",
	},

	{
		"stevearc/oil.nvim",
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
})
