# AnyColorYouLikeSimple
This is simplified fork of [ACYL by pobtott](http://gnome-look.org/content/show.php/?content=102435) -- a highly customizable vector icon pack.

#### Main goals
* Rewrite the codebase with GTK3 and python3;
* Get rid of bash scripts and move all logic to Python scripts;
* Make scripts easy extensible. The user should have easy way to add new filters, icon alternatives, app themes;
* New icons and filters.

#### Screenshots
<img src="https://i.imgur.com/9DtRBrU.png" width="440"> <img src="https://i.imgur.com/XRQesGP.png" width="440">
<img src="https://i.imgur.com/xlih3G0.png" width="440"> <img src="https://i.imgur.com/HtZM5AR.png" width="440">

#### Dependencies
* GTK+ >=3.10
* Python >=3.4
* lxml
* gksu (optional)

#### Current state
Already done:
* Linear and radial gradient;
* Advanced icon preview;
* Icon alternatives switcher;
* Quick view of current state for the whole icon pack;
* Customizable filters;
* Specific application themes;
* Quick filter edit.

Dropped:
* Code view.

Future plans:
* Create test suite;
* More icons.

#### Installation
The easiest way to install icon pack is use git:
```shell
$ git clone https://github.com/worron/ACYLS.git ~/.icons/ACYLS
```
All scripts in this project are fully portable, so you can have as many copies of icon pack as you want. Also you can use a desktop file to provide quick launch of configuration program from your DE app menu. Just copy desktop file to one of designed locations, for example:
```shell
$ cp ~/.icons/ACYLS/desktop/acyls.desktop ~/.local/share/applications
```

#### Usage
To launch configuration program, start this script:
```shell
$ python3 ~/.icons/ACYLS/scripts/run.py
```

Following the application tooltips you will be able to do primary configuration of icon pack. Also see the [documentation](https://github.com/worron/ACYLS/wiki) for deep customization instructions.

Feel free to create an issue if icon for one of your favorite program is missing. Or, you could always try to [create an icon](https://github.com/worron/ACYLS/wiki/Create-new-icon) by yourself.

#### Icon Request
Open issue with following information

* Application homepage or source code link
* Exact icon name

The last one determined by desktop file (usually located in `/usr/share/applications`) 'Icon' option.
