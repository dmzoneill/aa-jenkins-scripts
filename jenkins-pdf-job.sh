#!/bin/bash

# echo "dmzoneill:110db6b32fb9d7ad9bxxxxxxxxxxxxxxxxxxx" > ~/.jenkins-api-creds
# echo "E2K7Rzc3Pbxxxxxxxxx" > ~/.gitlab-api-token

ENDPOINT=https://ci.int.devshift.net/job/automation-analytics-ephemeral/buildWithParameters
CREDS=$(cat ~/.jenkins-api-creds)
GITLAB_TOKEN=$(cat ~/.gitlab-api-token)

APP_NAME=pdf-generator
GIT_LAB_ID=48260
GITLAB_URL="https://gitlab.cee.redhat.com/api/v4/projects/$GIT_LAB_ID/repository/commits"


if [ "$#" -eq  "0" ]; then

    COMPONENT_NAME=pdf-generator
    IMAGE=quay.io/cloudservices/pdf-generator
    COMPONENTS_W_RESOURCES=all
    DEPLOY_TIMEOUT=1800
    RESERVATION_DURATION=2
    #POST_DEPLOYMENT_SCRIPT="cypress-local.sh"
    INCLUDE_UI="true"

    GIT_COMMIT_INPUT=$(curl -k --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL" | jq ".[0][\"id\"]" | sed 's/"//g')
    #IMAGE_TAG_INPUT=$(curl -k --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL" | jq ".[0][\"short_id\"]" | sed 's/"//g')
    IMAGE_TAG_INPUT=pr-pr-32-b33cae2

    APP_NAME="APP_NAME=$APP_NAME"
    COMPONENT_NAME="COMPONENT_NAME=$COMPONENT_NAME"
    IMAGE="IMAGE=$IMAGE"
    COMPONENTS_W_RESOURCES="COMPONENTS_W_RESOURCES=$COMPONENTS_W_RESOURCES"
    DEPLOY_TIMEOUT="DEPLOY_TIMEOUT=$DEPLOY_TIMEOUT"
    GIT_COMMIT_INPUT="GIT_COMMIT_INPUT=$GIT_COMMIT_INPUT"
    IMAGE_TAG_INPUT="IMAGE_TAG_INPUT=$IMAGE_TAG_INPUT"
    RESERVATION_DURATION="RESERVATION_DURATION=$RESERVATION_DURATION"
    #POST_DEPLOYMENT_SCRIPT="POST_DEPLOYMENT_SCRIPT=$POST_DEPLOYMENT_SCRIPT"
    INCLUDE_UI="INCLUDE_UI=$INCLUDE_UI"

    curl "$ENDPOINT" --user $CREDS --data $APP_NAME --data $COMPONENT_NAME --data $IMAGE --data $COMPONENTS_W_RESOURCES --data $DEPLOY_TIMEOUT --data $GIT_COMMIT_INPUT --data $IMAGE_TAG_INPUT --data COMPONENTS= --data $RESERVATION_DURATION --data $INCLUDE_UI
    
else

    RELEASE_NAMESPACE="RELEASE_NAMESPACE=true"
    NAMESPACE="NAMESPACE=$1"
    curl "$ENDPOINT" --user $CREDS --data $RELEASE_NAMESPACE --data $NAMESPACE 

fi



