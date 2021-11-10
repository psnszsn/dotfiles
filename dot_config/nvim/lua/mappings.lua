
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end


-------------------- MAPPINGS ------------------------------
vim.g.mapleader = " "
map("", "<leader>c", '"+y')
map("n", "<leader>v", ":execute 'tabe ' . system('chezmoi source-path $MYVIMRC')<CR>")
map("n", "<leader>l", ":set list! | :IndentBlanklineToggle<CR>")
map("n", "<leader>-", ":Telescope find_files<CR>")
map("n", "<leader>[", ":Telescope git_files<CR>")
map("n", "<leader>]", ":Telescope buffers<CR>")
map("n", "<leader>0", ":lua require('telescope.builtin').file_browser({ cwd = require'telescope.utils'.buffer_dir() }) <CR>")
map("n", "<leader><leader>-", ":lua require('telescope.builtin').find_files({ cwd = require'telescope.utils'.buffer_dir() }) <CR>")
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

-- map("i", "<S-Tab>", 'pumvisible() ? "<C-p>" : "<Tab>"', { expr = true })
-- map("i", "<Tab>", 'pumvisible() ? "<C-n>" : "<Tab>"', { expr = true })
-- map("i", "<C-Space>", "compe#complete()", { expr = true })
