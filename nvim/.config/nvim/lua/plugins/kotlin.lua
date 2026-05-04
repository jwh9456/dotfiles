return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      local rename_handler = vim.lsp.handlers["textDocument/rename"]

      vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
        local client = vim.lsp.get_client_by_id(ctx.client_id)

        if client and client.name == "kotlin_lsp" and result and result.documentChanges then
          for _, change in ipairs(result.documentChanges) do
            if change.textDocument then
              -- kotlin_lsp can return stale document versions for rename edits.
              -- Let Neovim apply the edit instead of rejecting it with "Buffer ... newer than edits".
              change.textDocument.version = vim.NIL
            end
          end
        end

        return rename_handler(err, result, ctx, config)
      end
    end,
    opts = {
      servers = {
        kotlin_lsp = {
          flags = {
            debounce_text_changes = 0,
          },
        },
      },
    },
  },
}
