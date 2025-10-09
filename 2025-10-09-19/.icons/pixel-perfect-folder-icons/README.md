![Screenshot of the theme](preview.png "Preview")

# Pixel Perfect Folder Icons for KDE Plasma

You love your icon theme but the folders don't quite live up to it?
Pixel Perfect folders to the rescue!  

This set includes **more than 80** different **finely crafted** folder icons including 32px versions like: **remote-backup**, **disk-vinyl**, **dev-sass**, **gdrive** and many more!  
The default folder, including colored versions and the kde system-file-manager app, even have pixel perfect resolutions for 22 and 16 pixels.  

Each icon is meticulously drawn to their resolution for that perfect sharp look.

### Installing

Go to `System Settings > Icons > Get New Themes...` and search for `Pixel Perfect`.  
By default the theme inherits from breeze icons first then gnome then deepin and lastly hicolor.  
Changes might not apply instantly. In that case remove `~/.cache/icon-cache.kcache` and relog.

### How to mix with your favorite theme

Adjust line 6 of `index.theme` which can be found at `~/.local/share/icons/pixel-perfect-folders/` or the icon themes directory path of your distribution. It says `Inherits=breeze,gnome,deepin,hicolor`. Put the name of the theme you want to combine directly after the equal sign exactly as it appears on the themes folder.  

This way you can even combine various icon themes. Just put those which have few but very nice icons to inherit first and then put some follow-ups after those.
You could even go completely nerd and add a function to the theme to recursively use specific folders from specific themes, [which is explained in the spec](https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html#icon_lookup).

### License

This project is licensed under the CC-BY-NC-SA - see the [LICENSE](LICENSE) file for details

### Coffee

In the past years I have spent quite some hours on open source projects. If you are the type of person who digs attention to detail, know how much work is involved in it and/or simply likes to support makers with a coffee or a beer I would greatly appreciate your donation on my [PayPayl](https://www.paypal.me/marianarlt) account.
