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

-- kotlin-lsp는 Homebrew(JetBrains/utils/kotlin-lsp)로 설치한다(mason 아님).
-- brew의 `kotlin-lsp`는 intellij-server 런처 심볼릭 링크라 `--stdio`로 호출한다.
-- (lspconfig 기본 cmd는 mason의 `intellij-server`라서 반드시 덮어써야 함)
vim.lsp.config('kotlin_lsp', {
  cmd = { 'kotlin-lsp', '--stdio' },
  flags = {
    -- 입력마다 didChange를 보내면 FIR 분석 엔진의 lazy-resolve 레이스가 잦아진다.
    -- 디바운스를 둬서 서버 부하/에러를 줄인다(0 -> 150ms).
    debounce_text_changes = 150,
  },
  on_init = function(client)
    -- 시맨틱 토큰 비활성화: 현재 빌드(LS-262.4739.0)의 LSKotlinSemanticTokensProvider가
    -- FIR resolve 중 예외를 폭주시킨다. 하이라이트는 treesitter가 담당.
    -- 서버 측에서 수정되면 이 on_init 블록만 제거하면 된다.
    client.server_capabilities.semanticTokensProvider = nil
  end,
})
