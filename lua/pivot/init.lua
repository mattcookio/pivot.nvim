-- pivot.nvim - Advanced buffer and split management for Neovim
local M = {}

-- Load modules
local config = require('pivot.config')
local utils = require('pivot.utils')
local buffers = require('pivot.buffers')
local splits = require('pivot.splits')
local commands = require('pivot.commands')

-- Export all module functions with main module as the entrypoint
M.setup = function(user_config)
  -- Initialize configuration
  config.setup(user_config)

  -- Define custom highlight groups
  utils.define_dim_highlight()

  -- Set up buffer history tracking (always enabled now)
  utils.setup_autocmds(config.options) -- Always call setup

  -- Register commands
  commands.register_commands(config.options)

  -- Set up keymaps
  commands.setup_keymaps(config.options)

  -- Export the health checks module
  M.health = require('pivot.health')
end

-- Export all functions for individual use

-- Split operations
M.split_move_right = function() splits.split_move_right(config.options) end
M.split_move_left = function() splits.split_move_left(config.options) end
M.split_move_up = function() splits.split_move_up(config.options) end
M.split_move_down = function() splits.split_move_down(config.options) end
M.smart_split = function(direction) splits.smart_split(direction, config.options) end

-- Split management
M.close_split = function() splits.close_split(config.options) end
M.close_other_splits = function() splits.close_other_splits(config.options) end
M.close_all_splits = function() splits.close_all_splits(config.options) end

-- Split resizing
M.resize = function(direction) splits.resize(direction, config.options) end
M.resize_equal = function() splits.resize_equal(config.options) end

-- Split navigation
M.navigate_left = function() splits.navigate_left(config.options) end
M.navigate_right = function() splits.navigate_right(config.options) end
M.navigate_down = function() splits.navigate_down(config.options) end
M.navigate_up = function() splits.navigate_up(config.options) end

-- Buffer operations
M.close_buffer = function() buffers.close_buffer(config.options) end
M.close_other_buffers = function() buffers.close_other_buffers(config.options) end
M.close_all_buffers = function() buffers.close_all_buffers(config.options) end
M.navigate_all_buffers = function(direction) buffers.navigate_all_buffers(direction, config.options) end

-- Add accessor for window history
M.get_window_buffer_history = function() return utils.window_buffer_history end

-- Add convenience methods for commonly used operations
M.create_empty_buffer = function() return utils.create_empty_buffer() end
M.get_fallback_buffer = function(win, current_buf) return utils.get_fallback_buffer(win, current_buf) end
M.get_valid_buffers = function(skip_visible) return utils.get_valid_buffers(skip_visible) end

-- Version information
M.version = "1.0.2"

return M
