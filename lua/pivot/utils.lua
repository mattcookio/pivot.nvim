local M = {}

-- Window buffer history tracker
M.window_buffer_history = {}

-- Track buffers loaded
M.loaded_buffers = {}

-- Store original window highlights during dimming
local dimmed_windows = {} -- { win_id = original_winhighlight }

-- Define the highlight group for dimmed windows (link to Comment by default)
function M.define_dim_highlight()
    -- Link PivotDimWindow to Comment if not already defined
    vim.cmd("silent! highlight default link PivotDimWindow Comment")
end

-- Apply dimming highlight to a window
function M.dim_window(win_id)
    if not win_id or not vim.api.nvim_win_is_valid(win_id) then return end
    local current_hl = vim.api.nvim_win_get_option(win_id, 'winhighlight')
    dimmed_windows[win_id] = current_hl -- Store original
    -- Dim Normal text, keep FloatBornder potentially for floats over dimmed area
    vim.api.nvim_win_set_option(win_id, 'winhighlight', 'Normal:PivotDimWindow,FloatBorder:FloatBorder')
end

-- Clear dimming highlight from all dimmed windows
function M.clear_dimming()
    for win_id, original_hl in pairs(dimmed_windows) do
        if vim.api.nvim_win_is_valid(win_id) then
            pcall(vim.api.nvim_win_set_option, win_id, 'winhighlight', original_hl)
        end
    end
    dimmed_windows = {} -- Reset the tracker
end

-- Check Neovim version for API compatibility
M.is_nvim_07_or_later = (function()
    -- Try to get version using vim.version()
    local nvim_version = vim.version and vim.version()
    if nvim_version and (nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 7)) then
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

-- Record a buffer in the window's history
M.record_buffer = function(win, buf)
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

    -- Clean up any invalid buffers from history
    for i = #M.window_buffer_history[win], 1, -1 do
        local history_buf = M.window_buffer_history[win][i]
        if not vim.api.nvim_buf_is_valid(history_buf) or
            M.safe_get_buf_option(history_buf, 'terminal') or
            not M.safe_get_buf_option(history_buf, 'buflisted') then
            table.remove(M.window_buffer_history[win], i)
        end
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
                M.record_buffer(win, buf)
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
    M.record_buffer(win, buf)
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

-- Helper function to find all neighboring windows in a given direction
function M.get_neighboring_windows(direction)
    local neighbors = {}
    local current_win_id = vim.api.nvim_get_current_win()
    local current_pos = vim.api.nvim_win_get_position(current_win_id)
    local current_width = vim.api.nvim_win_get_width(current_win_id)
    local current_height = vim.api.nvim_win_get_height(current_win_id)

    local current_top = current_pos[1]
    local current_bottom = current_pos[1] + current_height
    local current_left = current_pos[2]
    local current_right = current_pos[2] + current_width

    local tolerance = 2 -- Allow edges to be within 2 units

    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if win_id ~= current_win_id and vim.api.nvim_win_is_valid(win_id) then
            local pos = vim.api.nvim_win_get_position(win_id)
            local width = vim.api.nvim_win_get_width(win_id)
            local height = vim.api.nvim_win_get_height(win_id)

            local other_top = pos[1]
            local other_bottom = pos[1] + height
            local other_left = pos[2]
            local other_right = pos[2] + width

            local vertical_overlap = math.max(current_top, other_top) < math.min(current_bottom, other_bottom)
            local horizontal_overlap = math.max(current_left, other_left) < math.min(current_right, other_right)

            -- Check edge proximity within tolerance
            local is_left_edge_proximate = math.abs(current_left - other_right) <= tolerance
            local is_right_edge_proximate = math.abs(other_left - current_right) <= tolerance
            local is_up_edge_proximate = math.abs(current_top - other_bottom) <= tolerance
            local is_down_edge_proximate = math.abs(other_top - current_bottom) <= tolerance

            -- Check if the window is a neighbor in the specified direction
            local is_left_neighbor = direction == 'h' and is_left_edge_proximate and vertical_overlap
            local is_right_neighbor = direction == 'l' and is_right_edge_proximate and vertical_overlap
            local is_up_neighbor = direction == 'k' and is_up_edge_proximate and horizontal_overlap
            local is_down_neighbor = direction == 'j' and is_down_edge_proximate and horizontal_overlap

            if is_left_neighbor or is_right_neighbor or is_up_neighbor or is_down_neighbor then
                table.insert(neighbors, win_id) -- Add matching window ID to list
            end
        end
    end

    return neighbors -- Return the list of neighbors
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
