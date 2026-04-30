return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Lua
        "lua-language-server",
        "stylua",

        -- Shell
        "shellcheck",
        "shfmt",

        -- Python
        "pyright",
        "flake8",

        -- TypeScript / JSON / YAML
        "vtsls",
        "json-lsp",
        "yaml-language-server",

        -- Java (LazyVim lang.java extra와 중복되지만 안전하게 명시)
        "jdtls",
        "java-debug-adapter",
        "java-test",

        -- Kotlin
        "kotlin-lsp",
        "kotlin-debug-adapter",
        "ktlint",

        -- Misc
        "tree-sitter-cli",
      },
    },
  },
}
