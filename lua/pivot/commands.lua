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
    -- Split commands (standard or merge)
    [prefix .. "SplitRight"] = {
      function() splits.smart_split('l', config) end,
      desc = "Split right (standard :vnew) or merge"
    },
    [prefix .. "SplitLeft"] = {
      function() splits.smart_split('h', config) end,
      desc = "Split left (standard :vnew) or merge"
    },
    [prefix .. "SplitUp"] = {
      function() splits.smart_split('k', config) end,
      desc = "Split up (standard :new) or merge"
    },
    [prefix .. "SplitDown"] = {
      function() splits.smart_split('j', config) end,
      desc = "Split down (standard :new) or merge"
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

  local function set_keymap(key, func, desc)
    if key and key ~= false then
      if type(key) == "table" then
        for _, k in ipairs(key) do vim.keymap.set('n', k, func, { desc = desc, noremap = true, silent = true }) end
      else
        vim.keymap.set('n', key, func, { desc = desc, noremap = true, silent = true })
      end
    end
  end

  -- Use smart_split for all split keymaps
  set_keymap(keymaps.split_right, function() splits.smart_split('l', config) end,
    "Split right (standard :vnew or merge)")
  set_keymap(keymaps.split_left, function() splits.smart_split('h', config) end,
    "Split left (standard :vnew or merge)")
  set_keymap(keymaps.split_down, function() splits.smart_split('j', config) end,
    "Split down (standard :new or merge)")
  set_keymap(keymaps.split_up, function() splits.smart_split('k', config) end,
    "Split up (standard :new or merge)")

  -- Split management
  set_keymap(keymaps.close_split, function() splits.close_split(config) end, "Close split")
  set_keymap(keymaps.close_other_splits, function() splits.close_other_splits(config) end, "Close other splits")
  set_keymap(keymaps.close_all_splits, function() splits.close_all_splits(config) end, "Close all splits")
  set_keymap(keymaps.move_to_right, function() splits.move_buffer_to_split('l', config) end, "Move buffer to right split")
  set_keymap(keymaps.move_to_left, function() splits.move_buffer_to_split('h', config) end, "Move buffer to left split")
  set_keymap(keymaps.move_to_down, function() splits.move_buffer_to_split('j', config) end, "Move buffer to lower split")
  set_keymap(keymaps.move_to_up, function() splits.move_buffer_to_split('k', config) end, "Move buffer to upper split")
  set_keymap(keymaps.prev_buffer, function() buffers.navigate_all_buffers('prev', config) end, "Previous buffer")
  set_keymap(keymaps.next_buffer, function() buffers.navigate_all_buffers('next', config) end, "Next buffer")
  set_keymap(keymaps.alt_prev_buffer, function() buffers.navigate_all_buffers('prev', config) end,
    "Previous buffer (alt)")
  set_keymap(keymaps.alt_next_buffer, function() buffers.navigate_all_buffers('next', config) end, "Next buffer (alt)")
  set_keymap(keymaps.nav_left, function() splits.navigate_left(config) end, "Navigate to left split")
  set_keymap(keymaps.nav_right, function() splits.navigate_right(config) end, "Navigate to right split")
  set_keymap(keymaps.nav_down, function() splits.navigate_down(config) end, "Navigate to split below")
  set_keymap(keymaps.nav_up, function() splits.navigate_up(config) end, "Navigate to split above")
  set_keymap(keymaps.close_buffer, function() buffers.close_buffer(config) end, "Close buffer (smart)")
  set_keymap(keymaps.close_other_buffers, function() buffers.close_other_buffers(config) end, "Close other buffers")
  set_keymap(keymaps.close_all_buffers, function() buffers.close_all_buffers(config) end, "Close all buffers")
end

return M
