#!/bin/bash

# Author: daoneill@redhat.com

ENDPOINT=https://ci.int.devshift.net/job/automation-analytics-ephemeral

APP_NAME=tower-analytics,gateway,insights-ephemeral
GIT_LAB_ID=37507
GITLAB_URL="https://gitlab.cee.redhat.com/api/v4/projects/$GIT_LAB_ID/repository/commits"

COMPONENT_NAME=tower-analytics-clowdapp
IMAGE=quay.io/cloudservices/automation-analytics-api
COMPONENTS_W_RESOURCES=all
DEPLOY_TIMEOUT=1800
RESERVATION_DURATION=72
POST_DEPLOYMENT_SCRIPT=""
INCLUDE_UI="true"

GIT_COMMIT_INPUT=""
IMAGE_TAG_INPUT=""

if [ -z "$1" ]; then
    GIT_COMMIT_INPUT=$(curl --no-progress-meter -k --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL" | jq ".[0][\"id\"]" | sed 's/"//g')
    IMAGE_TAG_INPUT=$(echo $GIT_COMMIT_INPUT | cut -c1-7)
    POST_DEPLOYMENT_SCRIPT="cypress.sh"
else
    GIT_COMMIT_INPUT=$1
    IMAGE_TAG_INPUT=$(echo $GIT_COMMIT_INPUT | cut -c1-7)
fi

APP_NAME="APP_NAME=$APP_NAME"
COMPONENT_NAME="COMPONENT_NAME=$COMPONENT_NAME"
IMAGE="IMAGE=$IMAGE"
COMPONENTS_W_RESOURCES="COMPONENTS_W_RESOURCES=$COMPONENTS_W_RESOURCES"
DEPLOY_TIMEOUT="DEPLOY_TIMEOUT=$DEPLOY_TIMEOUT"
GIT_COMMIT_INPUT="GIT_COMMIT_INPUT=$GIT_COMMIT_INPUT"
IMAGE_TAG_INPUT="IMAGE_TAG_INPUT=$IMAGE_TAG_INPUT"
RESERVATION_DURATION="RESERVATION_DURATION=$RESERVATION_DURATION"
POST_DEPLOYMENT_SCRIPT="POST_DEPLOYMENT_SCRIPT=$POST_DEPLOYMENT_SCRIPT"
INCLUDE_UI="INCLUDE_UI=$INCLUDE_UI"

REQ_URL="curl -i --no-progress-meter "$ENDPOINT/buildWithParameters" --user $JENKINS_CREDS --data $POST_DEPLOYMENT_SCRIPT --data $APP_NAME --data $COMPONENT_NAME --data $IMAGE --data $COMPONENTS_W_RESOURCES --data $DEPLOY_TIMEOUT --data $GIT_COMMIT_INPUT --data $IMAGE_TAG_INPUT --data COMPONENTS= --data $RESERVATION_DURATION --data $INCLUDE_UI"
OUTPUT=$($REQ_URL)
QUEUE_URL=$(echo $OUTPUT | grep -oP 'Location: \K.*')
QUEUE_ID=$(echo $QUEUE_URL | awk -F'/' '{print $6}')

export NEXT_BUILD_NO=$(curl --no-progress-meter "$ENDPOINT/api/json" --user $JENKINS_CREDS | jq '.nextBuildNumber')
export BUILD_NO=$NEXT_BUILD_NO

echo -n "Waiting for queue item to be scheduled as a job .."
sleep 5
    
while true; do
    STUCK=$(curl --no-progress-meter "$ENDPOINT/api/json" --user $JENKINS_CREDS | jq '.queueItem')
    if [[ "$STUCK" == "null" ]]; then
        echo "" 
        break
    else
        echo -n "." 
        sleep 10
    fi
done

echo ""
echo " >> $ENDPOINT/$NEXT_BUILD_NO/consoleText" #yfwjs8
# open the jenkins conosle output
nohup "$ENDPOINT/$NEXT_BUILD_NO/console" >/dev/null 2>&1


# change to the namespace on the console
echo ""
echo -n "Waiting for the namespace to be determined in the build .."
curl --no-progress-meter "$ENDPOINT/$NEXT_BUILD_NO/consoleText" --user $JENKINS_CREDS | grep -o 'apply.*ephemeral-[a-z0-9]\{6\}' >/dev/null 2>&1    
while [ $? -eq 1 ]; do
    echo -n "."
    sleep 10
    curl --no-progress-meter "$ENDPOINT/$NEXT_BUILD_NO/consoleText" --user $JENKINS_CREDS | grep -o 'apply.*ephemeral-[a-z0-9]\{6\}' >/dev/null 2>&1
done

export NAMESPACE=$(curl --no-progress-meter "$ENDPOINT/$NEXT_BUILD_NO/consoleText" --user $JENKINS_CREDS | grep -o 'apply.*ephemeral-[a-z0-9]\{6\}' | awk -F'-' '{print $5}' | tail -n 1)

echo ""
oc project ephemeral-$NAMESPACE


# Open the consoledot URL
echo ""
echo -n "Waiting for the consoledot URL .."
curl --no-progress-meter "$ENDPOINT/$NEXT_BUILD_NO/consoleText" --user $JENKINS_CREDS | grep 'https://console-openshift-console.apps.*' >/dev/null 2>&1
while [ $? -eq 1 ]; do	
    echo -n "."
    sleep 10
    curl --no-progress-meter "$ENDPOINT/$NEXT_BUILD_NO/consoleText" --user $JENKINS_CREDS | grep 'https://console-openshift-console.apps.*' >/dev/null 2>&1
done

echo ""
echo ""
CONSOLEDOT=$(curl --no-progress-meter "$ENDPOINT/$NEXT_BUILD_NO/consoleText" --user $JENKINS_CREDS | grep -o 'https://console-openshift-console.apps.*'  | tail -n 1)
echo " >> $CONSOLEDOT"
nohup xdg-open "$CONSOLEDOT" >/dev/null 2>&1


# Open the ui URL
echo ""
echo -n "Waiting for the UI URL .."
curl --no-progress-meter "$ENDPOINT/$NEXT_BUILD_NO/consoleText" --user $JENKINS_CREDS | grep 'https://front-end-aggregator-ephemeral.*' >/dev/null 2>&1
while [ $? -eq 1 ]; do
    echo -n "."
    sleep 10
    curl --no-progress-meter "$ENDPOINT/$NEXT_BUILD_NO/consoleText" --user $JENKINS_CREDS | grep 'https://front-end-aggregator-ephemeral.*' >/dev/null 2>&1
done

echo ""
echo ""
echo -n "Project / Namespace"
echo ""
echo ""
echo " >> export NAMESPACE=ephemeral-$NAMESPACE"
echo " >> export BONFIRE_NS_REQUESTER=automation-analytics-ephemeral-$NEXT_BUILD_NO"
export BONFIRE_NS_REQUESTER=automation-analytics-ephemeral-$NEXT_BUILD_NO
export NAMESPACE=ephemeral-$NAMESPACE
