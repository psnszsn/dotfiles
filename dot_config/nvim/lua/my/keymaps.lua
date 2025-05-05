local builtin = require 'telescope.builtin'

local key_mappings = {
	{ 'm', 'h' },
	{ 'n', 'j' },
	{ 'e', 'k' },
	{ 'i', 'l' },

	{ 'h', 'n' },
	{ 'j', 'm' },
	{ 'k', 'e' },
	{ 'l', 'i' },
}

for _, mapping in ipairs(key_mappings) do
	local from, to = mapping[1], mapping[2]
	vim.keymap.set('n', from, to, { noremap = true, silent = true })
	vim.keymap.set('n', from:upper(), to:upper(), { noremap = true, silent = true })
end

vim.keymap.set('v', 'n', 'j', { noremap = true, silent = true })
vim.keymap.set('v', 'e', 'k', { noremap = true, silent = true })

-- vim.opt.langmap="mh,nj,ek,il,yo,ui,hn,ke,jy,lu,om"

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'e', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, noremap = true })
vim.keymap.set('n', 'n', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, noremap = true })

vim.keymap.set('', '<leader>c', '"+y')
vim.keymap.set('', '<leader>ps', '"+p')

vim.keymap.set('x', '<leader>px', '"_dP')
vim.keymap.set('n', '<leader>m', ':make<CR>')
vim.keymap.set('n', '<leader>v', ':tabe $MYVIMRC<CR>')
vim.keymap.set('n', '<leader>l', ':set list! | :IndentBlanklineToggle<CR>')
-- vim.keymap.set("n", "-", vim.cmd.Ex)
vim.keymap.set('n', '-', require('oil').open, { desc = 'Open parent directory' })
vim.keymap.set('n', '<leader>a', '<esc>ggVG<CR>')
vim.keymap.set('n', '<leader>ww', ':w<CR>')

-- Shortcut for searching your neovim configuration files
vim.keymap.set('n', '<leader>sn', function()
	builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- vim.keymap.set("n", "<leader>-", function()
-- require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
-- local in_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
-- if in_git_repo then
-- 	builtin.git_files()
-- else
-- 	builtin.find_files()
-- 	-- builtin.find_files({ cwd = require("telescope.utils").buffer_dir() })
-- end
-- end, { desc = "Find files (git/local)" })

-- vim.keymap.set("n", "<leader><leader>-", function()
-- 	builtin.find_files({ cwd = require("telescope.utils").buffer_dir() })
-- end, { desc = "Telescope find files in buffer dir" })

vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><leader>', function()
	require('telescope').extensions.smart_open.smart_open {
		cwd_only = true,
	}
end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>/', function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
		winblend = 10,
		previewer = false,
	})
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = '[F]ind [G]it Files' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind current [W]ord' })
vim.keymap.set('n', '<leader>rg', builtin.live_grep, { desc = 'Find by [R]ip[G]rep' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]find [R]resume' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[ ] Find existing buffers' })
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

vim.keymap.set('n', '\\', '<cmd>noh<CR>')

-- vim.keymap.set("n", "U", "<C-R>")

vim.keymap.set('', '<A-m>', function()
	vim.cmd.wincmd 'h'
end)

vim.keymap.set('', '<A-n>', function()
	vim.cmd.wincmd 'j'
end)
vim.keymap.set('', '<A-e>', function()
	vim.cmd.wincmd 'k'
end)
vim.keymap.set('', '<A-i>', function()
	vim.cmd.wincmd 'l'
end)

vim.keymap.set('', 'M', '^')
vim.keymap.set('', 'I', '$')

-- vim.keymap.set("n", "<Tab>", ":tabnext<CR>")
-- vim.keymap.set("n", "<S-Tab>", ":tabprevious<CR>")
-- vim.keymap.set("n", "<leader><BS>", "<c-^>")

vim.keymap.set('n', '<up>', '<nop>')
vim.keymap.set('n', '<down>', '<nop>')
vim.keymap.set('n', '<left>', '<nop>')
vim.keymap.set('n', '<right>', '<nop>')
vim.keymap.set('n', '<S-up>', '<nop>')
vim.keymap.set('n', '<S-down>', '<nop>')
vim.keymap.set('i', '<up>', '<nop>')
vim.keymap.set('i', '<down>', '<nop>')
vim.keymap.set('i', '<S-up>', '<nop>')
vim.keymap.set('i', '<S-down>', '<nop>')

vim.keymap.set('c', '<C-a>', '<home>', { noremap = true })
vim.keymap.set('c', '<C-f>', '<right>', { noremap = true })
vim.keymap.set('c', '<C-b>', '<left>', { noremap = true })
vim.keymap.set('c', '<Esc>b', '<S-left>', { noremap = true })
vim.keymap.set('c', '<Esc>f', '<S-right>', { noremap = true })

vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')

vim.keymap.set('c', '<C-n>', function()
	return vim.fn.wildmenumode() == 1 and '<C-n>' or '<Down>'
end, { expr = true })

vim.keymap.set('c', '<C-p>', function()
	return vim.fn.wildmenumode() == 1 and '<C-p>' or '<Up>'
end, { expr = true })

vim.keymap.set('n', 'jj', function()
	vim.keymap.set('n', 'p', function()
		vim.cmd.normal { 'p', bang = true }
		local pos = vim.fn.getpos '.'
		pos[3] = vim.b.saved_cursor[3]
		vim.fn.setpos('.', pos)
		vim.b.saved_cursor = nil

		vim.keymap.del('n', 'p', { buffer = true })
	end, { buffer = true })
	vim.b.saved_cursor = vim.fn.getpos '.'
	vim.cmd.normal { 'yy', bang = true }
end)
