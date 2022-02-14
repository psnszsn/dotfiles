
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end



vim.cmd [[runtime plugin/astronauta.vim]]
local nnoremap = vim.keymap.nnoremap
-- local km = require('astronauta.keymap')

-------------------- MAPPINGS ------------------------------
vim.g.mapleader = " "
map("", "<leader>c", '"+y')
map("n", "<leader>v", ":tabe $MYVIMRC<CR>")
map("n", "<leader>l", ":set list! | :IndentBlanklineToggle<CR>")
map("n", "-", ":Ex<CR>")
map("n", "<leader>a", "<esc>ggVG<CR>")

nnoremap { '<leader>-', function() require('telescope.builtin').find_files() end }
nnoremap { '<leader>[', function() require('telescope.builtin').git_files() end }
nnoremap { '<leader>]', function() require('telescope.builtin').buffers() end }
nnoremap { '<leader>0', function() require('telescope').extensions.file_browser.file_browser({ cwd = require'telescope.utils'.buffer_dir() }) end }
nnoremap { '<leader><leader>-', function() require('telescope.builtin').find_files({ cwd = require'telescope.utils'.buffer_dir() }) end }

nnoremap { '<leader>ff', function() require('telescope.builtin').find_files() end }
nnoremap { '<leader>fb', function() require('telescope.builtin').buffers() end }
nnoremap { '<leader>fg', function() require('telescope.builtin').live_grep() end }
nnoremap { '<leader>rg', function() require('telescope.builtin').live_grep() end }
nnoremap { '<leader>fh', function() require('telescope.builtin').help_tags() end }

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
map("n", "<S-up>", "<nop>")
map("n", "<S-down>", "<nop>")
map("i", "<up>", "<nop>")
map("i", "<down>", "<nop>")
map("i", "<S-up>", "<nop>")
map("i", "<S-down>", "<nop>")

map("n", "Q", "<nop>")

-- map("i", "<S-Tab>", 'pumvisible() ? "<C-p>" : "<Tab>"', { expr = true })
-- map("i", "<Tab>", 'pumvisible() ? "<C-n>" : "<Tab>"', { expr = true })
-- map("i", "<C-Space>", "compe#complete()", { expr = true })
