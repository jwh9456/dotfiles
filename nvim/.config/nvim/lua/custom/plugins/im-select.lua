local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'keaising/im-select.nvim',
}

require('im_select').setup {
  default_command = 'macism',
  default_im_select = 'com.apple.keylayout.ABC',
  set_default_events = { 'InsertLeave', 'CmdlineLeave' },
  set_previous_events = { 'InsertEnter' },
  keep_quiet_on_no_binary = false,
  async_switch_im = true,
}
