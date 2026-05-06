local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'MunifTanjim/nui.nvim',
  gh 'folke/noice.nvim',
  gh 'rcarriga/nvim-notify',
}

vim.notify = require 'notify'

require('noice').setup {
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = true,
  },
}

vim.keymap.set('n', '<leader>sN', '<cmd>Noice telescope<cr>', { desc = 'Search Noice messages' })
