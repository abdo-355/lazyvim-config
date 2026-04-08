local sql_ft = { "sql", "pgsql" }
local sqlfluff_config = vim.fn.stdpath("config") .. "/.sqlfluff"

local function add_unique(list, value)
  if not vim.tbl_contains(list, value) then
    table.insert(list, value)
  end
end

local excluded_rules = {
  LT01 = true,
  LT02 = true,
  LT04 = true,
  LT05 = true,
  LT06 = true,
  LT07 = true,
  LT08 = true,
  LT09 = true,
  LT10 = true,
  LT11 = true,
  LT12 = true,
  LT13 = true,
  LT14 = true,
  LT15 = true,
  AM04 = true,
  CP01 = true,
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      add_unique(opts.ensure_installed, "sql")
    end,
    init = function()
      vim.filetype.add({
        extension = {
          pgsql = "pgsql",
          sqlc = "sql",
        },
        pattern = {
          [".*queries.*%.sql"] = "sql",
          [".*%.pgsql"] = "pgsql",
          ["query%.sql"] = "sql",
        },
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      add_unique(opts.ensure_installed, "sqlfluff")
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters_by_ft = opts.linters_by_ft or {}

      opts.linters.sqlfluff_postgres = {
        cmd = "sqlfluff",
        args = {
          "lint",
          "--format=json",
          "--dialect=postgres",
          "--config",
          sqlfluff_config,
          "-",
        },
        stdin = true,
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output)
          local diagnostics = {}
          local ok, decoded = pcall(vim.json.decode, output)
          if not ok or type(decoded) ~= "table" then
            return diagnostics
          end

          for _, item in ipairs(decoded) do
            if item.filepath == "stdin" and item.violations then
              for _, violation in ipairs(item.violations) do
                local code = violation.code or ""
                if excluded_rules[code] then
                  goto continue
                end

                local severity = vim.diagnostic.severity.WARN
                if code:match("^L") then
                  severity = vim.diagnostic.severity.INFO
                elseif code:match("^E") then
                  severity = vim.diagnostic.severity.ERROR
                end

                table.insert(diagnostics, {
                  lnum = math.max(0, (violation.start_line_no or 1) - 1),
                  col = math.max(0, (violation.start_line_pos or 1) - 1),
                  end_lnum = math.max(0, (violation.end_line_no or violation.start_line_no or 1) - 1),
                  end_col = math.max(0, (violation.end_line_pos or violation.start_line_pos or 1) - 1),
                  severity = severity,
                  message = violation.description or "SQL issue",
                  code = code,
                  source = "sqlfluff",
                })

                ::continue::
              end
            end
          end

          return diagnostics
        end,
      }

      for _, ft in ipairs(sql_ft) do
        opts.linters_by_ft[ft] = opts.linters_by_ft[ft] or {}
        add_unique(opts.linters_by_ft[ft], "sqlfluff_postgres")
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      opts.formatters.sqlfluff_postgres = {
        command = "sqlfluff",
        args = {
          "format",
          "--dialect=postgres",
          "--config",
          sqlfluff_config,
          "-",
        },
        stdin = true,
      }

      for _, ft in ipairs(sql_ft) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 1, "sqlfluff_postgres")
      end
    end,
  },
}
