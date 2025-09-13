return {
  -- Configure gopls with file watching capabilities for sqlc support
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          -- Enable file watching capabilities to detect sqlc generated files
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          },
          -- Additional gopls settings for better sqlc support
          settings = {
            gopls = {
              -- Enable more features that help with generated code
              analyses = {
                unusedparams = true,
                shadow = true,
                fieldalignment = false, -- Can be noisy with generated code
              },
              -- Watch for changes in generated files
              experimentalPostfixCompletions = true,
              -- Better support for generated code
              gofumpt = true,
              usePlaceholders = true,
            },
          },
        },
      },
    },
  },

  -- Create custom commands and autocmds for sqlc integration
  {
    "nvim-lua/plenary.nvim", -- Ensure plenary is available for job control
  },

  -- Custom sqlc commands
  {
    "LazyVim/LazyVim",
    init = function()
      -- Register custom commands
      vim.api.nvim_create_user_command("SqlcGenerate", function()
        -- Use job control for better async handling
        local job = vim.fn.jobstart("sqlc generate", {
          on_exit = function(_, exit_code)
            if exit_code == 0 then
              vim.schedule(function()
                vim.notify("sqlc generate completed successfully", vim.log.levels.INFO)
                -- Restart LSP to pick up generated files
                vim.cmd("LspRestart")
              end)
            else
              vim.schedule(function()
                vim.notify("sqlc generate failed with exit code: " .. exit_code, vim.log.levels.ERROR)
              end)
            end
          end,
        })
        
        if job == 0 then
          vim.notify("Failed to start sqlc generate job", vim.log.levels.ERROR)
        else
          vim.notify("Running sqlc generate...", vim.log.levels.INFO)
        end
      end, { desc = "Run sqlc generate and restart LSP" })
      
      -- Alternative command that just runs sqlc without LSP restart
      vim.api.nvim_create_user_command("SqlcGen", function()
        local job = vim.fn.jobstart("sqlc generate", {
          on_exit = function(_, exit_code)
            if exit_code == 0 then
              vim.schedule(function()
                vim.notify("sqlc generate completed successfully", vim.log.levels.INFO)
              end)
            else
              vim.schedule(function()
                vim.notify("sqlc generate failed with exit code: " .. exit_code, vim.log.levels.ERROR)
              end)
            end
          end,
        })
        
        if job == 0 then
          vim.notify("Failed to start sqlc generate job", vim.log.levels.ERROR)
        else
          vim.notify("Running sqlc generate...", vim.log.levels.INFO)
        end
      end, { desc = "Run sqlc generate only" })
    end,
  },
}
