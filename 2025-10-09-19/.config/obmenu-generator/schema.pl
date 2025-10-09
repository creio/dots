#!/usr/bin/perl

# obmenu-generator - schema file

=for comment

    item:      add an item inside the menu               {item => ["command", "label", "icon"]},
    cat:       add a category inside the menu             {cat => ["name", "label", "icon"]},
    sep:       horizontal line separator                  {sep => undef}, {sep => "label"},
    pipe:      a pipe menu entry                         {pipe => ["command", "label", "icon"]},
    file:      include the content of an XML file        {file => "/path/to/file.xml"},
    raw:       any XML data supported by Openbox          {raw => q(...)},
    beg:       begin of a category                        {beg => ["name", "icon"]},
    end:       end of a category                          {end => undef},
    obgenmenu: generic menu settings                {obgenmenu => ["label", "icon"]},
    exit:      default "Exit" action                     {exit => ["label", "icon"]},

=cut

# NOTE:
#    * Keys and values are case sensitive. Keep all keys lowercase.
#    * ICON can be a either a direct path to an icon or a valid icon name
#    * Category names are case insensitive. (X-XFCE and x_xfce are equivalent)

require "$ENV{HOME}/.config/obmenu-generator/config.pl";

## Text editor
my $editor = $CONFIG->{editor};

our $SCHEMA = [

    {sep => 'CTLOS'},

    #          COMMAND                 LABEL              ICON
    {item => ['xdg-open .',       'Файловый Менеджер',  'system-file-manager']},
    {item => ['xfce4-terminal',   'Терминал',           'utilities-terminal']},
    {item => ['xdg-open http://', 'Браузер',            'web-browser']},
    {item => ['rofi -show drun',  'Лаунчер',            'system-run']},

    {sep => 'Категории'},

    #          NAME            LABEL                ICON
    {cat => ['utility',     'Инструменты', 'applications-utilities']},
    {cat => ['development', 'Разработка', 'applications-development']},
    {cat => ['education',   'Образование',   'applications-science']},
    {cat => ['game',        'Игры',       'applications-games']},
    {cat => ['graphics',    'Графика',    'applications-graphics']},
    {cat => ['audiovideo',  'Мультимедиа',  'applications-multimedia']},
    {cat => ['network',     'Интернет',     'applications-internet']},
    {cat => ['office',      'Офис',      'applications-office']},
    {cat => ['other',       'Прочие',       'applications-other']},
    {cat => ['settings',    'Настройки',    'applications-accessories']},
    {cat => ['system',      'Системные',      'applications-system']},

    #                  LABEL          ICON
    #{beg => ['My category',  'cat-icon']},
    #          ... some items ...
    #{end => undef},

    #            COMMAND     LABEL        ICON
    #{pipe => ['obbrowser', 'Disk', 'drive-harddisk']},

    ## Generic advanced settings
    #{sep       => undef},
    #{obgenmenu => ['Openbox Settings', 'applications-engineering']},
    #{sep       => undef},

    ## Custom advanced settings
    {sep => undef},
    {beg => ['Общие Настройки', 'applications-engineering']},

      # Configuration files
      {item => ["$editor ~/.conkyrc",              'Conky RC',    'text-x-generic']},
      {item => ["$editor ~/.config/tint2/tint2rc", 'Tint2 Panel', 'text-x-generic']},

      # obmenu-generator category
      {beg => ['Obmenu-Generator', 'accessories-text-editor']},
        {item => ["$editor ~/.config/obmenu-generator/schema.pl", 'Menu Schema', 'text-x-generic']},
        {item => ["$editor ~/.config/obmenu-generator/config.pl", 'Menu Config', 'text-x-generic']},

        {sep  => undef},
        {item => ['obmenu-generator -s -c',    'Сгенерировать статическое меню',             'accessories-text-editor']},
        {item => ['obmenu-generator -s -i -c', 'Сгенерировать статическое меню с иконками',  'accessories-text-editor']},
        {sep  => undef},
        {item => ['obmenu-generator -p',       'Сгенерировать динамическое меню',            'accessories-text-editor']},
        {item => ['obmenu-generator -p -i',    'Сгенерировать динамическое меню с иконками', 'accessories-text-editor']},
        {sep  => undef},

        {item => ['obmenu-generator -d', 'Перезапустить cache', 'view-refresh']},
      {end => undef},

      # Openbox category
      {beg => ['Openbox', 'openbox']},
        {item => ["$editor ~/.config/openbox/autostart", 'Openbox Autostart',   'text-x-generic']},
        {item => ["$editor ~/.config/openbox/rc.xml",    'Openbox RC',          'text-x-generic']},
        {item => ["$editor ~/.config/openbox/menu.xml",  'Openbox Menu',        'text-x-generic']},
        {item => ['openbox --reconfigure',               'Reconfigure Openbox', 'openbox']},
        {item => ['openbox --restart',                   'Restart Openbox', 'openbox']},
      {end => undef},
    {end => undef},

    {sep => undef},

    ## The xscreensaver lock command
    {item => ['i3lock-fancy', 'Заблокировать экран', 'system-lock-screen']},

    ## This option uses the default Openbox's "Exit" action
    # {exit => ['Exit', 'application-exit']},

    ## This uses the 'oblogout' menu
    {item => ['oblogout', 'Выйти из системы', 'application-exit']},
]
