if not vim.env.NVIM then
	return
end

local sock = vim.fn.sockconnect('pipe', vim.env.NVIM, { rpc = true })

local filepath = vim.api.nvim_buf_get_name(0)
if filepath and filepath ~= '' then
	print(filepath)
	vim.fn.rpcnotify(sock, 'nvim_command', 'edit ' .. vim.fn.fnameescape(filepath))
end

print 'nested nvim'
vim.fn.chanclose(sock)
os.exit()
