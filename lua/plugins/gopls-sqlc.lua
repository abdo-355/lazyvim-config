local function current_path()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then
    return name
  end
  return vim.uv.cwd()
end

local function find_project_root()
  local found = vim.fs.find({ "sqlc.yaml", "sqlc.yml", "go.work", "go.mod" }, {
    path = current_path(),
    upward = true,
  })
  if found and found[1] then
    return vim.fn.fnamemodify(found[1], ":h")
  end
  return vim.fn.fnamemodify(current_path(), ":h")
end

local function run_sqlc(restart_lsp)
  if vim.fn.executable("sqlc") ~= 1 then
    vim.notify("sqlc is not installed or not in PATH", vim.log.levels.ERROR)
    return
  end

  local root = find_project_root()
  local job = vim.fn.jobstart({ "sqlc", "generate" }, {
    cwd = root,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify("sqlc generate completed", vim.log.levels.INFO)
          if restart_lsp then
            vim.cmd("LspRestart")
          end
        else
          vim.notify("sqlc generate failed with exit code: " .. code, vim.log.levels.ERROR)
        end
      end)
    end,
  })

  if job <= 0 then
    vim.notify("failed to start sqlc generate", vim.log.levels.ERROR)
    return
  end

  vim.notify("running sqlc generate...", vim.log.levels.INFO)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          },
          settings = {
            gopls = {
              analyses = {
                shadow = true,
                fieldalignment = false,
              },
              experimentalPostfixCompletions = true,
            },
          },
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    init = function()
      vim.api.nvim_create_user_command("SqlcGenerate", function()
        run_sqlc(true)
      end, { desc = "Run sqlc generate and restart LSP" })

      vim.api.nvim_create_user_command("SqlcGen", function()
        run_sqlc(false)
      end, { desc = "Run sqlc generate" })
    end,
  },
}
