local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
  gh 'nvim-tree/nvim-web-devicons',
}

vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle reveal<cr>', { desc = 'Explorer NeoTree' })
vim.keymap.set('n', '<leader>E', '<cmd>Neotree toggle<cr>', { desc = 'Explorer NeoTree cwd' })
vim.keymap.set('n', '\\', '<cmd>Neotree reveal<cr>', { desc = 'NeoTree reveal' })

require('neo-tree').setup {
  close_if_last_window = true,
  filesystem = {
    follow_current_file = {
      enabled = true,
    },
    use_libuv_file_watcher = true,
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
