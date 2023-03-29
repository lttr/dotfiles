#!/usr/bin/env zsh

# Dependencies:
# - git recursive-status
# - httpie

echo "# Finish the day"
echo 

echo "## Checking repos"
echo

recursive_status=~/dotfiles/scripts/git/git-recursive-status.sh

. $recursive_status  ~/dotfiles 1 true
. $recursive_status  ~/code 2 true
. $recursive_status  ~/work 2 true

echo
echo "## Checking timesheets"
echo

TIMESHEETS_TODAY=`http --json -b "https://jira.quanti.cz/rest/timesheet-gadget/1.0/timesheet.json?csvExport=true&weekends=true&targetUser=trumml&reportingDay=2&numOfWeeks=1&offset=0&sum=day" authorization:"$(cat ~/.jira-auth)" | rg "$(date +"%d. %B %y")"`

if [ -z $TIMESHEETS_TODAY ]; then
	echo "No timesheets today!!!"
else
	echo -n "Number of hours logged today: "
	echo $TIMESHEETS_TODAY | cut -d, -f7 | tr -d '"'
fi

