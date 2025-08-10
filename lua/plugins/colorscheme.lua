return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)

      -- Custom function to make everything truly transparent with black background
      local function make_transparent()
        vim.cmd([[
          highlight Normal guibg=none ctermbg=none
          highlight NonText guibg=none ctermbg=none
          highlight SignColumn guibg=none ctermbg=none
          highlight NormalNC guibg=none ctermbg=none
          highlight MsgArea guibg=none ctermbg=none
          highlight TelescopeBorder guibg=none ctermbg=none
          highlight NvimTreeNormal guibg=none ctermbg=none
          highlight EndOfBuffer guibg=none ctermbg=none
        ]])
      end

      -- Apply transparency after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = make_transparent,
      })

      -- Apply immediately
      make_transparent()
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
