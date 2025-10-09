import subprocess
import sys, os

def read_xresources(prefix):
    props = {}
    x = subprocess.run(['xrdb', '-query'], stdout=subprocess.PIPE)
    lines = x.stdout.decode().split('\n')
    for line in filter(lambda l : l.startswith(prefix), lines):
        prop, _, value = line.partition(':\t')
        props[prop] = value
    return props

def clamp(val, minimum=0, maximum=255):
    if val < minimum:
        return minimum
    if val > maximum:
        return maximum
    return val

def adjust(hexstr, scalefactor):
    hexstr = hexstr.strip('#')
    if scalefactor < 0 or len(hexstr) != 6:
        return hexstr

    r, g, b = int(hexstr[:2], 16), int(hexstr[2:4], 16), int(hexstr[4:], 16)
    r = int(clamp(r * scalefactor))
    g = int(clamp(g * scalefactor))
    b = int(clamp(b * scalefactor))

    return "#%02x%02x%02x" % (r, g, b)

xresources = read_xresources('*')

config.load_autoconfig()

# config.bind(',p', 'spawn --userscript qute-pass --username-target secret')
# config.bind(',u', 'spawn --userscript qute-pass --username-target secret --username-only')
# config.bind(',P', 'spawn --userscript qute-pass --username-target secret --password-only')
config.bind(',p', 'spawn --userscript qute-bitwarden')
config.bind(',u', 'spawn --userscript qute-bitwarden --username-only')
config.bind(',P', 'spawn --userscript qute-bitwarden --password-only')

config.bind(';V', 'spawn mpv {url}')
config.bind(';v', 'hint links spawn mpv {hint-url}')
config.bind(',v', 'hint links spawn umpv {hint-url}')
config.bind(',V', 'hint --rapid links spawn umpv {hint-url}')

config.bind('<Ctrl-r>', 'restart')
config.bind('<Ctrl-Alt-Left>', 'back')
config.bind('<Ctrl-Alt-Right>', 'forward')
config.bind('<Ctrl-Right>', 'tab-next')
config.bind('<Ctrl-Left>', 'tab-prev')
config.bind('<Ctrl-Shift-Right>', 'tab-move +')
config.bind('<Ctrl-Shift-Left>', 'tab-move -')
config.bind('t', 'set-cmd-text -s :open -t')

c.tabs.background = False
# c.tabs.background = True
# config.bind(',t', 'hint -r links tab')

# aliases
c.aliases['ge'] = 'open -t https://wiki.archlinux.org/index.php/Forum_Etiquette'
c.aliases['gf'] = 'open -t http://flickr.com/jasonwryan '
c.aliases['gj'] = 'open -t http://jasonwryan.com'
c.aliases['gp'] = 'open -t http://127.0.0.1:4000'
c.aliases['gr'] = 'open -t https://feedbin.com/'

c.colors.completion.category.bg                 = xresources['*.background']
c.colors.completion.category.border.bottom      = xresources['*.color8']
c.colors.completion.category.border.top         = xresources['*.color0']
c.colors.completion.category.fg                 = xresources['*.color8']
c.colors.completion.even.bg                     = xresources['*.background']
c.colors.completion.item.selected.bg            = xresources['*.color0']
c.colors.completion.item.selected.border.bottom = xresources['*.color0']
c.colors.completion.item.selected.border.top    = xresources['*.color0']
c.colors.completion.item.selected.fg            = xresources['*.color7']
c.colors.completion.match.fg                    = xresources['*.color7']
c.colors.completion.odd.bg                      = xresources['*.background']
c.colors.completion.scrollbar.bg                = xresources['*.background']
c.colors.completion.scrollbar.fg                = xresources['*.color2']

c.colors.downloads.bar.bg    = xresources['*.color0']
c.colors.downloads.error.bg  = xresources['*.color1']
c.colors.downloads.error.fg  = xresources['*.color7']
c.colors.downloads.start.bg  = xresources['*.color2']
c.colors.downloads.start.fg  = xresources['*.color7']
c.colors.downloads.stop.bg   = xresources['*.background']
c.colors.downloads.stop.fg   = xresources['*.color7']
c.colors.downloads.system.bg = 'none'
c.colors.downloads.system.fg = 'none'

c.colors.hints.fg       = xresources['*.color0']
c.colors.hints.match.fg = xresources['*.color2']

c.colors.messages.error.bg       = xresources['*.color1']
c.colors.messages.error.border   = xresources['*.color1']
c.colors.messages.error.fg       = xresources['*.color7']
c.colors.messages.info.bg        = xresources['*.color0']
c.colors.messages.info.border    = xresources['*.color0']
c.colors.messages.info.fg        = xresources['*.color7']
c.colors.messages.warning.bg     = xresources['*.color1']
c.colors.messages.warning.border = xresources['*.color1']
c.colors.messages.warning.fg     = xresources['*.color7']

c.colors.prompts.bg          = xresources['*.background']
c.colors.prompts.border      = '1px solid gray'
c.colors.prompts.fg          = xresources['*.color7']
c.colors.prompts.selected.bg = xresources['*.background']

c.colors.statusbar.caret.bg             = xresources['*.color5']
c.colors.statusbar.caret.fg             = xresources['*.color7']
c.colors.statusbar.caret.selection.bg   = '#a12dff'
c.colors.statusbar.caret.selection.fg   = xresources['*.color7']
c.colors.statusbar.command.bg           = xresources['*.color0']
c.colors.statusbar.command.fg           = xresources['*.color7']
c.colors.statusbar.command.private.bg   = xresources['*.color7']
c.colors.statusbar.command.private.fg   = xresources['*.color7']
c.colors.statusbar.insert.bg            = xresources['*.background']
c.colors.statusbar.insert.fg            = xresources['*.color7']
c.colors.statusbar.normal.bg            = xresources['*.color0']
c.colors.statusbar.normal.fg            = xresources['*.foreground']
c.colors.statusbar.passthrough.bg       = xresources['*.color4']
c.colors.statusbar.passthrough.fg       = xresources['*.foreground']
c.colors.statusbar.private.bg           = '#666666'
c.colors.statusbar.private.fg           = xresources['*.foreground']
c.colors.statusbar.progress.bg          = xresources['*.color7']
c.colors.statusbar.url.fg               = xresources['*.foreground']
c.colors.statusbar.url.hover.fg         = xresources['*.color6']
c.colors.statusbar.url.success.https.fg = adjust(xresources['*.foreground'], 0.7)
c.colors.statusbar.url.warn.fg          = xresources['*.color3']


c.colors.tabs.bar.bg           = xresources['*.background']
c.colors.tabs.even.bg          = adjust(xresources['*.background'], 1.15)
c.colors.tabs.even.fg          = xresources['*.color7']
c.colors.tabs.indicator.error  = '#ff0000'
c.colors.tabs.odd.bg           = adjust(xresources['*.background'], 1.35)
c.colors.tabs.odd.fg           = xresources['*.color7']
c.colors.tabs.selected.even.bg = adjust(xresources['*.color0'], 1.35)
c.colors.tabs.selected.even.fg = xresources['*.color7']
c.colors.tabs.selected.odd.bg  = adjust(xresources['*.color0'], 1.35)
c.colors.tabs.selected.odd.fg  = xresources['*.color7']

c.url.searchengines = {'DEFAULT': 'https://gg.ctlos.ru/search?q={}', 'd': 'https://duckduckgo.com/?q={}', 'sp': 'https://www.startpage.com/do/search?q={}', 'g': 'https://www.google.com/search?q={}', 'w': 'https://en.wikipedia.org/wiki/{}'}

# c.url.start_pages = "/home/asdd/startpage/index.html"
c.url.default_page = "https://creio.github.io/dots/sp.html"

# yay -S python-adblock
c.content.blocking.method = "adblock"
c.content.blocking.adblock.lists = [
		"https://easylist.to/easylist/easylist.txt",
		"https://easylist.to/easylist/easyprivacy.txt",
		"https://easylist.to/easylist/fanboy-social.txt",
		"https://secure.fanboy.co.nz/fanboy-annoyance.txt",
		"https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt",
		#"https://gitlab.com/curben/urlhaus-filter/-/raw/master/urlhaus-filter.txt",
		"https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/legacy.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2021.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/badware.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt",
		"https://www.i-dont-care-about-cookies.eu/abp/",
		"https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
		"https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt"
]
c.content.blocking.enabled = True
c.content.blocking.hosts.lists = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"]
c.content.blocking.whitelist = []
