#!/bin/bash

# echo "dmzoneill:110db6b32fb9d7ad9bxxxxxxxxxxxxxxxxxxx" > ~/.jenkins-api-creds
# echo "E2K7Rzc3Pbxxxxxxxxx" > ~/.gitlab-api-token

ENDPOINT=https://ci.int.devshift.net/job/automation-analytics-ephemeral/buildWithParameters
CREDS=$(cat ~/.jenkins-api-creds)
RELEASE_NAMESPACE="RELEASE_NAMESPACE=true"
NAMESPACE="NAMESPACE=$1"

curl --no-progress-meter "$ENDPOINT" --user $CREDS --data $RELEASE_NAMESPACE --data $NAMESPACE >/dev/null 2>&1

