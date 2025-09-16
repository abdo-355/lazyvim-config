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
      -- Enable sqlfluff linting for SQL files with improved configuration
      opts.linters_by_ft.sql = { "sqlfluff" }
      opts.linters_by_ft.pgsql = { "sqlfluff" }
      
      opts.linters = opts.linters or {}
      opts.linters.sqlfluff = {
        cmd = "sqlfluff",
        args = { 
          "lint",
          "--format=json",
          "--dialect=postgres",
          "--config", vim.fn.expand("~/.config/.sqlfluff"),
          "-",
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
            -- Only process violations for stdin (current buffer)
            if item.filepath == "stdin" and item.violations then
              for _, violation in ipairs(item.violations) do
                -- Use 0-based line numbers for Neovim
                local start_lnum = math.max(0, (violation.start_line_no or 1) - 1)
                local start_col = math.max(0, (violation.start_line_pos or 1) - 1)
                local end_lnum = math.max(0, (violation.end_line_no or violation.start_line_no or 1) - 1)
                local end_col = math.max(0, (violation.end_line_pos or violation.start_line_pos or 1) - 1)

                -- Skip diagnostics that are disabled in config or not useful
                local code = violation.code or ""
                local excluded_rules = {
                  "LT01", "LT02", "LT04", "LT05", "LT06", "LT07", "LT08", "LT09", "LT10", 
                  "LT11", "LT12", "LT13", "LT14", "LT15", "AM04", "CP01"
                }
                
                local should_skip = false
                for _, rule in ipairs(excluded_rules) do
                  if code:match("^" .. rule) then
                    should_skip = true
                    break
                  end
                end
                
                -- Also skip spacing and layout issues that conflict with formatters
                if code:match("^LT01") or code:match("^LT14") or code:match("^LT09") or code:match("^AM04") or code:match("^CP01") then
                  should_skip = true
                end
                
                if should_skip then
                  goto continue
                end

                -- Determine severity based on rule type
                local severity = vim.diagnostic.severity.WARN
                if code:match("^L") then
                  severity = vim.diagnostic.severity.INFO
                elseif code:match("^E") then
                  severity = vim.diagnostic.severity.ERROR
                end

                table.insert(diagnostics, {
                  lnum = start_lnum,
                  col = start_col,
                  end_lnum = end_lnum,
                  end_col = end_col,
                  severity = severity,
                  message = violation.description or "SQL issue",
                  code = violation.code,
                  source = "sqlfluff",
                })
                ::continue::
              end
            end
          end

          return diagnostics
        end,
      }
    end,
  },
}
