local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'ibhagwan/fzf-lua',
}

local fzf = require 'fzf-lua'

fzf.setup {
  'default-title',
  fzf_colors = true,
  winopts = {
    border = 'rounded',
    preview = { border = 'rounded' },
  },
}

fzf.register_ui_select()

vim.keymap.set('n', '<leader>sh', fzf.helptags, { desc = 'Search help' })
vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = 'Search keymaps' })
vim.keymap.set('n', '<leader>sf', fzf.files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>ss', fzf.files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>sS', fzf.lsp_live_workspace_symbols, { desc = 'Search workspace symbols' })
vim.keymap.set('n', '<leader>sT', fzf.builtin, { desc = 'Search fzf-lua pickers' })
vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = 'Search current word' })
vim.keymap.set('v', '<leader>sw', fzf.grep_visual, { desc = 'Search current selection' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = 'Search grep' })
vim.keymap.set('n', '<leader>sd', fzf.diagnostics_workspace, { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = 'Search resume' })
vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = 'Search recent files' })
vim.keymap.set('n', '<leader>sc', fzf.commands, { desc = 'Search commands' })
vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = 'Find existing buffers' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('fzf-lua-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    vim.keymap.set('n', 'grr', fzf.lsp_references, { buffer = buf, desc = 'Goto references' })
    vim.keymap.set('n', 'gri', fzf.lsp_implementations, { buffer = buf, desc = 'Goto implementation' })
    vim.keymap.set('n', 'grd', fzf.lsp_definitions, { buffer = buf, desc = 'Goto definition' })
    vim.keymap.set('n', 'gO', fzf.lsp_document_symbols, { buffer = buf, desc = 'Open document symbols' })
    vim.keymap.set('n', 'gW', fzf.lsp_live_workspace_symbols, { buffer = buf, desc = 'Open workspace symbols' })

    local function jump_to_location_item(item)
      local target_buf = item.bufnr or vim.fn.bufadd(item.filename)
      vim.fn.bufload(target_buf)

      local line_count = vim.api.nvim_buf_line_count(target_buf)
      local line = math.min(math.max(item.lnum or 1, 1), line_count)
      local col = math.max((item.col or 1) - 1, 0)

      vim.cmd "normal! m'"
      vim.bo[target_buf].buflisted = true
      vim.api.nvim_win_set_buf(0, target_buf)
      vim.api.nvim_win_set_cursor(0, { line, col })
      vim.cmd 'normal! zv'
    end

    local function safe_type_definition()
      vim.lsp.buf.type_definition {
        on_list = function(opts)
          if #opts.items == 1 then
            jump_to_location_item(opts.items[1])
            return
          end

          vim.fn.setqflist({}, ' ', opts)
          vim.cmd 'botright copen'
        end,
      }
    end

    vim.keymap.set('n', 'grt', safe_type_definition, { buffer = buf, desc = 'Goto type definition' })
  end,
})

vim.keymap.set('n', '<leader>/', fzf.blines, { desc = 'Fuzzy search current buffer' })

vim.keymap.set('n', '<leader>s/', function()
  local paths = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
      local name = vim.api.nvim_buf_get_name(b)
      if name ~= '' and vim.fn.filereadable(name) == 1 then table.insert(paths, name) end
    end
  end
  fzf.live_grep { prompt = 'Open Files> ', search_paths = paths }
end, { desc = 'Search in open files' })

vim.keymap.set('n', '<leader>sn', function() fzf.files { cwd = vim.fn.stdpath 'config' } end, { desc = 'Search Neovim files' })
