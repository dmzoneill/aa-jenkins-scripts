#!/bin/bash

# ENDPOINT=https://ci.int.devshift.net/job/automation-analytics-ephemeral/buildWithParameters
# RELEASE_NAMESPACE="RELEASE_NAMESPACE=true"
# NAMESPACE="NAMESPACE=$1"

# curl --no-progress-meter "$ENDPOINT" --user $JENKNIS_CREDS --data $RELEASE_NAMESPACE --data $NAMESPACE >/dev/null 2>&1

WHOAMI=$(whoami)

NAMESPACES=$(bonfire namespace list | grep "automation-analytics-ephemeral\|$WHOAMI" | awk '{print $1}')

for X in $NAMESPACES; do
   yes | bonfire namespace release $X;
done
