local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'milanglacier/minuet-ai.nvim',
}

require('minuet').setup {
  notify = 'warn',
  request_timeout = 10,
  provider = 'openai_fim_compatible',
  provider_options = {
    openai_compatible = {
      name = 'ollama-cloud',
      model = 'nemotron-3-nano:30b',
      end_point = 'https://ollama.com/v1/chat/completions',
      api_key = 'OLLAMA_API_KEY',
      stream = true,
      optional = {
        reasoning_effort = 'none',
      },
    },
    openai_fim_compatible = {
      name = 'ollama-cloud',
      model = 'nemotron-3-nano:30b',
      end_point = 'https://ollama.com/v1/completions',
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
        model = 'nemotron-3-nano:30b',
        end_point = 'https://ollama.com/v1/chat/completions',
        api_key = 'OLLAMA_API_KEY',
        optional = {
          reasoning_effort = 'none',
        },
      },
    },
  },
  virtualtext = {},
}

return {}
