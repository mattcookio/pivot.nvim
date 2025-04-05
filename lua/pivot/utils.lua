local M = {}

-- Window buffer history tracker
M.window_buffer_history = {}

-- Track buffers loaded
M.loaded_buffers = {}

-- Check Neovim version for API compatibility
M.is_nvim_07_or_later = (function()
    -- Try to get version using vim.version()
    local v = vim.version and vim.version()
    if v and (v.major > 0 or (v.major == 0 and v.minor >= 7)) then
        return true
    end

    -- Fallback for older versions: check if necessary APIs exist
    if vim.api.nvim_create_augroup and vim.api.nvim_create_autocmd then
        return true
    end

    return false
end)()

-- Validate a window and buffer for move operations
M.validate_move = function(win, buf)
    if not win or not vim.api.nvim_win_is_valid(win) then
        return false, "Invalid window"
    end

    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return false, "Invalid buffer"
    end

    return true, nil
end

-- Create an empty scratch buffer
M.create_empty_buffer = function()
    local buf = vim.api.nvim_create_buf(false, true)
    return buf
end

-- Get a list of valid buffers, optionally skipping those visible in windows
M.get_valid_buffers = function(skip_visible)
    local buffers = {}
    local visible_buffers = {}

    -- If we need to skip visible buffers, collect them first
    if skip_visible then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
                local buf = vim.api.nvim_win_get_buf(win)
                visible_buffers[buf] = true
            end
        end
    end

    -- Collect valid buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and
            not M.safe_get_buf_option(buf, 'terminal') and
            M.safe_get_buf_option(buf, 'buflisted') then
            -- Skip visible buffers if requested
            if not (skip_visible and visible_buffers[buf]) then
                table.insert(buffers, buf)
            end
        end
    end

    return buffers
end

-- Record a buffer in the window's history
M.record_buffer = function(win, buf, limit)
    limit = limit or 10

    -- Skip terminals and non-listed buffers
    if not vim.api.nvim_buf_is_valid(buf) or
        M.safe_get_buf_option(buf, 'terminal') or
        not M.safe_get_buf_option(buf, 'buflisted') then
        return
    end

    -- Initialize history for this window if needed
    if not M.window_buffer_history[win] then
        M.window_buffer_history[win] = {}
    end

    -- Check if buffer is already in history, and remove it to avoid duplicates
    for i, history_buf in ipairs(M.window_buffer_history[win]) do
        if history_buf == buf then
            table.remove(M.window_buffer_history[win], i)
            break
        end
    end

    -- Add the buffer to the start of the history list
    table.insert(M.window_buffer_history[win], 1, buf)

    -- Trim the history to the limit
    while #M.window_buffer_history[win] > limit do
        table.remove(M.window_buffer_history[win])
    end
end

-- Get a fallback buffer for a window, using history or valid buffers
M.get_fallback_buffer = function(win, current_buf)
    -- Try the window's buffer history first
    if M.window_buffer_history[win] then
        for _, buf in ipairs(M.window_buffer_history[win]) do
            if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) and
                M.safe_get_buf_option(buf, 'buflisted') then
                return buf
            end
        end
    end

    -- If no valid buffer in history, try any valid buffer
    local buffers = M.get_valid_buffers(false)
    for _, buf in ipairs(buffers) do
        if buf ~= current_buf then
            return buf
        end
    end

    -- If no valid existing buffer, create an empty one
    return M.create_empty_buffer()
end

-- Setup autocmds for buffer history tracking
M.setup_autocmds = function(options)
    -- Different implementation based on Neovim version
    if M.is_nvim_07_or_later then
        -- Neovim 0.7+ API
        -- Clean up any existing autocmds
        if vim.api.nvim_get_autocmds then
            pcall(function()
                local existing = vim.api.nvim_get_autocmds({ group = "PivotHistory" })
                if existing and #existing > 0 then
                    vim.api.nvim_del_augroup_by_name("PivotHistory")
                end
            end)
        end

        -- Create a unique ID for our augroup
        local group_id
        local status, result = pcall(function()
            return vim.api.nvim_create_augroup("PivotHistory", { clear = true })
        end)

        if not status then
            -- Fall back to legacy approach if augroup creation failed
            vim.cmd([[
                augroup PivotHistory
                    autocmd!
                    autocmd BufEnter * lua require('pivot.utils').record_buffer_legacy()
                    autocmd WinClosed * lua require('pivot.utils').cleanup_window_history()
                augroup END
            ]])

            -- Store options globally for legacy callbacks
            M._options = options
            return
        end

        group_id = result

        -- Record buffer history on BufEnter
        vim.api.nvim_create_autocmd("BufEnter", {
            group = group_id,
            callback = function()
                local win = vim.api.nvim_get_current_win()
                local buf = vim.api.nvim_get_current_buf()
                M.record_buffer(win, buf, options.history_limit)
            end,
        })

        -- Clean up history when window is closed
        vim.api.nvim_create_autocmd("WinClosed", {
            group = group_id,
            callback = function(args)
                local win = tonumber(args.match)
                if win and M.window_buffer_history[win] then
                    M.window_buffer_history[win] = nil
                end
            end,
        })
    else
        -- Legacy approach for older Neovim versions
        vim.cmd([[
            augroup PivotHistory
                autocmd!
                autocmd BufEnter * lua require('pivot.utils').record_buffer_legacy()
                autocmd WinClosed * lua require('pivot.utils').cleanup_window_history()
            augroup END
        ]])

        -- Store options globally for legacy callbacks
        M._options = options
    end
end

-- Safe way to check buffer options to avoid errors
M.safe_get_buf_option = function(buf, option)
    local status, result = pcall(function()
        return vim.api.nvim_buf_get_option(buf, option)
    end)

    if not status then
        -- For 'terminal' option specifically, check buftype instead
        if option == 'terminal' then
            local buftype_status, buftype = pcall(function()
                return vim.api.nvim_buf_get_option(buf, 'buftype')
            end)

            if buftype_status and buftype == 'terminal' then
                return true
            end
            return false
        end
        return false
    end

    return result
end

-- Legacy callback for older Neovim versions
M.record_buffer_legacy = function()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    local limit = M._options and M._options.history_limit or 10
    M.record_buffer(win, buf, limit)
end

-- Legacy cleanup for older Neovim versions
M.cleanup_window_history = function()
    local win = tonumber(vim.fn.expand('<afile>'))
    if win and M.window_buffer_history[win] then
        M.window_buffer_history[win] = nil
    end
end

-- Calculate the current buffer's location within the total buffer list
M.calculate_buffer_position = function(current_buf, direction)
    local buffers = M.get_valid_buffers(true)
    local current_idx = nil

    -- Find current buffer's index
    for i, buf in ipairs(buffers) do
        if buf == current_buf then
            current_idx = i
            break
        end
    end

    -- If buffer isn't in the list (rare edge case)
    if not current_idx then
        if direction == "next" or direction == "forward" then
            return buffers[1], 1, #buffers
        else
            return buffers[#buffers], #buffers, #buffers
        end
    end

    return current_buf, current_idx, #buffers
end

-- Format a command string from a list of arguments
M.format_command = function(command, ...)
    local args = { ... }
    local result = command

    if #args > 0 then
        for _, arg in ipairs(args) do
            if arg and arg ~= "" then
                result = result .. " " .. arg
            end
        end
    end

    return result
end

-- Check if a buffer is a real, normal buffer
M.is_normal_buffer = function(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end

    -- Check buffer options safely
    local is_listed = M.safe_get_buf_option(buf, 'buflisted')
    local buftype = M.safe_get_buf_option(buf, 'buftype')

    -- Normal buffers are listed and have empty buftype
    return is_listed and (buftype == "" or buftype == false)
end

-- Get all valid normal buffers
M.get_valid_buffers = function(exclude_current)
    local buffers = {}
    local current_buf = exclude_current and vim.api.nvim_get_current_buf() or nil

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if M.is_normal_buffer(buf) and (not exclude_current or buf ~= current_buf) then
            table.insert(buffers, buf)
        end
    end

    return buffers
end

-- Count valid normal buffers
M.count_valid_buffers = function()
    return #M.get_valid_buffers(false)
end

-- Check if buffer is a terminal
M.is_terminal_buffer = function(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end

    -- First try the direct approach
    local is_term, _ = pcall(function()
        return vim.api.nvim_buf_get_option(buf, 'terminal')
    end)

    if is_term then
        return true
    end

    -- If that fails, check the buftype
    local status, buftype = pcall(function()
        return vim.api.nvim_buf_get_option(buf, 'buftype')
    end)

    return status and buftype == 'terminal'
end

-- Helper function to check if a split exists in a given direction
function M.split_exists_in_direction(direction)
    local current_win = vim.api.nvim_get_current_win()

    -- Try to navigate to the window in the specified direction
    vim.cmd("wincmd " .. direction)

    -- Check if we moved to a different window
    local new_win = vim.api.nvim_get_current_win()
    local exists = current_win ~= new_win

    -- Go back to the original window if we moved
    if exists then
        vim.cmd("wincmd p")
    end

    return exists
end

-- Find buffers visible in windows other than the specified one
function M.get_buffers_in_other_windows(excluded_win)
    local visible_bufs = {}

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if win ~= excluded_win and vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            visible_bufs[buf] = true
        end
    end

    return visible_bufs
end

return M
