local M = {}

-- Module dependencies
local config = require('pivot.config')
local utils = require('pivot.utils')

-- Neovim 0.8+: Use vim.health, otherwise use vim.fn['health#*']
local health
if vim.health then
  health = vim.health
else
  health = {
    start = vim.fn["health#report_start"],
    ok = vim.fn["health#report_ok"],
    warn = vim.fn["health#report_warn"],
    error = vim.fn["health#report_error"],
    info = vim.fn["health#report_info"],
  }
end

function M.check()
  health.start("pivot.nvim")

  -- Check Neovim version
  local v = vim.version and vim.version() or { major = 0, minor = 0, patch = 0 }

  if v.major > 0 or (v.major == 0 and v.minor >= 8) then
    health.ok("Neovim version: v" .. v.major .. "." .. v.minor .. "." .. v.patch .. " (fully compatible)")
  elseif v.major == 0 and v.minor >= 5 then
    health.ok("Neovim version: v" ..
      v.major .. "." .. v.minor .. "." .. v.patch .. " (compatible, using fallback methods)")
  else
    health.error("Neovim version: v" ..
      v.major .. "." .. v.minor .. "." .. v.patch .. " (too old, upgrade to 0.5.0 or newer)")
    health.info("pivot.nvim requires Neovim 0.5.0 or later")
  end

  -- Check required API functions exist
  local api_checks = {
    ["nvim_create_buf"] = "Creating buffers",
    ["nvim_win_get_buf"] = "Managing windows",
    ["nvim_buf_get_option"] = "Getting buffer options",
    ["nvim_win_set_buf"] = "Setting window buffers",
  }

  for func, purpose in pairs(api_checks) do
    if vim.api[func] then
      health.ok("API check: " .. func .. " (available)")
    else
      health.error("API check: " .. func .. " (missing, required for " .. purpose .. ")")
    end
  end

  -- Check for required dependencies or configurations
  local config_module = package.loaded["pivot.config"]
  if config_module and config_module.options then
    health.ok("Configuration loaded successfully")

    -- Check specific configuration settings
    if config_module.options.smart_splits then
      health.ok("Smart split/merge functionality is enabled")
    else
      health.info("Smart split/merge functionality is disabled (splits will never merge)")
    end

    -- Check for conflicting settings
    health.info("Checking for conflicting settings...")

    -- Check smart_splits and prevent_duplicates
    if config_module.options.smart_splits and not config_module.options.prevent_duplicates then
      health.warn("Potentially confusing settings: smart_splits is enabled but prevent_duplicates is disabled")
      health.info("Merging might create duplicate buffer views unexpectedly.")
    end

    -- Check for incomplete keymap pairs
    if config_module.options.keymaps then
      local missing_pairs = {}

      -- Check for horizontal/vertical split pairs
      if config_module.options.keymaps.split_right and not config_module.options.keymaps.split_left then
        table.insert(missing_pairs, "split_left")
      elseif config_module.options.keymaps.split_left and not config_module.options.keymaps.split_right then
        table.insert(missing_pairs, "split_right")
      end

      -- Check for up/down split pairs
      if config_module.options.keymaps.split_up and not config_module.options.keymaps.split_down then
        table.insert(missing_pairs, "split_down")
      elseif config_module.options.keymaps.split_down and not config_module.options.keymaps.split_up then
        table.insert(missing_pairs, "split_up")
      end

      -- Check swap pairs (horizontal)
      if config_module.options.keymaps.swap_right and not config_module.options.keymaps.swap_left then
        table.insert(missing_pairs, "swap_left")
      elseif config_module.options.keymaps.swap_left and not config_module.options.keymaps.swap_right then
        table.insert(missing_pairs, "swap_right")
      end

      -- Check swap pairs (vertical)
      if config_module.options.keymaps.swap_up and not config_module.options.keymaps.swap_down then
        table.insert(missing_pairs, "swap_down")
      elseif config_module.options.keymaps.swap_down and not config_module.options.keymaps.swap_up then
        table.insert(missing_pairs, "swap_up")
      end

      -- Check buffer navigation pairs
      if config_module.options.keymaps.prev_buffer and not config_module.options.keymaps.next_buffer then
        table.insert(missing_pairs, "next_buffer")
      elseif config_module.options.keymaps.next_buffer and not config_module.options.keymaps.prev_buffer then
        table.insert(missing_pairs, "prev_buffer")
      end

      if #missing_pairs > 0 then
        health.warn("Incomplete keymap pairs detected: " .. table.concat(missing_pairs, ", "))
        health.info("For consistent user experience, consider mapping these keys as well")
      end
    end
  else
    health.error("Failed to load configuration")
    health.info("Try running :lua require('pivot').setup({}) to initialize configuration")
  end

  -- Check autocommand setup
  if utils.is_nvim_07_or_later then
    health.ok("Using modern autocmd API (Neovim 0.7+ features)")
  else
    health.info("Using legacy autocmd approach (compatible with Neovim <0.7)")
  end

  -- Check split/buffer command parity
  local function check_command_pairs(keys, description)
    local missing = {}
    for _, key in ipairs(keys) do
      if not config_module.options.keymaps[key] then
        table.insert(missing, key)
      end
    end

    if #missing == 0 then
      health.ok(description .. ": All command pairs are configured")
    else
      health.warn(description .. ": Missing keys: " .. table.concat(missing, ", "))
      health.info("For complete functionality, configure all related keys")
    end
  end

  check_command_pairs(
    { "split_right", "split_left", "split_up", "split_down" },
    "Split creation"
  )

  check_command_pairs(
    { "move_to_right", "move_to_left", "move_to_up", "move_to_down" },
    "Buffer movement"
  )

  check_command_pairs(
    { "swap_right", "swap_left", "swap_up", "swap_down" },
    "Buffer swap"
  )

  check_command_pairs(
    { "close_split", "close_buffer" },
    "Close operations"
  )

  -- Check buffer option handling safety
  health.info("Checking buffer option safety...")

  -- Test safe_get_buf_option function
  local utils_module = require('pivot.utils')
  if utils_module.safe_get_buf_option then
    health.ok("Safe buffer option handling is available")
  else
    health.error("Safe buffer option handling is missing - this may cause errors")
    health.info("Update to the latest plugin version to fix this issue")
  end

  -- Test actual buffer handling with error protection
  local current_buf = vim.api.nvim_get_current_buf()
  local status, _ = pcall(function()
    local test = utils_module.safe_get_buf_option(current_buf, 'buflisted')
    return test
  end)

  if status then
    health.ok("Buffer option access works correctly with safe handling")
  else
    health.warn("Safe buffer option handling still encounters errors")
    health.info("This might be due to very old Neovim version or unusual buffer configuration")
  end

  -- Final status
  health.info("pivot.nvim version: " .. require('pivot').version)
  health.ok("Health check completed")
end

return M
