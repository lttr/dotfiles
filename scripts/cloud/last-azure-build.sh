#!/usr/bin/env bash

# Login, set defaults and install azure-devops extension first:
# az devops configure --defaults organization=...
# az devops configure --defaults project=...
# az login
# az extension add --name azure-devops

# Depends on `json` tool
# npm i -g json


PIPELINE=$(az pipelines build list --status InProgress --top 1 | json -a id)

if [[ $PIPELINE ]]; then
  BUILD_ID=$PIPELINE
else
  BUILD_ID=$(az pipelines build list --status Completed --top 1 | json -a id)
fi

az pipelines build show --open --id $BUILD_ID