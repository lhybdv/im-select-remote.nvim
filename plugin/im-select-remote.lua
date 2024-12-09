vim.api.nvim_create_user_command("IMSelectBySocket", require("im-select-remote").IMSelectBySocket, {})
vim.api.nvim_create_user_command("IMSelectSocketEnable", require("im-select-remote").IMSelectSocketEnable, {})
vim.api.nvim_create_user_command("IMSelectDisable", require("im-select-remote").IMSelectDisable, {})
