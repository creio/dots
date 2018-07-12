## Left Prompt
function fish_prompt
    # Set the annoying greeting to empty
    set fish_greeting
    printf $USER
    set_color red
    echo -n '@'
    echo -n (prompt_hostname)
    echo -n ' '
    set -l last_status $status
    # Show the current working directory
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    echo -n ' >'
    set_color normal
    printf '%s ' (__fish_git_prompt)
    set_color normal
end
## Right Prompt
function fish_right_prompt
    set_color black
    echo -n (date +"%H:%M")
    set_color normal
end
## Window title
function fish_title
    echo -n 'fish in '
    prompt_pwd
end

# fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
# Status Chars
set __fish_git_prompt_char_dirtystate '⚡'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'

## Keybinding
set fish_key_bindings fish_default_key_bindings

# 
set --export PATH $HOME/.bin $PATH

set --export EDITOR "vim -f"
set --export TERM "xterm-256color"
# set --export TERM "rxvt-unicode-256color"
set --export EDITOR "subl3"
set --export BROWSER "chromium"
set --export SSH_KEY_PATH "~/.ssh/dsa_id"
set --export API_TOKEN "nope"



## Aliases
alias mi "micro"
alias merge "xrdb -merge $HOME/.Xresources"
alias xcolor "xrdb -query | grep"
alias vga 'lspci -k | grep -A 2 -E "(VGA|3D)"'
alias upgrub "sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias iip "curl --max-time 10 -w '\n' http://ident.me"
alias tb "nc termbin.com 9999"

#alias neo "neofetch"
alias neo "neofetch --w3m ~/.config/neofetch/cn.jpg"
# alias neo "neofetch --kitty ~/.config/neofetch/cn.jpg"
# alias neo "neofetch --w3m"

# alias wtr "curl 'wttr.in/Москва?M&lang=ru'"
# alias wtr "curl 'wttr.in/Москва?M&lang=ru' | sed -n '1,17p'"
# alias wtr "curl 'wttr.in/?M1npQ&lang=ru'"
alias moon "curl 'wttr.in/Moon'"

alias ls "ls --color=auto"
alias ll "ls -alFh --color=auto"
alias la "ls -a --color=auto"
alias l "ls -CF --color=auto"

alias mk "mkdir"
alias .. "cd .."
alias ... "cd ../.."
alias :q "exit"

alias gh "cd ~/files/github"
alias ctliso "cd ~/files/github/ctlosiso"
alias ghc "cd ~/files/github/creio"
alias ghcd "cd ~/files/github/creio/dots"
alias gl "cd ~/files/gitlab"
alias glc "cd ~/files/gitlab/creio"

alias gi "git init"
alias gs "git status"
alias glog "git log --stat --pretty=oneline --graph --date=short"
alias gg "gitg &"
alias gad "git add --all"
alias gr "git remote"
alias gf "git fetch"
alias gpl "git pull"
alias gp "git push"
alias gpm "git push origin master"
alias ghab "$BROWSER http://github.com/ctlos &"

alias torc "$BROWSER --proxy-server='socks://127.0.0.1:9050' &"
alias yt "youtube-viewer"
alias porn "mpv 'http://www.pornhub.com/random'"
alias mvis "ncmpcpp -S visualizer"
alias m "ncmpcpp"
alias rss "newsboat"

alias st "$EDITOR"
alias sst "sudo $EDITOR"
alias tm "tmux attach || tmux new -s work"
alias tmd "tmux detach"
alias tmk "tmux kill-server"
alias fm "ranger"
alias sfm "sudo ranger"
alias sth "sudo thunar ."
alias th "thunar . &"
alias na "nautilus . &"
alias sna "sudo nautilus ."
alias h "htop"
alias vim "nvim"
alias vi "nvim"

alias packey "sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman-key --refresh-keys && sudo pacman -Syy"
alias sp "sudo pacman -S"
alias spU "sudo pacman -U"
alias sps "sudo pacman -Ss"
alias spc "sudo pacman -Sc"
alias spcc "sudo pacman -Scc"
alias spy "sudo pacman -Syy"
alias spu "sudo pacman -Syu"
alias spr "sudo pacman -R"

alias y "yay -S"
alias yn "yay -S --noconfirm"
alias ys "yay"
alias ysn "yay --noconfirm"
alias yc "yay -Sc"
alias ycc "yay -Scc"
alias yy "yay -Syy"
alias yu "yay -Syu"
alias yun "yay -Syu --noconfirm"
alias yr "yay -R"
alias yrn "yay -R --noconfirm"
alias ygpg "yay --mflags '--nocheck --skippgpcheck --noconfirm'"
alias ynskip "yay --mflags --skipinteg --noconfirm"

alias ve "virtualenv ve"
alias vea "source ve/bin/activate"
alias ved "deactivate"
alias pipr "pip install -r requirements.txt"



## function
# fzf
function zzh
    du -a ~/ | awk '{print $2end' | fzf | xargs -r $EDITOR
end
function zz
    du -a . | awk '{print $2end' | fzf | xargs -r $EDITOR
end

function hcat
    cat $argv | less -m -N
end

# share vbox В локальной машине mkdir vboxshare
# в виртуалке uid={имя пользователяend git={группаend
function vboxshare
    mkdir vboxshare
    sudo mount -t vboxsf -o rw,uid=1000,gid=1000 vboxshare vboxshare
    # sudo mount -t vboxsf -o rw,uid=st,gid=users vboxshare vboxshare
end

# aur pkg
function aget
    git clone https://aur.archlinux.org/$argv.git
    # curl -fO https://aur.archlinux.org/cgit/aur.git/snapshot/$argv.tar.gz
end

# build and install pkg from aur
function abuild
    cd ~/.build
    git clone https://aur.archlinux.org/$argv.git
    # curl -fO https://aur.archlinux.org/cgit/aur.git/snapshot/$argv.tar.gz
    # tar -xvf $argv.tar.gz
    cd $argv
    makepkg -si --skipinteg
    cd ~
    # rm -rf ~/.build/$argv ~/.build/$argv.tar.gz
    rm -rf ~/.build/$argv
end

function wtr
    curl "wttr.in/Gomel?M'$argv'npQ&lang=ru"
    # curl "wttr.in/Москва?M$argvnpQ&lang=ru"
end
function wts
    curl "wttr.in/'$argv'?M&lang=ru"
end

function mkj
    mkdir -p $argv
    cd $argv
end

function gc
    git clone $argv
end
function gcj
    git clone $argv
    cd $argv
    $EDITOR .
end

function gac
    git add --all
    git commit -am $argv
end

function ytv
    youtube-viewer $argv
end

# youtube-dl --ignore-errors -o '~/Видео/youtube/%(playlist)s/%(title)s.%(ext)s' https://www.youtube.com/playlist?list=PL-UzghgfytJQV-JCEtyuttutudMk7
# Загрузка Видео ~/Videos или ~/Видео
# Пример: dlv https://www.youtube.com/watch?v=gBAfejjUQoA
function ytv
    youtube-dl --ignore-errors -o '~/Videos/youtube/%(title)s.%(ext)s' $argv
end
# dlp https://www.youtube.com/playlist?list=PL-UzghgfytJQV-JCEtyuttutudMk7
function ytp
    youtube-dl --ignore-errors -o '~/Videos/youtube/%(playlist)s/%(title)s.%(ext)s' $argv
end

# Загрузка аудио ~/Music или ~/Музыка
# Пример: mp3 https://www.youtube.com/watch?v=gBAfejjUQoA
function mp3
    youtube-dl --ignore-errors -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o '~/Music/youtube/%(title)s.%(ext)s' $argv
end
# mp3p https://www.youtube.com/watch?v=-F7A24f6gNc&list=RD-F7A24f6gNc
function mp3p
    youtube-dl --ignore-errors -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o '~/Music/youtube/%(playlist)s/%(title)s.%(ext)s' $argv
end

function pf
    peerflix $argv --mpv
end

function wgetw
    wget -rkx $argv
end