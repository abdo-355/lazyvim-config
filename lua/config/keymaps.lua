-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
-- F13 evdev key maps to XF86Tools keysym in XKB
vim.keymap.set({ "n", "x", "s", "o", "i", "c", "t" }, "<F13>", "<Esc>", { desc = "Caps tap to Escape" })
vim.keymap.set({ "n", "x", "s", "o", "i", "c", "t" }, "<XF86Tools>", "<Esc>", { desc = "Caps tap to Escape" })
