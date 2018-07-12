## Installation:<br>
First clone the repository:<br>
```git clone https://github.com/Eayu/sddm-theme-clairvoyance```<br><br>
Make sure that you have sddm, qt5 and fira-mono installed. On arch:<br>
```sudo pacman -S sddm qt5 ttf-fira-mono```<br><br>
Then move it to the sddm-themes directory:<br>
```sudo mv sddm-theme-clairvoyance /usr/share/sddm/themes/clairvoyance```<br><br>
Then set the current theme to clairvoyance in sddm.conf:<br>
```sudo vim /etc/sddm.conf```<br>
and set "Current" equal to "clairvoyance" (no speech marks).

## Video example:
Click the image to see the video:

[![Alt text](clairvoyance_screenshot.png?raw=true "Click to see video")](clairvoyance_example.webm?raw=true)

## Customisation:
There are a few options that you can edit in "theme.conf" - background, autoFocusPassword and enableHDPI.<br><br>
<b>background</b>: set this equal to the path of your background. I would recommend you place your background in the Assets folder and use the relative path (e.g. the default is Assets/background.jpg).<br><br>
<b>autoFocusPassword</b>: set this equal to 'true' (no quotes) to make the password input to automatically focus after you have chosen your user. To focus the password without using this option you can press the TAB key, or click in the area.<br><br>
<b>enableHDPI</b>: set this equal to 'true' (no quotes) to enable HDPI mode - this decreases some of the font-sized as they are automaticaly scaled up, messing up some of the layout. I can't test this myself on a HDPI screen, so if you have any issues, don't be afriad to open an issue.<br>

## Credits

I shamelessly stole the power icons (shutdown restart etc.) from https://github.com/Match-Yang/sddm-deepin .
