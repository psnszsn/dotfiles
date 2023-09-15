local cmd, fn, g = vim.cmd, vim.fn, vim.g
local opt = vim.opt

-------------------- OPTIONS -------------------------------
local indent = 4
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
opt.relativenumber = false -- Relative line numbers
opt.signcolumn = "yes" -- Show sign column

opt.listchars = { tab = "▸ ", trail = "·", nbsp = "+", eol = "¬" }
-- set listchars=tab:▸\ ,eol:¬
-- asdasd  asdasd
opt.shortmess:append({ c = true })
-- opt.completeopt = { "menuone", "noselect" }
opt.completeopt = { "menu", "menuone", "noselect" }

if g.neovide then
	opt.guifont = { "JetBrains Mono", ":h11" }
	-- opt.guifont = { "Iosevka Fixed" }
end

-- opt.foldnestmax=1
-- opt.foldmethod = "expr"
-- opt.foldexpr="nvim_treesitter#foldexpr()"

if vim.env.TERM == "xterm" then
	opt.termguicolors = false
	opt.guicursor = ""
end
