#!/usr/bin/zsh

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx &> /dev/null
# [[ $(fgconsole 2>/dev/null) == 1 ]] && exec startx -- vt1 &> /dev/null

# zmodload zsh/zprof

export PATH=$HOME/.bin:$HOME/.config/rofi/scripts:$HOME/.local/bin:/usr/local/bin:$PATH

export HISTFILE=~/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000

### load zgen
## git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
source "${HOME}/.zgen/zgen.zsh"
if ! zgen saved; then
  echo "Creating a zgen save"
  zgen oh-my-zsh
  # plugins
  zgen load zsh-users/zsh-autosuggestions
  # zgen load zsh-users/zsh-syntax-highlighting
  # zgen load zsh-users/zsh-history-substring-search
  # zgen load zsh-users/zsh-completions src
  zgen load zdharma/fast-syntax-highlighting
  # theme
  zgen oh-my-zsh themes/af-magic
  zgen save
fi

# fzf & fd
[[ -e "/usr/share/fzf/fzf-extras.zsh" ]] && source /usr/share/fzf/fzf-extras.zsh
export FZF_DEFAULT_COMMAND="fd --type file --color=always --follow --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_DEFAULT_OPTS="--ansi"
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --preview 'file {}' --preview-window down:1"
export FZF_COMPLETION_TRIGGER="~~"

export TERM="rxvt-256color"
export EDITOR="$([[ -n $DISPLAY && $(command -v subl3) ]] && echo 'subl3' || echo 'nano')"
export BROWSER="chromium"
export SSH_KEY_PATH="~/.ssh/dsa_id"
export XDG_CONFIG_HOME="$HOME/.config"
export _JAVA_AWT_WM_NONREPARENTING=1

export MANPAGER="sh -c 'sed -e s/.\\\\x08//g | bat -l man -p'"

[[ -f ~/.env ]] && . ~/.env
[[ -f ~/.alias_zsh ]] && . ~/.alias_zsh

export PATH=$HOME/.gem/ruby/2.7.0/bin:$PATH
# export PATH="$PATH:`yarn global bin`"

# export GOPATH=$HOME/.go
# export GOBIN=$GOPATH/bin
# export PATH="$PATH:$GOBIN"

# zprof
