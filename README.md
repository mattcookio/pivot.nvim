# 🔀 pivot.nvim

🪄 Magically manage your Neovim buffers and splits with style!

## 📌 TL;DR

**pivot.nvim** intelligently manages buffers and splits in Neovim with context-aware operations.

- **What it does:** Creates, merges, and manages window splits while tracking buffer history to make smart decisions
- **Key benefits:**
  - Maintains clean window layouts without duplicate buffers
  - Remembers buffer history per window for smart fallbacks
  - Provides consistent commands for both buffer and split operations
- **Default keymaps:**
  | Action | Keys | Description |
  |--------|------|-------------|
  | **Splits** | `<leader>sl/sh/sj/sk` | Create/merge splits (right/left/down/up) |
  | | `<leader>sd/so/sa` | Close split / close others / close all |
  | **Buffers** | `<leader>bd/bo/ba` | Close buffer / close others / close all |
  | | `<C-h>/<C-l>` or `<C-k>/<C-j>` | Navigate prev/next buffer |
  | **Navigation** | `<C-D-h>/<C-D-l>/<C-D-j>/<C-D-k>` | Navigate between splits (left/right/down/up) |
  | **Movement** | `<leader>bl/bh/bj/bk` | Move buffer to split (right/left/down/up) |
- **Get started:** `require('pivot').setup()` - uses sensible defaults and can be customized

## ✨ What is pivot.nvim?

pivot.nvim makes working with buffers and splits in Neovim fun again! No more window management headaches - just simple commands that do exactly what you expect.

## 🌟 Highlights

- 🧠 **Smart Splits**: Creates splits intelligently or merges windows when it makes sense
- 🔄 **Context Aware**: Remembers your window history and acts accordingly
- 🚫 **No Duplicates**: Avoids showing the same buffer in multiple windows
- 🤝 **Consistent Commands**: Similar keystrokes for both buffer and split operations
- 🎮 **Fully Customizable**: Configure every aspect to match your workflow

## 📦 Installation

<details>
<summary>Using lazy.nvim</summary>

```lua
{
  "username/pivot.nvim",
  config = function()
    require("pivot").setup() -- Use defaults or add your config
  end
}
```

</details>

<details>
<summary>Using packer.nvim</summary>

```lua
use {
  "username/pivot.nvim",
  config = function()
    require("pivot").setup() -- Use defaults or add your config
  end
}
```

</details>

## 🎮 Quick Start

With default settings, just try these commands:

- `<leader>sl` - Split window to the right (or merge if a window exists there)
- `<leader>bd` - Close current buffer smartly (preserves layout)
- `<C-h>` / `<C-l>` - Navigate between buffers

## 🔧 Configuration

<details>
<summary>Default configuration with explanations</summary>

```lua
require('pivot').setup({
  -- Core behavior settings
  auto_record_history = true,  -- Remember buffer history for smarter decisions
  history_limit = 10,          -- Maximum number of buffers to remember per window
  smart_splits = true,         -- Create new splits or merge existing ones based on context
  smart_close = true,          -- Close buffers while preserving window layout when possible
  prevent_duplicates = true,   -- Avoid showing the same buffer in multiple windows

  -- Keymap configuration (set any to false to disable)
  keymaps = {
    -- Split creation/merging
    split_right = '<leader>sl',  -- Split right or merge to right window
    split_left = '<leader>sh',   -- Split left or merge to left window
    split_down = '<leader>sj',   -- Split down or merge to window below
    split_up = '<leader>sk',     -- Split up or merge to window above

    -- Split window management
    close_split = '<leader>sd',         -- Close the current split
    close_other_splits = '<leader>so',  -- Close all splits except current
    close_all_splits = '<leader>sa',    -- Close all splits (keep one empty)

    -- Buffer operations
    close_buffer = '<leader>bd',         -- Close current buffer (smart)
    close_other_buffers = '<leader>bo',  -- Close all buffers except current
    close_all_buffers = '<leader>ba',    -- Close all buffers

    -- Move buffer to different split
    move_to_right = '<leader>bl',  -- Move buffer to split on the right
    move_to_left = '<leader>bh',   -- Move buffer to split on the left
    move_to_down = '<leader>bj',   -- Move buffer to split below
    move_to_up = '<leader>bk',     -- Move buffer to split above

    -- Buffer navigation (skips buffers visible in other windows)
    prev_buffer = '<C-h>',       -- Go to previous buffer
    next_buffer = '<C-l>',       -- Go to next buffer
    alt_prev_buffer = '<C-k>',   -- Alternate previous buffer binding
    alt_next_buffer = '<C-j>',   -- Alternate next buffer binding

    -- Alternative keys for different keyboard layouts/OS
    alt_prev = {'˙', '<A-h>'},  -- Mac Option-h, Windows/Linux Alt-h
    alt_next = {'¬', '<A-l>'},  -- Mac Option-l, Windows/Linux Alt-l
  },

  -- Command settings
  commands = {
    enable = true,      -- Whether to create Neovim commands
    prefix = 'Pivot',   -- Prefix for all commands (e.g., :PivotSplitRight)
  },
})
```

</details>

## 🚀 Usage Guide

### 🪟 Split Management

Create beautiful window layouts with ease:

<details>
<summary>Show split window diagram</summary>

```
+---------------+                +--------+--------+
|               |     Split      |        |        |
|    Buffer     |     Right      | Buffer |  New   |
|               |     ------>    |        |        |
+---------------+                +--------+--------+
```

</details>

Commands:

- `<leader>sl` - Split right or merge with right window
- `<leader>sh` - Split left or merge with left window
- `<leader>sj` - Split down or merge with window below
- `<leader>sk` - Split up or merge with window above
- `<leader>sd` - Close current split
- `<leader>so` - Close all other splits
- `<leader>sa` - Close all splits (keep one)

### 📄 Buffer Management

Manage buffers like a pro:

- `<leader>bd` - Close current buffer intelligently
- `<leader>bo` - Close all other buffers
- `<leader>ba` - Close all buffers
- `<C-h>` / `<C-k>` - Go to previous buffer
- `<C-l>` / `<C-j>` - Go to next buffer

### 🔀 Buffer Movement

Move buffers between splits:

<details>
<summary>Show buffer movement diagram</summary>

```
+--------+--------+                +--------+--------+
|        |        |   Move Right   |        |        |
| Buffer |   B2   |   --------->   |   B2   | Buffer |
|   A    |        |                |        |   A    |
+--------+--------+                +--------+--------+
```

</details>

Commands:

- `<leader>bl` - Move buffer to right split
- `<leader>bh` - Move buffer to left split
- `<leader>bj` - Move buffer to split below
- `<leader>bk` - Move buffer to split above

## ⌨️ Vim Commands

<details>
<summary>Show all available Vim commands</summary>

```
:PivotSplitRight        - Create split on the right
:PivotSmartSplitRight   - Smart split right (or merge)
:PivotCloseSplit        - Close current split
:PivotCloseBuffer       - Close buffer smartly
:PivotMove {dir}        - Move buffer to direction (h/j/k/l)
:PivotNavigate {dir}    - Navigate buffers (next/prev)
:PivotNavigateSplit {dir} - Navigate to split in direction (left/right/up/down or h/j/k/l)
```

</details>

## 🧰 Lua API

<details>
<summary>Show Lua API examples</summary>

```lua
local pivot = require('pivot')

-- Examples
pivot.smart_split('l')          -- Split right or merge
pivot.move_buffer_to_split('h') -- Move buffer to left split
pivot.close_buffer()            -- Close buffer intelligently
```

</details>

## 🩺 Health Check

Run `:checkhealth pivot` to verify your setup is working properly.

<details>
<summary>What gets checked?</summary>

The health check verifies:

- ✅ Neovim version compatibility
- ✅ Required API functions
- ✅ Plugin configuration status
- ✅ Conflicting settings, including:
  - `auto_record_history: true` with `history_limit: 0` (history won't work)
  - `auto_record_history: false` with `smart_close: true` (reduced functionality)
  - `smart_splits: true` with `prevent_duplicates: false` (potential duplicates)
- ✅ Incomplete keymap pairs (missing complementary mappings)
- ✅ Buffer handling safety

If issues are found, the health check will provide recommendations to fix them.

</details>

## 🛠️ Customization Examples

<details>
<summary>Minimal Configuration</summary>

```lua
require('pivot').setup({
  -- Just the essentials
  keymaps = {
    split_right = '<leader>v',
    split_left = '<leader>V',
    close_buffer = '<leader>q',
    prev_buffer = '<Tab>',
    next_buffer = '<S-Tab>',
  }
})
```

</details>

<details>
<summary>Disable Features You Don't Need</summary>

```lua
require('pivot').setup({
  smart_splits = false,       -- Use regular splits
  prevent_duplicates = false, -- Allow same buffer in multiple windows

  -- Disable specific keymaps
  keymaps = {
    close_other_splits = false,
    close_all_splits = false,
  }
})
```

</details>

## 🔍 Troubleshooting

<details>
<summary>Configuration Problems</summary>

If some features don't work as expected, it might be due to conflicting settings:

- **Smart buffer closing not working well?**  
  Ensure both `auto_record_history` and `smart_close` are enabled.

- **Duplicate buffers appearing in splits?**  
  Check that `prevent_duplicates` is enabled.

- **Buffer history not working?**  
  Verify that `history_limit` is greater than 0.

- **Weird behavior with incomplete keymaps?**  
  Make sure you've mapped both sides of paired operations (left/right, previous/next).

Run `:checkhealth pivot` to automatically detect these issues.

</details>
