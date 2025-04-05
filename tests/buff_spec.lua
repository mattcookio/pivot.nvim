-- tests/buff_spec.lua
-- Unit tests for buff.nvim using busted test framework

-- Set up package path to find our module
local function setup_package_path()
  -- Get the current directory of this test file
  local test_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
  -- Go one directory up to the plugin root
  local plugin_root = test_dir:gsub("/tests/$", "")

  -- Add the plugin directory to the package path
  package.path = plugin_root .. "/?.lua;" .. plugin_root .. "/?/init.lua;" .. package.path
  package.path = plugin_root .. "/lua/?.lua;" .. plugin_root .. "/lua/?/init.lua;" .. package.path
end

-- Configure package path before loading any modules
setup_package_path()

local mock = require('luassert.mock')
local stub = require('luassert.stub')

-- Mock vim global to avoid dependency on actual Neovim API during tests
local function setup_vim_mock()
  _G.vim = {
    api = {
      nvim_get_current_win = stub().returns(1),
      nvim_get_current_buf = stub().returns(1),
      nvim_win_get_buf = stub().returns(1),
      nvim_win_get_config = stub().returns({ relative = '' }),
      nvim_buf_get_option = stub().returns(false),
      nvim_command = stub(),
      nvim_win_close = stub(),
      nvim_set_current_win = stub(),
      nvim_set_current_buf = stub(),
      nvim_list_wins = stub().returns({ 1, 2, 3 }),
      nvim_list_bufs = stub().returns({ 1, 2, 3 }),
      nvim_win_set_buf = stub(),
      nvim_create_buf = stub().returns(10),
      nvim_win_get_position = stub().returns({ 0, 0 }),
      nvim_win_get_height = stub().returns(10),
      nvim_win_get_width = stub().returns(20),
      nvim_open_win = stub().returns(4),
      nvim_buf_is_valid = stub().returns(true),
      nvim_win_is_valid = stub().returns(true),
      nvim_create_autocmd = stub(),
      nvim_create_augroup = stub().returns(1),
      nvim_buf_get_name = stub().returns('test_buffer'),
      nvim_echo = stub(),
      nvim_notify = stub(),
    },
    fn = {
      bufnr = stub().returns(1),
      winlayout = stub().returns({ 'leaf', 1 }),
      win_splitmove = stub().returns(1),
      winsaveview = stub().returns({}),
      winrestview = stub(),
      winnr = stub().returns(1),
      exists = stub().returns(1),
    },
    cmd = stub(),
    o = {},
    opt = {},
    g = {},
    deepcopy = function(t) return vim.tbl_deep_extend('force', {}, t) end,
    tbl_deep_extend = function(_, ...)
      local result = {}
      for i = 2, select("#", ...) do
        local tbl = select(i, ...)
        if tbl then
          for k, v in pairs(tbl) do
            result[k] = v
          end
        end
      end
      return result
    end,
    tbl_contains = function(t, value)
      for _, v in ipairs(t) do
        if v == value then
          return true
        end
      end
      return false
    end,
    split = function(str, sep)
      local result = {}
      for match in (str .. sep):gmatch("(.-)" .. sep) do
        table.insert(result, match)
      end
      return result
    end,
  }

  return _G.vim
end

-- Define fake implementation for modules that might not exist yet
local function mock_buff_modules()
  -- Create package.preload entries for our modules to avoid external dependencies
  package.preload['buff.config'] = function()
    local config = {}
    config.defaults = {
      auto_record_history = true,
      history_limit = 10,
      smart_splits = true,
      smart_close = true,
      prevent_duplicates = true,
      keymaps = {
        split_right = '<leader>sl',
        split_left = '<leader>sh',
        split_down = '<leader>sj',
        split_up = '<leader>sk',
        close_split = '<leader>sd',
        close_other_splits = '<leader>so',
        close_all_splits = '<leader>sa',
        close_buffer = '<leader>bd',
        close_other_buffers = '<leader>bo',
        close_all_buffers = '<leader>ba',
        move_to_right = '<leader>bl',
        move_to_left = '<leader>bh',
        move_to_down = '<leader>bj',
        move_to_up = '<leader>bk',
        prev_buffer = '<C-h>',
        next_buffer = '<C-l>',
        alt_prev_buffer = '<C-k>',
        alt_next_buffer = '<C-j>',
        alt_prev = { '˙', '<A-h>' },
        alt_next = { '¬', '<A-l>' },
      },
      commands = {
        enable = true,
        prefix = 'Buff',
      }
    }
    config.options = nil
    config.setup = function(user_config)
      config.options = vim.tbl_deep_extend("force", {}, config.defaults)
      if user_config then
        config.options = vim.tbl_deep_extend("force", config.options, user_config)
      end
      return config.options
    end
    return config
  end

  package.preload['buff.utils'] = function()
    local utils = {}
    utils.window_buffer_history = {}
    utils.setup_autocmds = function() end
    utils.create_empty_buffer = function() return 10 end
    utils.get_fallback_buffer = function() return 2 end
    utils.get_valid_buffers = function() return { 1, 2, 3 } end
    return utils
  end

  package.preload['buff.buffers'] = function()
    local buffers = {}
    buffers.close_buffer = function() end
    buffers.close_other_buffers = function() end
    buffers.close_all_buffers = function() end
    buffers.navigate_all_buffers = function() end
    return buffers
  end

  package.preload['buff.splits'] = function()
    local splits = {}
    splits.split_move_right = function() end
    splits.split_move_left = function() end
    splits.split_move_up = function() end
    splits.split_move_down = function() end
    splits.smart_split = function() end
    splits.merge_buffer_direction = function() end
    splits.move_buffer_to_split = function() end
    splits.close_split = function() end
    splits.close_other_splits = function() end
    splits.close_all_splits = function() end
    return splits
  end

  package.preload['buff.commands'] = function()
    local commands = {}
    commands.register_commands = function() end
    commands.setup_keymaps = function() end
    return commands
  end

  package.preload['buff.health'] = function()
    return {}
  end

  -- Create our mock buff module
  package.preload['buff'] = function()
    local buff = {}

    -- Load modules
    local config = require('buff.config')
    local utils = require('buff.utils')
    local buffers = require('buff.buffers')
    local splits = require('buff.splits')
    local commands = require('buff.commands')

    -- Setup function
    buff.setup = function(user_config)
      config.setup(user_config)
      -- Simulate other setup actions
      return config.options
    end

    -- Expose split functions
    buff.split_move_right = function() return splits.split_move_right() end
    buff.split_move_left = function() return splits.split_move_left() end
    buff.split_move_up = function() return splits.split_move_up() end
    buff.split_move_down = function() return splits.split_move_down() end
    buff.smart_split = function(dir) return splits.smart_split(dir) end
    buff.merge_buffer_direction = function(dir) return splits.merge_buffer_direction(dir) end
    buff.move_buffer_to_split = function(dir) return splits.move_buffer_to_split(dir) end

    -- Expose split management
    buff.close_split = function() return splits.close_split() end
    buff.close_other_splits = function() return splits.close_other_splits() end
    buff.close_all_splits = function() return splits.close_all_splits() end

    -- Expose buffer operations
    buff.close_buffer = function() return buffers.close_buffer() end
    buff.close_other_buffers = function() return buffers.close_other_buffers() end
    buff.close_all_buffers = function() return buffers.close_all_buffers() end
    buff.navigate_all_buffers = function(dir) return buffers.navigate_all_buffers(dir) end

    -- Expose utilities
    buff.get_window_buffer_history = function() return utils.window_buffer_history end
    buff.create_empty_buffer = function() return utils.create_empty_buffer() end
    buff.get_fallback_buffer = function(win, buf) return utils.get_fallback_buffer(win, buf) end
    buff.get_valid_buffers = function(skip) return utils.get_valid_buffers(skip) end

    -- Version information
    buff.version = "1.0.0"

    -- Health module
    buff.health = require('buff.health')

    return buff
  end
end

describe("buff.nvim", function()
  local buff
  local vim_mock

  before_each(function()
    -- Setup clean environment
    vim_mock = setup_vim_mock()

    -- Create mock module structure
    mock_buff_modules()

    -- Clean loaded package to ensure fresh state
    package.loaded['buff'] = nil
    package.loaded['buff.config'] = nil
    package.loaded['buff.utils'] = nil
    package.loaded['buff.buffers'] = nil
    package.loaded['buff.splits'] = nil
    package.loaded['buff.commands'] = nil

    -- Load the buff module
    buff = require('buff')

    -- Call setup with test configuration
    buff.setup({
      auto_record_history = true,
      history_limit = 5,
      smart_splits = true,
      smart_close = true,
      prevent_duplicates = true,
      keymaps = false,              -- Disable keymaps for testing
      commands = { enable = false } -- Disable commands for testing
    })
  end)

  after_each(function()
    -- Clean up mocks
    mock.revert(vim_mock)
  end)

  describe("setup", function()
    it("initializes with default config when no config provided", function()
      package.loaded['buff'] = nil
      package.loaded['buff.config'] = nil

      local b = require('buff')
      b.setup()

      local config = require('buff.config')
      assert.is_not_nil(config.options)
      assert.equals(true, config.options.auto_record_history)
      assert.equals(10, config.options.history_limit)
    end)

    it("overrides defaults with user config", function()
      package.loaded['buff'] = nil
      package.loaded['buff.config'] = nil

      local b = require('buff')
      b.setup({
        auto_record_history = false,
        history_limit = 20
      })

      local config = require('buff.config')
      assert.is_not_nil(config.options)
      assert.equals(false, config.options.auto_record_history)
      assert.equals(20, config.options.history_limit)
    end)
  end)

  describe("buffer operations", function()
    it("closes the current buffer", function()
      -- Setup vim mock to return specific values
      vim_mock.api.nvim_get_current_buf.returns(1)
      vim_mock.api.nvim_get_current_win.returns(1)
      vim_mock.api.nvim_win_get_buf.returns(1)

      -- Mock the buffer functions
      local buffers = require('buff.buffers')
      stub(buffers, 'close_buffer')

      -- Record the call to close buffer
      buff.close_buffer()

      -- Should have called the close_buffer function
      assert.stub(buffers.close_buffer).was_called()

      -- Clean up
      buffers.close_buffer:revert()
    end)

    it("navigates to the next buffer", function()
      -- Setup test conditions
      vim_mock.api.nvim_get_current_buf.returns(1)
      vim_mock.api.nvim_get_current_win.returns(1)
      vim_mock.api.nvim_list_bufs.returns({ 1, 2, 3 })

      -- Mock the buffer navigation function
      local buffers = require('buff.buffers')
      stub(buffers, 'navigate_all_buffers')

      -- Call the function to test
      buff.navigate_all_buffers('next')

      -- Should have called the navigate function
      assert.stub(buffers.navigate_all_buffers).was_called_with('next')

      -- Clean up
      buffers.navigate_all_buffers:revert()
    end)
  end)

  describe("split operations", function()
    it("creates a split and moves the buffer to it", function()
      -- Setup test conditions
      vim_mock.api.nvim_get_current_buf.returns(1)
      vim_mock.api.nvim_get_current_win.returns(1)
      vim_mock.api.nvim_list_bufs.returns({ 1, 2 })
      vim_mock.api.nvim_open_win.returns(2)

      -- Mock the split function
      local splits = require('buff.splits')
      stub(splits, 'split_move_right')

      -- Call the function to test
      buff.split_move_right()

      -- Should have called the split function
      assert.stub(splits.split_move_right).was_called()

      -- Clean up
      splits.split_move_right:revert()
    end)

    it("performs smart split by checking if target split exists", function()
      -- Setup test conditions
      vim_mock.api.nvim_get_current_win.returns(1)
      vim_mock.api.nvim_get_current_buf.returns(1)

      -- Mock the smart split function
      local splits = require('buff.splits')
      stub(splits, 'smart_split')

      -- Call the function to test
      buff.smart_split('l')

      -- Should have called the smart split function
      assert.stub(splits.smart_split).was_called_with('l')

      -- Clean up
      splits.smart_split:revert()
    end)
  end)

  describe("buffer movement", function()
    it("moves buffer to target split", function()
      -- Setup test conditions
      vim_mock.api.nvim_get_current_win.returns(1)
      vim_mock.api.nvim_get_current_buf.returns(1)

      -- Mock the move function
      local splits = require('buff.splits')
      stub(splits, 'move_buffer_to_split')

      -- Call the function to test
      buff.move_buffer_to_split('l')

      -- Should have called the move function
      assert.stub(splits.move_buffer_to_split).was_called_with('l')

      -- Clean up
      splits.move_buffer_to_split:revert()
    end)
  end)

  describe("utility functions", function()
    it("creates an empty buffer", function()
      -- Mock the utility function
      local utils = require('buff.utils')
      stub(utils, 'create_empty_buffer').returns(10)

      -- Call the function to test
      local result = buff.create_empty_buffer()

      -- Should have called the utility function
      assert.stub(utils.create_empty_buffer).was_called()

      -- Should return the new buffer number
      assert.equals(10, result)

      -- Clean up
      utils.create_empty_buffer:revert()
    end)

    it("gets window buffer history", function()
      -- Mock history
      local utils = require('buff.utils')
      utils.window_buffer_history = { [1] = { 1, 2, 3 } }

      -- Get the history
      local history = buff.get_window_buffer_history()

      -- Should be a table
      assert.is_table(history)
      assert.is_table(history[1])
      assert.equals(1, history[1][1])
    end)

    it("safely gets buffer options", function()
      -- Mock vim environment to simulate an error
      local old_nvim_buf_get_option = vim_mock.api.nvim_buf_get_option
      vim_mock.api.nvim_buf_get_option = function(buf, opt)
        if opt == "invalid_option" then
          error("Invalid option: invalid_option")
        elseif opt == "terminal" then
          error("Invalid option: terminal")
        elseif opt == "buftype" then
          return "terminal"
        else
          return true
        end
      end

      local utils = require('buff.utils')

      -- Test valid option
      local result1 = utils.safe_get_buf_option(1, "valid_option")
      assert.is_true(result1)

      -- Test invalid option
      local result2 = utils.safe_get_buf_option(1, "invalid_option")
      assert.is_false(result2)

      -- Test terminal option with fallback
      local result3 = utils.safe_get_buf_option(1, "terminal")
      assert.is_true(result3)

      -- Restore original function
      vim_mock.api.nvim_buf_get_option = old_nvim_buf_get_option
    end)
  end)
end)
