local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'NMAC427/guess-indent.nvim',
  gh 'lewis6991/gitsigns.nvim',
  gh 'folke/todo-comments.nvim',
  gh 'nvim-mini/mini.nvim',
}

if vim.g.have_nerd_font then vim.pack.add { gh 'nvim-tree/nvim-web-devicons' } end

require('guess-indent').setup {}

require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

require('todo-comments').setup { signs = false }

require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

require('mini.surround').setup()

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
statusline.section_location = function() return '%2l:%-2v' end

local map = require 'mini.map'
map.setup {
  integrations = {
    map.gen_integration.builtin_search(),
    map.gen_integration.diagnostic {
      error = 'DiagnosticFloatingError',
      warn = 'DiagnosticFloatingWarn',
      info = 'DiagnosticFloatingInfo',
      hint = 'DiagnosticFloatingHint',
    },
    map.gen_integration.gitsigns(),
  },
  symbols = {
    encode = map.gen_encode_symbols.dot '4x2',
    scroll_line = '█',
    scroll_view = '┃',
  },
  window = {
    side = 'right',
    width = 10,
    winblend = 25,
    show_integration_count = false,
  },
}

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function() map.open() end,
})
