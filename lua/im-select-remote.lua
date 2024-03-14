local M = {}
M.config = {
  osc = {
    secret = "",
  },
  socket = {
    port = 23333,
    max_retry_count = 3,
    command = "im-select com.apple.keylayout.ABC",
  },
}

local retry_count = 0

--- write writes the OSC 1337 escape sequence to the terminal
-- @tparam osc1337 string the OSC 1337 escape sequence
-- @treturn bool whether the write was successful
local function write(osc1337)
  local success = false
  if vim.fn.has("nvim") then
    success = vim.fn.chansend(vim.api.nvim_get_var("stderr"), osc1337) > 0
  else
    vim.cmd("silent! !echo " .. vim.fn.shellescape(osc1337))
    vim.cmd("redraw!")
    success = true
  end
  return success
end

--- check_auto_enable_conditions checks whether the auto enable conditions are met
-- @treturn bool whether the auto enable conditions are met
local function check_auto_enable_socket()
  if vim.fn.system("cat ~/.ssh/config | grep 'Port " .. M.config.socket.port .. "'") ~= "" then
    return true
  end
  return false
end

M.IMSelectByOSC = function()
  write("\033]1337;Custom=id=" .. M.config.osc.secret .. ":im-select\a")
end

--- IMSelectBySocket
-- @treturn int the exit code of the command
M.IMSelectBySocket = function()
  local function on_stdout() end
  local cmd = "echo "
    .. vim.fn.shellescape(M.config.socket.command)
    .. " | nc localhost "
    .. M.config.socket.port
    .. " -q 0"
  vim.fn.jobstart(cmd, {
    on_stdout = on_stdout,
    on_stderr = on_stdout,
    on_exit = on_stdout,
    stdout_buffered = false,
    stderr_buffered = false,
  })
end

M.IMSelectOSCEnable = function()
  vim.cmd([[
      augroup im_select_remote
        autocmd!
        autocmd BufEnter * lua require("im-select-remote").IMSelectByOSC()
        autocmd InsertLeave * lua require("im-select-remote").IMSelectByOSC()
      augroup END
    ]])
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
  if check_auto_enable_socket() then
    local result = os.execute("nc -z localhost " .. M.config.socket.port .. " -q 0")
    for i = 1, M.config.socket.max_retry_count do
      if result == 0 then
        break
      end
      result = os.execute("nc -z localhost " .. M.config.socket.port .. " -q 0")
      retry_count = i
      vim.cmd("sleep 50m")
    end

    if retry_count == M.config.socket.max_retry_count then
      vim.notify("IMSelectServer is not running, please start it first!", vim.log.levels.WARN)
      return
    end

    M.IMSelectSocketEnable()
  end
end

return M
