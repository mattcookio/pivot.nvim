local M = {}

-- Module dependencies
local utils = require('pivot.utils')

-- Split current buffer to the right, moving the buffer if a fallback exists for the original window
function M.split_move_right(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    -- 1. Check for Fallback
    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf

    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then
            can_replace_original = false -- Cannot use this fallback due to duplicate prevention
        end
    end

    -- 2. Split (focus moves to new_win)
    vim.cmd('botright vnew')
    local new_win = vim.api.nvim_get_current_win()
    local temp_buf = vim.api.nvim_get_current_buf() -- Buffer created by :vnew

    -- 3. Conditional Move
    if can_replace_original then
        -- Move current_buf to new_win
        vim.api.nvim_win_set_buf(new_win, current_buf)

        -- Set fallback_buf in original window
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, fallback_buf)

        -- Delete the temporary buffer if it's valid and unused
        if vim.api.nvim_buf_is_valid(temp_buf) then
            local temp_buf_in_use = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == temp_buf then
                    temp_buf_in_use = true
                    break
                end
            end
            if not temp_buf_in_use then
                pcall(vim.api.nvim_buf_delete, temp_buf, { force = true })
            end
        end

        -- Focus the new window
        vim.api.nvim_set_current_win(new_win)
    else
        -- No replacement possible. Leave current_buf in current_win.
        -- New window (new_win) keeps the empty temp_buf.
        -- Focus is already on new_win.
    end
end

-- Split current buffer to the left, moving the buffer if a fallback exists for the original window
function M.split_move_left(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    -- 1. Check for Fallback
    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf

    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then
            can_replace_original = false
        end
    end

    -- 2. Split (focus moves to new_win)
    vim.cmd('topleft vnew')
    local new_win = vim.api.nvim_get_current_win()
    local temp_buf = vim.api.nvim_get_current_buf()

    -- 3. Conditional Move
    if can_replace_original then
        vim.api.nvim_win_set_buf(new_win, current_buf)
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, fallback_buf)

        if vim.api.nvim_buf_is_valid(temp_buf) then
            local temp_buf_in_use = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == temp_buf then
                    temp_buf_in_use = true
                    break
                end
            end
            if not temp_buf_in_use then
                pcall(vim.api.nvim_buf_delete, temp_buf, { force = true })
            end
        end

        vim.api.nvim_set_current_win(new_win)
    end
end

-- Split current buffer below, moving the buffer if a fallback exists for the original window
function M.split_move_down(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf

    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then
            can_replace_original = false
        end
    end

    vim.cmd('botright new')
    local new_win = vim.api.nvim_get_current_win()
    local temp_buf = vim.api.nvim_get_current_buf()

    if can_replace_original then
        vim.api.nvim_win_set_buf(new_win, current_buf)
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, fallback_buf)

        if vim.api.nvim_buf_is_valid(temp_buf) then
            local temp_buf_in_use = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == temp_buf then
                    temp_buf_in_use = true
                    break
                end
            end
            if not temp_buf_in_use then
                pcall(vim.api.nvim_buf_delete, temp_buf, { force = true })
            end
        end

        vim.api.nvim_set_current_win(new_win)
    end
end

-- Split current buffer above, moving the buffer if a fallback exists for the original window
function M.split_move_up(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf

    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then
            can_replace_original = false
        end
    end

    vim.cmd('topleft new')
    local new_win = vim.api.nvim_get_current_win()
    local temp_buf = vim.api.nvim_get_current_buf()

    if can_replace_original then
        vim.api.nvim_win_set_buf(new_win, current_buf)
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, fallback_buf)

        if vim.api.nvim_buf_is_valid(temp_buf) then
            local temp_buf_in_use = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == temp_buf then
                    temp_buf_in_use = true
                    break
                end
            end
            if not temp_buf_in_use then
                pcall(vim.api.nvim_buf_delete, temp_buf, { force = true })
            end
        end

        vim.api.nvim_set_current_win(new_win)
    end
end

-- Helper function to merge the current buffer into an adjacent split
function M.merge_buffer_direction(direction, opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local original_win = vim.api.nvim_get_current_win()

    if vim.bo[current_buf].buftype ~= "" then
        vim.notify("Cannot merge this type of window.", vim.log.levels.WARN)
        return
    end

    -- Try moving to the target split
    vim.cmd('wincmd ' .. direction)
    local target_win = vim.api.nvim_get_current_win()

    -- Check if we actually moved (i.e., target split exists)
    if target_win ~= original_win then
        -- Set target window's buffer to the current buffer
        vim.api.nvim_win_set_buf(target_win, current_buf)

        -- Try to close the original window
        if vim.api.nvim_win_is_valid(original_win) and #vim.api.nvim_list_wins() > 1 then
            pcall(vim.api.nvim_win_close, original_win, true)
        end

        -- Ensure focus is on the target window
        vim.api.nvim_set_current_win(target_win)
    else
        -- If wincmd didn't move us, there's no split in that direction
        vim.notify("No split in that direction to merge into.", vim.log.levels.WARN)
    end
end

-- Helper function to move buffer to adjacent split
function M.move_buffer_to_split(direction, opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local original_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd ' .. direction)                        -- Try moving to the target split

    if vim.api.nvim_get_current_win() ~= original_win then -- Check if we actually moved
        local target_win = vim.api.nvim_get_current_win()
        vim.cmd('wincmd p')                                -- Move back to the original window

        -- Check if the target window is valid and different from the original
        if vim.api.nvim_win_is_valid(target_win) and target_win ~= original_win then
            -- Check if the target window is displaying a different buffer
            local target_buf = vim.api.nvim_win_get_buf(target_win)
            if target_buf ~= current_buf then
                -- Set the target window's buffer to the current buffer
                vim.api.nvim_win_set_buf(target_win, current_buf)

                -- Try to find a fallback buffer for the original window
                local fallback_buf = utils.get_fallback_buffer(original_win, current_buf)

                if fallback_buf then
                    -- We have a valid fallback buffer
                    vim.api.nvim_win_set_buf(original_win, fallback_buf)
                else
                    -- No fallback buffer, close the original window
                    vim.api.nvim_win_close(original_win, true) -- Use true to force close
                end

                -- Move focus back to the target window where the buffer now resides
                vim.api.nvim_set_current_win(target_win)
            else
                -- If the target window already has the buffer, just move focus
                vim.api.nvim_set_current_win(target_win)
            end
        else
            -- If we couldn't move back or target is invalid/same, just stay put
            vim.api.nvim_set_current_win(original_win)
            vim.notify("Cannot move buffer to that split.", vim.log.levels.WARN)
        end
    else
        -- If wincmd didn't move us, there's no split in that direction
        vim.notify("No split in that direction.", vim.log.levels.WARN)
    end
end

-- Smart split function that either creates a split or merges based on context
function M.smart_split(direction, opts)
    if not opts.smart_splits then
        -- If smart splits are disabled, always create a new split
        if direction == 'h' then
            M.split_move_left(opts)
        elseif direction == 'l' then
            M.split_move_right(opts)
        elseif direction == 'j' then
            M.split_move_down(opts)
        elseif direction == 'k' then
            M.split_move_up(opts)
        end
        return
    end

    -- Check if a split exists in the given direction
    if utils.split_exists_in_direction(direction) then
        -- If split exists, merge in that direction
        M.merge_buffer_direction(direction, opts)
    else
        -- If no split exists, create a new one
        if direction == 'h' then
            M.split_move_left(opts)
        elseif direction == 'l' then
            M.split_move_right(opts)
        elseif direction == 'j' then
            M.split_move_down(opts)
        elseif direction == 'k' then
            M.split_move_up(opts)
        end
    end
end

-- Close the current split if there are multiple windows
function M.close_split(opts)
    local current_win = vim.api.nvim_get_current_win()

    -- Check if this is the last window
    if #vim.api.nvim_list_wins() <= 1 then
        vim.notify("Cannot close the last window.", vim.log.levels.WARN)
        return
    end

    -- Close the current window
    pcall(vim.api.nvim_win_close, current_win, false)
end

-- Close all splits except the current one (only)
function M.close_other_splits(opts)
    local current_win = vim.api.nvim_get_current_win()

    -- Use the Vim command 'only' to close all other windows
    vim.cmd('only')

    -- Ensure we're still in the correct window after the operation
    if vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_set_current_win(current_win)
    end
end

-- Close all splits (keeping at least one)
function M.close_all_splits(opts)
    -- Remember current buffer
    local current_buf = vim.api.nvim_get_current_buf()

    -- Close all windows except one
    vim.cmd('only')

    -- If available, create a new empty buffer
    if opts.smart_close then
        vim.cmd('enew')
    end

    -- Try to delete the original buffer
    if current_buf ~= vim.api.nvim_get_current_buf() and
        vim.api.nvim_buf_is_valid(current_buf) and
        vim.bo[current_buf].buftype == "" then
        pcall(vim.api.nvim_buf_delete, current_buf, { force = false })
    end
end

-- Helper function to navigate to a split in a given direction
function M.navigate_split(direction, opts)
    -- Try to navigate to the split in the specified direction
    vim.cmd("wincmd " .. direction)
end

-- Navigate to the split on the left
function M.navigate_left(opts)
    M.navigate_split('h', opts)
end

-- Navigate to the split on the right
function M.navigate_right(opts)
    M.navigate_split('l', opts)
end

-- Navigate to the split below
function M.navigate_down(opts)
    M.navigate_split('j', opts)
end

-- Navigate to the split above
function M.navigate_up(opts)
    M.navigate_split('k', opts)
end

-- *** Full-Span Split Functions ***

-- Split full-height right, moving buffer if fallback exists
function M.split_move_full_right(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf
    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then can_replace_original = false end
    end

    vim.cmd('vnew') -- Use plain vnew (attempts larger split)
    local new_win = vim.api.nvim_get_current_win()
    local temp_buf = vim.api.nvim_get_current_buf()

    if can_replace_original then
        vim.api.nvim_win_set_buf(new_win, current_buf)
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, fallback_buf)
        if vim.api.nvim_buf_is_valid(temp_buf) then
            local temp_buf_in_use = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == temp_buf then
                    temp_buf_in_use = true; break
                end
            end
            if not temp_buf_in_use then pcall(vim.api.nvim_buf_delete, temp_buf, { force = true }) end
        end
        vim.api.nvim_set_current_win(new_win)
    end
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(new_win) then -- Check if window still valid
            vim.cmd('wincmd =')
        end
    end)
end

-- Split full-height left, moving buffer if fallback exists
function M.split_move_full_left(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf
    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then can_replace_original = false end
    end

    vim.cmd('vert vnew') -- Use plain vert vnew (attempts larger split left)
    local new_win = vim.api.nvim_get_current_win()
    local temp_buf = vim.api.nvim_get_current_buf()

    if can_replace_original then
        vim.api.nvim_win_set_buf(new_win, current_buf)
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, fallback_buf)
        if vim.api.nvim_buf_is_valid(temp_buf) then
            local temp_buf_in_use = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == temp_buf then
                    temp_buf_in_use = true; break
                end
            end
            if not temp_buf_in_use then pcall(vim.api.nvim_buf_delete, temp_buf, { force = true }) end
        end
        vim.api.nvim_set_current_win(new_win)
    end
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(new_win) then -- Check if window still valid
            vim.cmd('wincmd =')
        end
    end)
end

-- Split full-width down, moving buffer if fallback exists
function M.split_move_full_down(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf
    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then can_replace_original = false end
    end

    vim.cmd('new') -- Use plain new (attempts larger split down)
    local new_win = vim.api.nvim_get_current_win()
    local temp_buf = vim.api.nvim_get_current_buf()

    if can_replace_original then
        vim.api.nvim_win_set_buf(new_win, current_buf)
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, fallback_buf)
        if vim.api.nvim_buf_is_valid(temp_buf) then
            local temp_buf_in_use = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == temp_buf then
                    temp_buf_in_use = true; break
                end
            end
            if not temp_buf_in_use then pcall(vim.api.nvim_buf_delete, temp_buf, { force = true }) end
        end
        vim.api.nvim_set_current_win(new_win)
    end
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(new_win) then -- Check if window still valid
            vim.cmd('wincmd =')
        end
    end)
end

-- Split full-width up, moving buffer if fallback exists
function M.split_move_full_up(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf
    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then can_replace_original = false end
    end

    vim.cmd('topleft new') -- Use topleft new (attempts larger split up)
    local new_win = vim.api.nvim_get_current_win()
    local temp_buf = vim.api.nvim_get_current_buf()

    if can_replace_original then
        vim.api.nvim_win_set_buf(new_win, current_buf)
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, fallback_buf)
        if vim.api.nvim_buf_is_valid(temp_buf) then
            local temp_buf_in_use = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == temp_buf then
                    temp_buf_in_use = true; break
                end
            end
            if not temp_buf_in_use then pcall(vim.api.nvim_buf_delete, temp_buf, { force = true }) end
        end
        vim.api.nvim_set_current_win(new_win)
    end
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(new_win) then -- Check if window still valid
            vim.cmd('wincmd =')
        end
    end)
end

return M
