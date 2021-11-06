
-------------------- PLUGINS -------------------------------
require("packer").startup(function()
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	use("tpope/vim-commentary")
	use("tpope/vim-surround")
	use("tpope/vim-repeat")
	use("tpope/vim-sensible")
	use("tpope/vim-fugitive")

	use("JoosepAlviste/nvim-ts-context-commentstring")

	use("neovim/nvim-lspconfig")

	use({
		"hrsh7th/nvim-cmp",
		requires = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
		},
		-- config = function() print "commmm" end,
	})

	use({
		"nvim-treesitter/nvim-treesitter",
	})
	use({
		"ojroques/nvim-lspfuzzy",
		config = require("lspfuzzy").setup({}),
		requires = {
			{ "junegunn/fzf" },
			{ "junegunn/fzf.vim" }, -- to enable preview (optional)
		},
	})

	use("nvim-lua/lsp-status.nvim")

	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	-- use({
	-- 	"itchyny/lightline.vim",
	-- 	setup = function()
	-- 		g["lightline"] = {
	-- 			colorscheme = "embark",
	-- 			active = {
	-- 				left = {
	-- 					{ "mode", "paste" },
	-- 					{ "lsp_status", "readonly", "filename", "modified" },
	-- 				},
	-- 			},
	-- 			component_expand = { lsp_status = "v:lua.lspstat" },
	-- 		}
	-- 	end,
	-- })
	use("itchyny/lightline.vim")
	use("lambdalisue/suda.vim")
	use("lukas-reineke/indent-blankline.nvim")

	use("shaunsingh/nord.nvim")
	use("embark-theme/vim")
	use("mboughaba/i3config.vim")
	use "ojroques/vim-oscyank"
end)
