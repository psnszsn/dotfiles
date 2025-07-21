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
	-- vim.keymap.set('n', from:upper(), to:upper(), { noremap = true, silent = true })
end

vim.keymap.set('n', 'L', 'I', { noremap = true, silent = true })
vim.keymap.set('n', 'H', 'N', { noremap = true, silent = true })
vim.keymap.set('v', 'n', 'j', { noremap = true, silent = true })
vim.keymap.set('v', 'e', 'k', { noremap = true, silent = true })

-- vim.keymap.set({ 'n', 'v' }, '<C-k>', '<C-]>', { noremap = true })

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

vim.keymap.set('n', '-', require('oil').open, { desc = 'Open parent directory' })
vim.keymap.set('n', '<leader>a', '<esc>ggVG<CR>')
vim.keymap.set('n', '<leader>ww', ':w<CR>')

vim.keymap.set('n', '\\', '<cmd>noh<CR>')

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
