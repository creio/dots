-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat titlebar                                                   --
-----------------------------------------------------------------------------------------------------------------------
-- model titlebar with two view: light and full
-- Only simple indicators avaliable, no buttons
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.titlebar v3.5.2
------ (c) 2012 Uli Schlachter
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local error = error
local table = table
local unpack = unpack or table.unpack

local awful = require("awful")
local drawable = require("wibox.drawable")
local color = require("gears.color")
local wibox = require("wibox")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = { mt = {}, widget = {}, _index = 1, _num = 1 }
titlebar.list = setmetatable({}, { __mode = 'k' })


-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local default_style = {
	size          = 8,
	position      = "top",
	font          = "Sans 12 bold",
	border_margin = { 0, 0, 0, 4 },
	color         = { main = "#b1222b", wibox = "#202020", gray = "#575757",
	                  text = "#aaaaaa", icon = "#a0a0a0", urgent = "#32882d" }
}

local default_mark_style = {
	size  = 20,
	angle = 0,
	color = default_style.color
}

local default_button_style = {
	list  = { unknown = redutil.base.placeholder({ txt = "X" }) },
	color = default_style.color
}

local positions = { "left", "right", "top", "bottom" }

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Get titlebar function
------------------------------------------------------------
local function get_titlebar_function(c, position)
	if     position == "left"   then return c.titlebar_left
	elseif position == "right"  then return c.titlebar_right
	elseif position == "top"    then return c.titlebar_top
	elseif position == "bottom" then return c.titlebar_bottom
	else
		error("Invalid titlebar position '" .. position .. "'")
	end
end

-- Get titlebar model
------------------------------------------------------------
function titlebar.get_model(c, position)
	position = position or "top"
	return titlebar.list[c] and titlebar.list[c][position] or nil
end

-- Get titlebar client list
------------------------------------------------------------
function titlebar.get_clients()
	local cl = {}
	for c, _ in pairs(titlebar.list) do table.insert(cl, c) end
	return cl
end


-- Build client titlebar
-----------------------------------------------------------------------------------------------------------------------
function titlebar.new(c, style)
	if not titlebar.list[c] then titlebar.list[c] = {} end
	style = redutil.table.merge(default_style, style or {})

	-- Make sure that there is never more than one titlebar for any given client
	local ret
	if not titlebar.list[c][style.position] then
		local tfunction = get_titlebar_function(c, style.position)
		local d = tfunction(c, style.size)

		local context = { client = c, position = style.position }
		local base = wibox.container.margin(nil, unpack(style.border_margin))

		ret = drawable(d, context, "redbar")
		ret:_inform_visible(true)
		ret:set_bg(style.color.wibox)

		-- add info to model
		local model = {
			layouts = {},
			current = nil,
			style = style,
			size = style.size,
			drawable = ret,
			hidden = false,
			cutted = false,
			tfunction = tfunction,
			base = base,
		}

		-- set titlebar base layout
		ret:set_widget(base)

		-- save titlebar info
		titlebar.list[c][style.position] = model
		c:connect_signal("unmanage", function() ret:_inform_visible(false) end)
	else
		ret = titlebar.list[c][style.position].drawable
	end

	return ret
end

-- Titlebar functions
-----------------------------------------------------------------------------------------------------------------------

-- Show client titlebar
------------------------------------------------------------
function titlebar.show(c, position)
	local model = titlebar.get_model(c, position)
	if model and model.hidden then
		model.hidden = false
		model.tfunction(c, not model.cutted and model.size or 0)
	end
end

-- Hide client titlebar
------------------------------------------------------------
function titlebar.hide(c, position)
	local model = titlebar.get_model(c, position)
	if model and not model.hidden then
		model.tfunction(c, 0)
		model.hidden = true
	end
end

-- Toggle client titlebar
------------------------------------------------------------
function titlebar.toggle(c, position)
	local all_positions = position and { position } or positions
	for _, pos in ipairs(all_positions) do
		local model = titlebar.get_model(c, pos)
		if model then
			model.tfunction(c, model.hidden and not model.cutted and model.size or 0)
			model.hidden = not model.hidden
		end
	end
end

-- Add titlebar view model
------------------------------------------------------------
function titlebar.add_layout(c, position, layout, size)
	local model = titlebar.get_model(c, position)
	if not model then return end

	size = size or model.style.size
	local l = { layout = layout, size = size }
	table.insert(model.layouts, l)
	if #model.layouts > titlebar._num then titlebar._num = #model.layouts end

	if not model.current then
		model.base:set_widget(layout)
		model.current = 1
		if model.size ~= size then
			model.tfunction(c, size)
			model.size = size
		end
	end
end

-- Switch titlebar view model
------------------------------------------------------------
function titlebar.switch(c, position, index)
	local model = titlebar.get_model(c, position)
	if not model or #model.layouts == 1 then return end

	if index then
		if not model.layouts[index] then return end
		model.current = index
	else
		model.current = (model.current < #model.layouts) and (model.current + 1) or 1
	end
	local layout = model.layouts[model.current]

	model.base:set_widget(layout.layout)
	if not model.cutted and not model.hidden and model.size ~= layout.size then
		model.tfunction(c, layout.size)
	end
	model.size = layout.size
end


-- Titlebar mass actions
-----------------------------------------------------------------------------------------------------------------------

-- Temporary hide client titlebar
------------------------------------------------------------
function titlebar.cut_all(cl, position)
	cl = cl or titlebar.get_clients()
	--local cutted = {}
	local all_positions = position and { position } or positions

	for _, pos in ipairs(all_positions) do
		for _, c in ipairs(cl) do
			local model = titlebar.get_model(c, pos)
			if model and not model.cutted then
				model.cutted = true
				--table.insert(cutted, c)
				if not model.hidden then model.tfunction(c, 0) end
			end
		end
	end
	--return cutted
end

-- Restore client titlebar if it was cutted
------------------------------------------------------------
function titlebar.restore_all(cl, position)
	cl = cl or titlebar.get_clients()
	local all_positions = position and { position } or positions
	for _, pos in ipairs(all_positions) do
		for _, c in ipairs(cl) do
			local model = titlebar.get_model(c, pos)
			if model and model.cutted then
				model.cutted = false
				if not model.hidden then model.tfunction(c, model.size) end
			end
		end
	end
end

-- Mass actions
------------------------------------------------------------
function titlebar.toggle_all(cl, position)
	cl = cl or titlebar.get_clients()
	for _, c in pairs(cl) do titlebar.toggle(c, position) end
end

--function titlebar.switch_all(cl, position)
--	cl = cl or titlebar.get_clients()
--	for _, c in pairs(cl) do titlebar.switch(c, position) end
--end

function titlebar.show_all(cl, position)
	cl = cl or titlebar.get_clients()
	for _, c in pairs(cl) do titlebar.show(c, position) end
end

function titlebar.hide_all(cl, position)
	cl = cl or titlebar.get_clients()
	for _, c in pairs(cl) do titlebar.hide(c, position) end
end

-- Global layout switch
------------------------------------------------------------
function titlebar.global_switch(index)
	titlebar._index = index or titlebar._index + 1
	if titlebar._index > titlebar._num then titlebar._index = 1 end

	for _, c in pairs(titlebar.get_clients()) do
		for _, position in ipairs(positions) do
			titlebar.switch(c, position, titlebar._index)
		end
	end
end


-- Titlebar indicators
-----------------------------------------------------------------------------------------------------------------------
titlebar.mark = {}
titlebar.button = {}

-- Client mark blank
------------------------------------------------------------
function titlebar.mark.base(_, style)

	-- build widget
	local widg = wibox.widget.base.make_widget()
	widg._data = { color = style.color.gray }
	widg._style = redutil.table.merge(default_mark_style, style or {})

	-- widget setup
	function widg:fit(_, _, width, height)
		return width, height
	end

	function widg:draw(_, cr, width, height)
		local d = math.tan(self._style.angle) * height

		cr:set_source(color(self._data.color))
		cr:move_to(0, height)
		cr:rel_line_to(d, - height)
		cr:rel_line_to(width - d, 0)
		cr:rel_line_to(-d, height)
		cr:close_path()

		cr:fill()
	end

	-- user function
	function widg:set_active(active)
		self._data.color = active and style.color.main or style.color.gray
		self:emit_signal("widget::redraw_needed")
	end

	-- widget width setup
	widg:set_forced_width(style.size)

	return widg
end

-- Client property indicator
------------------------------------------------------------
function titlebar.mark.property(c, prop, style)
	local w = titlebar.mark.base(c, style)
	w:set_active(c[prop])
	c:connect_signal("property::" .. prop, function() w:set_active(c[prop]) end)
	return w
end

-- Client focus indicator
------------------------------------------------------------
function titlebar.mark.focus(c, style)
	local w = titlebar.mark.base(c, style)
	c:connect_signal("focus", function() w:set_active(true) end)
	c:connect_signal("unfocus", function() w:set_active(false) end)
	return w
end

-- Client button blank
------------------------------------------------------------
function titlebar.button.base(icon, style, is_inactive)
	style = redutil.table.merge(default_button_style, style or {})

	-- widget
	local widg = svgbox(style.list[icon] or style.list.unknown)
	widg._current_color = style.color.icon
	widg.is_under_mouse = false

	-- state
	function widg:set_active(active)
		widg._current_color = active and style.color.main or style.color.icon
		widg:set_color(widg.is_under_mouse and style.color.urgent or widg._current_color)
		--self:emit_signal("widget::redraw_needed")
	end

	local function update(is_under_mouse)
		widg.is_under_mouse = is_under_mouse
		widg:set_color(widg.is_under_mouse and style.color.urgent or widg._current_color)
	end

	if not is_inactive then
		widg:connect_signal("mouse::enter", function() update(true) end)
		widg:connect_signal("mouse::leave", function() update(false) end)
	end

	widg:set_active(false)
	return widg
end

-- Client focus button
------------------------------------------------------------
function titlebar.button.focus(c, style)
	local w = titlebar.button.base("focus", style, true)
	c:connect_signal("focus", function() w:set_active(true) end)
	c:connect_signal("unfocus", function() w:set_active(false) end)
	return w
end

-- Client property button
------------------------------------------------------------
function titlebar.button.property(c, prop, style)
	local w = titlebar.button.base(prop, style)
	w:set_active(c[prop])
	w:buttons(awful.util.table.join(awful.button({ }, 1, function() c[prop] = not c[prop] end)))
	c:connect_signal("property::" .. prop, function() w:set_active(c[prop]) end)
	return w
end

-- Client close button
------------------------------------------------------------
function titlebar.button.close(c, style)
	local w = titlebar.button.base("close", style)
	w:buttons(awful.util.table.join(awful.button({ }, 1, function() c:kill() end)))
	return w
end

-- Client name indicator
------------------------------------------------------------
function titlebar.label(c, style, is_highlighted)
	style = redutil.table.merge(default_style, style or {})
	local w = wibox.widget.textbox()
	w:set_font(style.font)
	w:set_align("center")
	w._current_color = style.color.text

	local function update()
		local txt = awful.util.escape(c.name or "Unknown")
		w:set_markup(string.format('<span color="%s">%s</span>', w._current_color, txt))
	end
	c:connect_signal("property::name", update)

	if is_highlighted then
		c:connect_signal("focus", function() w._current_color = style.color.main; update() end)
		c:connect_signal("unfocus", function() w._current_color = style.color.text; update()end)
	end

	update()
	return w
end


-- Remove from list on close
-----------------------------------------------------------------------------------------------------------------------
client.connect_signal("unmanage", function(c) titlebar.list[c] = nil end)


-- Config metatable to call titlebar module as function
-----------------------------------------------------------------------------------------------------------------------
function titlebar.mt:__call(...)
	return titlebar.new(...)
end

return setmetatable(titlebar, titlebar.mt)
