local nvim_lsp = require("lspconfig")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
	-- Mappings.
	local opts = { buffer = bufnr }
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gi", require("telescope.builtin").lsp_implementations, opts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
	vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
	vim.keymap.set("n", "<leader>wl", function()
		vim.inspect(vim.lsp.buf.list_workspace_folders())
	end, opts)
	vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	-- vim.keymap.set("n", "gr", vim.lsp.lsp_buf.references, opts)
	vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>so", require("telescope.builtin").lsp_document_symbols, opts)
	vim.keymap.set("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, opts)
	-- vim.keymap.set("n", "<space>ds", vim.lsp.buf.document_symbol, opts)
	-- vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, opts)
	vim.keymap.set("n", "<space>f", function()
		vim.lsp.buf.format({ async = true })
	end, opts)

	if client.name == "clangd" then
		vim.keymap.set("n", "<space>x", "<cmd>ClangdSwitchSourceHeader<CR>", opts)
	end
end

local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.shfmt,
		null_ls.builtins.formatting.black,
		null_ls.builtins.diagnostics.pylint.with({
			method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
		}),
	},
	on_attach = on_attach,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- local servers = { "pyright", "rust_analyzer", "tsserver" }
local servers = { "clangd", "rust_analyzer", "gopls", "svelte", "pyright", "zls" }
for _, lsp in ipairs(servers) do
	nvim_lsp[lsp].setup({
		on_attach = on_attach,
		flags = { debounce_text_changes = 150 },
		capabilities = capabilities,
	})
end

nvim_lsp.lua_ls.setup({
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
			format = {
				enable = false,
			},
		},
	},
})
