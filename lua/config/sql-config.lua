-- SQL-specific configuration and autocmds

-- Set up SQL filetype settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "pgsql" },
  callback = function()
    -- Set comment string for SQL files
    vim.bo.commentstring = "-- %s"
    
    -- Set indentation preferences (compact formatting per user preference)
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
    
    -- Enable word wrap for long queries
    vim.wo.wrap = true
    vim.wo.linebreak = true
    
    -- Set textwidth for better formatting
    vim.bo.textwidth = 80
  end,
})

-- Create sqlfluff configuration directory and file if it doesn't exist
local function setup_sqlfluff_config()
  local config_dir = vim.fn.expand("~/.config")
  local sqlfluff_config = config_dir .. "/.sqlfluff"
  
  -- Check if .sqlfluff config exists, if not create a basic one
  if vim.fn.filereadable(sqlfluff_config) == 0 then
    local config_content = [[
[sqlfluff]
dialect = postgres
templater = placeholder
max_line_length = 80

[sqlfluff:layout:type:comma]
line_position = leading

[sqlfluff:rules:capitalisation.keywords]
capitalisation_policy = upper

[sqlfluff:rules:capitalisation.identifiers]
extended_capitalisation_policy = lower

[sqlfluff:rules:capitalisation.functions]
extended_capitalisation_policy = upper

[sqlfluff:rules:capitalisation.literals]
capitalisation_policy = upper

[sqlfluff:templater:placeholder]
param_style = dollar_quoted
]]
    
    local file = io.open(sqlfluff_config, "w")
    if file then
      file:write(config_content)
      file:close()
    end
  end
end

-- Setup sqlfluff config on startup
setup_sqlfluff_config()

-- Additional SQL-specific keymaps will be set in keymaps.lua
return {}
