-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat svg icon widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Imagebox widget modification
-- Use Gtk PixBuf API to resize svg image
-- Color setup added
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ wibox.widget.imagebox v3.5.2
------ (c) 2010 Uli Schlachter
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local string = string
local type = type
local pcall = pcall
local print = print
local math = math

-- local Gdk = require("lgi").Gdk
-- local pixbuf = require("lgi").GdkPixbuf
-- local cairo = require("lgi").cairo
local base = require("wibox.widget.base")
local surface = require("gears.surface")
local color = require("gears.color")

local pixbuf
local function load_pixbuf()
	local _ = require("lgi").Gdk
	pixbuf = require("lgi").GdkPixbuf
end
local is_pixbuf_loaded = pcall(load_pixbuf)

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local svgbox = { mt = {} }

-- weak table is useless here
-- TODO: implement mechanics to clear cache
local cache = setmetatable({}, { __mode = 'k' })

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Check if given argument is SVG file
local function is_svg(args)
	return type(args) == "string" and string.match(args, "%.svg")
end

-- Check if need scale image
local function need_scale(widg, width, height)
	return (widg._image.width ~= width or widg._image.height ~= height) and widg.resize_allowed
end

-- Cache functions
local function get_cache(file, width, height)
	return cache[file .. "-" .. width .. "x" .. height]
end

local function set_cache(file, width, height, surf)
	cache[file .. "-" .. width .. "x" .. height] = surf
end

-- Get cairo pattern
local function get_current_pattern(cr)
	cr:push_group()
	cr:paint()
	return cr:pop_group()
end

-- Create Gdk PixBuf from SVG file with given sizes
local function pixbuf_from_svg(file, width, height)
	local cached = get_cache(file, width, height)

	if cached then
		return cached
	else
		-- naughty.notify({ text = file })
		local buf = pixbuf.Pixbuf.new_from_file_at_scale(file, width, height, true)
		set_cache(file, width, height, buf)
		return buf
	end
end

-- Returns a new svgbox
-----------------------------------------------------------------------------------------------------------------------
function svgbox.new(image, resize_allowed, newcolor)

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_image(image_name)
		local loaded_image

		if type(image_name) == "string" then
			local success, result = pcall(surface.load, image_name)
			if not success then
				print("Error while reading '" .. image_name .. "': " .. result)
				return false
			end
			self.image_name = image_name
			loaded_image = result
		else
			loaded_image = surface.load(image_name)
		end

		if loaded_image and (loaded_image.height <= 0 or loaded_image.width <= 0) then return false end

		self._image = loaded_image
		self.is_svg = is_svg(image_name)

		self:emit_signal("widget::redraw_needed")
		return true
	end

	function widg:set_color(new_color)
		if self.color ~= new_color then
			self.color = new_color
			self:emit_signal("widget::redraw_needed")
		end
	end

	function widg:set_resize(allowed)
		self.resize_allowed = allowed
		self:emit_signal("widget::redraw_needed")
	end

	function widg:set_vector_resize(allowed)
		self.vector_resize_allowed = allowed
		self:emit_signal("widget::redraw_needed")
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		local fw, fh = self:get_forced_width(), self:get_forced_height()
		if fw or fh then
			return fw or width, fh or height
		else
			if not self._image then return 0, 0 end

			local w, h = self._image.width, self._image.height

			if self.resize_allowed or w > width or h > height then
				local aspect = math.min(width / w, height / h)
				return w * aspect, h * aspect
			end

			return w, h
		end
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width, height)
		if width == 0 or height == 0 or not self._image then return end

		local w, h = self._image.width, self._image.height
		local aspect = math.min(width / w, height / h)

		cr:save()
		-- let's scale the image so that it fits into (width, height)
		if need_scale(self, width, height) then
			if self.is_svg and self.vector_resize_allowed and is_pixbuf_loaded then
				-- for vector image
				local pixbuf_ = pixbuf_from_svg(self.image_name, math.floor(w * aspect), math.floor(h * aspect))
				cr:set_source_pixbuf(pixbuf_, 0, 0)
			else
				-- for raster image
				cr:scale(aspect, aspect)
				cr:set_source_surface(self._image, 0, 0)
				cr:scale(1/aspect, 1/aspect) -- fix this !!!
			end
		else
			cr:set_source_surface(self._image, 0, 0)
		end

		-- set icon color if need
		if self.color then
			local pattern = get_current_pattern(cr)
			cr:scale(aspect, aspect) -- fix this !!!
			cr:set_source(color(self.color))
			cr:scale(1/aspect, 1/aspect) -- fix this !!!
			cr:mask(pattern, 0, 0)
		else
			cr:paint()
		end

		cr:restore()
	end

	--------------------------------------------------------------------------------
	if resize_allowed ~= nil then
		widg.resize_allowed = resize_allowed
	else
		widg.resize_allowed = true
	end

	widg.color = newcolor
	widg.vector_resize_allowed = true

	if image then widg:set_image(image) end

	return widg
end

-- Config metatable to call svgbox module as function
-----------------------------------------------------------------------------------------------------------------------
function svgbox.mt:__call(...)
	return svgbox.new(...)
end

return setmetatable(svgbox, svgbox.mt)
