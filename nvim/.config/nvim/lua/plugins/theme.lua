return {

  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    opts = {
      colors = {
        bg = "#161719",
      },
      highlights = {
        Normal = { bg = "#161719" },
        NormalFloat = { bg = "#161719" },
        NormalNC = { bg = "#161719" },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
