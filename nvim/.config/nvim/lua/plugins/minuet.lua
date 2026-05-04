return {
  {
    "milanglacier/minuet-ai.nvim",
    opts = {
      notify = "warn",
      request_timeout = 10,
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          name = "ollama-cloud",
          model = "deepseek-v4-flash",
          end_point = "https://ollama.com/v1/chat/completions",
          api_key = "OLLAMA_API_KEY",
          stream = true,
          optional = {
            reasoning_effort = "none",
          },
        },
      },
      duet = {
        provider = "openai_compatible",
        provider_options = {
          openai_compatible = {
            name = "ollama-cloud",
            model = "deepseek-v4-flash",
            end_point = "https://ollama.com/v1/chat/completions",
            api_key = "OLLAMA_API_KEY",
            optional = {
              reasoning_effort = "none",
            },
          },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap["<A-y>"] = {
        function(cmp)
          cmp.show({ providers = { "minuet" } })
        end,
      }

      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      if not vim.tbl_contains(opts.sources.default, "minuet") then
        table.insert(opts.sources.default, "minuet")
      end

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.minuet = {
        name = "minuet",
        module = "minuet.blink",
        async = true,
        timeout_ms = 3000,
        score_offset = 50,
      }
      opts.completion = { trigger = { prefetch_on_insert = false } }
    end,
  },
}
