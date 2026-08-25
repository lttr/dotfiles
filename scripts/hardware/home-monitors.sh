#!/usr/bin/env bash
set -euo pipefail

# Home desk layout under COSMIC (Wayland): Samsung 24" portrait on the left,
# LG 27" QHD landscape on the right, vertically centred against it.
# xrandr cannot be used here - Xwayland only mirrors the compositor's layout.

cosmic-randr mode DP-5 1920 1200 --refresh 59.950 --transform rotate270 --scale 1 --pos-x 0 --pos-y 0
cosmic-randr mode DP-3 2560 1440 --refresh 59.951 --transform normal --scale 1 --pos-x 1200 --pos-y 185

cosmic-randr xwayland --primary DP-3
