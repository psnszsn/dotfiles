local builtin = require("telescope.builtin")

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("", "<leader>c", '"+y')
vim.keymap.set("", "<leader>ps", '"+p')

vim.keymap.set("x", "<leader>px", '"_dP')
vim.keymap.set("n", "<leader>m", ":make<CR>")
vim.keymap.set("n", "<leader>v", ":tabe $MYVIMRC<CR>")
vim.keymap.set("n", "<leader>l", ":set list! | :IndentBlanklineToggle<CR>")
-- vim.keymap.set("n", "-", vim.cmd.Ex)
vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>a", "<esc>ggVG<CR>")

-- Shortcut for searching your neovim configuration files
vim.keymap.set('n', '<leader>sn', function()
	builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

vim.keymap.set("n", "<leader>-", function()
	local in_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
	if in_git_repo then
		builtin.git_files()
	else
		builtin.find_files()
		-- builtin.find_files({ cwd = require("telescope.utils").buffer_dir() })
	end
end, { desc = "Find files (git/local)" })

-- vim.keymap.set("n", "<leader><leader>-", function()
-- 	builtin.find_files({ cwd = require("telescope.utils").buffer_dir() })
-- end, { desc = "Telescope find files in buffer dir" })

vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Search [G]it [F]iles" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>rg", builtin.live_grep, { desc = "Find by [R]ip[G]rep" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]find [R]resume" })
--
-----------
-- vim.keymap.set("n", "<space>fo", function()
-- 	local win_state = vim.fn.winsaveview()
-- 	local formatprg = vim.opt_local.formatprg:get()
--
-- 	-- vim.cmd.execute("normal! i ")
-- 	-- vim.cmd.execute([[normal! a\<bs>"]])
--
-- 	vim.cmd("%!" .. formatprg)
-- 	-- vim.cmd("keepjumps normal gggqG")
--
-- 	vim.fn.winrestview(win_state)
-- end, { desc = "Format buffer" })

vim.keymap.set("n", "\\", "<cmd>noh<CR>")
vim.keymap.set("n", "U", "<C-R>")

vim.keymap.set("", "<C-h>", "<C-w>h")
vim.keymap.set("", "<C-j>", "<C-w>j")
vim.keymap.set("", "<C-k>", "<C-w>k")
vim.keymap.set("", "<C-l>", "<C-w>l")

vim.keymap.set("", "H", "^")
vim.keymap.set("", "L", "$")

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
