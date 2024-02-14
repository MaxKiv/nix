-- Neovim config entry point, looks for modules in ./lua/

-- Neovim internal lua interpreter seems to be 5.1
table.unpack = table.unpack or unpack -- 5.1 compatibility

-- "Global" Keymappings
require("mappings")

-- All non plugin related (vim) options
require("options")

-- Vim autocommands/autogroups
require("autocmd")

-- Global functions
require("functions")

-- Plugin management via lazy
require("plugin_manager")

