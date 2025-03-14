if not vim.env.NVIM then
	function _G.IsBufnrClosed(bufnr)
		return not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr)
	end
	return
end

local sock = vim.fn.sockconnect('pipe', vim.env.NVIM, { rpc = true })

local filepath = vim.api.nvim_buf_get_name(0)
if filepath and filepath ~= '' then
	vim.print(filepath)
	vim.fn.rpcrequest(sock, 'nvim_command', 'edit ' .. vim.fn.fnameescape(filepath))

	local bufnr = vim.fn.rpcrequest(sock, 'nvim_call_function', 'bufnr', { '%' })
	print(bufnr)
	while not vim.fn.rpcrequest(sock, 'nvim_exec_lua', 'return _G.IsBufnrClosed(...)', { bufnr }) do
		-- print 'not closed'
		vim.wait(100)
	end
end

print 'nested nvim'
vim.fn.chanclose(sock)
os.exit()
