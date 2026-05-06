local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'catppuccin/nvim',
}

require('catppuccin').setup {
  flavour = 'mocha',
  integrations = {
    blink_cmp = true,
    diffview = true,
    gitsigns = true,
    mason = true,
    mini = true,
    neotree = true,
    noice = true,
    notify = true,
    treesitter = true,
    which_key = true,
  },
}

vim.cmd.colorscheme 'catppuccin'
