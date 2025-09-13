-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })

-- for ui code actions
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- remap the write to an easier key
vim.keymap.set("n", "<leader>ww", vim.cmd.write, { desc = "Write" })

vim.api.nvim_set_keymap("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true }) -- Move line down
vim.api.nvim_set_keymap("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true }) -- Move line up

-- SQL-specific keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "pgsql" },
  callback = function(event)
    local opts = { buffer = event.buf, noremap = true, silent = true }
    
    -- Format SQL buffer
    vim.keymap.set("n", "<leader>sf", function()
      vim.lsp.buf.format({ async = true })
    end, vim.tbl_extend("force", opts, { desc = "Format SQL" }))
    
    -- Run SQL linting
    vim.keymap.set("n", "<leader>sl", function()
      require("lint").try_lint()
    end, vim.tbl_extend("force", opts, { desc = "Lint SQL" }))
    
    -- Execute SQL query (placeholder for future integration)
    vim.keymap.set("n", "<leader>se", function()
      print("SQL execution not configured - add your preferred SQL client integration here")
    end, vim.tbl_extend("force", opts, { desc = "Execute SQL" }))
    
    -- sqlc generate and restart LSP
    vim.keymap.set("n", "<leader>sg", function()
      vim.cmd("SqlcGenerate")
    end, vim.tbl_extend("force", opts, { desc = "sqlc Generate + LSP Restart" }))
    
    -- sqlc generate only
    vim.keymap.set("n", "<leader>sG", function()
      vim.cmd("SqlcGen")
    end, vim.tbl_extend("force", opts, { desc = "sqlc Generate Only" }))
  end,
})

-- Go-specific keymaps for sqlc integration
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function(event)
    local opts = { buffer = event.buf, noremap = true, silent = true }
    
    -- sqlc generate and restart LSP (useful when working with generated Go files)
    vim.keymap.set("n", "<leader>gg", function()
      vim.cmd("SqlcGenerate")
    end, vim.tbl_extend("force", opts, { desc = "sqlc Generate + LSP Restart" }))
    
    -- Restart LSP (useful when LSP doesn't recognize changes)
    vim.keymap.set("n", "<leader>gr", function()
      vim.cmd("LspRestart")
    end, vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
  end,
})
