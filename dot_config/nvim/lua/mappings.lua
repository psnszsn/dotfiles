-------------------- MAPPINGS ------------------------------
vim.g.mapleader = " "
vim.keymap.set("", "<leader>c", '"+y')
vim.keymap.set("", "<leader>ps", '"+p')

vim.keymap.set("x", "<leader>px", '"_dP')
vim.keymap.set("n", "<leader>m", ":make<CR>")
vim.keymap.set("n", "<leader>v", ":tabe $MYVIMRC<CR>")
vim.keymap.set("n", "<leader>l", ":set list! | :IndentBlanklineToggle<CR>")
-- vim.keymap.set("n", "-", vim.cmd.Ex)
vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>a", "<esc>ggVG<CR>")

vim.keymap.set("n", "<leader>-", function()
	local in_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
	if in_git_repo then
		require("telescope.builtin").git_files()
	else
		require("telescope.builtin").find_files()
	end
end)

vim.keymap.set("n", "<leader>[", require("telescope.builtin").git_files)
vim.keymap.set("n", "<leader>]", require("telescope.builtin").buffers)

vim.keymap.set("n", "<leader>0", function()
	require("telescope").extensions.file_browser.file_browser({ cwd = require("telescope.utils").buffer_dir() })
end)
vim.keymap.set("n", "<leader><leader>-", function()
	require("telescope.builtin").find_files({ cwd = require("telescope.utils").buffer_dir() })
end)

vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers)
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<leader>rg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags)
vim.keymap.set("n", "<leader>/", require("telescope.builtin").current_buffer_fuzzy_find)

vim.keymap.set("n", "\\", "<cmd>noh<CR>")
vim.keymap.set("n", "U", "<C-R>")

vim.keymap.set("", "<C-h>", "<C-w>h")
vim.keymap.set("", "<C-j>", "<C-w>j")
vim.keymap.set("", "<C-k>", "<C-w>k")
vim.keymap.set("", "<C-l>", "<C-w>l")

vim.keymap.set("", "H", "^")
vim.keymap.set("", "L", "$")

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- vim.keymap.set("n", "<Tab>", ":tabnext<CR>")
-- vim.keymap.set("n", "<S-Tab>", ":tabprevious<CR>")
-- vim.keymap.set("n", "<leader><BS>", "<c-^>")

vim.keymap.set("n", "<up>", "<nop>")
vim.keymap.set("n", "<down>", "<nop>")
vim.keymap.set("n", "<left>", "<nop>")
vim.keymap.set("n", "<right>", "<nop>")
vim.keymap.set("n", "<S-up>", "<nop>")
vim.keymap.set("n", "<S-down>", "<nop>")
vim.keymap.set("i", "<up>", "<nop>")
vim.keymap.set("i", "<down>", "<nop>")
vim.keymap.set("i", "<S-up>", "<nop>")
vim.keymap.set("i", "<S-down>", "<nop>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("t", "<C-Esc>", "<C-\\><C-n>")

-- map("i", "<S-Tab>", 'pumvisible() ? "<C-p>" : "<Tab>"', { expr = true })
-- map("i", "<Tab>", 'pumvisible() ? "<C-n>" : "<Tab>"', { expr = true })
-- map("i", "<C-Space>", "compe#complete()", { expr = true })
