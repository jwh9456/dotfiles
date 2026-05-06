local starter = require 'mini.starter'
local sessions = require 'mini.sessions'

local max_sessions = 5

local function session_name()
  local cwd = vim.fn.getcwd()
  local basename = vim.fn.fnamemodify(cwd, ':t')
  local hash = vim.fn.sha256(cwd):sub(1, 8)
  return basename .. '-' .. hash .. '.vim'
end

local function prune_old_sessions()
  local detected = {}
  for name, data in pairs(sessions.detected or {}) do
    if data.type == 'global' then table.insert(detected, { name = name, modify_time = data.modify_time }) end
  end

  table.sort(detected, function(a, b) return a.modify_time > b.modify_time end)

  for i = max_sessions + 1, #detected do
    pcall(sessions.delete, detected[i].name, { force = true, verbose = false })
  end
end

local function save_current_session(verbose)
  sessions.write(session_name(), { force = true, verbose = verbose == true })
  prune_old_sessions()
end

sessions.setup {
  autoread = false,
  autowrite = true,
}

starter.setup {
  evaluate_single = true,
  items = {
    starter.sections.builtin_actions(),
    starter.sections.recent_files(10, false),
    starter.sections.recent_files(10, true),
    starter.sections.sessions(5, true),
  },
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.indexing('all', { 'Builtin actions' }),
    starter.gen_hook.padding(3, 2),
  },
}

vim.keymap.set('n', '<leader>qs', function()
  save_current_session(true)
end, { desc = 'Save Session' })

vim.keymap.set('n', '<leader>ql', function()
  sessions.read()
end, { desc = 'Restore Session' })

vim.keymap.set('n', '<leader>qd', function()
  sessions.delete(session_name(), { force = true })
end, { desc = 'Delete Session' })

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('custom-mini-sessions-auto-save', { clear = true }),
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.line '$' == 1 and vim.fn.getline(1) == '' then return end
    pcall(save_current_session, false)
  end,
  desc = 'Save current project session and keep latest sessions',
})
