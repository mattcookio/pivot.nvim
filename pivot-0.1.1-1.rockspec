rockspec_format = "3.0"
package = "pivot"
version = "0.1.1-1"
source = {
   url = "git+https://github.com/username/pivot.nvim.git"
}
description = {
   summary = "Advanced buffer and split management for Neovim",
   detailed = [[
      pivot.nvim is a plugin for advanced buffer and split management in Neovim.
      It provides smart functions for creating splits, navigating buffers, 
      and managing window layouts with a consistent interface.
   ]],
   homepage = "https://github.com/username/pivot.nvim",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["pivot"] = "lua/pivot/init.lua",
      ["pivot.config"] = "lua/pivot/config.lua",
      ["pivot.utils"] = "lua/pivot/utils.lua",
      ["pivot.buffers"] = "lua/pivot/buffers.lua",
      ["pivot.splits"] = "lua/pivot/splits.lua",
      ["pivot.commands"] = "lua/pivot/commands.lua",
      ["pivot.health"] = "lua/pivot/health.lua"
   }
}
test_dependencies = {
   "busted >= 2.0.0",
   "luassert >= 1.9.0"
}
test = {
   type = "busted",
} 
