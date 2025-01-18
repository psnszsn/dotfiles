---@param line1 integer
---@param line2 integer
local function get_linerange(line1, line2)
	return line1 == line2 and string.format('L%d', line1) or string.format('L%d-L%d', line1, line2)
end

local rules = {
	{
		pattern = '^git@([^:]+):(.+)/(.+)%.git$',
		format = function(host, user, repo, branch, filepath, line1, line2)
			return string.format(
				'https://%s/%s/%s/blob/%s/%s#%s',
				host,
				user,
				repo,
				branch,
				filepath,
				get_linerange(line1, line2)
			)
		end,
	},
	{
		pattern = '^(.-):([^/]+)/(.+)$',
		format = function(host, user, repo, branch, filepath, line1, line2)
			return string.format(
				'https://sg.uberinternal.com/%s/uber-code/%s-%s@%s/-/blob/%s?%s',
				host,
				user,
				repo,
				branch,
				filepath,
				get_linerange(line1, line2)
			)
		end,
	},
}
table.insert(rules, {
	pattern = '^https?://([^/]+)/([^/]+)/([^/]+)$',
	format = rules[1].format,
})

---@param remote string
---@param branch string
local function get_web_url(remote, branch, filepath, line1, line2)
	for _, rule in ipairs(rules) do
		local captures = { remote:match(rule.pattern) }
		if #captures ~= 0 then
			table.insert(captures, branch)
			table.insert(captures, filepath)
			table.insert(captures, line1)
			table.insert(captures, line2)
			return rule.format(table.unpack(captures))
		end
	end
end

local function copy_web_url(args)
	local filepath = vim.api.nvim_buf_get_name(0)
	local directory = vim.fn.fnamemodify(filepath, ':h')

	local git_root_proc = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { cwd = directory }):wait()
	if git_root_proc.code ~= 0 then
		vim.notify('Not inside a Git repository: ' .. (git_root_proc.stderr or ''), vim.log.levels.ERROR)
		return
	end
	local git_root = git_root_proc.stdout
	local relative_path = filepath:sub(#git_root + 1)

	local remote_url_proc = vim.system({ 'git', 'config', '--get', 'remote.origin.url' }, { cwd = directory }):wait()
	if remote_url_proc.code ~= 0 then
		vim.notify('No valid remote URL found: ' .. (remote_url_proc.stderr or ''), vim.log.levels.ERROR)
		return
	end
	local remote_url = vim.trim(remote_url_proc.stdout)

	local proc = vim.system({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }, { cwd = directory }):wait()
	if proc.code ~= 0 then
		vim.notify('Unable to get current branch: ' .. (proc.stderr or ''), vim.log.levels.ERROR)
		return
	end
	local branch = vim.trim(proc.stdout)

	local url = get_web_url(remote_url, branch, relative_path, args.line1, args.line2)

	vim.fn.setreg('+', url)

	vim.notify('URL copied to clipboard: ' .. url, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command(
	'WebUrl',
	copy_web_url,
	{ desc = 'Get the Web URL for the current line/range', range = true }
)

return {
	__get_baseurl = get_web_url,
}
