-----------------------------------------------------------------------------------------------------------------------
--                                          RedFlat hotkeys helper widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with list of hotkeys
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local math = math
local unpack = unpack or table.unpack

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local timer = require("gears.timer")

local redflat = require("redflat")
local redutil = require("redflat.util")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = { keypack = {}, lastkey = nil, cache = {}, boxes = {} }
local hasitem = awful.util.table.hasitem

-- key bindings
hotkeys.keys = { close = { "Escape" }, close_all = { "Super_L" } }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry      = { width = 800 },
		border_margin = { 10, 10, 10, 10 },
		tspace        = 5,
		delim         = "   ",
		border_width  = 2,
		ltimeout      = 0.05,
		font          = "Sans 12",
		keyfont       = "Sans bold 12",
		titlefont     = "Sans bold 14",
		is_align      = false,
		separator     = {},
		heights       = { key = 20, title = 24 },
		color         = { border = "#575757", text = "#aaaaaa", main = "#b1222b", wibox = "#202020",
		                  gray = "#575757" },
		shape         = nil
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "float.hotkeys") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Calculate keytip length
--------------------------------------------------------------------------------
local function check_key_len(k)
	local res = k.key:len()
	for _, v in pairs(k.mod) do res = res + v:len() + 1 end
	return res
end

-- Parse raw key table
--------------------------------------------------------------------------------
local keysort = function(a, b)
	if a.length ~= b.length then
		return a.length < b.length
	else
		return a.key < b.key
	end
end

local function parse(rawkeys, columns)
	local keys = {}
	columns = columns or 1

	local rk = {}
	for _, k in ipairs(rawkeys) do if k[#k].description then table.insert(rk, k) end end
	local p = math.ceil(#rk / columns)

	-- dirty trick for raw sorting
	local sp = {}
	for _, v in ipairs(rk) do
		if not hasitem(sp, v[#v].group) then table.insert(sp, v[#v].group) end
	end
	table.sort(rk, function(a, b)
		local ai, bi = hasitem(sp, a[#a].group), hasitem(sp, b[#b].group)
		if ai ~= bi then
			return ai < bi
		else
			return a[2] < b[2]
		end
	end)

	-- split keys to columns
	for i = 1, columns do
		keys[i] = { groups = {}, length = nil, names = {} }
		local chunk = { unpack(rk, 1, p) }
		rk = { unpack(rk, p + 1) }

		-- build key column
		for _, v in ipairs(chunk) do
			local data = v[#v]
			local k = {
				mod = v[1], key = v[2],
				description = data.description,
				group       = data.group,
				keyset      = data.keyset or { v[2] },
				length      = check_key_len({ mod = v[1], key = v[2] })
			}

			if not keys[i].groups[k.group] then
				keys[i].groups[k.group] = {}
				table.insert(keys[i].names, k.group) -- sorted names list to save group order
			end
			table.insert(keys[i].groups[k.group], k)

			-- calculate max tip lenght
			if not keys[i].length or keys[i].length < k.length then keys[i].length = k.length end
		end

		-- sort key by lenght inside group
		for _, group in pairs(keys[i].groups) do table.sort(group, keysort) end
	end

	return keys
end

-- Form hotkeys helper text
--------------------------------------------------------------------------------
local function build_tip(pack, style, keypressed)
	local text = {}

	for i, column in ipairs(pack) do
		local coltxt = {}
		local height = 0

		for _, name in pairs(column.names) do
			local group = column.groups[name]

			-- set group title
			coltxt[#coltxt + 1] = string.format(
				'<span font="%s" color="%s">%s</span>',
				style.titlefont, style.color.gray, name
			)
			height = height + style.heights.title

			-- build key tip line
			for _, key in ipairs(group) do

				-- key with align
				local line = string.format('<b>%s</b>', key.key)
				if style.is_align then
					--noinspection StringConcatenationInLoops
					line = line .. string.rep(" ", column.length - key.length)
				end

				-- key with mods
				if #key.mod > 0 then
					local fm = {}
					for ki, v in ipairs(key.mod) do fm[ki] = string.format('<b>%s</b>', v) end
					table.insert(fm, line)
					line = table.concat(fm, string.format('<span color="%s">+</span>', style.color.gray))
				end

				-- key with description
				local clr = keypressed and hasitem(key.keyset, keypressed) and style.color.main or style.color.text
				line = string.format(
					'<span color="%s"><span font="%s">%s</span>%s%s</span>',
					clr, style.keyfont, line, style.delim, key.description
				)
				coltxt[#coltxt + 1] = line
				height = height + style.heights.key
			end
		end

		text[i] = { text = table.concat(coltxt, '\n'), height = height }
	end

	return text
end

-- Initialize widget
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init()

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = default_style()
	self.style = style
	self.tip = {}

	-- summary vertical size for all elements except tip textboxes
	-- used to auto adjust widget height
	self.vertical_pag = style.border_margin[3] + style.border_margin[4] + style.tspace + 2
	if style.separator.marginh then
		self.vertical_pag = self.vertical_pag + style.separator.marginh[3] + style.separator.marginh[4]
	end

	-- alias
	local bm = style.border_margin

	-- Create floating wibox for top widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})

	self.wibox:geometry(style.geometry)

	-- Widget layout setup
	--------------------------------------------------------------------------------
	self.layout = wibox.layout.flex.horizontal()

	self.title = wibox.widget.textbox("Title")
	self.title:set_align("center")
	self.title:set_font(style.titlefont)

	local _, th = self.title:get_preferred_size()
	self.vertical_pag = self.vertical_pag + th

	local subtitle = wibox.widget.textbox("Press any key to highlight tip, Escape for exit")
	subtitle:set_align("center")

	local _, sh = subtitle:get_preferred_size()
	self.vertical_pag = self.vertical_pag + sh

	self.wibox:setup({
		{
			{
				self.title,
				subtitle,
				redflat.gauge.separator.horizontal(style.separator),
				spacing = style.tspace,
				layout = wibox.layout.fixed.vertical,
			},
			self.layout,
			layout = wibox.layout.align.vertical,
		},
		left = bm[1], right = bm[2], top = bm[3], bottom = bm[4],
		layout = wibox.container.margin,
	})

	-- Highlight timer
	--------------------------------------------------------------------------------
	local ltimer = timer({ timeout = style.ltimeout })
	ltimer:connect_signal("timeout",
		function()
			ltimer:stop()
			self:highlight()
		end
	)

	-- Keygrabber
	--------------------------------------------------------------------------------
	self.keygrabber = function(_, key, event)
		if event == "release" then
			if hasitem(self.keys.close, key) then
				self:hide(); return
			end

			if hasitem(self.keys.close_all, key) then
				self:hide()
				if self.keypack[#self.keypack].on_close then self.keypack[#self.keypack].on_close() end
				return
			end
		end

		self.lastkey = event == "press" and key or nil
		ltimer:again()
	end
end


-- Keypack managment
-----------------------------------------------------------------------------------------------------------------------

-- Set new keypack
--------------------------------------------------------------------------------
function hotkeys:set_pack(name, pack, columns, geometry, on_close)
	if not self.wibox then self:init() end

	if not self.cache[name] then self.cache[name] = parse(pack, columns) end
	table.insert(
		self.keypack,
		{ name = name, pack = self.cache[name], geometry = geometry or self.style.geometry, on_close = on_close }
	)
	self.title:set_text(name .. " hotkeys")
	self:highlight()
	self:update_geometry(self.keypack[#self.keypack].geometry)
end

-- Remove current keypack
--------------------------------------------------------------------------------
function hotkeys:remove_pack()
	table.remove(self.keypack)
	self.title:set_text(self.keypack[#self.keypack].name .. " hotkeys")
	self:highlight()
	self:update_geometry(self.keypack[#self.keypack].geometry)
end

-- Calculate and set widget height
--------------------------------------------------------------------------------
function hotkeys:update_geometry(predefined)
	local height = 0
	for _, column in ipairs(self.tip) do height = math.max(height, column.height) end

	self.wibox:geometry({ width = predefined.width, height = predefined.height or height + self.vertical_pag })
end

-- Highlight key tip
--------------------------------------------------------------------------------
function hotkeys:highlight()
	self.tip = build_tip(self.keypack[#self.keypack].pack, self.style, self.lastkey)

	self.layout:reset()
	for i, column in ipairs(self.tip) do
		if not self.boxes[i] then
			self.boxes[i] = wibox.widget.textbox()
			self.boxes[i]:set_valign("top")
			self.boxes[i]:set_font(self.style.font)
		end

		self.boxes[i]:set_markup(column.text)
		self.layout:add(self.boxes[i])
	end
end


-- Show/hide widget
-----------------------------------------------------------------------------------------------------------------------

-- show
function hotkeys:show()
	if not self.wibox then self:init() end

	if not self.wibox.visible then
		redutil.placement.centered(self.wibox, nil, mouse.screen.workarea)
		self.wibox.visible = true
		awful.keygrabber.run(self.keygrabber)
	-- else
	-- 	self:hide()
	end
end

-- hide
function hotkeys:hide()
	self.wibox.visible = false
	self.lastkey = nil
	self:highlight()
	awful.keygrabber.stop(self.keygrabber)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
