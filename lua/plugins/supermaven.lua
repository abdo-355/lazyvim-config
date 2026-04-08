return {
  {
    "saghen/blink.cmp",
    dependencies = {
      {
        "supermaven-inc/supermaven-nvim",
        opts = {
          disable_inline_completion = true,
          disable_keymaps = true,
        },
      },
      { "saghen/blink.compat", opts = {} },
      { "Huijiro/blink-cmp-supermaven" },
    },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }

      if not vim.tbl_contains(opts.sources.default, "supermaven") then
        table.insert(opts.sources.default, 3, "supermaven")
      end

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.supermaven = vim.tbl_deep_extend("force", opts.sources.providers.supermaven or {}, {
        name = "supermaven",
        module = "blink-cmp-supermaven",
        async = true,
      })
    end,
  },
}
