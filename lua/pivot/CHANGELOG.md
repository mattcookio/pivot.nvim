# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2023-10-15

### Fixed

- Added robust error handling for autocommand group creation
- Fixed 'terminal' option error by adding safe buffer option checking
- Improved Neovim version compatibility with better fallback mechanisms
- Added more graceful error handling for all API calls

## [1.0.1] - 2023-10-12

### Fixed

- Resolved issue with autocommand group creation on older Neovim versions
- Added robust version detection for better compatibility
- Improved health check to verify version compatibility
- Fixed potential error when loading the plugin on Neovim versions below 0.7

### Added

- Better error reporting for plugin initialization issues
- Extended documentation about version compatibility

## [1.0.0] - 2023-10-10
