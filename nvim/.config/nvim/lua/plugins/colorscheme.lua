return {
  -- 1. Install One Dark Pro plugin
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first
    config = function()
      require("onedarkpro").setup({
        options = {
          transparency = false, -- Set to false for a "Flat" look
          cursorline = true,
          lualine_transparency = false, -- Keep lualine solid
        },
        colors = {
          -- Darken the background slightly to achieve the "Night Flat" look (Optional)
          onedark_dark = {
            bg = "#0f111a", -- A deep, dark flat color
          },
        },
      })
    end,
  },

  -- 2. Set it as the default theme in LazyVim
  {
    "LazyVim/LazyVim",
    opts = {
      -- Use "onedark_dark" for the Night mode variant
      colorscheme = "onedark_dark",
    },
  },
}
