local cmd = vim.cmdfunct
local fn = vim.fn

local M = {}

M.toggle_qf = function()
  local windows = fn.getwininfo()
  local qf_exists = false
  for _, win in pairs(windows) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    cmd("cclose")
    return
  end
  if M.isNotEmpty(fn.getqflist()) then
    cmd("copen")
  end
end

M.toggle_colorcolumn = function()
  local value = vim.api.nvim_get_option_value("colorcolumn", {})
  if value == "" then
    M.notify("Enable colocolumn", 1, "functions.lua")
    vim.api.nvim_set_option_value("colorcolumn", "79", {})
  else
    M.notify("Disable colocolumn", 1, "functions.lua")
    vim.api.nvim_set_option_value("colorcolumn", "", {})
  end
end

M.copy_file_path = function()
  vim.fn.setreg('+', vim.fn.expand('%:p'))
end

M.copy_file_name = function()
  vim.fn.setreg('+', vim.fn.expand('%:t'))
end

M.copy_file_path_from_root = function()
  vim.fn.setreg('+', vim.fn.fnamemodify(vim.fn.expand('%'), ':p:.'))
end

M.clipboard_switch_brackets = function()
  local sub, count = string.gsub(vim.fn.getreg('+'), [[\]], [[/]])
  if(count > 0) then
    vim.fn.setreg('+', sub)
  else
    local sub, _ = string.gsub(vim.fn.getreg('+'), [[/]], [[\]])
    vim.fn.setreg('+', sub)
  end
end

-- TODO this could be cleaner
M.diff_is_toggled = false
M.toggle_diff_splits = function ()
  local neo_tree_loaded, _ = pcall(require, 'neo-tree')
  if M.diff_is_toggled then
    if neo_tree_loaded then
      vim.cmd([[NeoTreeClose]])
    end
    vim.cmd([[windo diffthis]])
  else
    vim.cmd([[diffoff!]])
  end
  M.diff_is_toggled = not M.diff_is_toggled
end

return M
