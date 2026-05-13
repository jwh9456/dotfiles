local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.ft = nil
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function notify_missing(feature)
  vim.notify(feature .. ' is not available in this kickstart config', vim.log.levels.WARN)
end

local function git_root()
  local root = vim.fs.root(0, '.git')
  return root or vim.fn.getcwd()
end

local function current_file()
  local file = vim.api.nvim_buf_get_name(0)
  return file ~= '' and file or nil
end

local function delete_buffer(bufnr, force)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(buf) return vim.bo[buf].buflisted end, vim.api.nvim_list_bufs())

  if #listed > 1 then vim.cmd.bprevious() end
  vim.cmd((force and 'bdelete! ' or 'bdelete ') .. bufnr)
end

local function delete_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if bufnr ~= current and vim.bo[bufnr].buflisted then pcall(vim.cmd, 'bdelete ' .. bufnr) end
  end
end

local function toggle_option(name, opts)
  opts = opts or {}
  local current = vim.o[name]
  local next_value

  if opts.off ~= nil and opts.on ~= nil then
    next_value = current == opts.on and opts.off or opts.on
  else
    next_value = not current
  end

  vim.o[name] = next_value
  vim.notify((opts.name or name) .. ' ' .. (next_value and 'enabled' or 'disabled'))
end

local function toggle_diagnostics()
  vim.g.diagnostics_enabled = vim.g.diagnostics_enabled ~= false
  vim.g.diagnostics_enabled = not vim.g.diagnostics_enabled
  vim.diagnostic.enable(vim.g.diagnostics_enabled)
  vim.notify('Diagnostics ' .. (vim.g.diagnostics_enabled and 'enabled' or 'disabled'))
end

local function toggle_treesitter()
  vim.g.treesitter_enabled = vim.g.treesitter_enabled ~= false
  vim.g.treesitter_enabled = not vim.g.treesitter_enabled

  if vim.g.treesitter_enabled then
    pcall(vim.treesitter.start)
  else
    pcall(vim.treesitter.stop)
  end

  vim.notify('Treesitter ' .. (vim.g.treesitter_enabled and 'enabled' or 'disabled'))
end

local terminal = {
  buf = nil,
  win = nil,
}

local zoom = {
  tab = nil,
  win = nil,
}

local function open_terminal(cwd)
  if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
    vim.api.nvim_set_current_win(terminal.win)
    vim.cmd.startinsert()
    return
  end

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.85)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  terminal.buf = vim.api.nvim_create_buf(false, true)
  terminal.win = vim.api.nvim_open_win(terminal.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  vim.fn.termopen(vim.o.shell, {
    cwd = cwd,
    on_exit = function()
      if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then vim.api.nvim_win_close(terminal.win, true) end
      terminal.buf = nil
      terminal.win = nil
    end,
  })
  vim.cmd.startinsert()
end

local function fzf(name, opts)
  return function()
    local ok, fzf_lua = pcall(require, 'fzf-lua')
    if not ok then
      notify_missing('fzf-lua')
      return
    end
    fzf_lua[name](opts or {})
  end
end

local function gitbrowse(copy)
  local file = current_file()
  if not file then return end

  local root = git_root()
  local rel = vim.fn.fnamemodify(file, ':p'):sub(#vim.fn.fnamemodify(root, ':p') + 1)
  local remote = vim.fn.system({ 'git', '-C', root, 'config', '--get', 'remote.origin.url' }):gsub('%s+$', '')
  local branch = vim.fn.system({ 'git', '-C', root, 'branch', '--show-current' }):gsub('%s+$', '')

  if remote == '' or branch == '' then
    notify_missing('Git remote or branch')
    return
  end

  local url = remote:gsub('^git@([^:]+):', 'https://%1/'):gsub('%.git$', '')
  url = url .. '/blob/' .. branch .. '/' .. rel .. '#L' .. vim.fn.line '.'

  if copy then
    vim.fn.setreg('+', url)
    vim.notify('Copied ' .. url)
  else
    vim.ui.open(url)
  end
end

local function git_blame_line()
  local file = current_file()
  if not file then return end

  local root = git_root()
  local rel = vim.fn.fnamemodify(file, ':p'):sub(#vim.fn.fnamemodify(root, ':p') + 1)
  local line = vim.fn.line '.'
  local result = vim.system({ 'git', '-C', root, 'blame', '-L', line .. ',' .. line, '--', rel }, { text = true }):wait()

  if result.code ~= 0 then
    vim.notify(result.stderr ~= '' and result.stderr or 'git blame failed', vim.log.levels.ERROR)
    return
  end

  vim.notify(vim.trim(result.stdout))
end

local function toggle_zoom()
  if zoom.tab and vim.api.nvim_tabpage_is_valid(zoom.tab) then
    vim.cmd.tabclose()
    zoom.tab = nil
    zoom.win = nil
    return
  end

  zoom.win = vim.api.nvim_get_current_win()
  vim.cmd 'tab split'
  zoom.tab = vim.api.nvim_get_current_tabpage()
end

local function diagnostic_goto(next, severity)
  return function()
    vim.diagnostic.jump {
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    }
  end
end

-- better up/down
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })

-- windows
map('n', '<C-h>', '<C-w>h', { desc = 'Go to Left Window', remap = true })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to Lower Window', remap = true })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to Upper Window', remap = true })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to Right Window', remap = true })
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })
map('n', '<leader>-', '<C-w>s', { desc = 'Split Window Below', remap = true })
map('n', '<leader>|', '<C-w>v', { desc = 'Split Window Right', remap = true })
map('n', '<leader>wd', '<C-w>c', { desc = 'Delete Window', remap = true })
map('n', '<leader>ww', '<C-w>w', { desc = 'Other Window' })

-- move lines
map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
map('v', '<A-j>', ':<C-u>execute "\'<,\'>move \'>+" . v:count1<cr>gv=gv', { desc = 'Move Down' })
map('v', '<A-k>', ':<C-u>execute "\'<,\'>move \'<-" . (v:count1 + 1)<cr>gv=gv', { desc = 'Move Up' })

-- buffers
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
map('n', '<leader>`', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
map('n', '<leader>bd', function() delete_buffer(nil, false) end, { desc = 'Delete Buffer' })
map('n', '<leader>bo', delete_other_buffers, { desc = 'Delete Other Buffers' })
map('n', '<leader>bD', '<cmd>bd<cr>', { desc = 'Delete Buffer and Window' })

-- editing
map({ 'i', 'n', 's' }, '<esc>', function()
  vim.cmd.nohlsearch()
  return '<esc>'
end, { expr = true, desc = 'Escape and Clear hlsearch' })
map('n', '<leader>ur', '<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-l><cr>', { desc = 'Redraw / Clear hlsearch / Diff Update' })
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
map('i', ',', ',<C-g>u')
map('i', '.', '.<C-g>u')
map('i', ';', ';<C-g>u')
map({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })
map('n', '<leader>K', '<cmd>norm! K<cr>', { desc = 'Keywordprg' })
map('x', '<', '<gv')
map('x', '>', '>gv')
map('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Below' })
map('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })
map('n', '<leader>fn', '<cmd>enew<cr>', { desc = 'New File' })
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })

-- lists, diagnostics, formatting
map('n', '<leader>xl', function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'Location List' })
map('n', '<leader>xq', function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'Quickfix List' })
map('n', '[q', vim.cmd.cprev, { desc = 'Previous Quickfix' })
map('n', ']q', vim.cmd.cnext, { desc = 'Next Quickfix' })
map({ 'n', 'x' }, '<leader>cf', function() require('conform').format { async = true } end, { desc = 'Format' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
map('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
map('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
map('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
map('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
map('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })

-- toggles
map('n', '<leader>uf', function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify('Autoformat ' .. (vim.g.autoformat and 'enabled' or 'disabled'))
end, { desc = 'Toggle Autoformat' })
map('n', '<leader>uF', function()
  vim.b.autoformat = not vim.b.autoformat
  vim.notify('Buffer autoformat ' .. (vim.b.autoformat and 'enabled' or 'disabled'))
end, { desc = 'Toggle Autoformat Buffer' })
map('n', '<leader>us', function() toggle_option('spell', { name = 'Spelling' }) end, { desc = 'Toggle Spelling' })
map('n', '<leader>uw', function() toggle_option('wrap', { name = 'Wrap' }) end, { desc = 'Toggle Wrap' })
map('n', '<leader>uL', function() toggle_option('relativenumber', { name = 'Relative Number' }) end, { desc = 'Toggle Relative Number' })
map('n', '<leader>ud', toggle_diagnostics, { desc = 'Toggle Diagnostics' })
map('n', '<leader>ul', function() toggle_option('number', { name = 'Line Number' }) end, { desc = 'Toggle Line Number' })
map('n', '<leader>uc', function() toggle_option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = 'Conceal Level' }) end, { desc = 'Toggle Conceal Level' })
map('n', '<leader>uA', function() toggle_option('showtabline', { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = 'Tabline' }) end, { desc = 'Toggle Tabline' })
map('n', '<leader>uT', toggle_treesitter, { desc = 'Toggle Treesitter' })
map('n', '<leader>ub', function() toggle_option('background', { off = 'light', on = 'dark', name = 'Dark Background' }) end, { desc = 'Toggle Dark Background' })
map('n', '<leader>uD', function() notify_missing('Dim toggle') end, { desc = 'Toggle Dim' })
map('n', '<leader>ua', function() notify_missing('Animation toggle') end, { desc = 'Toggle Animations' })
map('n', '<leader>ug', function() notify_missing('Indent guides toggle') end, { desc = 'Toggle Indent Guides' })
map('n', '<leader>uS', function() notify_missing('Smooth scroll toggle') end, { desc = 'Toggle Smooth Scroll' })
map('n', '<leader>dpp', function() notify_missing('Profiler') end, { desc = 'Toggle Profiler' })
map('n', '<leader>dph', function() notify_missing('Profiler highlights') end, { desc = 'Toggle Profiler Highlights' })
if vim.lsp.inlay_hint then
  map('n', '<leader>uh', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {}) end, { desc = 'Toggle Inlay Hints' })
end

-- git
map('n', '<leader>gL', fzf 'git_commits', { desc = 'Git Log cwd' })
map('n', '<leader>gb', git_blame_line, { desc = 'Git Blame Line' })
map('n', '<leader>gf', fzf 'git_bcommits', { desc = 'Git Current File History' })
map('n', '<leader>gl', fzf('git_commits', { cwd = git_root() }), { desc = 'Git Log' })
map({ 'n', 'x' }, '<leader>gB', function() gitbrowse(false) end, { desc = 'Git Browse open' })
map({ 'n', 'x' }, '<leader>gY', function() gitbrowse(true) end, { desc = 'Git Browse copy' })

-- inspect
map('n', '<leader>ui', vim.show_pos, { desc = 'Inspect Pos' })
map('n', '<leader>uI', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input 'I'
end, { desc = 'Inspect Tree' })
map('n', '<leader>l', function() vim.pack.update(nil, { offline = true }) end, { desc = 'vim.pack status' })

-- terminal
map('n', '<leader>fT', function() open_terminal(vim.fn.getcwd()) end, { desc = 'Terminal cwd' })
map('n', '<leader>ft', function() open_terminal(git_root()) end, { desc = 'Terminal Root Dir' })
map({ 'n', 't' }, '<C-/>', function() open_terminal(git_root()) end, { desc = 'Terminal Root Dir' })
map({ 'n', 't' }, '<C-_>', function() open_terminal(git_root()) end, { desc = 'which_key_ignore' })
map('n', '<leader>wm', toggle_zoom, { desc = 'Toggle Zoom' })
map('n', '<leader>uZ', toggle_zoom, { desc = 'Toggle Zoom' })
map('n', '<leader>uz', function() notify_missing('Zen mode') end, { desc = 'Toggle Zen Mode' })

-- tabs
map('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
map('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
map('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

-- lua
map({ 'n', 'x' }, '<localleader>r', function() vim.cmd.source '%' end, { desc = 'Run Lua', ft = 'lua' })
