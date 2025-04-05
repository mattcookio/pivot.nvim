local M = {}

-- Default configuration
M.defaults = {
  -- Core behavior options
  auto_record_history = true,
  history_limit = 10,
  smart_splits = true,
  smart_close = true,
  prevent_duplicates = true,

  -- User-configurable keymaps - set to false to disable a keymap
  keymaps = {
    -- Split operations
    split_right = '<leader>sl',
    split_left = '<leader>sh',
    split_down = '<leader>sj',
    split_up = '<leader>sk',

    -- Split management
    close_split = '<leader>sd',
    close_other_splits = '<leader>so',
    close_all_splits = '<leader>sa',

    -- Buffer operations
    close_buffer = '<leader>bd',
    close_other_buffers = '<leader>bo',
    close_all_buffers = '<leader>ba',

    -- Move buffer to different split
    move_to_right = '<leader>bl',
    move_to_left = '<leader>bh',
    move_to_down = '<leader>bj',
    move_to_up = '<leader>bk',

    -- Buffer navigation (skips buffers visible in other windows)
    prev_buffer = '<C-h>',
    next_buffer = '<C-l>',
    alt_prev_buffer = '<C-k>',
    alt_next_buffer = '<C-j>',

    -- Split navigation
    nav_left = '<C-D-h>',  -- Navigate to the split on the left
    nav_right = '<C-D-l>', -- Navigate to the split on the right
    nav_down = '<C-D-j>',  -- Navigate to the split below
    nav_up = '<C-D-k>',    -- Navigate to the split above
  },

  -- Command options
  commands = {
    enable = true,    -- Whether to create Neovim commands
    prefix = 'Pivot', -- Prefix for all commands (e.g. PivotSplitRight)
  },
}

-- Current user config (set in setup)
M.user = {}

-- Final merged configuration
M.options = {}

-- Function to validate the user configuration
function M.validate(user_config)
  user_config = user_config or {}

  -- Basic validation of configuration values
  if user_config.history_limit and type(user_config.history_limit) ~= "number" then
    vim.notify("pivot.nvim: history_limit must be a number", vim.log.levels.WARN)
    user_config.history_limit = M.defaults.history_limit
  end

  -- Validate keymaps configuration
  if user_config.keymaps and type(user_config.keymaps) ~= "table" then
    vim.notify("pivot.nvim: keymaps must be a table", vim.log.levels.WARN)
    user_config.keymaps = vim.deepcopy(M.defaults.keymaps)
  end

  return user_config
end

-- Initialize configuration with user overrides
function M.setup(user_config)
  -- Store the user config
  M.user = M.validate(user_config)

  -- Merge with defaults
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, M.user)

  return M.options
end

return M
