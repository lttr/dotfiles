#
# Hardware setup
#

# ===== Keyboard =====
setxkbmap -layout "us,cz" -variant "basic,qwerty"
setxkbmap -option grp:lalt_lshift_toggle
setxkbmap -option caps:escape

# ===== Mouse =====
# Remap forward mouse key to be back, too
# Source: http://askubuntu.com/questions/492744/how-do-i-automatically-remap-buttons-on-my-mouse-at-startup
mouse_id=$(xinput | grep "USB Gaming Mouse" | grep pointer | head -1 | awk -F= '{print substr($2,1,2)}')
xinput set-button-map $mouse_id 1 2 3 4 5 6 7 8 8)

# ===== Monitor =====
xrandr --newmode "1920x1200R"  154.00  1920 1968 2000 2080  1200 1203 1209 1235 +hsync -vsync
xrandr --addmode DVI-I-1 "1920x1200R"
xrandr --output DVI-I-1 --mode "1920x1200R"
