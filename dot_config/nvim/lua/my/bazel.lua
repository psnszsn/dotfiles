local M = {}

---@param target string
---@param workspace string
local function add_python_deps_to_pyright(target, workspace)
	local query = 'bazel cquery '
		.. target
		.. ' --output starlark --starlark:expr=\'providers(target)["PyInfo"].imports\''
	-- print(query)

	local ws_name = '__main__'
	local function parse_and_add_extra_path(_, stdout)
		-- local extra_paths = {workspace}
		local extra_paths = {}
		local query_output = stdout[1]
		local depset = query_output:match 'depset%(%[(.*)%]'
		-- print("ddd", depset)
		if depset == nil then
			return
		end
		for extra_path in depset:gmatch '"(.-)"' do
			if extra_path:match('^' .. ws_name) then
				-- local path = extra_path:gsub("^" .. ws_name, workspace .. "/bazel-bin")
				local path = extra_path:gsub('^' .. ws_name, workspace)
				-- vim.
				table.insert(extra_paths, path)
			else
				local ws_tail = vim.fn.fnamemodify(workspace, ':t')
				table.insert(extra_paths, workspace .. '/bazel-' .. ws_tail .. '/external/' .. extra_path)
			end
		end
		-- print(table.concat(extra_paths, "\n"))
		-- local pythonpath = table.concat(extra_paths, ":")
		-- print("export PYTHONPATH=" .. pythonpath)
		-- vim.print(extra_paths)
		Set_pyright_paths(extra_paths)

		-- vim.print(extra_paths)
		-- setup_pyright(extra_paths)
	end

	vim.fn.jobstart(query, { on_stdout = parse_and_add_extra_path })
end

function Set_pyright_paths(extra_paths)
	local clients = vim.lsp.get_clients {
		bufnr = vim.api.nvim_get_current_buf(),
		name = 'pyright',
	}
	for _, client in ipairs(clients) do
		client.settings.python =
			vim.tbl_deep_extend('force', client.settings.python, { analysis = { extraPaths = extra_paths } })
		client.notify('workspace/didChangeConfiguration', { settings = nil })
	end
end

function Bzl()
	local ws = vim.fs.root(0,'WORKSPACE')
	if ws == nil then
		vim.notify('Could not find bazel root', vim.log.levels.ERROR)
		return
	end
	vim.print(ws)
	add_python_deps_to_pyright(':test', ws)
end

vim.api.nvim_create_user_command('Bzl', Bzl, { desc = 'Get the Web URL for the current line/range' })
