-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat layoutbox widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Paintbox widget used to display layout
-- Layouts menu added
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.layoutbox v3.5.2
------ (c) 2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs = ipairs
local table = table
local awful = require("awful")
local layout = require("awful.layout")
local beautiful = require("beautiful")

local redmenu = require("redflat.menu")
local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local layoutbox = { mt = {} }

local last_tag

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon       = { unknown = redutil.base.placeholder() },
		micon      = { blank = redutil.base.placeholder({ txt = " " }),
		               check = redutil.base.placeholder({ txt = "+" }) },
		name_alias = {},
		menu       = { color = { right_icon = "#a0a0a0", left_icon = "#a0a0a0" } },
		color      = { icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.layoutbox") or {})
end

-- Initialize layoutbox
-----------------------------------------------------------------------------------------------------------------------
function layoutbox:init(layouts, style)

	style = style or default_style()

	-- Set tooltip
	------------------------------------------------------------
	layoutbox.tp = tooltip({})

	-- Construct layout list
	------------------------------------------------------------
	local items = {}
	for _, l in ipairs(layouts) do
		local layout_name = layout.getname(l)
		local icon = style.icon[layout_name] or style.icon.unknown
		local text = style.name_alias[layout_name] or layout_name
		table.insert(items, { text, function() layout.set (l, last_tag) end, icon, style.micon.blank })
	end

	-- Update tooltip function
	------------------------------------------------------------
	function self:update_tooltip(layout_name)
		self.tp:set_text(style.name_alias[layout_name] or layout_name)
	end

	-- Update menu function
	------------------------------------------------------------
	function self:update_menu(t)
		local cl = awful.tag.getproperty(t, "layout")
		for i, l in ipairs(layouts) do
			local mark = cl == l and style.micon.check or style.micon.blank
			if self.menu.items[i].right_icon then
				self.menu.items[i].right_icon:set_image(mark)
			end
		end
	end

	-- Initialize menu
	------------------------------------------------------------
	self.menu = redmenu({ theme = style.menu, items = items })
end

-- Show layout menu
-----------------------------------------------------------------------------------------------------------------------
function layoutbox:toggle_menu(t)
	if self.menu.wibox.visible and t == last_tag then
		self.menu:hide()
	else
		if self.menu.wibox.visible then self.menu.wibox.visible = false end
		awful.placement.under_mouse(self.menu.wibox)
		awful.placement.no_offscreen(self.menu.wibox)

		last_tag = t
		self.menu:show({coords = {x = self.menu.wibox.x, y = self.menu.wibox.y}})
		self:update_menu(last_tag)
	end
end

-- Create a layoutbox widge
-- @param screen The screen number that the layout will be represented for
-- @param layouts List of layouts
-----------------------------------------------------------------------------------------------------------------------
function layoutbox.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	args = args or {}
	local layouts = args.layouts or awful.layout.layouts
	local s = args.screen or 1
	style = redutil.table.merge(default_style(), style or {})
	local w = svgbox()
	w:set_color(style.color.icon)

	if not layoutbox.menu then layoutbox:init(layouts, style) end

	-- Set tooltip
	--------------------------------------------------------------------------------
	layoutbox.tp:add_to_object(w)

	-- Update function
	--------------------------------------------------------------------------------
	local function update()
		local layout_name = layout.getname(layout.get(s))
		w:set_image(style.icon[layout_name] or style.icon.unknown)
		layoutbox:update_tooltip(layout_name)

		if layoutbox.menu.wibox.visible then
			layoutbox:update_menu(last_tag)
		end
	end

	-- Set signals
	--------------------------------------------------------------------------------
	tag.connect_signal("property::selected", update)
	tag.connect_signal("property::layout", update)
	w:connect_signal("mouse::enter",
		function()
			local layout_name = layout.getname(layout.get(s))
			layoutbox:update_tooltip(layout_name)
		end
	)
	w:connect_signal("mouse::leave",
		function()
			if layoutbox.menu.hidetimer and layoutbox.menu.wibox.visible then
				layoutbox.menu.hidetimer:start()
			end
		end
	)

	--------------------------------------------------------------------------------
	update()
	return w
end

-- Config metatable to call layoutbox module as function
-----------------------------------------------------------------------------------------------------------------------
function layoutbox.mt:__call(...)
	return layoutbox.new(...)
end

return setmetatable(layoutbox, layoutbox.mt)
