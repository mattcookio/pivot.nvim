#!/bin/bash

# run_tests.sh - Script to run all tests for pivot.nvim
# Usage: ./run_tests.sh [test_file]

# Make the script exit on error
set -e

# Change to the script directory
cd "$(dirname "$0")"

# Set up environment
echo "Setting up environment for tests..."
# This allows the tests to find the modules more reliably
export LUA_PATH="./?.lua;./lua/?.lua;./lua/?/init.lua;${LUA_PATH:-;;}"

# Run all tests or specific test file
if [ -z "$1" ]; then
  echo "Running all tests..."
  busted tests/
else
  echo "Running test file: $1"
  busted "$1"
fi 
