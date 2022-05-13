#!/bin/bash

ENDPOINT=https://ci.int.devshift.net/job/automation-analytics-ephemeral/$BUILD_NO/stop 
curl --no-progress-meter --request POST "$ENDPOINT" --user $JENKINS_CREDS >/dev/null 2>&1
