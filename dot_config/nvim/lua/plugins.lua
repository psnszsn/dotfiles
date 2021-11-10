-------------------- PLUGINS -------------------------------
require("packer").startup(function()
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	use("tpope/vim-commentary")
	use("tpope/vim-fugitive")
	use("tpope/vim-repeat")
	use("tpope/vim-sensible")
	use("tpope/vim-surround")

	use("nvim-treesitter/nvim-treesitter")
	use("JoosepAlviste/nvim-ts-context-commentstring")
	use("lukas-reineke/indent-blankline.nvim")
	use("neovim/nvim-lspconfig")
	-- use("nvim-lua/lsp-status.nvim")
	use ("windwp/nvim-autopairs")

	use("itchyny/lightline.vim")
	use("lambdalisue/suda.vim")
	use("mboughaba/i3config.vim")
	use("ojroques/vim-oscyank")

	use("shaunsingh/nord.nvim")
	use("embark-theme/vim")

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
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" }, { "gbrlsnchs/telescope-lsp-handlers.nvim" } },
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
end)
