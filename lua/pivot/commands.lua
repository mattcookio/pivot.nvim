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
    },
    [prefix .. "MoveBuffer"] = {
      function(opts)
        local direction_map = { left = 'h', right = 'l', up = 'k', down = 'j' }
        local direction = opts.args:lower()
        local mapped_dir = direction_map[direction] or direction -- Allow h/j/k/l directly
        if not table.concat({ 'h', 'j', 'k', 'l' }):find(mapped_dir, 1, true) then
          vim.notify("Invalid direction: " .. opts.args .. ". Use left/right/up/down or h/j/k/l.", vim.log.levels.ERROR)
          return
        end
        splits.move_buffer_to_split(mapped_dir, config)
      end,
      desc = "Move current buffer to adjacent split (left/right/up/down or h/j/k/l)",
      nargs = 1
    },
    [prefix .. "SwapBuffer"] = {
      function(opts)
        local direction_map = { left = 'h', right = 'l', up = 'k', down = 'j' }
        local direction = opts.args:lower()
        local mapped_dir = direction_map[direction] or direction
        if not table.concat({ 'h', 'j', 'k', 'l' }):find(mapped_dir, 1, true) then
          vim.notify("Invalid direction: " .. opts.args .. ". Use left/right/up/down or h/j/k/l.", vim.log.levels.ERROR)
          return
        end
        splits.swap_buffer_with_split(mapped_dir, config)
      end,
      desc = "Swap current buffer with adjacent split, cursor stays (left/right/up/down or h/j/k/l)",
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
  local function set_keymap(key, func, desc, modes)
    modes = modes or { 'n' } -- Default to Normal mode if not specified
    if key and key ~= false then
      -- Handle arrays of keys (for alternatives)
      if type(key) == "table" then
        for _, k in ipairs(key) do
          for _, mode in ipairs(modes) do
            vim.keymap.set(mode, k, func, { desc = desc, noremap = true, silent = true })
          end
        end
      else
        for _, mode in ipairs(modes) do
          vim.keymap.set(mode, key, func, { desc = desc, noremap = true, silent = true })
        end
      end
    end
  end

  -- Use smart_split for all split keymaps (Normal mode only)
  set_keymap(keymaps.split_right, function() splits.smart_split('l', config) end,
    "Split right (standard :vnew or merge)")
  set_keymap(keymaps.split_left, function() splits.smart_split('h', config) end,
    "Split left (standard :vnew or merge)")
  set_keymap(keymaps.split_down, function() splits.smart_split('j', config) end,
    "Split down (standard :new or merge)")
  set_keymap(keymaps.split_up, function() splits.smart_split('k', config) end,
    "Split up (standard :new or merge)")

  -- Terminal (Normal mode only)
  set_keymap(keymaps.terminal, function() vim.cmd('terminal') end,
    "Open terminal in current window")

  -- Split management (Normal mode only)
  set_keymap(keymaps.close_split, function() splits.close_split(config) end, "Close split")
  set_keymap(keymaps.close_other_splits, function() splits.close_other_splits(config) end, "Close other splits")
  set_keymap(keymaps.close_all_splits, function() splits.close_all_splits(config) end, "Close all splits")

  -- Buffer navigation (Normal mode only)
  set_keymap(keymaps.prev_buffer, function() buffers.navigate_all_buffers('prev', config) end, "Previous buffer")
  set_keymap(keymaps.next_buffer, function() buffers.navigate_all_buffers('next', config) end, "Next buffer")
  set_keymap(keymaps.alt_prev_buffer, function() buffers.navigate_all_buffers('prev', config) end,
    "Previous buffer (alt)")
  set_keymap(keymaps.alt_next_buffer, function() buffers.navigate_all_buffers('next', config) end, "Next buffer (alt)")

  -- Split navigation (Apply in Normal and Terminal modes)
  set_keymap(keymaps.nav_left, function() splits.navigate_left(config) end, "Navigate to left split", { 'n', 't' })
  set_keymap(keymaps.nav_right, function() splits.navigate_right(config) end, "Navigate to right split", { 'n', 't' })
  set_keymap(keymaps.nav_down, function() splits.navigate_down(config) end, "Navigate to split below", { 'n', 't' })
  set_keymap(keymaps.nav_up, function() splits.navigate_up(config) end, "Navigate to split above", { 'n', 't' })

  -- Buffer management (Normal mode only)
  set_keymap(keymaps.close_buffer, function() buffers.close_buffer(config) end, "Close buffer (smart)")
  set_keymap(keymaps.close_other_buffers, function() buffers.close_other_buffers(config) end, "Close other buffers")
  set_keymap(keymaps.close_all_buffers, function() buffers.close_all_buffers(config) end, "Close all buffers")

  -- Move buffer to adjacent split (Normal mode only)
  set_keymap(keymaps.move_to_right, function() splits.move_buffer_to_split('l', config) end, "Move buffer to right split")
  set_keymap(keymaps.move_to_left, function() splits.move_buffer_to_split('h', config) end, "Move buffer to left split")
  set_keymap(keymaps.move_to_down, function() splits.move_buffer_to_split('j', config) end, "Move buffer to down split")
  set_keymap(keymaps.move_to_up, function() splits.move_buffer_to_split('k', config) end, "Move buffer to up split")

  -- Swap buffer with adjacent split, cursor stays (Normal mode only)
  set_keymap(keymaps.swap_right, function() splits.swap_buffer_with_split('l', config) end, "Swap buffer with right split")
  set_keymap(keymaps.swap_left, function() splits.swap_buffer_with_split('h', config) end, "Swap buffer with left split")
  set_keymap(keymaps.swap_down, function() splits.swap_buffer_with_split('j', config) end, "Swap buffer with split below")
  set_keymap(keymaps.swap_up, function() splits.swap_buffer_with_split('k', config) end, "Swap buffer with split above")

  -- Terminal navigation
  set_keymap(keymaps.exit_terminal_mode, "<C-\\><C-n>", "Exit terminal mode", { 't' })
end

return M
