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

local terminals = {
	fish = { job_id = 0, buffer_id = 0, cmd = 'fish' },
	claude = { job_id = 0, buffer_id = 0, cmd = vim.env.CLAUDECMD or 'claude' },
}
local term_window_id = 0

local function toggle_terminal(term_type)
	local term = terminals[term_type]
	local cmd = term.cmd

	if term.buffer_id ~= 0 and vim.api.nvim_buf_is_valid(term.buffer_id) then
		-- Check if we're currently in the term window
		if term_window_id ~= 0 and vim.api.nvim_win_is_valid(term_window_id) then
			-- Just switch the buffer in the existing window
			vim.api.nvim_win_set_buf(term_window_id, term.buffer_id)
			vim.api.nvim_set_current_win(term_window_id)
			return
		end

		-- Open terminal buffer in new window and update tracked window
		vim.cmd.vnew()
		vim.api.nvim_win_set_buf(0, term.buffer_id)
		term_window_id = vim.api.nvim_get_current_win()
		return
	end

	-- Check if term window exists but we need to create a new terminal
	if term_window_id ~= 0 and vim.api.nvim_win_is_valid(term_window_id) then
		vim.api.nvim_set_current_win(term_window_id)
		vim.cmd.term(cmd)
	else
		vim.cmd.vnew()
		vim.cmd.term(cmd)
		term_window_id = vim.api.nvim_get_current_win()
	end

	term.job_id = vim.bo.channel
	term.buffer_id = vim.api.nvim_get_current_buf()
end

vim.keymap.set('n', '<leader>tt', function()
	toggle_terminal 'fish'
end)

vim.keymap.set('n', '<leader>tc', function()
	toggle_terminal 'claude'
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
