local M = {}

local function onstdout(id, data, _)
	if type(data) == 'table' and #data > 0 then
		data = table.concat(data, ' ')
	end

	if vim.endswith(data, 'password: ') then
		local password = vim.fn.inputsecret 'Password:'
		vim.fn.chansend(id, { password .. '\r\n' })
	end
end

function M.doas(term)
	local tempfile = vim.fn.tempname()
	vim.cmd.write { tempfile }
	local path = vim.fn.expand '%:p'
	if not path or #path == 0 then
		vim.schedule(function()
			vim.notify('E32: No file name', vim.log.levels.ERROR)
		end)
		return
	end

	local command = ('dd if=%s of=%s bs=1048576'):format(vim.fn.shellescape(tempfile), vim.fn.shellescape(path))
	local id = vim.fn.jobstart('doas ' .. command, {
		on_stdout = onstdout,
		on_stderr = onstdout,
		on_exit = function(_, exitcode)
			vim.cmd.edit { bang = true }
			-- vim.bo.modified = false
			-- vim.cmd.checktime()
			print('doas exitcode:', exitcode)
			vim.fn.delete(tempfile)
		end,
		pty = true,
	})
end

return M
