-- NEOVIM CONFIG
-------------------- HELPERS -------------------------------
local cmd, fn, g = vim.cmd, vim.fn, vim.g
local opt = vim.opt

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

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

	use("hrsh7th/nvim-compe")
	use({ "nvim-treesitter/nvim-treesitter", config = function() end })
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
		requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
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
	use "itchyny/lightline.vim"
	use("lambdalisue/suda.vim")
	use("lukas-reineke/indent-blankline.nvim")

	use("shaunsingh/nord.nvim")
	use("embark-theme/vim")
	use("mboughaba/i3config.vim")
end)

-------------------- PLUGIN SETUP --------------------------
-- g['netrw_banner'] = 0
g["csv_no_conceal"] = 1
g["xml_syntax_folding"] = 1
g["vim_markdown_conceal"] = 0
g["vim_markdown_conceal_code_blocks"] = 0
g["embark_terminal_italics"] = 1
-- g['completion_enable_snippet'] = 'UltiSnips'

cmd("au TextYankPost * lua vim.highlight.on_yank {on_visual = false}") -- disabled in visual mode

-- ÃĂªŞÞŢãăºşþţ
cmd(
	"command FixSub set fileencoding=utf-8 | %s/Ã/Ă/ge | %s/ª/Ș/ge | %s/Þ/Ț/ge | %s/ã/ă/ge | %s/º/ș/ge | %s/þ/ț/ge"
)

-------------------- OPTIONS -------------------------------
local indent = 4
cmd("colorscheme embark")
opt.expandtab = false -- Use spaces instead of tabs
opt.shiftwidth = indent -- Size of an indent
opt.smartindent = true -- Insert indents automatically
opt.tabstop = indent -- Number of spaces tabs count for

opt.mouse = "a" -- Use mouse
opt.undofile = true -- Persistend undo
opt.hidden = true -- Enable background buffers
opt.ignorecase = true -- Ignore case
opt.joinspaces = false -- No double spaces after a dot with join
opt.scrolloff = 4 -- Lines of context
opt.shiftround = true -- Round indent
opt.sidescrolloff = 8 -- Columns of context
opt.smartcase = true -- Don't ignore case with capital letters
opt.splitbelow = true -- Put new windows below current one
opt.splitright = true -- Put new windows right of current one
opt.termguicolors = true -- True color support
opt.updatetime = 100 -- Delay before swap file is saved
opt.conceallevel = 0 -- Disable conceal
opt.colorcolumn = "80" -- Line length marker
opt.cursorline = true -- Highlight cursor line
opt.list = false -- Show some invisible characters
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.signcolumn = "yes" -- Show sign column

opt.listchars = { tab = "▸ ", trail = "·", nbsp = "+", eol = "¬" }
-- set listchars=tab:▸\ ,eol:¬
-- asdasd  asdasd 
opt.shortmess:append({ c = true })
opt.completeopt = { "menuone", "noselect" }

-------------------- MAPPINGS ------------------------------
vim.g.mapleader = " "
map("", "<leader>c", '"+y')
map("n", "<leader>v", ":tabe $MYVIMRC<CR>")
map("n", "<leader>l", ":set list! | :IndentBlanklineToggle<CR>")
map("n", "<leader>-", ":Files<CR>")
map("n", "<leader>[", ":GFiles<CR>")
map("n", "<leader>]", ":Buffers<CR>")
map("n", "-", ":Ex<CR>")
map("n", "<leader>a", "<esc>ggVG<CR>")

map("n", "\\", "<cmd>noh<CR>")
map("n", "U", "<C-R>")

map("", "<C-h>", "<C-w>h")
map("", "<C-j>", "<C-w>j")
map("", "<C-k>", "<C-w>k")
map("", "<C-l>", "<C-w>l")

map("", "H", "^")
map("", "L", "$")

map("n", "j", "gj")
map("n", "k", "gk")

map("n", "<Tab>", ":tabnext<CR>")
map("n", "<S-Tab>", ":tabprevious<CR>")
map("n", "<leader><BS>", "<c-^>")

map("n", "<up>", "<nop>")
map("n", "<down>", "<nop>")
map("n", "<left>", "<nop>")
map("n", "<right>", "<nop>")
map("i", "<up>", "<nop>")
map("i", "<down>", "<nop>")
map("n", "Q", "<nop>")

map("i", "<S-Tab>", 'pumvisible() ? "<C-p>" : "<Tab>"', { expr = true })
map("i", "<Tab>", 'pumvisible() ? "<C-n>" : "<Tab>"', { expr = true })
map("i", "<C-Space>", "compe#complete()", { expr = true })

-------------------- LSP -----------------------------------
-- local lsp_status = require('lsp-status')
-- lsp_status.register_progress()

-- function lspstat()
-- 	if #vim.lsp.buf_get_clients() == 0 then
-- 		return ''
-- 	end
-- 	return lsp_status.status()
-- end

-- cmd 'au User LspDiagnosticsChanged call lightline#update()'
-- cmd 'au User LspMessageUpdate call lightline#update()'
-- cmd 'au User LspStatusUpdate call lightline#update()'

require("compe").setup({
	enabled = true,
	autocomplete = true,
	debug = false,
	min_length = 1,
	preselect = "enable",
	throttle_time = 80,
	source_timeout = 200,
	incomplete_delay = 400,
	max_abbr_width = 100,
	max_kind_width = 100,
	max_menu_width = 100,
	documentation = true,

	source = {
		path = true,
		buffer = true,
		calc = true,
		nvim_lsp = true,
		nvim_lua = true,
		vsnip = false,
	},
})

require("lsp")
sudo = require("doas")

cmd([[
	autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path %
	autocmd FileType zig setlocal commentstring=//\ %s
]])

local ts = require("nvim-treesitter.configs")
ts.setup({
	ensure_installed = "maintained",
	highlight = { enable = true },
	incremental_selection = { enable = true },
	indent = { enable = true },
	context_commentstring = {
		enable = true,
	},
})

-- require("indent_blankline").setup {
-- 	use_treesitter = true,
-- 	show_current_context = true,
-- }
