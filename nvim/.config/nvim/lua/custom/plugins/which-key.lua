local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'folke/which-key.nvim',
}

require('which-key').setup {
  preset = 'helix',
  delay = 0,
  win = {
    border = 'rounded',
    padding = { 1, 2 },
    title = true,
    title_pos = 'center',
    wo = { winblend = 0 },
  },
  layout = {
    width = { min = 20 },
    spacing = 3,
  },
  sort = { 'local', 'order', 'group', 'alphanum', 'mod' },
  icons = {
    mappings = vim.g.have_nerd_font,
    group = vim.g.have_nerd_font and ' ' or '+',
    separator = '➜',
  },
  spec = {
    { '<leader><tab>', group = 'tabs' },
    { '<leader>b', group = 'buffer' },
    { '<leader>c', group = 'code' },
    { '<leader>d', group = 'debug' },
    { '<leader>e', group = 'explorer' },
    { '<leader>f', group = 'file/find' },
    { '<leader>g', group = 'git' },
    { '<leader>h', group = 'git hunk', mode = { 'n', 'v' } },
    { '<leader>q', group = 'quit/session' },
    { '<leader>r', group = 'run' },
    { '<leader>s', group = 'search', mode = { 'n', 'v' } },
    { '<leader>t', group = 'toggle' },
    { '<leader>u', group = 'ui' },
    { '<leader>w', group = 'windows' },
    { '<leader>x', group = 'diagnostics/quickfix' },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}
