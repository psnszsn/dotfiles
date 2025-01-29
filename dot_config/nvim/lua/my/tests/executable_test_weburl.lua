#!/usr/bin/env -S nvim -l

local weburl = require 'my.weburl'

local cases = {
	{
		remote = 'git@github.com:psnszsn/dotfiles.git',
		baseurl = 'https://github.com/psnszsn/dotfiles/blob/main/dot_config/nvim/init.lua#L22-L24',
	},
	{
		remote = 'git@code.uber.internal:devexp/devpod-monorepo',
		baseurl = 'https://sg.uberinternal.com/code.uber.internal/uber-code/devexp-devpod-monorepo@main/-/blob/dot_config/nvim/init.lua?L22-L24',
	},
	{
		remote = 'code.com:hello/world',
		baseurl = 'https://sg.uberinternal.com/code.com/uber-code/hello-world@main/-/blob/dot_config/nvim/init.lua?L22-L24',
	},
	-- {
	-- 	remote = 'code.uber.internal:devexp/devpod-monorepo',
	-- 	baseurl = 'https://sg.uberinternal.com/code.com/uber-code/hello-world@main/-/blob/dot_config/nvim/init.lua?L22-L24',
	-- },
}

local T = {}

T['works'] = function()
	for _, c in ipairs(cases) do
		local result = weburl.__get_baseurl(c.remote, 'main', 'dot_config/nvim/init.lua', 22, 24)
		assert(result == c.baseurl, result)
	end
end

for name, func in pairs(T) do
	vim.print(name .. '...')
	func()
end
