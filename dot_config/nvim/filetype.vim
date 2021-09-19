" my filetype file
if exists("did_load_filetypes")
	finish
endif

augroup filetypedetect
	au! BufRead,BufNewFile *.fish		setfiletype fish
	au! BufRead,BufNewFile *.zig		setfiletype zig
augroup END
