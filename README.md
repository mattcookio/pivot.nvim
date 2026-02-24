# 🔀 pivot.nvim

🪄 Magically manage your Neovim buffers and splits with style!

## 📌 TL;DR

**pivot.nvim** intelligently manages buffers and splits in Neovim with context-aware operations.

- **What it does:** Creates standard Vim splits or merges into adjacent windows, tracks buffer history for smart fallbacks.
- **Key benefits:**
  - Clean window layouts without duplicate buffers.
  - Remembers buffer history per window.
  - Predictable split behavior + optional merging (with visual prompt).
- **Default keymaps:**
  | Action | Keys | Description |
  |------------------------------|-------------------------|--------------------------------------------------|
  | **Splits** | `<leader>sl/sh/sj/sk` | Split (standard geometry) or merge (visual prompt)|
  | **Terminal** | `<leader>tt` | Open terminal in current window |
  | **Split Management** | `<leader>sd/so/sa` | Close split / close others / close all |
  | **Buffers** | `<leader>bd/bo/ba` | Close buffer / close others / close all |
  | | `<C-h>/<C-l>` or `<C-k>/<C-j>` | Navigate prev/next buffer |
  | **Navigation** | `<C-D-h>/<C-D-l>/<C-D-j>/<C-D-k>` | Navigate between splits |
  | **Move Buffer** | `<leader>bl/bh/bj/bk` | Move current buffer to adjacent split (cursor follows) |
  | **Swap Buffer** | `<leader>sxl/sxh/sxj/sxk` | Swap buffer with adjacent split (cursor stays) |
- **Get started:** `require('pivot').setup()`

## ✨ What is pivot.nvim?

pivot.nvim makes working with buffers and splits in Neovim fun again! No more window management headaches - just simple commands that do exactly what you expect.

## 🌟 Highlights

- 🧠 **Smart Splits**: Merges into adjacent windows when possible (with visual prompt for ambiguity) or creates standard layout splits.
- 🔄 **Context Aware**: Remembers your window history and acts accordingly.
- 🚫 **No Duplicates**: Avoids showing the same buffer in multiple windows (configurable).
- 🤝 **Consistent Commands**: Similar keystrokes for both buffer and split operations.
- 🎮 **Fully Customizable**: Configure options and keymaps.

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

- `<leader>sl` - Split right (standard layout) or merge if window exists right.
- `<leader>bd` - Close current buffer smartly (preserves layout).
- `<C-h>` / `<C-l>` - Navigate between buffers.

## 🔧 Configuration

<details>
<summary>Default configuration with explanations</summary>

```lua
require('pivot').setup({
  -- Core behavior settings
  smart_splits = true,         -- Allow split keymaps to merge into adjacent windows instead of splitting
  smart_close = true,          -- Close buffers while preserving window layout
  prevent_duplicates = true,   -- Avoid showing the same buffer in multiple windows

  -- Keymap configuration (set any to false to disable)
  keymaps = {
    -- Split: Uses standard Vim geometry. Merges if smart_splits = true and neighbor exists.
    -- If multiple merge targets exist, shows a visual prompt.
    split_right = '<leader>sl', -- (:vnew or merge)
    split_left = '<leader>sh',  -- (:vnew or merge)
    split_down = '<leader>sj',  -- (:new or merge)
    split_up = '<leader>sk',    -- (:new or merge)

    -- Split management
    close_split = '<leader>sd',
    close_other_splits = '<leader>so',
    close_all_splits = '<leader>sa',

    -- Terminal
    terminal = '<leader>tt', -- Open terminal in current window

    -- Buffer operations
    close_buffer = '<leader>bd',
    close_other_buffers = '<leader>bo',
    close_all_buffers = '<leader>ba',

    -- Move buffer to different split (cursor follows)
    move_to_right = '<leader>bl',
    move_to_left = '<leader>bh',
    move_to_down = '<leader>bj',
    move_to_up = '<leader>bk',

    -- Swap buffer with adjacent split (cursor stays)
    swap_right = '<leader>sxl',
    swap_left = '<leader>sxh',
    swap_down = '<leader>sxj',
    swap_up = '<leader>sxk',

    -- Buffer navigation (skips buffers visible in other windows)
    prev_buffer = '<C-h>',
    next_buffer = '<C-l>',
    alt_prev_buffer = '<C-k>',
    alt_next_buffer = '<C-j>',

    -- Split navigation
    nav_left = '<C-D-h>',
    nav_right = '<C-D-l>',
    nav_down = '<C-D-j>',
    nav_up = '<C-D-k>',

    -- Terminal navigation
    exit_terminal_mode = '<Esc>',
  },

  -- Command options
  commands = {
    enable = true,
    prefix = 'Pivot',
  },
})
```

</details>

## 🚀 Usage Guide

### 🪟 Split Management

Split commands (`<leader>sl/sh/sj/sk`) either merge into an adjacent window or create a new split using standard Vim geometry:

- **Merging:**
  - If `smart_splits = true` (default) and one or more windows exist adjacent to the current window in the target direction, pivot.nvim will offer to **merge** the current buffer into one of those neighbors.
  - **If exactly one neighbor exists**, the merge happens automatically.
  - **If multiple neighbors exist**:
    - Other windows will be dimmed slightly.
    - A number (1-9) overlay will appear over each potential target window (showing the number character repeated to fill the window space).
    - You will be prompted to press the number corresponding to the window you want to merge into.
    - Pressing the number merges into the chosen window; any other key (like Esc) cancels.
    - The dimming and number overlays are removed after your selection or cancellation.
- **Splitting:**
  - If merging is not possible (no neighbor or `smart_splits = false`), a new split is created using standard Vim geometry:
    - Right/Left (`sl`/`sh`) use `:vnew` / `:topleft vnew` (respects layout).
    - Down/Up (`sj`/`sk`) use `:new` / `:topleft new` (respects layout).
  - The plugin intelligently handles buffer placement in the new/merged windows.

**Window Equalization:**

After every split creation command, pivot.nvim attempts to equalize all window sizes using `vim.cmd('wincmd =')` (via `vim.schedule`).

<details>
<summary>Show split window diagram (Right/Left Split - :vnew)</summary>

```
+---------------+                +--------+--------+
|               |   Split Right  |        |        |
|    Buffer     |   (<leader>sl)  | Buffer | New/Fb |
|               |   (:vnew)      |        |        |
+---------------+                +--------+--------+
```

(Fb = Fallback Buffer)

</details>

<details>
<summary>Show split window diagram (Down/Up Split - :new)</summary>

```
+-----------------------+          +-----------------------+
|                       | Split Dn |        Buffer         |
|      Wide Buffer      | (<leader>sj) |                       |
|                       | (:new)   +-----------------------+
+-----------------------+ -------->|        New/Fb         |
|                       |          |                       |
|      Other Window     |          |      Other Window     |
|                       |          |                       |
+-----------------------+          +-----------------------+
```

(Fb = Fallback Buffer)

</details>

**Keymaps:**

| Action                   | Keys                                   | Description                                                     |
| ------------------------ | -------------------------------------- | --------------------------------------------------------------- |
| Split Right/Left/Down/Up | `<leader>sl/sh/sj/sk`                  | Split (standard geometry) or Merge (visual prompt if ambiguous) |
| Open Terminal            | `<leader>tt`                           | Open terminal in current window                                 |
| Close Split              | `<leader>sd`                           | Close current split                                             |
| Close Other Splits       | `<leader>so`                           | Close all other splits                                          |
| Close All Splits         | `<leader>sa`                           | Close all splits (keep one)                                     |
| Close Buffer             | `<leader>bd`                           | Close buffer (smart)                                            |
| Close Other Buffers      | `<leader>bo`                           | Close other buffers                                             |
| Close All Buffers        | `<leader>ba`                           | Close all buffers                                               |
| Navigate Prev/Next Buf   | `<C-h>` / `<C-l>` or `<C-k>` / `<C-j>` | Navigate prev/next buffer (skips visible in other wins)         |
| Navigate Splits          | `<C-D-h>/<C-D-l>/<C-D-j>/<C-D-k>`      | Navigate between splits (Normal & Terminal modes)               |
| Exit Terminal Mode       | `<Esc>` (in term mode)                 | Exit terminal mode                                              |
| Move Buffer R/L/D/U      | `<leader>bl/bh/bj/bk`                  | Move buffer to adjacent split, cursor follows (visual prompt if ambiguous) |
| Swap Buffer R/L/D/U      | `<leader>sxl/sxh/sxj/sxk`              | Swap buffer with adjacent split, cursor stays (visual prompt if ambiguous) |

### 🪟 Buffer Management

Manage buffers like a pro:

- `<leader>bd` - Close current buffer intelligently
- `<leader>bo` - Close all other buffers
- `<leader>ba` - Close all buffers
- `<C-h>` / `<C-k>` - Go to previous buffer
- `<C-l>` / `<C-j>` - Go to next buffer

## ⌨️ Vim Commands

<details>
<summary>Show all available Vim commands (default prefix: Pivot)</summary>

```
:PivotSplitRight                     - Split right (standard :vnew) or merge
:PivotSplitLeft                      - Split left (standard :vnew) or merge
:PivotSplitUp                        - Split up (standard :new) or merge
:PivotSplitDown                      - Split down (standard :new) or merge
:PivotCloseSplit                      - Close current split
:PivotCloseOtherSplits                - Close all splits except current one
:PivotCloseAllSplits                  - Close all splits, keeping only one with empty buffer
:PivotCloseBuffer                     - Smart buffer closing with window management (preserves layout, avoids duplicates)
:PivotCloseOthers                     - Close all other buffers
:PivotCloseAll                        - Close all buffers
:PivotNavigate {next/prev}            - Navigate buffers (next/prev) that are not in other windows
:PivotNavigateSplit {direction}       - Navigate to split in specified direction (left/right/up/down or h/j/k/l)
:PivotMoveBuffer {direction}         - Move current buffer to adjacent split (left/right/up/down or h/j/k/l)
:PivotSwapBuffer {direction}         - Swap buffer with adjacent split, cursor stays (left/right/up/down or h/j/k/l)
```

</details>

## 🧰 Lua API

<details>
<summary>Show Lua API examples</summary>

```lua
local pivot = require('pivot')

-- Examples
pivot.move_buffer_to_split('h')  -- Move buffer to left split (cursor follows)
pivot.swap_buffer_with_split('l') -- Swap buffer with right split (cursor stays)
pivot.close_buffer()              -- Close buffer intelligently
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
  - `smart_splits = true` with `prevent_duplicates = false` (potential duplicates when merging)
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

- **Duplicate buffers appearing in splits?**
  Check that `prevent_duplicates` is enabled.

- **Weird behavior with incomplete keymaps?**
  Make sure you've mapped both sides of paired operations (left/right, previous/next).

Run `:checkhealth pivot` to automatically detect these issues.

</details>
