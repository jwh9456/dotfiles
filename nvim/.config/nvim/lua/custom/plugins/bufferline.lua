local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'akinsho/bufferline.nvim', version = vim.version.range '*' },
  gh 'nvim-tree/nvim-web-devicons',
}

vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next buffer' })

require('bufferline').setup {
  options = {
    diagnostics = 'nvim_lsp',
    offsets = {
      {
        filetype = 'neo-tree',
        text = 'Neo-tree',
        highlight = 'Directory',
        text_align = 'left',
      },
    },
    separator_style = 'thin',
    show_buffer_close_icons = false,
    show_close_icon = false,
  },
}
