return {
  "L3MON4D3/LuaSnip",
  config = function()
    local luasnip = require("luasnip")
    
    -- Load custom Go snippets from LuaSnip directory
    require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/LuaSnip/" })
    
    -- Configure LuaSnip
    luasnip.config.setup({
      update_events = 'TextChanged,TextChangedI',
      enable_autosnippets = true,
      store_selection_keys = "<Tab>",
    })
    
    -- Load friendly-snippets (already loaded by LazyVim extra)
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Key mappings for snippet navigation
    vim.keymap.set({ "i", "s" }, "<C-k>", function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { silent = true })
    
    vim.keymap.set({ "i", "s" }, "<C-j>", function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { silent = true })
    
    vim.keymap.set({ "i", "s" }, "<C-l>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end, { silent = true })
    
    -- Load custom snippets from snippets directory
    require("luasnip.loaders.from_vscode").lazy_load({
      paths = { "~/.config/nvim/snippets" }
    })
  end,
}
