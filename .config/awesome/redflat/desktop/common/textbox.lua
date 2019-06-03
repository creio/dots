-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat textbox widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Custom textbox for desktop widgets
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local color = require("gears.color")
local beautiful = require("beautiful")

local redutil = require("redflat.util")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local textbox = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width     = nil,
		height    = nil,
		draw      = "by_left",
		separator = '%s',
		color     = "#404040",
		font      = { font = "Sans", size = 20, face = 0, slant = 0 }
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.common.textbox") or {})
end

-- Text alignment functions
-----------------------------------------------------------------------------------------------------------------------
local align = {}

function align.by_left(cr, _, _, text)
	local ext = cr:text_extents(text)
	--cr:move_to(0, height)
	cr:move_to(0, ext.height)
	cr:show_text(text)
end

function align.by_right(cr, width, _, text)
	local ext = cr:text_extents(text)
	--cr:move_to(width - (ext.width + ext.x_bearing), height)
	cr:move_to(width - (ext.width + ext.x_bearing), ext.height)
	cr:show_text(text)
end

function align.by_edges(cr, width, height, text, style)
	local left_text, right_text = string.match(text, "(.+)" .. style.separator .. "(.+)")
	if left_text and right_text then
		align.by_left(cr, width, height, left_text)
		align.by_right(cr, width, height, right_text)
	else
		align.by_right(cr, width, height, text)
	end
end

function align.by_width(cr, width, _, text)
	local ext = cr:text_extents(text)
	local text_gap = (width - ext.width - ext.x_bearing)/(#text - 1)
	local gap = 0

	for i = 1, #text do
		local c = string.sub(text, i, i)
		--cr:move_to(gap, height)
		cr:move_to(gap, ext.height)
		cr:show_text(c)

		local c_ext = cr:text_extents(c)
		gap = gap + text_gap + c_ext.width + c_ext.x_bearing
		-- !!! WORKAROUND for space character width only for font size = 24 font = "Play bold" !!!
		--if c == " " then
		--  gap = gap + 6
		--end
	end
end

-- Create a new textbox widget
-- @param txt Text to display
-- @param style.text Table containing font parameters
-- @param style.color Font color
-- @param style.draw Text align method
-- @param style.width Widget width (optional)
-- @param style.height Widget height (optional)
-----------------------------------------------------------------------------------------------------------------------
function textbox.new(txt, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})
--	local textdraw = align[style.draw] or align.by_left

	-- Create custom widget
	--------------------------------------------------------------------------------
	local textwidg = wibox.widget.base.make_widget()
	textwidg._data = {
		text = txt or "",
		width = style.width,
		color = style.color
	}

	-- User functions
	------------------------------------------------------------
	function textwidg:set_text(text)
		if self._data.text ~= text then
			self._data.text = text
			self:emit_signal("widget::redraw_needed")
		end
	end

	function textwidg:set_color(value)
		if self._data.color ~= value then
			self._data.color = value
			self:emit_signal("widget::redraw_needed")
		end
	end

	function textwidg:set_width(width)
		if self._data.width ~= width then
			self._data.width = width
			self:emit_signal("widget::redraw_needed")
		end
	end

	-- Fit
	------------------------------------------------------------
	function textwidg:fit(_, width, height)
		local w = self._data.width and math.min(self._data.width, width) or width
		local h = style.height and math.min(style.height, height) or height
		return w, h
	end

	-- Draw
	------------------------------------------------------------
	function textwidg:draw(_, cr, width, height)
		cr:set_source(color(self._data.color))
		redutil.cairo.set_font(cr, style.font)

		align[style.draw](cr, width, height, self._data.text, style)
	end

	--------------------------------------------------------------------------------
	return textwidg
end

-- Config metatable to call textbox module as function
-----------------------------------------------------------------------------------------------------------------------
function textbox.mt:__call(...)
	return textbox.new(...)
end

return setmetatable(textbox, textbox.mt)
