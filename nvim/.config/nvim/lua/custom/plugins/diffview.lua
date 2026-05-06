local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'sindrets/diffview.nvim',
}

vim.keymap.set('n', '<leader>gD', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview' })
vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File History' })

require('diffview').setup {}
