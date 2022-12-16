if vim.b.current_compiler then
	print("CURRENT COMP")
	return
end

vim.opt_local.makeprg = "zig build $*"

vim.b.current_compiler = "zig_build"
