#!/bin/bash

ENDPOINT=https://ci.int.devshift.net/job/automation-analytics-ephemeral/buildWithParameters
RELEASE_NAMESPACE="RELEASE_NAMESPACE=true"
NAMESPACE="NAMESPACE=$1"

curl --no-progress-meter "$ENDPOINT" --user $JENKNIS_CREDS --data $RELEASE_NAMESPACE --data $NAMESPACE >/dev/null 2>&1

