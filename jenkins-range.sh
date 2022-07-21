#!/bin/bash

IFS=$'\n'

REPO_DIR="../automation-analytics-backend"

START_COMMIT=$1
# 80b7efcb1187e03962636605651fa7471b400302

END_COMMIT=$2
# f0d8f92862ad2a55681d5c82e98d7e578673d4ec

STR_COMMITS=$(cd $REPO_DIR; git log -20 --pretty=format:"%H")

readarray -t ALL_COMMITS <<<"$STR_COMMITS"
STARTED=0
ENDED=0

for ((i=${#ALL_COMMITS[@]}-1; i>=0; i--)); do
  if [[ "${ALL_COMMITS[$i]}" == "$START_COMMIT" ]]; then
    STARTED=1
  fi

  if [[ "${ALL_COMMITS[$i]}" == "$END_COMMIT" ]]; then
    ENDED=1
  fi

  if [[ $STARTED -eq 1 && $ENDED -eq 0 ]]; then  
    echo "${ALL_COMMITS[$i]}"
    ./jenkins-start.sh "${ALL_COMMITS[$i]}"
    ./jenkins-release.sh
  fi  
done
