-----------------------------------------------------------------------------------------------------------------------
--                                        RedFlat binary clock widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Why not?
-----------------------------------------------------------------------------------------------------------------------

local setmetatable = setmetatable
local os = os

local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local color = require("gears.color")

local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local binclock = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width   = 60,
		tooltip = {},
		dot     = { size = 5 },
		color   = { main = "#b1222b", gray = "#575757" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.binclock") or {})
end


-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function binary_time(num)
	local binary = {}
	for i = 6, 1, -1 do
		local rest = num % 2
		binary[i] = rest
		num = math.floor((num - rest) / 2)
	end
	return binary
end


-- Create widget.
-----------------------------------------------------------------------------------------------------------------------
function binclock.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	args = args or {}
	local timeout = args.timeout or 60
	style = redutil.table.merge(default_style(), style or {})

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	widg._data = {
		time = { {}, {}, {} },
		width = style.width or nil
	}

	-- User functions
	------------------------------------------------------------
	function widg:update()
		local date = os.date('*t')
		self._data.time = { binary_time(date.hour), binary_time(date.min), binary_time(date.sec) }

		self:emit_signal("widget::redraw_needed")
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		if self._data.width then
			return math.min(width, self._data.width), height
		else
			return width, height
		end
	end

	function widg:draw(_, cr, width, height)
		local dx = (width - style.dot.size) / 5
		local dy = (height - style.dot.size) / 2

		for i = 1, 3 do
			for j = 1, 6 do
				cr:set_source(color(self._data.time[i][j] == 1 and style.color.main or style.color.gray ))
				cr:rectangle((j -1) * dx, (i -1) * dy, style.dot.size, style.dot.size)
				cr:fill()
			end
		end
	end

	-- Set tooltip if need
	--------------------------------------------------------------------------------
	local tp
	if args.dateformat then tp = tooltip({ objects = { widg } }, style.tooltip) end

	-- Set update timer
	--------------------------------------------------------------------------------
	local timer = gears.timer({ timeout = timeout })
	timer:connect_signal("timeout",
		function()
			widg:update()
			if args.dateformat then tp:set_text(os.date(args.dateformat)) end
		end)
	timer:start()
	timer:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call textclock module as function
-----------------------------------------------------------------------------------------------------------------------
function binclock.mt:__call(...)
	return binclock.new(...)
end

return setmetatable(binclock, binclock.mt)
