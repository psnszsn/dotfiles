local M = {}

vim.api.nvim_create_autocmd('WinEnter', {
	pattern = 'term://*',
	group = vim.api.nvim_create_augroup('custom-term-enter', { clear = true }),
	callback = function()
		local win = vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_get_current_buf()
		local total_lines = vim.api.nvim_buf_line_count(buf)
		local cursor_line = vim.api.nvim_win_get_cursor(win)[1]

		-- Only enter insert mode if cursor is on the last line
		if cursor_line == total_lines then
			vim.cmd.startinsert()
		end
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

vim.keymap.set('t', '<A-m>', function()
	vim.cmd.wincmd 'h'
end)

local term_clear = function()
  vim.fn.feedkeys("^L", 'n')
  local sb = vim.bo.scrollback
  vim.bo.scrollback = 1
  vim.bo.scrollback = sb
end

vim.keymap.set('t', '<C-l>', term_clear)

return M
