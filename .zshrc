#!/usr/bin/zsh

# ALERT="telegram alert bot"
# curl -s -X POST https://api.telegram.org/bot$TOKEN_TG/sendMessage -d chat_id=$CHAT_ID_TG -d text="$ALERT"

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx &> /dev/null
# [[ $(fgconsole 2>/dev/null) == 1 ]] && exec startx -- vt1 &> /dev/null

# zmodload zsh/zprof
export PATH=$HOME/.bin:$HOME/.local/bin:$HOME/.config/rofi/scripts:$PATH

export HISTFILE=~/.zhistory
export HISTSIZE=3000
export SAVEHIST=3000

# export LC_ALL=en_US.UTF-8
# export LANG=en_US.UTF-8

autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# ohmyzsh
export ZSH="/usr/share/oh-my-zsh"
ZSH_THEME="af-magic"
DISABLE_AUTO_UPDATE="true"
ZSH_TMUX_AUTOSTART="false"
plugins=()
ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
[[ ! -d $ZSH_CACHE_DIR ]] && mkdir -p $ZSH_CACHE_DIR
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=white"

# fzf & fd
[[ -e /usr/share/fzf/fzf-extras.zsh ]] && source /usr/share/fzf/fzf-extras.zsh
export FZF_DEFAULT_COMMAND="fd --type file --color=always --follow --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_DEFAULT_OPTS="--ansi"
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --preview 'file {}' --preview-window down:1"
export FZF_COMPLETION_TRIGGER="~~"

# export TERM="rxvt-256color"
export TERM="xterm-256color"
export SSH_KEY_PATH="~/.ssh/dsa_id"
export XDG_CONFIG_HOME="$HOME/.config"
export _JAVA_AWT_WM_NONREPARENTING=1

# export GPG_TTY=$(tty)

[[ $(command -v bat) ]] && export MANPAGER="sh -c 'sed -e s/.\\\\x08//g | bat -l man -p'"

[[ -s ~/.env ]] && . ~/.env
[[ -s ~/.env_borg ]] && . ~/.env_borg
[[ -f ~/.alias_zsh ]] && . ~/.alias_zsh

### https://wiki.archlinux.org/title/RVM
# [[ -d "$HOME/.rvm/bin" ]] && export PATH="$PATH:$HOME/.rvm/bin"
# [[ -r "$HOME/.rvm/scripts/completion" ]] && . "$HOME/.rvm/scripts/completion"
# [[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm
# [[ $(command -v ruby) ]] && export PATH="$PATH:$(ruby -e 'puts Gem.user_dir')/bin"

### yay rbenv ruby-build
eval "$(rbenv init - zsh)"

# export PATH=$HOME/.gem/ruby/3.0.0/bin:$PATH

# export PATH="$PATH:`yarn global bin`"

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GO111MODULE=on

export NVM_DIR="$HOME/.config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Lazy load
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  NODE_GLOBALS=(`find $NVM_DIR/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)
  NODE_GLOBALS+=("node")
  NODE_GLOBALS+=("nvm")
  # Lazy-loading nvm + npm on node globals
  load_nvm () {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    export NODE_PATH=$(nvm which current)
    # export NPM_PATH=$(which npm)
  }
  # Making node global trigger the lazy loading
  for cmd in "${NODE_GLOBALS[@]}"; do
    eval "${cmd}(){ unset -f ${NODE_GLOBALS}; load_nvm; ${cmd} \$@ }"
  done
fi
# zprof

CODESTATS_PLUG_PATH="$HOME/.zsh/plugins/codestats.plugin.zsh"
[[ -s $CODESTATS_PLUG_PATH ]] && . $CODESTATS_PLUG_PATH

# eval "$(starship init zsh)"

# >>>> Vagrant command completion (start)
# fpath=(/opt/vagrant/embedded/gems/2.2.18/gems/vagrant-2.2.18/contrib/zsh $fpath)
# <<<<  Vagrant command completion (end)

# ___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
