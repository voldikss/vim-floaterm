-- vim:sw=2:
-- ============================================================================
-- FileName: floaterm.vim
-- Author: voldikss <dyzplus@gmail.com>
-- GitHub: https://github.com/voldikss
-- ============================================================================

local M = {}

local get_nvim_info = function()
  return vim.fn.split(vim.fn.execute('version'), "\n")[1]
end

local get_plugin_info = function()
  local home = string.sub(debug.getinfo(1).source, 2, string.len('/health.lua') * -1)
  local result = vim.fn.system('cd ' .. home .. ' ; git rev-parse --short HEAD')
  return result
end

local check_common = function()
  vim.health.start('common')
  vim.health.info('Platform: ' .. vim.loop.os_uname().sysname)
  vim.health.info('Nvim: ' .. get_nvim_info())
  vim.health.info('Plugin: ' .. get_plugin_info())
end

local check_terminal = function()
  vim.health.start('terminal')
  if vim.fn.exists(':terminal') then
    vim.health.ok('Terminal emulator is available')
  else
    vim.health.error(
      'Terminal emulator is missing',
      {'Install the latest version of neovim'}
    )
  end
end

local check_floating = function()
  vim.health.start('floating')
  if vim.fn.exists('*nvim_win_set_config') then
    vim.health.ok('Floating window is available')
  else
    vim.health.warn(
      'Floating window is missing, will fallback to use normal window',
      {'Install the latest version neovim'}
    )
  end
end

M.check = function()
  check_common()
  check_terminal()
  check_floating()
end

return M
