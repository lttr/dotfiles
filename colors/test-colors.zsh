#!/usr/bin/env zsh


msgcat --color=test

echo "======================================================="

autoload -Uz colors && colors

echo "> ZSH arrays with color names test:"
echo
echo $fg_no_bold[default]default $fg_bold[default]bold-default
echo $fg_no_bold[black]black $fg_bold[black]bold-black
echo $fg_no_bold[blue]blue $fg_bold[blue]bold-blue
echo $fg_no_bold[cyan]cyan $fg_bold[cyan]bold-cyan
echo $fg_no_bold[green]green $fg_bold[green]bold-green
echo $fg_no_bold[magenta]magenta $fg_bold[magenta]bold-magenta
echo $fg_no_bold[red]red $fg_bold[red]bold-red
echo $fg_no_bold[white]white $fg_bold[white]bold-white
echo $fg_no_bold[yellow]yellow $fg_bold[yellow]bold-yellow
echo $fg_no_bold[default]

# OR


echo "> Terminal number definition of colors test:"
echo
for i in {0..9}; do
    echo -n ${$(tput setaf $i)}test $i ${$(tput sgr 0)}; 
    echo -n ${$(tput bold)}${$(tput setaf $i)}test $i ${$(tput sgr 0)}; 
    echo -n ${$(tput smul)}${$(tput setaf $i)}test $i ${$(tput sgr 0)}; 
    echo -n ${$(tput smso)}${$(tput setaf $i)}test $i ${$(tput sgr 0)}; 
    echo
done
