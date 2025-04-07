local M = {}

-- Module dependencies
local splits = require('pivot.splits')
local buffers = require('pivot.buffers')

-- Register user commands
function M.register_commands(config)
  if not config.commands.enable then
    return
  end

  local prefix = config.commands.prefix

  -- Command definitions
  local command_def = {
    -- Split commands (Layout-Aware)
    [prefix .. "SplitRight"] = {
      function() splits.split_move_right(config) end,
      desc = "Split window right (layout aware), moving buffer if possible"
    },
    [prefix .. "SplitLeft"] = {
      function() splits.split_move_left(config) end,
      desc = "Split window left (layout aware), moving buffer if possible"
    },
    [prefix .. "SplitUp"] = {
      function() splits.split_move_up(config) end,
      desc = "Split window up (layout aware), moving buffer if possible"
    },
    [prefix .. "SplitDown"] = {
      function() splits.split_move_down(config) end,
      desc = "Split window down (layout aware), moving buffer if possible"
    },

    -- Smart split commands (Merge or Layout-Aware Split)
    [prefix .. "SmartSplitRight"] = {
      function() splits.smart_split('l', config) end,
      desc = "Smart split right (merge or layout-aware split)"
    },
    [prefix .. "SmartSplitLeft"] = {
      function() splits.smart_split('h', config) end,
      desc = "Smart split left (merge or layout-aware split)"
    },
    [prefix .. "SmartSplitUp"] = {
      function() splits.smart_split('k', config) end,
      desc = "Smart split up (merge or layout-aware split)"
    },
    [prefix .. "SmartSplitDown"] = {
      function() splits.smart_split('j', config) end,
      desc = "Smart split down (merge or layout-aware split)"
    },

    -- Split commands (Full-Span)
    [prefix .. "SplitFullRight"] = {
      function() splits.split_move_full_right(config) end,
      desc = "Split window full-height right, moving buffer if possible"
    },
    [prefix .. "SplitFullLeft"] = {
      function() splits.split_move_full_left(config) end,
      desc = "Split window full-height left, moving buffer if possible"
    },
    [prefix .. "SplitFullUp"] = {
      function() splits.split_move_full_up(config) end,
      desc = "Split window full-width up, moving buffer if possible"
    },
    [prefix .. "SplitFullDown"] = {
      function() splits.split_move_full_down(config) end,
      desc = "Split window full-width down, moving buffer if possible"
    },

    -- Split management
    [prefix .. "CloseSplit"] = {
      function() splits.close_split(config) end,
      desc = "Close current split"
    },
    [prefix .. "CloseOtherSplits"] = {
      function() splits.close_other_splits(config) end,
      desc = "Close all splits except current one"
    },
    [prefix .. "CloseAllSplits"] = {
      function() splits.close_all_splits(config) end,
      desc = "Close all splits, keeping only one with empty buffer"
    },

    -- Buffer operations
    [prefix .. "CloseBuffer"] = {
      function() buffers.close_buffer(config) end,
      desc = "Smart buffer closing with window management (preserves layout, avoids duplicates)"
    },
    [prefix .. "CloseOthers"] = {
      function() buffers.close_other_buffers(config) end,
      desc = "Close all other buffers"
    },
    [prefix .. "CloseAll"] = {
      function() buffers.close_all_buffers(config) end,
      desc = "Close all buffers"
    },
  }

  -- Commands with arguments
  local commands_with_args = {
    [prefix .. "Merge"] = {
      function(opts) splits.merge_buffer_direction(opts.args, config) end,
      desc = "Merge buffer in specified direction (h/j/k/l)",
      nargs = 1
    },
    [prefix .. "Move"] = {
      function(opts) splits.move_buffer_to_split(opts.args, config) end,
      desc = "Move buffer to split in specified direction (h/j/k/l)",
      nargs = 1
    },
    [prefix .. "Navigate"] = {
      function(opts) buffers.navigate_all_buffers(opts.args, config) end,
      desc = "Navigate buffers (next/prev) that are not in other windows",
      nargs = 1
    },
    [prefix .. "NavigateSplit"] = {
      function(opts)
        local direction = opts.args
        if direction == 'left' or direction == 'h' then
          splits.navigate_left(config)
        elseif direction == 'right' or direction == 'l' then
          splits.navigate_right(config)
        elseif direction == 'down' or direction == 'j' then
          splits.navigate_down(config)
        elseif direction == 'up' or direction == 'k' then
          splits.navigate_up(config)
        else
          vim.notify("Invalid direction: " .. direction, vim.log.levels.ERROR)
        end
      end,
      desc = "Navigate to split in specified direction (left/right/up/down or h/j/k/l)",
      nargs = 1
    }
  }

  -- Register commands without arguments
  for name, def in pairs(command_def) do
    pcall(vim.api.nvim_del_user_command, name)
    vim.api.nvim_create_user_command(name, def[1], { desc = def.desc })
  end

  -- Register commands with arguments
  for name, def in pairs(commands_with_args) do
    pcall(vim.api.nvim_del_user_command, name)
    vim.api.nvim_create_user_command(name, def[1], {
      desc = def.desc,
      nargs = def.nargs
    })
  end
end

-- Set up keymaps from configuration
function M.setup_keymaps(config)
  local keymaps = config.keymaps
  if not keymaps then return end

  -- Helper function to set keymap if it's enabled
  local function set_keymap(key, func, desc)
    if key and key ~= false then
      -- Handle arrays of keys (for alternatives)
      if type(key) == "table" then
        for _, k in ipairs(key) do
          vim.keymap.set('n', k, func, { desc = desc, noremap = true, silent = true })
        end
      else
        vim.keymap.set('n', key, func, { desc = desc, noremap = true, silent = true })
      end
    end
  end

  -- Split operations (Smart/Layout-Aware)
  set_keymap(keymaps.split_smart_right, function() splits.smart_split('l', config) end,
    "Smart split right (merge or layout-aware)")
  set_keymap(keymaps.split_smart_left, function() splits.smart_split('h', config) end,
    "Smart split left (merge or layout-aware)")
  set_keymap(keymaps.split_smart_down, function() splits.smart_split('j', config) end,
    "Smart split down (merge or layout-aware)")
  set_keymap(keymaps.split_smart_up, function() splits.smart_split('k', config) end,
    "Smart split up (merge or layout-aware)")

  -- Split operations (Full-Span)
  set_keymap(keymaps.split_full_right, function() splits.split_move_full_right(config) end, "Split full-height right")
  set_keymap(keymaps.split_full_left, function() splits.split_move_full_left(config) end, "Split full-height left")
  set_keymap(keymaps.split_full_down, function() splits.split_move_full_down(config) end, "Split full-width down")
  set_keymap(keymaps.split_full_up, function() splits.split_move_full_up(config) end, "Split full-width up")

  -- Split management
  set_keymap(keymaps.close_split, function() splits.close_split(config) end, "Close split")
  set_keymap(keymaps.close_other_splits, function() splits.close_other_splits(config) end, "Close other splits")
  set_keymap(keymaps.close_all_splits, function() splits.close_all_splits(config) end, "Close all splits")

  -- Buffer movement to splits
  set_keymap(keymaps.move_to_right, function() splits.move_buffer_to_split('l', config) end, "Move buffer to right split")
  set_keymap(keymaps.move_to_left, function() splits.move_buffer_to_split('h', config) end, "Move buffer to left split")
  set_keymap(keymaps.move_to_down, function() splits.move_buffer_to_split('j', config) end, "Move buffer to lower split")
  set_keymap(keymaps.move_to_up, function() splits.move_buffer_to_split('k', config) end, "Move buffer to upper split")

  -- Buffer navigation
  set_keymap(keymaps.prev_buffer, function() buffers.navigate_all_buffers('prev', config) end, "Previous buffer")
  set_keymap(keymaps.next_buffer, function() buffers.navigate_all_buffers('next', config) end, "Next buffer")
  set_keymap(keymaps.alt_prev_buffer, function() buffers.navigate_all_buffers('prev', config) end,
    "Previous buffer (alt)")
  set_keymap(keymaps.alt_next_buffer, function() buffers.navigate_all_buffers('next', config) end, "Next buffer (alt)")

  -- Split navigation
  set_keymap(keymaps.nav_left, function() splits.navigate_left(config) end, "Navigate to left split")
  set_keymap(keymaps.nav_right, function() splits.navigate_right(config) end, "Navigate to right split")
  set_keymap(keymaps.nav_down, function() splits.navigate_down(config) end, "Navigate to split below")
  set_keymap(keymaps.nav_up, function() splits.navigate_up(config) end, "Navigate to split above")

  -- Buffer management
  set_keymap(keymaps.close_buffer, function() buffers.close_buffer(config) end, "Close buffer (smart)")
  set_keymap(keymaps.close_other_buffers, function() buffers.close_other_buffers(config) end, "Close other buffers")
  set_keymap(keymaps.close_all_buffers, function() buffers.close_all_buffers(config) end, "Close all buffers")
end

return M
