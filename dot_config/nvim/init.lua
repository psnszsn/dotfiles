-- neovim config

-------------------- HELPERS -------------------------------
local cmd, fn, g = vim.cmd, vim.fn, vim.g
local o, bo, wo = vim.o, vim.bo, vim.wo

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then for k, v in pairs(opts) do options[k] = v end end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end


local function set_global_opt(...)
	local args={...}
	for i=1,#args do
		if pcall(vim.api.nvim_buf_get_option, 0, args[i]) then
			o[args[i]]=bo[args[i]]
		elseif pcall(vim.api.nvim_win_get_option, 0, args[i]) then
			o[args[i]]=wo[args[i]]
		else
			print("Invalid option.")
		end
		-- bo[args[i]]=o[args[i]]
		-- print(args[i])
	end
end

-------------------- PLUGINS -------------------------------
cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq
paq{'savq/paq-nvim', opt=true}     -- Let Paq manage itself

paq 'tpope/vim-commentary'
paq 'tpope/vim-surround'
paq 'tpope/vim-repeat'
paq 'tpope/vim-sensible'
paq 'tpope/vim-fugitive'
paq 'neovim/nvim-lspconfig'
-- paq 'nvim-lua/completion-nvim'
paq 'hrsh7th/nvim-compe'
paq {'nvim-treesitter/nvim-treesitter'}
paq 'ojroques/nvim-lspfuzzy'
paq 'nvim-lua/lsp-status.nvim'

-- paq 'SirVer/ultisnips'
-- paq 'honza/vim-snippets'

paq 'nvim-lua/popup.nvim'
paq 'nvim-lua/plenary.nvim'
paq 'nvim-telescope/telescope.nvim'

paq {'junegunn/fzf.vim'}
paq 'itchyny/lightline.vim'
paq 'lambdalisue/suda.vim'
-- paq 'Yggdroot/indentLine'
paq{'lukas-reineke/indent-blankline.nvim', branch='lua'}

paq 'arzg/vim-colors-xcode'
-- paq 'arcticicestudio/nord-vim'
paq 'shaunsingh/nord.nvim'
paq 'embark-theme/vim'
-- paq 'shaunsingh/moonlight.nvim'
-- paq 'evanleck/vim-svelte'
paq 'mboughaba/i3config.vim'
paq 'ziglang/zig.vim'

-------------------- PLUGIN SETUP --------------------------
-- g['netrw_banner'] = 0
g['csv_no_conceal'] = 1
g['xml_syntax_folding'] = 1
g['vim_markdown_conceal'] = 0
g['vim_markdown_conceal_code_blocks'] = 0
g['embark_terminal_italics'] = 1
-- g['completion_enable_snippet'] = 'UltiSnips'

g['lightline'] = {
	colorscheme = 'embark',
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

cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'  -- disabled in visual mode

 -- ÃĂªŞÞŢãăºşþţ
 cmd 'command FixSub set fileencoding=utf-8 | %s/Ã/Ă/ge | %s/ª/Ș/ge | %s/Þ/Ț/ge | %s/ã/ă/ge | %s/º/ș/ge | %s/þ/ț/ge'


-------------------- OPTIONS -------------------------------
local indent = 4
cmd 'colorscheme embark'
bo.expandtab = false              -- Use spaces instead of tabs
bo.shiftwidth = indent            -- Size of an indent
bo.smartindent = true             -- Insert indents automatically
bo.tabstop = indent               -- Number of spaces tabs count for
set_global_opt('expandtab', 'shiftwidth', 'smartindent', 'tabstop');

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
o.listchars = 'tab:▸ ,trail:·,nbsp:+,eol:¬'
-- o.listchars = 'tab:▸ ,trail:·,nbsp:+,eol:¬'
wo.number = true                  -- Print line number
wo.relativenumber = true          -- Relative line numbers
wo.signcolumn = 'yes'             -- Show sign column
set_global_opt('number', 'relativenumber' ,'signcolumn')
-- wo.wrap = false                   -- Disable line wrap
--      asda sd asd

o.shortmess = o.shortmess..'c'
o.completeopt= 'menuone,noselect'

-------------------- MAPPINGS ------------------------------
vim.g.mapleader = " "
map('', '<leader>c', '"+y')
map('n', '<leader>v', ':tabe $MYVIMRC<CR>')
map('n', '<leader>l', ':set list!<CR>')
map('n', '<leader>-', ':Files<CR>')
map('n', '<leader>[', ':GFiles<CR>')
map('n', '<leader>]', ':Buffers<CR>')
map('n', '-', ':Ex<CR>')
map('n', '<leader>a', '<esc>ggVG<CR>')

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
map('i', '<C-Space>', 'compe#complete()', {expr = true})


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

local nvim_lsp = require('lspconfig')
local lsp_completion = require('completion')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

	lsp_status.on_attach(client)
	-- lsp_completion.on_attach(client)
end

-- local default_lsp_config = {on_attach = on_attach, capabilities = lsp_status.capabilities}

-- lsp.clangd.setup(default_lsp_config)
-- lsp.rust_analyzer.setup(default_lsp_config)
-- lsp.gopls.setup(default_lsp_config)

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = { "clangd", "rust_analyzer", "gopls", "svelte", "zls"}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach, capabilities = lsp_status.capabilities }
end

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = false;
  };

}


nvim_lsp.sumneko_lua.setup {
  cmd = {'/bin/lua-language-server'},
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    },
  },
}

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

-- map('n', '<leader>,', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
-- map('n', '<leader>;', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
-- map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
-- map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
-- map('n', 'gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
-- map('n', 'gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
-- map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
-- map('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
-- map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
-- map('n', '<leader>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
-- map('n', '<leader>x', '<cmd>ClangdSwitchSourceHeader<CR>')
-- map('n', '<leader>qf', '<cmd>lua vim.lsp.buf.code_action()<CR>')
-- map('n', '<leader>ee','<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')

-------------------- TREE-SITTER ---------------------------
local ts = require 'nvim-treesitter.configs'
ts.setup {
	ensure_installed = 'maintained',
	highlight = {enable = true},
	incremental_selection = {enable = true},
	indent = {enable = true},
}
