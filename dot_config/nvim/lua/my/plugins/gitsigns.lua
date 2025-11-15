return {
	-- Adds git related signs to the gutter, as well as utilities for managing changes
	'lewis6991/gitsigns.nvim',
	opts = {
		-- See `:help gitsigns.txt`
		signs = {
			add = { text = '+' },
			change = { text = '~' },
			delete = { text = '_' },
			topdelete = { text = '‾' },
			changedelete = { text = '~' },
		},
		on_attach = function(bufnr)
			local gitsigns = require 'gitsigns'

			-- Navigation
			vim.keymap.set('n', ']c', function()
				if vim.wo.diff then
					vim.cmd.normal { ']c', bang = true }
				else
					gitsigns.nav_hunk 'next'
				end
			end, { buffer = bufnr, desc = 'Jump to next git [c]hange' })

			vim.keymap.set('n', '[c', function()
				if vim.wo.diff then
					vim.cmd.normal { '[c', bang = true }
				else
					gitsigns.nav_hunk 'prev'
				end
			end, { buffer = bufnr, desc = 'Jump to previous git [c]hange' })

			-- Actions
			-- visual mode
			vim.keymap.set('v', '<leader>hs', function()
				gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
			end, { buffer = bufnr, desc = 'git [s]tage hunk' })

			vim.keymap.set('v', '<leader>hr', function()
				gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
			end, { buffer = bufnr, desc = 'git [r]eset hunk' })

			-- normal mode
			vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { buffer = bufnr, desc = 'git [s]tage hunk' })
			vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { buffer = bufnr, desc = 'git [r]eset hunk' })
			vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { buffer = bufnr, desc = 'git [S]tage buffer' })
			vim.keymap.set('n', '<leader>hu', gitsigns.stage_hunk, { buffer = bufnr, desc = 'git [u]ndo stage hunk' })
			vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { buffer = bufnr, desc = 'git [R]eset buffer' })
			vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { buffer = bufnr, desc = 'git [p]review hunk' })
			vim.keymap.set('n', '<leader>hb', gitsigns.blame_line, { buffer = bufnr, desc = 'git [b]lame line' })
			vim.keymap.set('n', '<leader>hb', gitsigns.blame, { buffer = bufnr, desc = 'git [b]lame window' })
			vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { buffer = bufnr, desc = 'git [d]iff against index' })

			vim.keymap.set('n', '<leader>hD', function()
				gitsigns.diffthis '@'
			end, { buffer = bufnr, desc = 'git [D]iff against last commit' })
			-- Toggles
			vim.keymap.set(
				'n',
				'<leader>tb',
				gitsigns.toggle_current_line_blame,
				{ buffer = bufnr, desc = '[T]oggle git show [b]lame line' }
			)
			vim.keymap.set(
				'n',
				'<leader>tD',
				gitsigns.preview_hunk_inline,
				{ buffer = bufnr, desc = '[T]oggle git show [D]eleted' }
			)
		end,
	},
}
