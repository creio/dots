-----------------------------------------------------------------------------------------------------------------------
--                                       Red Flat calendar desktop widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Multi monitoring widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local os = os
local string = string
local setmetatable = setmetatable

local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")
local timer = require("gears.timer")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local calendar = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		show_pointer = true,
		label        = { gap = 12, font = { font = "Sans", size = 18, face = 1, slant = 0 }, sep = "-" },
		mark         = { height = 20, width = 40, dx = 10, line = 4 },
		color        = { main = "#b1222b", wibox = "#161616", gray = "#404040", bg = "#161616" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.calendar") or {})
end

local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function is_leap_year(year)
	return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

-- Drawing function
-----------------------------------------------------------------------------------------------------------------------
local function daymarks(style)

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	widg._data = {
		gap     = 1,
		label_x = 0,
		pointer = { show = false, index = 1, label = "01-01" },
		days    = 31,
		marks   = 31,
		today   = 1,
		label   = "01-01",
		weekend = { 6, 0 }
	}

	-- User functions
	------------------------------------------------------------
	function widg:update_data()
		local date = os.date('*t')
		local first_week_day = os.date('%w', os.time({ year = date.year, month = date.month, day = 1 }))

		self._data.today = date.day
		self._data.days = date.month == 2 and is_leap_year(date.year) and 29 or days_in_month[date.month]
		self._data.weekend = { (7 - first_week_day) % 7, (8 - first_week_day) % 7 }
		self._data.label = string.format("%.2d%s%.2d", date.day, style.label.sep, date.month)

		self:emit_signal("widget::redraw_needed")
	end

	function widg:update_pointer(show, index)
		self._data.pointer.show = show
		if index then self._data.pointer.index = index end

		local date = os.date('*t')
		self._data.pointer.label = string.format("%.2d%s%.2d", self._data.pointer.index, style.label.sep, date.month)

		self:emit_signal("widget::redraw_needed")
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		return width, height
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width, height)

		-- main draw
		self._data.gap = (height - self._data.days * style.mark.height) / (self._data.days - 1)
		self._data.label_x = width - style.mark.width - style.mark.dx - style.label.gap
		cr:set_line_width(style.mark.line)

		for i = 1, self._data.days do
			-- calendar marks
			local id = i % 7
			local is_weekend = id == self._data.weekend[1] or id == self._data.weekend[2]

			cr:set_source(color(is_weekend and style.color.main or style.color.gray))
			cr:move_to(width, (style.mark.height + self._data.gap) * (i - 1))
			cr:rel_line_to(0, style.mark.height)
			cr:rel_line_to(-style.mark.width, 0)
			cr:rel_line_to(-style.mark.dx, -style.mark.height / 2)
			cr:rel_line_to(style.mark.dx, -style.mark.height / 2)
			cr:close_path()
			cr:fill()

			-- data label
			if i == self._data.today or (self._data.pointer.show and i == self._data.pointer.index) then
				cr:set_source(color(i == self._data.today and style.color.main or style.color.gray))
				local coord_y = ((style.mark.height + self._data.gap) * (i - 1)) + style.mark.height / 2
				redutil.cairo.set_font(cr, style.label.font)

				local ext = cr:text_extents(self._data.label)
				cr:move_to(
					self._data.label_x - (ext.width + 2 * ext.x_bearing), coord_y - (ext.height/2 + ext.y_bearing)
				)
				cr:show_text(i == self._data.today and self._data.label or self._data.pointer.label)
			end
		end
	end

	--------------------------------------------------------------------------------
	return widg
end


-- Create a new widget
-----------------------------------------------------------------------------------------------------------------------
function calendar.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	args = args or {}
	style = redutil.table.merge(default_style(), style or {})
	local timeout = args.timeout or 300

	dwidget.style = style

	-- Create calendar widget
	--------------------------------------------------------------------------------
	dwidget.calendar = daymarks(style)
	dwidget.area = wibox.container.margin(dwidget.calendar)

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = timeout })
	t:connect_signal("timeout", function () dwidget.calendar:update_data() end)
	t:start()
	t:emit_signal("timeout")

	-- Drawing date label under mouse
	--------------------------------------------------------------------------------
	function dwidget:activate_wibox(wbox)
		if style.show_pointer then
			wbox:connect_signal("mouse::move", function(_, x, y)
				local show_poiter = false
				local index

				if x > self.calendar._data.label_x then
					for i = 1, self.calendar._data.days do
						local cy = y - (i - 1) * (self.calendar._data.gap + style.mark.height)
						if cy > 0 and cy < style.mark.height then
							show_poiter = true
							index = i
							break
						end
					end
				end

				if self.calendar._data.pointer.show ~= show_poiter then
					self.calendar:update_pointer(show_poiter, index)
				end
			end)

			wbox:connect_signal("mouse::leave", function()
				if self.calendar._data.pointer.show then self.calendar:update_pointer(false) end
			end)
		end
	end

	--------------------------------------------------------------------------------
	return dwidget
end

-- Config metatable to call module as function
-----------------------------------------------------------------------------------------------------------------------
function calendar.mt:__call(...)
	return calendar.new(...)
end

return setmetatable(calendar, calendar.mt)
