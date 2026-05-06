-- Kickstart-based personal Neovim config.
--
-- Core editor behavior lives in lua/custom/core.lua.
-- Plugin build hooks live in lua/custom/pack.lua.
-- Plugins are split into lua/custom/plugins/*.lua and loaded deterministically.

require 'custom.core'
require 'custom.pack'
require 'custom.plugins'

-- vim: ts=2 sts=2 sw=2 et
