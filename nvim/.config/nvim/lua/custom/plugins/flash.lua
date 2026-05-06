local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'folke/flash.nvim',
}

local flash = require 'flash'

flash.setup {
  modes = {
    char = {
      enabled = true,
      jump_labels = true,
    },
  },
}

vim.keymap.set({ 'n', 'x', 'o' }, 's', function() flash.jump() end, { desc = 'Flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() flash.treesitter() end, { desc = 'Flash Treesitter' })
vim.keymap.set('o', 'r', function() flash.remote() end, { desc = 'Remote Flash' })
vim.keymap.set({ 'o', 'x' }, 'R', function() flash.treesitter_search() end, { desc = 'Treesitter Search' })
vim.keymap.set('c', '<C-s>', function() flash.toggle() end, { desc = 'Toggle Flash Search' })
