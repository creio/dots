#!/usr/bin/sh

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

ZSH=/usr/share/oh-my-zsh/

# ZSH_THEME="robbyrussell"
# ZSH_THEME="oxide"
# ZSH_THEME="refined"
ZSH_THEME="af-magic"
DISABLE_AUTO_UPDATE="true"
plugins=(
)
export PATH=$HOME/.bin:$HOME/.bin/popup:$HOME/.local/bin:/usr/local/bin:$PATH
ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
[[ ! -d $ZSH_CACHE_DIR ]] && mkdir $ZSH_CACHE_DIR
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=white"

# fzf & fd
[[ -e "/usr/share/fzf/fzf-extras.zsh" ]] && source /usr/share/fzf/fzf-extras.zsh
export FZF_DEFAULT_COMMAND="fd --type file --color=always --follow --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_DEFAULT_OPTS="--ansi"
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --preview 'file {}' --preview-window down:1"
export FZF_COMPLETION_TRIGGER="~~"

# export TERM="xterm-kitty"
# export TERM="rxvt-unicode"
# export TERM="rxvt-unicode-256color"
export TERM="xterm-256color"
export EDITOR="$(if [[ -n $DISPLAY ]]; then echo 'subl3'; else echo 'nano'; fi)"
export BROWSER="firefox"
export SSH_KEY_PATH="~/.ssh/dsa_id"
export XDG_CONFIG_HOME="$HOME/.config"

[[ -f ~/.alias_zsh ]] && . ~/.alias_zsh

export PF_INFO="ascii os kernel wm shell pkgs memory palette"

export PATH=$HOME/.gem/ruby/2.6.0/bin:$PATH
# export PATH="$PATH:`yarn global bin`"
# export NVM_DIR="$HOME/.config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
