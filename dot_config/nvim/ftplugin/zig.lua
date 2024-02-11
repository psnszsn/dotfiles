if vim.b.did_ftplugin then
	-- print "DONE"
	return
end

vim.b.did_ftplugin = 1

-- print("Hello Zig!")
local opt_local = vim.opt_local

opt_local.expandtab = true
opt_local.tabstop = 8
opt_local.softtabstop = 4
opt_local.shiftwidth = 4
opt_local.suffixesadd = { ".zig", ".zir", ".zon" }

vim.cmd.compiler("zig_build2")

opt_local.commentstring = "// %s"
-- opt_local.formatoptions-=t formatoptions+=croql
--
vim.keymap.set("n", "<leader>sl", function()
	require("telescope.builtin").find_files({ cwd = "/usr/lib/zig/std/" })
end)
