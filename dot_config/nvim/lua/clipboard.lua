local dic = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function b64enc(data)
	return (
			(data:gsub(".", function(x)
				local r, b = "", x:byte()
				for i = 8, 1, -1 do
					r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
				end
				return r
			end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
				if #x < 6 then
					return ""
				end
				local c = 0
				for i = 1, 6 do
					c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
				end
				return dic:sub(c + 1, c + 1)
			end) .. ({ "", "==", "=" })[#data % 3 + 1]
		)
end

function osc_yank(str)
	file = io.open("/dev/tty", "wb")
	buf = "\27]52;c;" .. b64enc(str) .. "\7"
	file:write(buf)
	file:flush()
	io.close(file)
end

vim.g.clipboard = {
	name = "osc52",
	copy = {
		["+"] = function(lines, regtype)
			osc_yank(table.concat(lines, "\n"))
		end,
	},
	paste = {
		["+"] = { "notify_send", "no paste" },
	},
	cache_enabled = false,
}
