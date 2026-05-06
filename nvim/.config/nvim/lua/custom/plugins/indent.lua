local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'lukas-reineke/indent-blankline.nvim',
}

require('ibl').setup {
  indent = {
    char = '│',
    tab_char = '│',
  },
  scope = {
    enabled = true,
    show_start = false,
    show_end = false,
  },
  exclude = {
    filetypes = {
      'dashboard',
      'help',
      'lazy',
      'mason',
      'neo-tree',
      'noice',
      'notify',
      'starter',
      'terminal',
    },
  },
}
