return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      terminal_colors = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
        comments = { italic = false },
        keywords = { italic = false },
        functions = { bold = true },
        variables = {},
      },
      sidebars = { "qf", "help", "vista_kind", "terminal", "packer" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = true,
      on_colors = function(colors)
        -- High contrast modifications
        colors.bg = "#0a0a0a"  -- Darker background
        colors.bg_dark = "#000000"  -- Even darker for sidebars
        colors.bg_float = "#0a0a0a"  -- Darker float backgrounds
        colors.bg_highlight = "#1a1a1a"  -- Darker highlight background
        colors.bg_popup = "#0a0a0a"  -- Darker popup background
        colors.bg_search = "#2d4a67"  -- More visible search highlight
        colors.bg_sidebar = "#000000"  -- Darker sidebar
        colors.bg_statusline = "#0a0a0a"  -- Darker statusline
        colors.bg_visual = "#2d4a67"  -- More visible visual selection
        colors.border = "#565f89"  -- More visible borders
        colors.fg = "#c0caf5"  -- Brighter foreground
        colors.fg_dark = "#a9b1d6"  -- Brighter dark foreground
        colors.fg_float = "#c0caf5"  -- Brighter float foreground
        colors.fg_gutter = "#3b4261"  -- More visible gutter
        colors.fg_sidebar = "#a9b1d6"  -- Brighter sidebar foreground
        colors.comment = "#7aa2f7"  -- More visible comments
        colors.diff = { add = "#2d4a67", change = "#2d4a67", delete = "#2d4a67" }  -- More visible diff
        colors.git = { add = "#2d4a67", change = "#2d4a67", delete = "#2d4a67" }  -- More visible git
        colors.gitSigns = { add = "#2d4a67", change = "#2d4a67", delete = "#2d4a67" }  -- More visible git signs
        colors.hint = "#1abc9c"  -- Brighter hint
        colors.info = "#0db9d7"  -- Brighter info
        colors.magenta = "#bb9af7"  -- Brighter magenta
        colors.orange = "#ff9e64"  -- Brighter orange
        colors.red = "#f7768e"  -- Brighter red
        colors.warning = "#e0af68"  -- Brighter warning
        colors.yellow = "#e0af68"  -- Brighter yellow
      end,
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
