-----------------------------------------------------------------------------------------------------------------------
--                                                   RedFlat library                                                 --
-----------------------------------------------------------------------------------------------------------------------

local wrequire = require("redflat.util").wrequire
local setmetatable = setmetatable

local lib = { _NAME = "redflat.desktop.common.bar" }

return setmetatable(lib, { __index = wrequire })
