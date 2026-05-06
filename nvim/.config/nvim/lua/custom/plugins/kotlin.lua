local rename_handler = vim.lsp.handlers['textDocument/rename']

vim.lsp.handlers['textDocument/rename'] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)

  if client and client.name == 'kotlin_lsp' and result and result.documentChanges then
    for _, change in ipairs(result.documentChanges) do
      if change.textDocument then
        change.textDocument.version = vim.NIL
      end
    end
  end

  return rename_handler(err, result, ctx, config)
end

vim.lsp.config('kotlin_lsp', {
  flags = {
    debounce_text_changes = 0,
  },
})
