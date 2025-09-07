return {
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = { "nvimtools/hydra.nvim" },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCunderCursor", "MCpattern" },
    keys = {
      {
        mode = { "n", "v" },
        "<leader>m",
        "<cmd>MCstart<cr>",
        desc = "Start multiple cursors",
      },
      {
        mode = { "n", "v" },
        "<leader>mc",
        "<cmd>MCclear<cr>",
        desc = "Clear multiple cursors",
      },
    },
  },
}
