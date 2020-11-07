#!/bin/bash

SESSION=work

pid="$(pidof tmux)"

# exec
if test "$pid"; then
  tmux attach
else
  tmux new -d -s $SESSION
  #
  tmux new-window -t $SESSION:1 -n 'music'
  tmux send-keys "ncmpcpp" C-m
  tmux split-window -h
  tmux select-pane -t 1
  tmux resize-pane -R 10
  tmux split-window -v
  tmux resize-pane -D 1
  tmux send-keys "cava" C-m
  tmux select-pane -t 3
  tmux send-keys "ff" C-m
  #
  tmux new-window -t $SESSION:2 -n 'proc'
  tmux send-keys "gotop" C-m
  tmux split-window -h
  tmux select-pane -t 1
  tmux resize-pane -R 5
  tmux split-window -v
  tmux resize-pane -D 1
  tmux send-keys "htop" C-m
  tmux select-pane -t 3
  tmux send-keys "ranger" C-m
  #
  tmux new-window -t $SESSION:3 -n 'edit'
  tmux send-keys "nvim" C-m
  tmux split-window -h
  tmux resize-pane -R 40
  tmux select-pane -t 2
  tmux send-keys C-m
  #
  tmux new-window -t $SESSION:4 -n 'rss'
  tmux send-keys "newsboat" C-m
  #
  tmux select-window -t $SESSION:1
  tmux attach-session -t $SESSION
fi
