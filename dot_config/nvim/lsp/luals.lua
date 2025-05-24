return {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { '.luarc.json', '.luarc.jsonc' },
	settings = {
		Lua = {
			telemetry = {
				enable = false,
			},
			format = {
				enable = false,
			},
		},
	},
}
