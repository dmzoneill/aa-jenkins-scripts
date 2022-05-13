#!/bin/bash

# echo "dmzoneill:110db6b32fb9d7ad9bxxxxxxxxxxxxxxxxxxx" > ~/.jenkins-api-creds
# echo "E2K7Rzc3Pbxxxxxxxxx" > ~/.gitlab-api-token

ENDPOINT=https://ci.int.devshift.net/job/automation-analytics-ephemeral/$BUILD_NO/stop 
CREDS=$(cat ~/.jenkins-api-creds)
curl --no-progress-meter --request POST "$ENDPOINT" --user $CREDS >/dev/null 2>&1
