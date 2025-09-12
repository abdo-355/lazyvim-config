return {
  -- Treesitter configuration for SQL syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "sql" })
    end,
    init = function()
      -- Set up filetype associations for SQL and sqlc files
      vim.filetype.add({
        extension = {
          sql = "sql",
          pgsql = "pgsql", 
          sqlc = "sql", -- sqlc query files use SQL syntax
        },
        pattern = {
          [".*%.sql"] = "sql",
          [".*%.pgsql"] = "pgsql",
          ["query%.sql"] = "sql", -- common sqlc pattern
          [".*queries.*%.sql"] = "sql", -- sqlc queries directory pattern
        },
      })
    end,
  },

  -- SQL Language Server disabled for now due to sqlc placeholder compatibility issues
  -- The sql-language-server doesn't properly handle PostgreSQL $1, $2, etc. placeholders
  -- You can re-enable this later if you find a better SQL LSP that supports sqlc

  -- Linting configuration with nvim-lint
  {
    "mfussenegger/nvim-lint", 
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      -- Only use sqlfluff for regular SQL files, not sqlc files
      opts.linters_by_ft.sql = {}  -- Disable linting for now due to sqlc compatibility
      opts.linters_by_ft.pgsql = {}
      
      opts.linters = opts.linters or {}
      opts.linters.sqlfluff = {
        cmd = "sqlfluff",
        args = { 
          "lint", 
          "--format=json", 
          "--dialect=postgres",
          "--config", vim.fn.expand("~/.config/nvim/.sqlfluff"),
        },
        stdin = true,
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output, bufnr)
          local diagnostics = {}
          local ok, decoded = pcall(vim.json.decode, output)
          if not ok or not decoded then
            return diagnostics
          end
          
          for _, item in ipairs(decoded) do
            if item.violations then
              for _, violation in ipairs(item.violations) do
                table.insert(diagnostics, {
                  lnum = (violation.line_no or 1) - 1,
                  col = (violation.line_pos or 1) - 1,
                  end_lnum = (violation.line_no or 1) - 1,
                  end_col = (violation.line_pos or 1) - 1,
                  severity = violation.code:match("^L") and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR,
                  message = violation.description or "SQL formatting issue",
                  code = violation.code,
                  source = "sqlfluff",
                })
              end
            end
          end
          
          return diagnostics
        end,
      }
    end,
  },
}
