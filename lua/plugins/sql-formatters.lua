-- Alternative SQL formatters configuration
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Extend the existing formatters_by_ft
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sql = { "sqlfluff" }
      opts.formatters_by_ft.pgsql = { "sqlfluff" }
      
      -- Configure formatters
      opts.formatters = opts.formatters or {}
      
      -- SQLFluff formatter (primary choice)
      opts.formatters.sqlfluff = {
        command = "sqlfluff",
        args = { "format", "--dialect=postgres", "--config", vim.fn.expand("~/.config/nvim/.sqlfluff"), "-" },
        stdin = true,
      }
      
      -- pg_format formatter (sqlc-friendly)
      opts.formatters.pg_format = {
        command = "pg_format",
        args = {
          "--type-case", "2",        -- uppercase type names
          "--keyword-case", "2",     -- uppercase keywords  
          "--comma-start",           -- comma at start of line
          "--wrap-limit", "80",      -- line wrap at 80 chars
          "--no-space-function",     -- no space before function parentheses
          "--placeholder", "dollaronly", -- handle $1, $2, etc. placeholders
        },
        stdin = true,
      }
      
      return opts
    end,
  },
}
