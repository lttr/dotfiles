#!/usr/bin/env bash

browser_exe="google-chrome"
editor_exe="code"
port="2000"

hyperlayout lttr

$editor_exe ~/code/lukastrumm

sleep 2
$browser_exe --new-window -d "http://localhost:$port"
