local dic = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function b64enc(data)
	return (
		(data:gsub('.', function(x)
			local r, b = '', x:byte()
			for i = 8, 1, -1 do
				r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
			end
			return r
		end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if #x < 6 then
				return ''
			end
			local c = 0
			for i = 1, 6 do
				c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
			end
			return dic:sub(c + 1, c + 1)
		end) .. ({ '', '==', '=' })[#data % 3 + 1]
	)
end

local function osc52_yank(...)
	local str = string.format(...)
	local base64 = b64enc(str)
	local osc52str = string.format('\x1b]52;c;%s\x07', base64)
	local bytes = vim.fn.chansend(vim.v.stderr, osc52str)
	assert(bytes > 0)
	print(string.format('[OSC52] %d chars copied (%d bytes)', #str, bytes))
end

if vim.env.SSH_CONNECTION then
	vim.g.clipboard = {
		name = 'osc52',
		copy = {
			['+'] = function(lines, regtype)
				osc52_yank(table.concat(lines, '\n'))
			end,
		},
		paste = {
			['+'] = function()
				print 'No paste'
			end,
		},
		cache_enabled = false,
	}
end
