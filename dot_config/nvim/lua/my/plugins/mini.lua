return {
	{ -- Collection of various small independent plugins/modules
		'echasnovski/mini.nvim',
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [']quote
			--  - ci'  - [C]hange [I]nside [']quote
			require('mini.ai').setup { n_lines = 500 }

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			require('mini.surround').setup {
				mappings = {
					add = 'js',
					delete = 'ds',
					find = '',
					find_left = '',
					highlight = '',
					replace = 'cs',
					update_n_lines = '',

					-- Add this only if you don't want to use extended mappings
					suffix_last = '',
					suffix_next = '',
				},
				search_method = 'cover_or_next',
			}

			-- Remap adding surrounding to Visual mode selection
			vim.keymap.del('x', 'js')
			vim.keymap.set('x', 'S', function()
				require('mini.surround').add 'visual'
			end, { silent = true })

			-- Make special mapping for "add surrounding for line"
			vim.keymap.set('n', 'jss', 'ys_', { remap = true })

			require('mini.comment').setup()
			require('mini.align').setup()
			require('mini.splitjoin').setup()
			require('mini.visits').setup()

			-- vim.opt.background = 'light'
			-- vim.cmd.colorscheme 'minicyan'

			require('mini.pick').setup {}
			require('mini.extra').setup {}

			local minipick = require 'mini.pick'
			local miniextra = require 'mini.extra'

			minipick.setup {
				mappings = {
					scroll_down = '<C-d>',
					scroll_up = '<C-u>',
				},
			}

			vim.keymap.set('n', '<leader>ff', minipick.builtin.files, { desc = '[F]ind [F]iles' })
			vim.keymap.set('n', '<leader>fe', miniextra.pickers.explorer, { desc = '[F]ile [E]xplorer' })
			vim.keymap.set('n', '<leader>fb', minipick.builtin.buffers, { desc = '[F]ind existing [b]uffers' })
			vim.keymap.set('n', '<leader>rg', minipick.builtin.grep_live, { desc = 'Find by [R]ip[G]rep' })
			-- Shortcut for searching your neovim configuration files
			vim.keymap.set('n', '<leader>sn', function()
				minipick.builtin.files({}, { source = { cwd = vim.fn.stdpath 'config' } })
			end, { desc = '[S]earch [N]eovim files' })
			vim.keymap.set('n', '<leader><leader>', function()
				miniextra.pickers.visit_paths()
			end, { noremap = true, silent = true })
		end,
	},
}
