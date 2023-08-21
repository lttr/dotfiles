#!/bin/env bash

cp $HOME/.steam/steam/steamapps/common/AoE2DE/vc_redist.x64.exe $HOME/.steam/steam/steamapps/compatdata/813780/pfx/drive_c/windows/system32/vc_redist.x64.exe

sudo apt-get install cabextract

cd $HOME/.steam/steam/steamapps/compatdata/813780/pfx/drive_c/windows/system32/

sudo cabextract vc_redist.x64.exe

sudo cabextract a10

cd ..

sudo chown -R $USER:$USER system32
