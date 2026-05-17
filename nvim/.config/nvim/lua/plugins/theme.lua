local primary_bg = "#090d17"
local split_color = "#191c21"
local selection_color = "#141b2b"
local highlight_color = "#141b2b"

return {

  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    opts = {
      colors = {
        bg = primary_bg,
        split = split_color,
      },
      highlights = {
        Normal = { bg = primary_bg },
        NormalFloat = { bg = primary_bg },
        NormalNC = { bg = primary_bg },

        Visual = { bg = selection_color },
        NeoTreeDirectoryName = { fg = "#abb2bf" },
        NeoTreeFileNameOpened = { fg = "#61afef", bg = selection_color },

        WinSeparator = { fg = split_color, bg = primary_bg },
        NeoTreeWinSeparator = { fg = split_color, bg = primary_bg },
        VertSplit = { fg = split_color, bg = primary_bg },
        SnacksPickerBorder = { fg = split_color, bg = primary_bg },

        LspReferenceText = { bg = highlight_color },
        LspReferenceRead = { bg = highlight_color },
        LspReferenceWrite = { bg = highlight_color },
        IlluminatedWordText = { bg = highlight_color },
        IlluminatedWordRead = { bg = highlight_color },
        IlluminatedWordWrite = { bg = highlight_color },
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
