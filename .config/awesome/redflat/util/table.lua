-- RedFlat util submodule

local awful = require("awful")

local table_ = {}

-- Functions
-----------------------------------------------------------------------------------------------------------------------

-- Merge two table to new one
------------------------------------------------------------
function table_.merge(t1, t2)
	local ret = awful.util.table.clone(t1)

	for k, v in pairs(t2) do
		if type(v) == "table" and ret[k] and type(ret[k]) == "table" then
			ret[k] = table_.merge(ret[k], v)
		else
			ret[k] = v
		end
	end

	return ret
end

-- Check if deep key exists
------------------------------------------------------------
function table_.check(t, s)
	local v = t

	for key in string.gmatch(s, "([^%.]+)(%.?)") do
		if v[key] then
			v = v[key]
		else
			return nil
		end
	end

	return v
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return table_

