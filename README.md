# 🔀 pivot.nvim

🪄 Magically manage your Neovim buffers and splits with style!

## 📌 TL;DR

**pivot.nvim** intelligently manages buffers and splits in Neovim with context-aware operations.

- **What it does:** Creates, merges, and manages window splits while tracking buffer history to make smart decisions
- **Key benefits:**
  - Maintains clean window layouts without duplicate buffers
  - Remembers buffer history per window for smart fallbacks (history is unlimited)
  - Provides consistent commands for both buffer and split operations
- **Default keymaps:**
  | Action | Keys | Description |
  |----------------------------------|-------------------------|-------------------------------------------|
  | **Smart Splits (Layout-Aware)** | `<leader>sl/sh/sj/sk` | Create/merge splits (right/left/down/up) |
  | **Full-Span Splits** | `<leader>sL/sH/sJ/sK` | Create full-width/height splits |
  | **Split Management** | `<leader>sd/so/sa` | Close split / close others / close all |
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
  auto_record_history = true,  -- Remember buffer history for smarter decisions (history is unlimited)
  smart_splits = true,         -- Create new splits or merge existing ones based on context (using smart keymaps)
  smart_close = true,          -- Close buffers while preserving window layout when possible
  prevent_duplicates = true,   -- Avoid showing the same buffer in multiple windows

  -- Keymap configuration (set any to false to disable)
  keymaps = {
    -- Split operations (Layout-Aware/Smart: merge or split within layout)
    split_smart_right = '<leader>sl', -- Default: Lowercase l
    split_smart_left = '<leader>sh',  -- Default: Lowercase h
    split_smart_down = '<leader>sj',  -- Default: Lowercase j
    split_smart_up = '<leader>sk',    -- Default: Lowercase k

    -- Split operations (Full-Span: always split, ignoring layout)
    split_full_right = '<leader>sL', -- Default: Capital L
    split_full_left = '<leader>sH',  -- Default: Capital H
    split_full_down = '<leader>sJ',  -- Default: Capital J
    split_full_up = '<leader>sK',    -- Default: Capital K

    -- Split window management
    close_split = '<leader>sd',
    close_other_splits = '<leader>so',
    close_all_splits = '<leader>sa',

    -- Buffer operations
    close_buffer = '<leader>bd',
    close_other_buffers = '<leader>bo',
    close_all_buffers = '<leader>ba',

    -- Move buffer to different split
    move_to_right = '<leader>bl',
    move_to_left = '<leader>bh',
    move_to_down = '<leader>bj',
    move_to_up = '<leader>bk',

    -- Buffer navigation (skips buffers visible in other windows)
    prev_buffer = '<C-h>',
    next_buffer = '<C-l>',
    alt_prev_buffer = '<C-k>', -- Alternate binding
    alt_next_buffer = '<C-j>', -- Alternate binding

    -- Alternative keys for different keyboard layouts/OS (Example)
    -- alt_prev = {'˙', '<A-h>'},  -- Mac Option-h, Windows/Linux Alt-h
    -- alt_next = {'¬', '<A-l>'},  -- Mac Option-l, Windows/Linux Alt-l
  },

  -- Command settings
  commands = {
    enable = true,
    prefix = 'Pivot',
  },
})
```

</details>

## 🚀 Usage Guide

### 🪟 Split Management

pivot.nvim offers two types of splitting behavior:

1.  **Smart/Layout-Aware Splits:** (Default: `<leader>sl/sh/sj/sk`)

    - If `smart_splits = true` (default) and a split already exists in the target direction, pivot will **merge** the current buffer into that split.
    - If no split exists or `smart_splits = false`, pivot creates a new split **within the current layout column/row**. It intelligently moves the current buffer to the new split and replaces the original window's buffer with a fallback from its history (if available and `prevent_duplicates` allows).

2.  **Full-Span Splits:** (Default: `<leader>sL/sH/sJ/sK`)
    - These commands **always** create a new split that spans the **full height (for left/right) or full width (for up/down)** of the Neovim window, regardless of the existing layout.
    - They also intelligently move the current buffer and find a fallback for the original window.
    - After splitting, window sizes are automatically equalized (`wincmd =`).

<details>
<summary>Show split window diagram (Layout-Aware)</summary>

```
+---------------+                +--------+--------+
|               |   Layout-Aware |        |        |
|    Buffer     |   Split Right  | Buffer | New/Fb |
|               |   (<leader>sl)  |        |        |
+---------------+                +--------+--------+
```

(Fb = Fallback Buffer)

</details>

<details>
<summary>Show split window diagram (Full-Span)</summary>

```
+---------------+                +-----------------+             +-----------------+
|   Win 1       |                |   Win 1 (Fb)    |             |   Win 1 (Fb)    |
+---------------+   Full-Span    +-----------------+   wincmd=   +-----------------+
|   Win 2 (Cur) |   Split Right  |   Win 2 (New)   |   ----->    |   Win 2 (New)   |
+---------------+   (<leader>sL)  |   (Buffer)      |             |   (Buffer)      |
|   Win 3       |                |   Win 3         |             |   Win 3         |
+---------------+                +-----------------+             +-----------------+
```

(Creates a new full-height window on the right, moves Buffer, puts Fallback in original Win 2, then equalizes)

</details>

**Keymaps:**

- `<leader>sl/sh/sj/sk`: Smart/Layout-Aware split (right/left/down/up)
- `<leader>sL/sH/sJ/sK`: Full-Span split (right/left/down/up)
- `<leader>sd`: Close current split
- `<leader>so`: Close all other splits
- `<leader>sa`: Close all splits (keep one)

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
<summary>Show all available Vim commands (default prefix: Pivot)</summary>

```
:PivotSplitRight/Left/Up/Down          - Split window (layout aware), moving buffer if possible
:PivotSmartSplitRight/Left/Up/Down     - Smart split (merge or layout-aware split)
:PivotSplitFullRight/Left/Up/Down     - Split window full-span, moving buffer if possible
:PivotCloseSplit                      - Close current split
:PivotCloseOtherSplits                - Close all splits except current
:PivotCloseAllSplits                  - Close all splits (keep one empty if smart_close)
:PivotCloseBuffer                     - Close buffer smartly (preserves layout)
:PivotCloseOtherBuffers               - Close all buffers except current
:PivotCloseAllBuffers                 - Close all buffers (creates empty if smart_close)
:PivotMoveToSplit {dir}               - Move buffer to split in direction (h/j/k/l)
:PivotMergeBufferDirection {dir}      - Merge current buffer into adjacent split (h/j/k/l)
:PivotNavigate {dir}                  - Navigate buffers (next/prev/first/last or index)
:PivotNavigateAll {dir}               - Navigate all buffers, skipping visible (next/prev)
:PivotNavigateSplit {dir}             - Navigate to split in direction (left/right/up/down or h/j/k/l)
:PivotCycleBufferHistory {dir}        - Cycle through the current window's buffer history (prev/next)
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

- **Weird behavior with incomplete keymaps?**
  Make sure you've mapped both sides of paired operations (left/right, previous/next).

Run `:checkhealth pivot` to automatically detect these issues.

</details>
