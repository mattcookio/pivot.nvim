# buff.nvim Test Suite

This directory contains tests for the buff.nvim plugin using the [busted](https://olivinelabs.com/busted/) testing framework with [luassert](https://github.com/Olivine-Labs/luassert) for assertions.

## Requirements

To run these tests, you need to install:

1. Lua 5.1+ or LuaJIT
2. busted (testing framework)
3. luassert (assertion library)

You can install these dependencies using LuaRocks:

```bash
# Global installation
luarocks install busted
luarocks install luassert

# Or local installation with --local flag
luarocks install --local busted
luarocks install --local luassert
```

## Running Tests

The easiest way to run the tests is to use the provided shell script:

```bash
# Make the script executable (first time only)
chmod +x run_tests.sh

# Run all tests
./run_tests.sh

# Run a specific test file
./run_tests.sh tests/buff_spec.lua
```

Alternatively, you can run the tests manually, ensuring your Lua path is set correctly:

```bash
# Set up Lua path to find the modules
export LUA_PATH="./?.lua;./lua/?.lua;./lua/?/init.lua;${LUA_PATH:-;;}"

# Run from the plugin root directory
busted tests/

# Or run a specific test file
busted tests/buff_spec.lua
```

## Test Structure

The tests are organized into several sections:

- **Setup Tests**: Verify configuration loading and option handling
- **Buffer Operations**: Test buffer navigation and management
- **Split Operations**: Test split creation, closing, and management
- **Buffer Movement**: Test moving buffers between splits
- **Utility Functions**: Test helper functions

## Mock Implementation

The tests use a mock implementation of the Neovim API to avoid dependencies on an actual Neovim instance. The `setup_vim_mock()` function creates a mock environment that simulates the behavior of the `vim` global object.

## Adding New Tests

When adding new tests:

1. Use the existing structure and patterns
2. Mock any additional Neovim API functions needed
3. Test both success and error cases
4. Verify all code paths in the implementation

## Troubleshooting

If you encounter module not found errors:

1. Verify that all required packages are installed (`busted` and `luassert`)
2. Use the provided shell script which sets up the correct Lua path
3. If running tests manually, ensure your `LUA_PATH` includes the plugin's directories:
   ```bash
   export LUA_PATH="./?.lua;./lua/?.lua;./lua/?/init.lua;${LUA_PATH:-;;}"
   ```

## Continuous Integration

These tests can be integrated into a CI workflow to ensure plugin reliability across changes. A sample GitHub Actions workflow is included in the `.github/workflows` directory.

## Debugging Tests

To debug test failures, you can run busted with the verbose flag:

```bash
# Using the script
./run_tests.sh tests/buff_spec.lua -v

# Or directly
busted -v tests/
```

For more detailed output, including stack traces:

```bash
busted --verbose --output=TAP tests/
```
