#!/usr/bin/env bash

SESSION=work

pid="$(pidof tmux)"

# exec
if test "$pid"; then
  tmux attach
else
  tmux new -d -s $SESSION
  #
  tmux new-window -t $SESSION:1 -n 'term'
  tmux send-keys "ff" C-m
  #
  tmux new-window -t $SESSION:2 -n 'tilde'
  tmux send-keys "ssh cvc" C-m
  #
  tmux new-window -t $SESSION:3 -n 'edit'
  tmux send-keys "nvim" C-m
  #
  tmux new-window -t $SESSION:4 -n 'music'
  tmux send-keys "ncmpcpp" C-m
  tmux split-window -h
  tmux select-pane -t 1
  tmux resize-pane -R 10
  tmux split-window -v
  tmux resize-pane -D 1
  tmux send-keys "cava" C-m
  #
  tmux new-window -t $SESSION:5 -n 'proc'
  tmux send-keys "btm" C-m
  #
  tmux new-window -t $SESSION:6 -n 'rss'
  tmux send-keys "newsboat" C-m
  #
  tmux select-window -t $SESSION:1
  tmux attach-session -t $SESSION
fi
