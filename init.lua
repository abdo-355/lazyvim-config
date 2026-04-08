-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.diagnostic.config({
  virtual_text = {
    source = "always",  -- Change from "if_many" to "always"
    prefix = "●",
  }
})