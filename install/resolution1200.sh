xrandr --newmode $(cvt -r 1920 1200 60 | grep Modeline | sed 's/Modeline\ //')
xrandr --addmode DVI-I-1 "1920x1200R"
xrandr --output DVI-I-1 --mode "1920x1200R"
