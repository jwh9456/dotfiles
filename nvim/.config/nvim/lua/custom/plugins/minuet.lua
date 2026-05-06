local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'milanglacier/minuet-ai.nvim',
}

require('minuet').setup {
  notify = 'warn',
  request_timeout = 10,
  provider = 'openai_compatible',
  provider_options = {
    openai_compatible = {
      name = 'ollama-cloud',
      model = 'deepseek-v4-flash',
      end_point = 'https://ollama.com/v1/chat/completions',
      api_key = 'OLLAMA_API_KEY',
      stream = true,
      optional = {
        reasoning_effort = 'none',
      },
    },
  },
  duet = {
    provider = 'openai_compatible',
    provider_options = {
      openai_compatible = {
        name = 'ollama-cloud',
        model = 'deepseek-v4-flash',
        end_point = 'https://ollama.com/v1/chat/completions',
        api_key = 'OLLAMA_API_KEY',
        optional = {
          reasoning_effort = 'none',
        },
      },
    },
  },
}

return {
  blink = {
    keymap = {
      ['<A-y>'] = {
        function(cmp) cmp.show { providers = { 'minuet' } } end,
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
      providers = {
        minuet = {
          name = 'minuet',
          module = 'minuet.blink',
          async = true,
          timeout_ms = 3000,
          score_offset = 50,
        },
      },
    },
    completion = {
      trigger = {
        prefetch_on_insert = false,
      },
    },
  },
}
