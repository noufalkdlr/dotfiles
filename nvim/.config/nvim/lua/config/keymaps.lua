-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>cx", function()
  local file = vim.fn.expand("%:p")

  if file == "" then
    return
  end

  vim.cmd("write")

  vim.fn.system({
    "ruff",
    "check",
    "--fix",
    "--exit-zero",
    file,
  })

  local format_output = vim.fn.system({
    "ruff",
    "format",
    file,
  })

  if vim.v.shell_error ~= 0 then
    vim.notify(format_output, vim.log.levels.ERROR)
    return
  end

  local check_output = vim.fn.system({
    "ruff",
    "check",
    file,
  })

  vim.cmd("edit!")

  if vim.v.shell_error ~= 0 then
    vim.notify(check_output, vim.log.levels.WARN)
    return
  end

  vim.notify("Ruff fixed and formatted")
end, { desc = "Ruff Fix + Format" })
