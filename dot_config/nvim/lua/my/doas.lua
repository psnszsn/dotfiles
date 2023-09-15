local M = {}
local loop = vim.loop
local api = vim.api
local results = {}

local function onread(err, data)
    if err then
        -- print('ERROR: ', err)
        -- TODO handle err
    end
	print(data)
    -- if data then
    --     local vals = vim.split(data, "\n")
    --     for _, d in pairs(vals) do
    --         if d == "" then goto continue end
    --         table.insert(results, d)
    --         ::continue::
    --     end
    -- end
	-- print(results)
end

function M.doas(term)
    local stdin = vim.loop.new_pipe(false)
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)
	local password = vim.fn.inputsecret('Password:')

    handle = vim.loop.spawn('doas', {args = {"ls"}, stdio = {stdin, stdout, stderr}}, vim.schedule_wrap(function(code, signal)
		print("doas exit code:", code)
		stdin:close()
		stdout:close()
        handle:close()
        -- setQF()
    end))
	vim.loop.write(stdin, password)
	vim.loop.read_start(stdout, onread)
	vim.loop.read_start(stderr, onread)
	-- vim.loop.write(stdin, password)
end

-- M.doas("f")

return M
