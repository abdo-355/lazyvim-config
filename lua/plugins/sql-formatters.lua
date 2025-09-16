-- Enhanced SQL formatters configuration
return {
  -- SQL Formatter plugin for better formatting
  {
    "sergei-durkin/sql-formatter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("sql-formatter").setup({
        sql = {
          dialect = "postgresql",
          tabWidth = 2,
          useTabs = false,
          keywordCase = "upper",
          functionCase = "upper",
          dataTypeCase = "upper",
          identifierCase = "lower",
          linesBetweenQueries = 1,
        },
        pgsql = {
          dialect = "postgresql", 
          tabWidth = 2,
          useTabs = false,
          keywordCase = "upper",
          functionCase = "upper",
          dataTypeCase = "upper",
          identifierCase = "lower",
          linesBetweenQueries = 1,
        },
      })
    end,
    keys = {
      { "<leader>fs", ":FormatSql<CR>", desc = "Format SQL", mode = { "n", "v" } },
    },
  },

  -- Conform.nvim configuration with improved formatters
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Extend the existing formatters_by_ft
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sql = { "sql_formatter", "pg_format" }
      opts.formatters_by_ft.pgsql = { "sql_formatter", "pg_format" }
      
      -- Configure formatters
      opts.formatters = opts.formatters or {}
      
      -- SQL Formatter (Node.js based - more reliable)
      opts.formatters.sql_formatter = {
        command = "sql-formatter",
        args = {
          "--language", "postgresql",
          "--config", vim.fn.expand("~/.config/.sql-formatter.json"),
        },
        stdin = true,
      }
      
      -- pg_format formatter (sqlc-friendly, compact style)
      opts.formatters.pg_format = {
        command = "pg_format",
        args = {
          "--type-case", "2",        -- uppercase type names
          "--keyword-case", "2",     -- uppercase keywords  
          "--comma-end",             -- comma at end of line (not start)
          "--wrap-limit", "100",     -- line wrap at 100 chars
          "--no-space-function",     -- no space before function parentheses
          "--placeholder", "dollaronly", -- handle $1, $2, etc. placeholders
          "--spaces", "2",           -- 2 space indentation
        },
        stdin = true,
      }
      
      return opts
    end,
  },
}
