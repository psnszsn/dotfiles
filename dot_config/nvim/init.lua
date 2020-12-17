-- neovim config

-------------------- HELPERS -------------------------------
local cmd, fn, g = vim.cmd, vim.fn, vim.g
local o, bo, wo = vim.o, vim.bo, vim.wo

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then for k, v in pairs(opts) do options[k] = v end end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-------------------- PLUGINS -------------------------------
cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq

paq 'tpope/vim-commentary'
paq 'tpope/vim-surround'
paq 'tpope/vim-repeat'
paq 'tpope/vim-sensible'
paq 'tpope/vim-fugitive'
paq 'neovim/nvim-lspconfig'
paq 'nvim-lua/completion-nvim'
paq {'nvim-treesitter/nvim-treesitter'}
paq 'ojroques/nvim-lspfuzzy'
paq 'nvim-lua/lsp-status.nvim'

paq {'junegunn/fzf.vim'}
paq 'itchyny/lightline.vim'
paq 'lambdalisue/suda.vim'
paq 'Yggdroot/indentLine'
paq 'mcchrish/nnn.vim'

paq 'arzg/vim-colors-xcode'

-------------------- PLUGIN SETUP --------------------------
g['netrw_banner'] = 0
g['csv_no_conceal'] = 1
g['xml_syntax_folding'] = 1
g['vim_markdown_conceal'] = 0
g['vim_markdown_conceal_code_blocks'] = 0

g['lightline'] = {
	active = {
		left = {
			{'mode','paste'},
			{'lsp_status', 'readonly', 'filename', 'modified'}
		}
	},
	component_expand = {
		lsp_status = 'v:lua.lspstat'
     },
}

-------------------- OPTIONS -------------------------------
local indent = 4
cmd 'colorscheme xcodedarkhc'
bo.expandtab = true               -- Use spaces instead of tabs
bo.shiftwidth = indent            -- Size of an indent
bo.smartindent = true             -- Insert indents automatically
bo.tabstop = indent               -- Number of spaces tabs count for
o.mouse='a'                       -- Use mouse
o.undofile = true                 -- Persistend undo
o.hidden = true                   -- Enable background buffers
o.ignorecase = true               -- Ignore case
o.joinspaces = false              -- No double spaces after a dot with join
-- o.pastetoggle = '<F2>'            -- Paste mode
o.scrolloff = 4                   -- Lines of context
o.shiftround = true               -- Round indent
o.sidescrolloff = 8               -- Columns of context
o.smartcase = true                -- Don't ignore case with capital letters
o.splitbelow = true               -- Put new windows below current one
o.splitright = true               -- Put new windows right of current one
o.termguicolors = true            -- True color support
o.updatetime = 100                -- Delay before swap file is saved
-- o.wildmode = 'longest:full,full'  -- Command-line completion mode
o.conceallevel = 0                -- Disable conceal
wo.colorcolumn = '80'             -- Line length marker
wo.cursorline = true              -- Highlight cursor line
wo.list = false                   -- Show some invisible characters
wo.listchars = 'tab:▸ ,trail:·,nbsp:+,eol:¬'
wo.number = true                  -- Print line number
wo.relativenumber = true          -- Relative line numbers
wo.signcolumn = 'yes'             -- Show sign column
wo.wrap = false                   -- Disable line wrap

o.shortmess = o.shortmess..'c'
o.completeopt= 'menuone,noinsert,noselect'

-------------------- MAPPINGS ------------------------------
vim.g.mapleader = " "
map('', '<leader>c', '"+y')
map('n', '<leader>v', ':tabe $MYVIMRC<CR>')
map('n', '<leader>l', ':set list!<CR>')
map('n', '<leader>-', ':Files<CR>')
map('n', '<leader>[', ':GFiles<CR>')
map('n', '<leader>]', ':Buffers<CR>')
map('n', '\\', '<cmd>noh<CR>')
map('n', 'U', '<C-R>')

map('', '<C-h>', '<C-w>h')
map('', '<C-j>', '<C-w>j')
map('', '<C-k>', '<C-w>k')
map('', '<C-l>', '<C-w>l')

map('', 'H', '^')
map('', 'L', '$')

map('n', 'j', 'gj')
map('n', 'k', 'gk')

map('n', '<Tab>', ':tabnext<CR>')
map('n', '<S-Tab>', ':tabprevious<CR>')
map('n', '<leader><BS>', '<c-^>')

map('n', '<up>', '<nop>')
map('n', '<down>', '<nop>')
map('n', '<left>', '<nop>')
map('n', '<right>', '<nop>')
map('i', '<up>', '<nop>')
map('i', '<down>', '<nop>')
map('n', 'Q', '<nop>')

map('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "<C-n>" : "<Tab>"', {expr = true})

-------------------- LSP -----------------------------------
local lsp_status = require('lsp-status')
lsp_status.register_progress()

function lspstat()
	if #vim.lsp.buf_get_clients() == 0 then
		return ''
	end	
	return require('lsp-status').status()
end

cmd 'au User LspDiagnosticsChanged call lightline#update()'
cmd 'au User LspMessageUpdate call lightline#update()'
cmd 'au User LspStatusUpdate call lightline#update()'
	
local lsp = require 'lspconfig'
local lsp_completion = require('completion')

local function on_attach(client)
    lsp_status.on_attach(client)
    lsp_completion.on_attach(client)
end

local default_lsp_config = {on_attach = on_attach, capabilities = lsp_status.capabilities}

lsp.clangd.setup(default_lsp_config)
lsp.rust_analyzer.setup(default_lsp_config)

require('lspfuzzy').setup {}
-- cmd 'autocmd BufEnter * lua require'completion'.on_attach()'

-- fn.sign_define("LspDiagnosticsSignError",
--     {text = "", texthl = "LspDiagnosticsSignError"})
-- fn.sign_define("LspDiagnosticsSignWarning",
--     {text = "", texthl = "LspDiagnosticsSignWarning"})
-- fn.sign_define("LspDiagnosticsSignInformation",
--     {text = "🛈", texthl = "LspDiagnosticsSignInformation"})
-- fn.sign_define("LspDiagnosticsSignHint",
--     {text = "!", texthl = "LspDiagnosticsSignHint"})

map('n', '<leader>,', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
map('n', '<leader>;', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', 'gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
map('n', 'gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
map('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<leader>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
map('n', '<leader>x', '<cmd>ClangdSwitchSourceHeader<CR>')
map('n', '<leader>qf', '<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n', '<leader>ee','<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')

-------------------- TREE-SITTER ---------------------------
local ts = require 'nvim-treesitter.configs'
ts.setup {ensure_installed = 'maintained', highlight = {enable = true}}
