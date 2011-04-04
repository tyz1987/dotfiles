#!/bin/bash

mpc play $(sed -n "s@^ *\([0-9]\+\);$(mpc playlist|dmenu -i -p 'song name'||echo ";;;")@\1@p" < <(mpc playlist|nl -s ';'))
