if vim.b.current_compiler then
	print("CURRENT COMP")
	return
end
print("zzz")

vim.opt_local.makeprg = "zig build $*"
vim.opt_local.errorformat = [[%f:%l:%c: %t%.%#: %m]]

vim.b.current_compiler = "zig_build2"
