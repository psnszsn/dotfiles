local function get_web_url(args)
	local filepath = vim.api.nvim_buf_get_name(0)
	local directory = vim.fn.fnamemodify(filepath, ':h')
	local line_range = args.line1 == args.line2 and string.format('L%d', args.line1)
		or string.format('L%d-L%d', args.line1, args.line2)

	local git_root_proc = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { cwd = directory }):wait()
	if git_root_proc.code ~= 0 then
		vim.notify('Not inside a Git repository: ' .. (git_root_proc.stderr or ''), vim.log.levels.ERROR)
		return
	end
	local git_root = git_root_proc.stdout
	local relative_path = filepath:sub(#git_root + 1)

	local remote_url_proc = vim.system({ 'git', 'config', '--get', 'remote.origin.url' }, { cwd = directory }):wait()
	if remote_url_proc.code ~= 0 then
		vim.notify('No valid GitHub remote URL found: ' .. (remote_url_proc.stderr or ''), vim.log.levels.ERROR)
		return
	end
	local remote_url = vim.trim(remote_url_proc.stdout)

	local transformed_url = remote_url:gsub('^(.-):([^/]+)/(.+)$', 'https://sg.uberinternal.com/%1/uber-code/%2-%3')

	local proc = vim.system({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }, { cwd = directory }):wait()
	if proc.code ~= 0 then
		vim.notify('Unable tget current branch: ' .. (proc.stderr or ''), vim.log.levels.ERROR)
		return
	end
	local branch = vim.trim(proc.stdout)

	local url = string.format('%s@%s/-/blob/%s?%s', transformed_url, branch, relative_path, line_range)

	vim.fn.setreg('+', url)

	vim.notify('URL copied to clipboard: ' .. url, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command(
	'WebUrl',
	get_web_url,
	{ desc = 'Get the Web URL for the current line/range', range = true }
)
