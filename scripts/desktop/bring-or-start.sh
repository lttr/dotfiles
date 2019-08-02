#!/bin/bash

if pgrep "$1"; then bring-window "$1"; else "$1"; fi
