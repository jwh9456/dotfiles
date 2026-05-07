local ok, jdtls = pcall(require, 'jdtls')
if not ok then return end

local root_dir = vim.fs.root(0, {
  'gradlew',
  'mvnw',
  'settings.gradle',
  'settings.gradle.kts',
  'pom.xml',
  '.git',
})

if not root_dir then return end

local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name
local jdtls_cmd = 'jdtls'

if vim.fn.executable(jdtls_cmd) ~= 1 then
  vim.notify('jdtls is not installed. Run brew install jdtls.', vim.log.levels.WARN)
  return
end

jdtls.start_or_attach {
  cmd = {
    jdtls_cmd,
    '-data',
    workspace_dir,
  },
  root_dir = root_dir,
}
