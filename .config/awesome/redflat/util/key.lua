-- RedFlat util submodule

local unpack = unpack or table.unpack

local table = table
local awful = require("awful")

local key = {}

key.ignored_mod = { "Unknown", "Mod2" }

-- Functions
-----------------------------------------------------------------------------------------------------------------------

-- Build awful keys from reflat raw keys table
------------------------------------------------------------
function key.build(t)
	local temp = {}

	for _, v in ipairs(t) do
		table.insert(temp, awful.key(unpack(v)))
	end

	return awful.util.table.join(unpack(temp))
end

-- Check if redflat raw key matched with awful prompt key
------------------------------------------------------------
function key.match_prompt(rawkey, mod, _key)
	for m, _ in pairs(mod) do
		if awful.util.table.hasitem(key.ignored_mod, m) then
			mod[m] = nil
			break
		end
	end

	local modcheck = true
	local count = 0

	for k, _ in pairs(mod) do
		modcheck = modcheck and awful.util.table.hasitem(rawkey[1], k)
		count = count + 1
	end

	return #rawkey[1] == count and modcheck and _key:lower() == rawkey[2]:lower()
end

-- Check if redflat raw key matched with awful prompt key
------------------------------------------------------------
function key.match_grabber(rawkey, mod, _key)
	for i, m in ipairs(mod) do
		if awful.util.table.hasitem(key.ignored_mod, m) then
			table.remove(mod, i)
			break
		end
	end

	local modcheck = #mod == #rawkey[1]
	for _, v in ipairs(mod) do modcheck = modcheck and awful.util.table.hasitem(rawkey[1], v) end
	return modcheck and _key:lower() == rawkey[2]:lower()
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return key

