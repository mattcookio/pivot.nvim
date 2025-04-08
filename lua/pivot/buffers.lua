local M = {}

-- Module dependencies
local utils = require('pivot.utils')

-- Smart buffer closing with window management
function M.close_buffer(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    -- Handle terminal buffers differently
    if vim.bo[current_buf].buftype == 'terminal' then
        -- vim.cmd('q') -- Don't quit window
        local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
        -- Ensure fallback is not the terminal buffer itself or invalid
        if fallback_buf and vim.api.nvim_buf_is_valid(fallback_buf) and fallback_buf ~= current_buf then
            vim.api.nvim_win_set_buf(current_win, fallback_buf)
            -- Attempt to delete the original terminal buffer (use force = true)
            pcall(vim.api.nvim_buf_delete, current_buf, { force = true })
        else
            -- If no suitable fallback, just delete terminal buffer and leave window empty
            pcall(vim.api.nvim_buf_delete, current_buf, { force = true })
            vim.cmd('enew') -- Open an empty buffer
        end
        return              -- Stop processing for terminals here
    end

    -- Find a fallback buffer for this window (for non-terminal buffers)
    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)

    -- Check if this is the last window
    local is_last_window = #vim.api.nvim_list_wins() <= 1

    -- If prevention of duplicates is enabled, check if fallback would create a duplicate
    local fallback_is_duplicate = false
    if opts.prevent_duplicates and fallback_buf then
        local visible_bufs = utils.get_buffers_in_other_windows(current_win)
        fallback_is_duplicate = visible_bufs[fallback_buf] or false
    end

    -- Count valid, non-special buffers (not including the current one)
    local valid_bufs = utils.get_valid_buffers(true)

    -- Decide what to do
    if is_last_window then
        -- For the last window, always follow standard behavior (don't close Neovim)
        if #valid_bufs == 0 then
            -- No other buffers, create an empty buffer
            vim.cmd('enew')
        else
            -- Switch to any other buffer
            vim.cmd('bp')
        end
        -- Now delete the original buffer
        pcall(vim.api.nvim_buf_delete, current_buf, { force = false })
    else
        -- Not the last window, we can potentially close it
        if not fallback_buf or (opts.prevent_duplicates and fallback_is_duplicate) or #valid_bufs == 0 then
            -- No fallback buffer, or fallback would be a duplicate, or no more valid buffers
            -- Delete the buffer and close the window
            pcall(vim.api.nvim_buf_delete, current_buf, { force = false })
            pcall(vim.api.nvim_win_close, current_win, false)
        else
            -- We have a valid fallback buffer that's not a duplicate elsewhere
            -- Switch to fallback buffer before deleting current one
            vim.api.nvim_win_set_buf(current_win, fallback_buf)

            -- Now delete the original buffer
            pcall(vim.api.nvim_buf_delete, current_buf, { force = false })

            -- Update buffer history for this window
            if utils.window_buffer_history[current_win] then
                for i, buf in ipairs(utils.window_buffer_history[current_win]) do
                    if buf == current_buf then
                        table.remove(utils.window_buffer_history[current_win], i)
                        break
                    end
                end
            end
        end
    end
end

-- Close all other buffers, keeping only the current one
function M.close_other_buffers(opts)
    local current_buf = vim.api.nvim_get_current_buf()

    if vim.bo[current_buf].buftype == 'terminal' then
        vim.cmd('q')
        return
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end
end

-- Close all buffers
function M.close_all_buffers(opts)
    local current_buf = vim.api.nvim_get_current_buf()

    if vim.bo[current_buf].buftype == 'terminal' then
        vim.cmd('q')
        return
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end
end

-- Helper function to navigate through buffers, skipping those visible in other windows
function M.navigate_all_buffers(direction, opts)
    local bufs = vim.api.nvim_list_bufs()
    local current_buf = vim.api.nvim_get_current_buf()
    local current_idx = -1
    local current_win = vim.api.nvim_get_current_win()

    -- Filter out invalid or non-listed buffers
    bufs = vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
    end, bufs)

    -- If we should avoid duplicates, filter out buffers visible in other windows
    if opts.prevent_duplicates then
        local visible_bufs = utils.get_buffers_in_other_windows(current_win)

        bufs = vim.tbl_filter(function(b)
            return not visible_bufs[b]
        end, bufs)
    end

    -- If no buffers left after filtering, just return without switching
    if #bufs == 0 then
        vim.notify("No other buffers available" .. (opts.prevent_duplicates and " (not shown in other windows)" or ""),
            vim.log.levels.INFO)
        return
    end

    -- Find the index of the current buffer in the filtered list
    for i, buf in ipairs(bufs) do
        if buf == current_buf then
            current_idx = i
            break
        end
    end

    -- If current buffer isn't in our filtered list, start from beginning
    if current_idx == -1 then
        current_idx = 1
        -- Use the first buffer as fallback
        if direction == 'next' then
            vim.cmd('buffer! ' .. bufs[1])
        else
            vim.cmd('buffer! ' .. bufs[#bufs])
        end
        return
    end

    local next_idx
    if direction == 'next' then
        next_idx = (current_idx % #bufs) + 1               -- Wrap around using modulo
    elseif direction == 'prev' then
        next_idx = ((current_idx - 2 + #bufs) % #bufs) + 1 -- Wrap around backwards
    else
        vim.notify("Invalid direction for navigate_all_buffers", vim.log.levels.ERROR)
        return
    end

    -- Use buffer! to switch even with unsaved changes
    vim.cmd('buffer! ' .. bufs[next_idx])
end

return M
