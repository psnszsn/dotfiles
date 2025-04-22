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
		end,
	},
}
