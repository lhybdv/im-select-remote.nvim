local M = {}
M.config = {
  socket = {
    host = "127.0.0.1",
    port = 23333,
    max_retry_count = 3,
    command = "im-select 1033",
  },
}

--- check_auto_enable_conditions checks whether the auto enable conditions are met
-- @treturn bool whether the auto enable conditions are met
local function check_auto_enable_socket()
  if vim.fn.system("cat ~/.ssh/config | grep 'Port " .. M.config.socket.port .. "'") ~= "" then
    return true
  end
  return false
end

--- IMSelectBySocket
-- @treturn int the exit code of the command
M.IMSelectBySocket = function()
  local function on_stdout() end
  local cmd = "echo \""
    .. M.config.socket.command
    .. "\" | nc "
    .. M.config.socket.host
    .. " "
    .. M.config.socket.port
  vim.fn.jobstart(cmd, {
    on_stdout = on_stdout,
    on_stderr = on_stdout,
    on_exit = on_stdout,
    stdout_buffered = false,
    stderr_buffered = false,
  })
end

M.IMSelectSocketEnable = function()
  vim.notify("IMSelectRemote: Socket enabled", vim.log.levels.INFO)
  vim.cmd([[
      augroup im_select_remote
        autocmd!
        autocmd BufEnter * lua require("im-select-remote").IMSelectBySocket()
        autocmd InsertLeave * lua require("im-select-remote").IMSelectBySocket()
      augroup END
    ]])
end

M.IMSelectDisable = function()
  vim.cmd([[
      augroup im_select_remote
        autocmd!
      augroup END
    ]])
end

M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  M.IMSelectSocketEnable()
end

return M
