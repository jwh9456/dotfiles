local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' },
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' },
}

require('luasnip').setup {}

local blink_opts = {
  keymap = {
    preset = 'default',
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
}

local has_minuet, minuet = pcall(require, 'custom.plugins.minuet')
if has_minuet then blink_opts = vim.tbl_deep_extend('force', blink_opts, minuet.blink or {}) end

require('blink.cmp').setup(blink_opts)
