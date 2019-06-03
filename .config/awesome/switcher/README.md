awesome-switcher
================

This plugin integrates the familiar application switcher functionality in the
[awesome window manager](https://github.com/awesomeWM/awesome).

![Screenshot of awesome-switcher](screenshot.gif)

Features:

* Live previews while alt-tabbing AND/OR Opacity effects for unselected clients
* Easily adjustable settings
* No previews when modifier (e.g.: Alt) is released within some time-frame
* Backward cycle using second modifier (e.g.: Shift)
* Intuitive order, respecting your client history
* Includes minimized clients (in contrast to some of the default window-switching utilies)
* Preview selectable by mouse

## Installation ##

Clone the repo into your `$XDG_CONFIG_HOME/awesome` directory:

```Shell
cd "$XDG_CONFIG_HOME/awesome"
git clone https://github.com/berlam/awesome-switcher.git awesome-switcher
```

Then add the dependency to your Awesome `rc.lua` config file:

```Lua
    local switcher = require("awesome-switcher")
```

## Configuration ##

Optionally edit any subset of the following settings, the defaults are:

```Lua
    switcher.settings.preview_box = true,                                 -- display preview-box
    switcher.settings.preview_box_bg = "#ddddddaa",                       -- background color
    switcher.settings.preview_box_border = "#22222200",                   -- border-color
    switcher.settings.preview_box_fps = 30,                               -- refresh framerate
    switcher.settings.preview_box_delay = 150,                            -- delay in ms
    switcher.settings.preview_box_title_font = {"sans","italic","normal"},-- the font for cairo
    switcher.settings.preview_box_title_font_size_factor = 0.8,           -- the font sizing factor
    switcher.settings.preview_box_title_color = {0,0,0,1},                -- the font color
    
    switcher.settings.client_opacity = false,                             -- opacity for unselected clients
    switcher.settings.client_opacity_value = 0.5,                         -- alpha-value for any client
    switcher.settings.client_opacity_value_in_focus = 0.5,                -- alpha-value for the client currently in focus
    switcher.settings.client_opacity_value_selected = 1,                  -- alpha-value for the selected client

    switcher.settings.cycle_raise_client = true,                          -- raise clients on cycle
```

Then add key-bindings. On my particular system I switch to the next client by Alt-Tab and
back with Alt-Shift-Tab. Therefore, this is what my keybindings look like:

```Lua
    awful.key({ "Mod1",           }, "Tab",
      function ()
          switcher.switch( 1, "Mod1", "Alt_L", "Shift", "Tab")
      end),
    
    awful.key({ "Mod1", "Shift"   }, "Tab",
      function ()
          switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
      end),
```

Please keep in mind that "Mod1" and "Shift" are actual modifiers and not real keys.
This is important for the keygrabber as the keygrabber uses "Shift_L" for a pressed (left) "Shift" key.

## Credits ##

This plugin was created by [Joren Heit](https://github.com/jorenheit)
and later improved upon by [Matthias Berla](https://github.com/berlam).

## License ##

See [LICENSE](LICENSE).
