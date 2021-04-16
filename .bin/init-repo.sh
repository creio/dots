#!/bin/bash

## ~/.alias_zsh
# alias dots="git --git-dir=$HOME/.dots/ --work-tree=$HOME"

# Create and configure repository
git init --bare $HOME/.dots || return 1
dots config --local status.showUntrackedFiles no

# Create gitignore and initial commit
echo .dots >> $HOME/.gitignore
dots add $HOME/.gitignore
dots commit -m "Initialize dotfiles repo"
