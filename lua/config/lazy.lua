-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with LazyVim, your plugins, and Lazygit
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" }, -- LazyVim core and defaults [10][19]
 { import = "lazyvim.plugins.extras.coding.luasnip" },
    { import = "plugins" }, -- your own plugin specs folder [6][10]
    {
      "kdheepak/lazygit.nvim", -- Lazygit integration
      dependencies = { "nvim-lua/plenary.nvim" },
      keys = {
        { "<leader>g", "<cmd>LazyGit<cr>", desc = "Open Lazygit" }, -- keymap to open Lazygit
      },
      cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Diagnostics: update in insert so errors clear immediately when fixed
vim.diagnostic.config({
  update_in_insert = true,
})
