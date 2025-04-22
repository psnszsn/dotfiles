local M = {}

vim.api.nvim_create_autocmd('TermOpen', {
	group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd('WinEnter', {
	pattern = 'term://*',
	group = vim.api.nvim_create_augroup('custom-term-enter', { clear = true }),
	callback = function()
		vim.cmd.startinsert()
	end,
})

local job_id = 0
local term_buffer_id = 0

vim.keymap.set('n', '<space>t', function()
	if term_buffer_id ~= 0 and vim.api.nvim_buf_is_valid(term_buffer_id) then
		local windows = vim.api.nvim_list_wins()
		for _, win_id in ipairs(windows) do
			if vim.api.nvim_win_get_buf(win_id) == term_buffer_id then
				vim.api.nvim_set_current_win(win_id)
				return
			end
		end
		vim.cmd.vnew()
		vim.api.nvim_win_set_buf(0, term_buffer_id)
		return
	end

	vim.cmd.vnew()
	vim.cmd.term 'fish'
	job_id = vim.bo.channel
	term_buffer_id = vim.api.nvim_get_current_buf()
end)

vim.keymap.set('t', '<C-m>', function()
	vim.cmd.wincmd 'h'
end)

return M
