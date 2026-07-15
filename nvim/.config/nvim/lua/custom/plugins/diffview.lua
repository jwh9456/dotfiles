local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'sindrets/diffview.nvim',
}

vim.keymap.set('n', '<leader>gD', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview' })
vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File History' })
vim.keymap.set('n', '<leader>gp', function()
  vim.ui.input({ prompt = 'Base: ', default = 'origin/master' }, function(base)
    if base and base ~= '' then vim.cmd('DiffviewOpen ' .. base .. '...HEAD') end
  end)
end, { desc = 'PR Diff vs base' })

require('diffview').setup {}
