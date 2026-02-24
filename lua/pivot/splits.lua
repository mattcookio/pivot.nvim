local M = {}

-- Module dependencies
local utils = require('pivot.utils')

-- Split current buffer right (standard vnew), moving buffer if fallback exists
function M.split_move_right(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()
    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf
    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then can_replace_original = false end
    end

    vim.cmd('botright vnew') -- Standard vertical split right
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
    vim.schedule(function() pcall(vim.cmd, 'wincmd =') end)
end

function M.split_move_left(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()
    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf
    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then can_replace_original = false end
    end

    vim.cmd('topleft vnew') -- Standard vertical split left
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
    vim.schedule(function() pcall(vim.cmd, 'wincmd =') end)
end

function M.split_move_down(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()
    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf
    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then can_replace_original = false end
    end

    vim.cmd('botright new') -- Standard horizontal split down
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
    vim.schedule(function() pcall(vim.cmd, 'wincmd =') end)
end

function M.split_move_up(opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()
    local fallback_buf = utils.get_fallback_buffer(current_win, current_buf)
    local can_replace_original = fallback_buf and fallback_buf ~= current_buf
    if can_replace_original and opts.prevent_duplicates then
        local visible_elsewhere = utils.get_buffers_in_other_windows(current_win)
        if visible_elsewhere[fallback_buf] then can_replace_original = false end
    end

    vim.cmd('topleft new') -- Standard horizontal split up
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
    vim.schedule(function() pcall(vim.cmd, 'wincmd =') end)
end

-- Helper function to merge the current buffer into a SPECIFIC target window
local function merge_buffer_into_window(target_win_id, opts)
    local current_buf = vim.api.nvim_get_current_buf()
    local original_win = vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(target_win_id) or target_win_id == original_win then
        vim.notify("Cannot merge into invalid or same window.", vim.log.levels.WARN)
        return
    end
    if vim.bo[current_buf].buftype ~= "" then
        vim.notify("Cannot merge this type of window.", vim.log.levels.WARN)
        return
    end
    vim.api.nvim_win_set_buf(target_win_id, current_buf)
    if vim.api.nvim_win_is_valid(original_win) and #vim.api.nvim_list_wins() > 1 then
        pcall(vim.api.nvim_win_close, original_win, true)
    end
    vim.api.nvim_set_current_win(target_win_id)
end

-- Track floating windows for overlays
local floating_windows = {}

-- Close all active overlay floating windows
local function close_number_floats()
    for _, float_win_id in pairs(floating_windows) do
        if vim.api.nvim_win_is_valid(float_win_id) then
            pcall(vim.api.nvim_win_close, float_win_id, true)
        end
    end
    floating_windows = {}
end

-- Function to handle visual selection for merging
local function prompt_visual_merge_selection(neighbors, opts, merge_callback)
    local original_win = vim.api.nvim_get_current_win()
    local choice_map = {} -- Map number key ('1', '2', ...) to neighbor win_id
    local choice_num = 1
    local function cleanup()
        utils.clear_dimming()
        close_number_floats()
        if vim.api.nvim_get_current_win() ~= original_win and vim.api.nvim_win_is_valid(original_win) then
            pcall(vim.api.nvim_set_current_win, original_win)
        end
    end
    local neighbor_map = {}
    for _, nid in ipairs(neighbors) do neighbor_map[nid] = true end
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if win_id ~= original_win and not neighbor_map[win_id] then
            utils.dim_window(win_id)
        end
    end
    for _, win_id in ipairs(neighbors) do
        if choice_num > 9 then break end
        local num_char = tostring(choice_num)
        local target_buf_id = vim.api.nvim_win_get_buf(win_id)
        local target_pos = vim.api.nvim_win_get_position(win_id)
        local target_width = vim.api.nvim_win_get_width(win_id)
        local target_height = vim.api.nvim_win_get_height(win_id)
        local target_lines = vim.api.nvim_buf_get_lines(target_buf_id, 0, target_height, false)
        local processed_lines = {}
        for _, line in ipairs(target_lines) do
            local processed_line = string.gsub(line, "%S", num_char)
            table.insert(processed_lines, processed_line)
        end
        local float_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, processed_lines)
        local float_win_id = vim.api.nvim_open_win(float_buf, false, {
            relative = 'editor',
            row = target_pos[1],
            col = target_pos[2],
            width = target_width,
            height = target_height,
            style = 'minimal',
            border = 'none',
            zindex = 100,
        })
        vim.api.nvim_win_set_option(float_win_id, 'winhl', 'Normal:Normal')
        vim.api.nvim_win_set_option(float_win_id, 'number', false)
        vim.api.nvim_win_set_option(float_win_id, 'relativenumber', false)
        vim.api.nvim_win_set_option(float_win_id, 'signcolumn', 'no')
        vim.api.nvim_win_set_option(float_win_id, 'foldcolumn', '0')
        table.insert(floating_windows, float_win_id)
        choice_map[num_char] = win_id
        choice_num = choice_num + 1
    end
    vim.notify("Select target window number (1-" .. (choice_num - 1) .. ") or Esc to cancel", vim.log.levels.INFO)
    vim.cmd('redraw')
    local selected_win_id = nil
    local char_code = vim.fn.getchar()
    local char = (type(char_code) == 'number' and char_code ~= 0) and vim.fn.nr2char(char_code) or nil
    if char and choice_map[char] then
        selected_win_id = choice_map[char]
        vim.notify("Merging into window " .. selected_win_id, vim.log.levels.INFO)
    else
        vim.notify("Merge cancelled.", vim.log.levels.INFO)
    end
    cleanup()
    if selected_win_id then
        merge_callback(selected_win_id, opts)
    end
end

-- Smart split function: Merges if possible, otherwise performs a standard split
function M.smart_split(direction, opts)
    local live_smart_splits = require('pivot.config').options.smart_splits
    local neighbors = utils.get_neighboring_windows(direction)

    if live_smart_splits and #neighbors > 0 then
        if #neighbors == 1 then
            merge_buffer_into_window(neighbors[1], opts)
        else
            prompt_visual_merge_selection(neighbors, opts, merge_buffer_into_window)
        end
    else
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

-- Helper function to swap buffers between two windows
local function swap_buffers(original_win, target_win, opts)
    if not vim.api.nvim_win_is_valid(original_win) or not vim.api.nvim_win_is_valid(target_win) then
        vim.notify("Cannot swap buffers: invalid window.", vim.log.levels.WARN)
        return
    end

    local buf1 = vim.api.nvim_win_get_buf(original_win)
    local buf2 = vim.api.nvim_win_get_buf(target_win)

    if buf1 == buf2 then
        vim.notify("Windows already contain the same buffer.", vim.log.levels.INFO)
        return
    end

    if vim.bo[buf1].buftype ~= "" or vim.bo[buf2].buftype ~= "" then
        vim.notify("Cannot swap buffer: involves a special buffer type.", vim.log.levels.WARN)
        return
    end

    local success1 = pcall(vim.api.nvim_win_set_buf, original_win, buf2)
    local success2 = pcall(vim.api.nvim_win_set_buf, target_win, buf1)

    if success1 and success2 then
        local follow = opts and opts.swap_follows_cursor
        if follow then
            vim.api.nvim_set_current_win(target_win)
        else
            vim.api.nvim_set_current_win(original_win)
        end
        vim.notify("Buffers swapped.", vim.log.levels.INFO)
    else
        vim.notify("Failed to swap buffers.", vim.log.levels.ERROR)
    end
end

-- Function to handle visual selection for swapping a buffer
local function prompt_visual_swap_selection(neighbors, opts, swap_callback)
    local original_win = vim.api.nvim_get_current_win()
    local choice_map = {}
    local choice_num = 1

    local function cleanup()
        utils.clear_dimming()
        close_number_floats()
        if vim.api.nvim_win_is_valid(original_win) then
            pcall(vim.api.nvim_set_current_win, original_win)
        end
    end

    local neighbor_map = {}
    for _, nid in ipairs(neighbors) do neighbor_map[nid] = true end

    -- Dim non-neighbor windows
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if win_id ~= original_win and not neighbor_map[win_id] then
            utils.dim_window(win_id)
        end
    end

    -- Create number overlays for neighbor windows
    for _, win_id in ipairs(neighbors) do
        if choice_num > 9 then break end
        local num_char = tostring(choice_num)
        local target_buf_id = vim.api.nvim_win_get_buf(win_id)
        local target_pos = vim.api.nvim_win_get_position(win_id)
        local target_width = vim.api.nvim_win_get_width(win_id)
        local target_height = vim.api.nvim_win_get_height(win_id)

        local target_lines = {}
        for i = 1, target_height do
            table.insert(target_lines, string.rep(num_char, target_width))
        end

        local float_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, target_lines)
        local float_win_id = vim.api.nvim_open_win(float_buf, false, {
            relative = 'editor',
            row = target_pos[1],
            col = target_pos[2],
            width = target_width,
            height = target_height,
            style = 'minimal',
            border = 'none',
            zindex = 100,
        })
        vim.api.nvim_win_set_option(float_win_id, 'winhl', 'Normal:Visual')
        vim.api.nvim_win_set_option(float_win_id, 'number', false)
        vim.api.nvim_win_set_option(float_win_id, 'relativenumber', false)
        vim.api.nvim_win_set_option(float_win_id, 'signcolumn', 'no')
        vim.api.nvim_win_set_option(float_win_id, 'foldcolumn', '0')

        table.insert(floating_windows, float_win_id)
        choice_map[num_char] = win_id
        choice_num = choice_num + 1
    end

    vim.notify("Swap buffer with window number (1-" .. (choice_num - 1) .. ") or Esc to cancel", vim.log.levels.INFO)
    vim.cmd('redraw')

    local selected_win_id = nil
    local char_code = vim.fn.getchar()
    local char = (type(char_code) == 'number' and char_code ~= 0) and vim.fn.nr2char(char_code) or nil

    if char and choice_map[char] then
        selected_win_id = choice_map[char]
        vim.notify("Swapping buffer with window " .. selected_win_id, vim.log.levels.INFO)
    else
        vim.notify("Swap cancelled.", vim.log.levels.INFO)
    end

    cleanup()

    if selected_win_id then
        swap_callback(original_win, selected_win_id, opts)
    end
end

-- Swap the buffer in the current window with an adjacent window
function M.swap_buffer_with_split(direction, opts)
    local current_win = vim.api.nvim_get_current_win()
    local neighbors = utils.get_neighboring_windows(direction)

    if #neighbors == 0 then
        vim.notify("No adjacent window found in that direction.", vim.log.levels.WARN)
    elseif #neighbors == 1 then
        swap_buffers(current_win, neighbors[1], opts)
    else
        prompt_visual_swap_selection(neighbors, opts, swap_buffers)
    end
end

-- Edge detection via wincmd: try to move in a direction, check if we
-- actually moved, then move back. This uses Neovim's own navigation
-- so it naturally ignores floating windows and handles all edge cases.
local function at_edge(dir)
    local cur = vim.api.nvim_get_current_win()
    vim.cmd('wincmd ' .. dir)
    local moved = vim.api.nvim_get_current_win() ~= cur
    if moved then vim.api.nvim_set_current_win(cur) end
    return not moved
end

-- Smart resize: j/l naturally grow, k/h naturally shrink.
-- At the bottom/right edge, the mapping flips so opposite keys
-- always do opposite things regardless of window position.
function M.resize(direction, opts)
    local step = opts.resize_step or 3

    if direction == 'j' or direction == 'k' then
        if at_edge('j') and at_edge('k') then return end -- no horizontal splits
        local flip = at_edge('j')
        if direction == 'j' then
            vim.cmd('resize ' .. (flip and '-' or '+') .. step)
        else
            vim.cmd('resize ' .. (flip and '+' or '-') .. step)
        end
    elseif direction == 'h' or direction == 'l' then
        if at_edge('h') and at_edge('l') then return end -- no vertical splits
        local flip = at_edge('l')
        if direction == 'l' then
            vim.cmd('vertical resize ' .. (flip and '-' or '+') .. step)
        else
            vim.cmd('vertical resize ' .. (flip and '+' or '-') .. step)
        end
    end
end

-- Equalize all split sizes
function M.resize_equal(opts)
    vim.cmd('wincmd =')
end

-- Hydra-style resize mode: h/j/k/l resize, = equalizes, Esc/q/any other key exits.
function M.resize_mode(opts)
    local valid = { h = true, j = true, k = true, l = true }
    vim.api.nvim_echo({ { ' RESIZE ', 'ModeMsg' }, { '  h/j/k/l resize, = equalize, Esc/Enter exit', 'Comment' } }, false, {})
    vim.cmd('redraw')

    while true do
        local ok, char_code = pcall(vim.fn.getchar)
        if not ok then break end
        local char = (type(char_code) == 'number' and char_code ~= 0) and vim.fn.nr2char(char_code) or nil

        if not char or char_code == 27 or char_code == 13 then -- Esc or Enter
            break
        elseif valid[char] then
            M.resize(char, opts)
            vim.api.nvim_echo({ { ' RESIZE ', 'ModeMsg' }, { '  h/j/k/l resize, = equalize, Esc/Enter exit', 'Comment' } }, false, {})
            vim.cmd('redraw')
        elseif char == '=' then
            M.resize_equal(opts)
            vim.api.nvim_echo({ { ' RESIZE ', 'ModeMsg' }, { '  h/j/k/l resize, = equalize, Esc/Enter exit', 'Comment' } }, false, {})
            vim.cmd('redraw')
        else
            break
        end
    end

    vim.api.nvim_echo({ { '' } }, false, {})
    vim.cmd('redraw')
end

return M
