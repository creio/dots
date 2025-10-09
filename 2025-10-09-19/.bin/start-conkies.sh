#! /bin/zsh
for f in ~/.config/conky/*.conf;do; conky -c $f &!; done;
