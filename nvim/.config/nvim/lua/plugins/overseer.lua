return {
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerRun",
      "OverseerToggle",
      "OverseerOpen",
      "OverseerClose",
      "OverseerShell",
      "OverseerTaskAction",
    },
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run task" },
      { "<leader>rt", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
      { "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "Task action menu" },
    },
    config = function()
      local overseer = require("overseer")
      overseer.setup({
        task_list = {
          direction = "right",
          min_width = { 80, 0.25 },
        },
      })

      -- 태스크 시작 시 자동으로 하단에 출력 split 열기
      overseer.add_template_hook(nil, function(task_defn, util)
        util.add_component(task_defn, {
          "open_output",
          direction = "horizontal",
          focus = false,
          on_start = "always",
        })
      end)

      local function gradle_root()
        local found = vim.fs.find(
          { "build.gradle.kts", "build.gradle", "settings.gradle.kts", "settings.gradle" },
          { upward = true, path = vim.fn.getcwd() }
        )
        return found[1] and vim.fs.dirname(found[1]) or nil
      end

      local gradle_condition = {
        callback = function()
          return gradle_root() ~= nil
        end,
      }

      local function parse_env(s)
        local env = {}
        if not s or s == "" then
          return env
        end
        for pair in vim.gsplit(s, ";", { trimempty = true }) do
          local eq = pair:find("=", 1, true)
          if eq then
            local k = pair:sub(1, eq - 1):gsub("^%s+", ""):gsub("%s+$", "")
            local v = pair:sub(eq + 1):gsub("^%s+", ""):gsub("%s+$", "")
            env[k] = v
          end
        end
        return env
      end

      overseer.register_template({
        name = "Spring bootRun",
        desc = "./gradlew --no-daemon bootRun (active profiles + env vars)",
        condition = gradle_condition,
        params = {
          profile = {
            type = "string",
            default = "local",
            desc = "Active profiles (comma-separated)",
            optional = true,
          },
          env = {
            type = "string",
            default = "AWS_PROFILE=ajd-dev;SPRING_SHELL_NONINTERACTIVE_ENABLED=false",
            desc = "Env vars (semicolon-separated)",
            optional = true,
          },
          extra_args = {
            type = "string",
            default = "",
            desc = "Extra --args= entries (space-separated)",
            optional = true,
          },
        },
        builder = function(params)
          local env = parse_env(params.env)
          local boot_args = {}

          -- IntelliJ의 Spring Boot "Active profiles"와 동일하게 애플리케이션 인자로도 전달한다.
          -- env도 같이 넣어 두면 Gradle/앱 양쪽에서 확인하기 쉽다.
          if params.profile and params.profile ~= "" then
            env.SPRING_PROFILES_ACTIVE = params.profile
            table.insert(boot_args, "--spring.profiles.active=" .. params.profile)
          end
          if params.extra_args and params.extra_args ~= "" then
            table.insert(boot_args, params.extra_args)
          end

          -- Gradle daemon은 환경변수 변경을 물고 있을 수 있어, 실행 태스크는 no-daemon으로 띄운다.
          local args = { "--no-daemon", "bootRun" }
          if #boot_args > 0 then
            table.insert(args, "--args=" .. table.concat(boot_args, " "))
          end
          return {
            cmd = { "./gradlew" },
            args = args,
            env = env,
            cwd = gradle_root(),
          }
        end,
      })


      overseer.register_template({
        name = "Gradle test",
        desc = "./gradlew test",
        condition = gradle_condition,
        params = {
          tests = {
            type = "string",
            default = "",
            desc = "Test filter (e.g. com.example.FooTest). Empty for all.",
            optional = true,
          },
        },
        builder = function(params)
          local args = { "test" }
          if params.tests and params.tests ~= "" then
            table.insert(args, "--tests")
            table.insert(args, params.tests)
          end
          return { cmd = { "./gradlew" }, args = args, cwd = gradle_root() }
        end,
      })

      overseer.register_template({
        name = "Gradle clean build",
        desc = "./gradlew clean build",
        condition = gradle_condition,
        builder = function()
          return { cmd = { "./gradlew" }, args = { "clean", "build" }, cwd = gradle_root() }
        end,
      })

      overseer.register_template({
        name = "Gradle (custom task)",
        desc = "Run any gradle task by name",
        condition = gradle_condition,
        params = {
          task = { type = "string", desc = "Gradle task name (e.g. flywayMigrate)" },
        },
        builder = function(params)
          return { cmd = { "./gradlew" }, args = { params.task }, cwd = gradle_root() }
        end,
      })
    end,
  },
}
