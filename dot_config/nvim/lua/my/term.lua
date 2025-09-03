local M = {}

vim.api.nvim_create_autocmd('WinEnter', {
	pattern = 'term://*',
	group = vim.api.nvim_create_augroup('custom-term-enter', { clear = true }),
	callback = function()
		local win = vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_get_current_buf()
		local total_lines = vim.api.nvim_buf_line_count(buf)
		local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
		local win_height = vim.api.nvim_win_get_height(win)

		-- Only enter insert mode if cursor is on the last page
		if cursor_line >= total_lines - win_height + 1 then
			vim.cmd.startinsert()
		end
	end,
})

local job_id = 0
local term_buffer_id = 0
local term_window_id = 0

vim.keymap.set('n', '<space>t', function()
	if term_buffer_id ~= 0 and vim.api.nvim_buf_is_valid(term_buffer_id) then
		-- If the tracked window still exists
		if term_window_id ~= 0 and vim.api.nvim_win_is_valid(term_window_id) then
			vim.api.nvim_set_current_win(term_window_id)
			-- If it doesn't have the terminal buffer, open it there
			if vim.api.nvim_win_get_buf(term_window_id) ~= term_buffer_id then
				vim.api.nvim_win_set_buf(term_window_id, term_buffer_id)
			end
			return
		end

		-- Open terminal buffer in new window and update tracked window
		vim.cmd.vnew()
		vim.api.nvim_win_set_buf(0, term_buffer_id)
		term_window_id = vim.api.nvim_get_current_win()
		return
	end

	vim.cmd.vnew()
	vim.cmd.term 'fish'
	job_id = vim.bo.channel
	term_buffer_id = vim.api.nvim_get_current_buf()
	term_window_id = vim.api.nvim_get_current_win()
end)

vim.keymap.set('t', '<A-m>', function()
	vim.cmd.wincmd 'h'
end)

local term_clear = function()
	vim.fn.feedkeys('^L', 'n')
	local sb = vim.bo.scrollback
	vim.bo.scrollback = 1
	vim.bo.scrollback = sb
end

vim.keymap.set('t', '<C-l>', term_clear)

return M
