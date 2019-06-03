-- RedFlat util submodule

local cairo = require("lgi").cairo
local gears = require("gears")
local wibox = require("wibox")
local surface = require("gears.surface")

local base = {}

-- Functions
-----------------------------------------------------------------------------------------------------------------------

-- Advanced buttons setup
-- Copypasted from awful.widget.common
-- (c) 2008-2009 Julien Danjou
--------------------------------------------------------------------------------
function base.buttons(buttons, object)
	if buttons then
		local btns = {}

		for _, b in ipairs(buttons) do
			-- Create a proxy button object: it will receive the real
			-- press and release events, and will propagate them the the
			-- button object the user provided, but with the object as
			-- argument.
			local btn = button { modifiers = b.modifiers, button = b.button }
			btn:connect_signal("press", function () b:emit_signal("press", object) end)
			btn:connect_signal("release", function () b:emit_signal("release", object) end)
			btns[#btns + 1] = btn
		end

		return btns
	end
end

-- Create cairo surface from text (useful for themed icons replacement)
--------------------------------------------------------------------------------
function base.placeholder(args)
	args = args or {}
	local tb = wibox.widget({
		markup = args.txt or "?",
		align  = "center",
		valign = "center",
		widget = wibox.widget.textbox
	})

	return surface.widget_to_surface(tb, args.width or 24, args.height or 24)
end

-- Create rectangle cairo surface image
--------------------------------------------------------------------------------
function base.image(width, height, geometry, color)
	local image = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
	local cr = cairo.Context(image)
	cr:set_source(gears.color(color or "#000000"))
	cr:rectangle(geometry.x, geometry.y, geometry.width, geometry.height)
	cr:fill()

	return image
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return base

