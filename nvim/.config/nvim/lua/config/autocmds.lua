-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ruff auto correction when save
vim.api.nvim_create_autocmd("BufWritePre", {
  -- This function triggers only for Python (.py) files
  pattern = "*.py",

  callback = function()
    -- We disable the diagnostic for the entire code action block below
    ---@diagnostic disable-next-line: assign-type-mismatch, missing-fields
    vim.lsp.buf.code_action({
      context = {
        only = { "source.fixAll.ruff" },
        diagnostics = {},
      },
      apply = true,
    })
  end,
})
