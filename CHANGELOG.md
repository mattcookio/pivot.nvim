# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - YYYY-MM-DD

### Added

- **Full-Span Splits:** New commands (`SplitFullRight`, `SplitFullLeft`, `SplitFullUp`, `SplitFullDown`) and keymaps (default: `<leader>sl/h/j/k`) to create splits that span the full editor height or width, regardless of current layout.
- Window equalization (`wincmd =`) is automatically applied after full-span splits to distribute window sizes evenly.

### Changed

- **Smart Split Keymaps:** Default keymaps for existing smart/layout-aware splits are now `<leader>sL/H/J/K` (using capital letters) to differentiate them from the new full-span splits.
- **Split Logic:** Refactored standard split behavior (`split_move_*`) to more reliably replace the buffer in the original window with a fallback buffer when available.
- **Window Equalization:** The `wincmd =` command after full-span splits is now deferred using `vim.schedule` for improved reliability.

### Removed

- **History Limit:** Removed the `history_limit` configuration option. Window buffer history is now effectively unlimited.

---

## [Unreleased] - YYYY-MM-DD

### Added

- Initial release of "pivot.nvim"
- Smart split creation (creating appropriate empty buffers vs. moving current buffer)
- Context-aware split creation and merging
- Window-aware buffer history tracking
- Smart buffer navigation (skipping buffers visible in other windows)
- Smart buffer closing with window management
- Full parity between buffer and split commands
- Buffer movement keymaps with 'b' prefix (e.g., '<leader>bh')
- Improved error handling for all operations
- Enhanced performance for large buffer lists
- Command registration with configurable prefix
- Customizable keymaps for all operations
- Full test suite
- Comprehensive documentation with examples
- Health check for plugin verification
- Robust version detection for better compatibility with older Neovim versions

#### Split Management Commands

- `split_move_right/left/up/down` - Create splits with intelligent buffer placement
- `smart_split` - Create or merge splits based on context
- `close_split` - Close current split
- `close_other_splits` - Close all splits except current
- `close_all_splits` - Close all splits, keeping one

#### Buffer Management Commands

- `close_buffer` - Smart buffer closing (preserves layout)
- `close_other_buffers` - Close all other buffers
- `close_all_buffers` - Close all buffers
- `navigate_all_buffers` - Navigate through buffers, skipping those visible in other windows
- `move_buffer_to_split` - Move buffer to split in specified direction
- `merge_buffer_direction` - Merge into adjacent split
