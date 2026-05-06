local lazygit_buf
local lazygit_win

local function git_root()
  local root = vim.fs.root(0, '.git')
  return root or vim.fn.getcwd()
end

local function open_lazygit(cwd)
  if vim.fn.executable 'lazygit' ~= 1 then
    vim.notify('lazygit executable not found', vim.log.levels.ERROR)
    return
  end

  if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
    vim.api.nvim_set_current_win(lazygit_win)
    return
  end

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  lazygit_buf = vim.api.nvim_create_buf(false, true)
  lazygit_win = vim.api.nvim_open_win(lazygit_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  vim.fn.termopen('lazygit', {
    cwd = cwd or vim.fn.getcwd(),
    on_exit = function()
      if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then vim.api.nvim_win_close(lazygit_win, true) end
      lazygit_win = nil
      lazygit_buf = nil
    end,
  })
  vim.cmd.startinsert()
end

vim.api.nvim_create_user_command('LazyGit', function(opts)
  open_lazygit(opts.bang and vim.fn.getcwd() or git_root())
end, { bang = true })
vim.keymap.set('n', '<leader>gg', function() open_lazygit(git_root()) end, { desc = 'Lazygit Root Dir' })
vim.keymap.set('n', '<leader>gG', function() open_lazygit(vim.fn.getcwd()) end, { desc = 'Lazygit cwd' })
