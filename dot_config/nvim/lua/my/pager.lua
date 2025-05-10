local M = {}
function M.run()
	-- local line1 = vim.api.nvim_buf_get_lines(0,0,1,false)[1]
	-- vim.print(line1)
	-- if vim.startswith(line1,"\27[1mdiff") then
	-- 	vim.opt_local.filetype="diff"
	-- end
	-- vim.cmd.substitute {
	-- 	mods = { silent = true },
	-- 	range = { 0, vim.fn.line '$' },
	-- 	args = { [=[/\v\e\[[;?]*[0-9.;]*[a-z]//egi]=] },
	-- }
	-- vim.api.nvim_win_set_cursor(0, {1,0})
	if vim.api.nvim_buf_line_count(0) == 1 then
		-- vim.cmd.q()
	end
	local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	if #content == 1 and content[1] == '' then
		vim.cmd.q()
	end

	vim.opt_local.filetype = 'git'

	vim.cmd.IBLDisable()
	vim.opt_local.synmaxcol = 0
	vim.opt_local.wrap = false

	vim.opt_local.modifiable = false
	vim.opt_local.modified = false
end

return M
