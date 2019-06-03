-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat ber pack widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Group of upright indicators placed in horizontal layout
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable

local wibox = require("wibox")
--local beautiful = require("beautiful")

local progressbar = require("redflat.desktop.common.bar.shaped")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local barpack = { mt = {} }

-- Create a new barpack widget
-- @param num Number of indicators
-- @param style Style variables for redflat shaped progressbar widget
-----------------------------------------------------------------------------------------------------------------------
function barpack.new(num, style)

	local pack = {}
	style = style or {}

	-- construct group of bar indicators
	pack.layout = wibox.layout.align.horizontal()
	local flex_horizontal = wibox.layout.flex.horizontal()
	local crn = {}

	for i = 1, num do
		crn[i] = progressbar(style)
		if i == 1 then
			pack.layout:set_left(crn[i])
		else
			local bar_space = wibox.layout.align.horizontal()
			bar_space:set_right(crn[i])
			flex_horizontal:add(bar_space)
		end
	end
	pack.layout:set_middle(flex_horizontal)

	-- setup functions
	function pack:set_values(values, n, tip)
		if n then
			if crn[n] then
				crn[n]:set_value(values)
				if tip then crn[n]:set_tip(tip) end
			end
		else
			for i, v in ipairs(values) do
				if crn[i] then
					crn[i]:set_value(v)
					if tip then crn[n]:set_tip(tip) end
				end
			end
		end
	end

	return pack
end

-- Config metatable to call barpack module as function
-----------------------------------------------------------------------------------------------------------------------
function barpack.mt:__call(...)
	return barpack.new(...)
end

return setmetatable(barpack, barpack.mt)
