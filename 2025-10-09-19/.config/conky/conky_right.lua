conky.config = {
    alignment = 'top_right',
    background = true,
    default_color = 'a5adff',
    color0 = '494b5a',
    color1 = '494b5a',
    color2 = '494b5a',
    color3 = '23ada0',
    color4 = 'af2445',
    color5 = 'a5adff',
    color6 = 'a5adff',
    cpu_avg_samples = 2,
    diskio_avg_samples = 2,
    double_buffer = true,
    font = 'Ubuntu:size=9:style=regular',
    font2 = 'Ubuntu:size=9:style=bold',
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,
    draw_graph_borders = false,
    border_inner_margin = 0,
    border_outer_margin = 0,
    border_width = 0,
    stippled_borders = 0,
    pad_percents = 0,
    gap_x = 5,
    gap_y = 0,
    maximum_width = 200,
    minimum_width = 200,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_type = 'override',
    own_window_transparent = true,
    update_interval = 1,
    use_xft = true,
    uppercase = false,
}

conky.text = [[

# TIME
${color}${alignc}${font Ubuntu:size=10}${time %H:%M:%S}${font}
${color0}${hr}

# NETWORK
${font2}${color1}NETWORK STATUS${font}
${color}GATEWAY${alignr}${color6}${gw_iface}
${color}GATEWAY IP${alignr}${color5}${gw_ip}
# ${color}MODE# ${alignr}${color4}${wireless_mode enp2s5}
# ${color}ACCESS POINT# ${alignr}${color3}${wireless_ap enp2s5}
# ${color}ESSID# ${alignr}${if_match "${wireless_essid enp2s5}"=="off/any"}${color1}disconnected${else}${color2}${wireless_essid enp2s5}${endif}
# ${color}PUBLIC IP# ${alignr}${color6}${execi 60 curl ipinfo.io/ip}
${color}LOCAL IP${alignr}${color4}${addrs enp2s5}

${color0}${hr}

${font2}${color1}NETWORK TRAFFIC${font}
${color}DOWN${alignr}${color6}${downspeedf enp2s5} KiB/s (${totaldown enp2s5})
${downspeedgraph enp2s5 50,220 af2445 14151f scale 975KiB -l}

${color}UP${alignr}${color6}${upspeedf enp2s5} KiB/s (${totalup enp2s5})
${upspeedgraph enp2s5 50,220 14151f 494a5b scale 100KiB -l}

# CPU USAGE
${font2}${color1}CPU USAGE${font}
${color}PERCENTAGE${alignr}${color3}${cpu}%
${color}PROCESSES${alignr}${color4}${processes}

${color0}${hr}

# CPU FREQ/GRAPH
${font2}${color1}CPU FREQ${alignr}${freq_g}GHz${font}
${loadgraph 80,220 af2445 14151f scale 975KiB -l}

# TOP CPU
${font2}${color1}TOP CPU${alignr}${color0}PID | NAME | CPU${font}
${color}${top pid 1}${goto 55}${color4}${top name 1}${alignr}${color5}${top cpu 1}%
${color}${top pid 2}${goto 55}${color4}${top name 2}${alignr}${color5}${top cpu 2}%
${color}${top pid 3}${goto 55}${color4}${top name 3}${alignr}${color5}${top cpu 3}%
${color}${top pid 4}${goto 55}${color4}${top name 4}${alignr}${color5}${top cpu 4}%
${color}${top pid 5}${goto 55}${color4}${top name 5}${alignr}${color5}${top cpu 5}%
${color}${top pid 6}${goto 55}${color4}${top name 6}${alignr}${color5}${top cpu 6}%
${color}${top pid 7}${goto 55}${color4}${top name 7}${alignr}${color5}${top cpu 7}%

${color0}${hr}

]];
