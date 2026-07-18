-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ruff auto correction when save

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   -- This function triggers only for Python (.py) files
--   pattern = "*.py",
--
--   callback = function()
--     -- We disable the diagnostic for the entire code action block below
--     ---@diagnostic disable-next-line: assign-type-mismatch, missing-fields
--     vim.lsp.buf.code_action({
--       context = {
--         only = { "source.fixAll.ruff" },
--         diagnostics = {},
--       },
--       apply = true,
--     })
--   end,
-- })

-- Workaround: Auto-select the "dev" Kulala environment on startup.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "http", "rest" },
  callback = function()
    vim.schedule(function()
      pcall(function()
        require("kulala").set_selected_env("dev")
      end)
    end)
  end,
})

-- Make <C-h> return to the HTTP request window instead of switching Kulala tabs.
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = "kulala_ui",
  callback = function(event)
    vim.defer_fn(function()
      vim.keymap.set("n", "<C-h>", function()
        vim.cmd("wincmd h")
      end, {
        buffer = event.buf,
        silent = true,
        nowait = true,
        desc = "Move to left window",
      })
    end, 100)
  end,
})
