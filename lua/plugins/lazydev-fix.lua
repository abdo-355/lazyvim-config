return {
  {
    "folke/lazydev.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.integrations = opts.integrations or {}
      -- Disable lspconfig integration to avoid 'is_enabled' nil errors
      opts.integrations.lspconfig = false
      return opts
    end,
  },
}


