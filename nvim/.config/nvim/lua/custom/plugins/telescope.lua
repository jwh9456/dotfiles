local function gh(repo) return 'https://github.com/' .. repo end

local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}

if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

vim.pack.add(telescope_plugins)

require('telescope').setup {
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'

vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search help' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Search keymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>ss', builtin.find_files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>sS', builtin.lsp_dynamic_workspace_symbols, { desc = 'Search workspace symbols' })
vim.keymap.set('n', '<leader>sT', builtin.builtin, { desc = 'Search Telescope pickers' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = 'Search current word' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Search grep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search resume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Search recent files' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = 'Search commands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find existing buffers' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = 'Goto references' })
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = 'Goto implementation' })
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = 'Goto definition' })
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open document symbols' })
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open workspace symbols' })

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

vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Fuzzy search current buffer' })

vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = 'Search in open files' })

vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'Search Neovim files' })
