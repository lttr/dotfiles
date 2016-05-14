#!/usr/bin/env bash

ping -c1 8.8.8.8 > /dev/null

if [[ $? -eq 0 ]]; then
	echo 
else
	echo 
fi
