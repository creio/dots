-----------------------------------------------------------------------------------------------------------------------
--                                                   RedFlat library                                                 --
-----------------------------------------------------------------------------------------------------------------------

local wrequire = function(table_, key)
	local module = rawget(table_, key)
	return module or require(table_._NAME .. '.' .. key)
end

local setmetatable = setmetatable

local lib = { _NAME = "redflat.util", wrequire = wrequire }

return setmetatable(lib, { __index = wrequire })
