#!/bin/bash

# Author: daoneill@redhat.com

oc project $NAMESPACE

# export IQE_MARKER_EXPRESSION="ephemeral"
# export IQE_IMAGE_TAG="automation-analytics"

export IQE_PLUGINS="automation_analytics"
export IQE_FILTER_EXPRESSION=""
export IQE_CJI_TIMEOUT="15m"
export CLOWD_APP_NAME=automation-analytics
export COMPONENT_NAME=automation-analytics

export UI_URL=`oc get route front-end-aggregator -o jsonpath='https://{.spec.host}{"\n"}' -n $NAMESPACE`
export KEYCLOCK_URL=`oc get route keycloak -o jsonpath='https://{.spec.host}{"\n"}' -n $NAMESPACE`
export SEP="========================================================================="


oc create route edge unleash --service=env-${NAMESPACE}-featureflags --port=featureflags

BUILD_COMMIT_ID=""

if [ -z "$1" ]; then
    rm -rf /tmp/frontend
    git clone --depth 1 --branch devel https://github.com/RedHatInsights/tower-analytics-frontend.git /tmp/frontend
    cd /tmp/frontend
    BUILD_COMMIT_ID=$(git log -n 1 --pretty=format:"%H" | tr -d '\n')
else
    BUILD_COMMIT_ID=$1
fi


cat >/tmp/app-config.yml <<EOL
---
automation-analytics:
    commit: $BUILD_COMMIT_ID
EOL


kubectl delete configmap aggregator-app-config -n $NAMESPACE
kubectl create configmap aggregator-app-config --from-file=/tmp/app-config.yml -n $NAMESPACE
kubectl rollout restart deployment/front-end-aggregator -n $NAMESPACE
kubectl rollout status deployment/front-end-aggregator -n $NAMESPACE

sleep 5

READY=$(kubectl get pods -l app=front-end-aggregator -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')

while [[ $READY != "True" ]]; do
    echo "Waiting for front-end-aggregator"
    sleep 1
    READY=$(kubectl get pods -l app=front-end-aggregator -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')
done

sleep 5

oc exec -n $NAMESPACE deployment/front-end-aggregator -- /www/src/do_platform_apps.py

FRONTEND_POD=$(oc get pods | grep -i front | awk '{print $1}')

KEYCLOCK_URL_CLEAN=$(echo $KEYCLOCK_URL |sed 's/https\?:\/\///')

mkdir -vp /tmp/fixsso
cat >/tmp/fixsso/fix_sso_url.sh <<EOL
#!/bin/bash -x

cd /all/code/chrome/js

for f in \`ls *.js\`; do 
	sed -i s/sso.qa.redhat.com/$KEYCLOCK_URL_CLEAN/g \$f 
	rm \$f.gz 
	gzip --keep \$f; 
done
EOL

chmod +x /tmp/fixsso/fix_sso_url.sh
oc rsync /tmp/fixsso $FRONTEND_POD:/tmp/

oc exec -n $NAMESPACE deployment/front-end-aggregator -- /tmp/fixsso/fix_sso_url.sh


echo $SEP
echo "Generate test data"
echo $SEP
oc exec -n $NAMESPACE deployments/automation-analytics-api-fastapi-v2 -- bash -c "./entrypoint ./tower_analytics_report/management/commands/generate_development_data.py --tenant_id 3340852"
oc exec -n $NAMESPACE deployments/automation-analytics-api-fastapi-v2 -- bash -c "./entrypoint ./tower_analytics_report/management/commands/process_rollups_one_time.py"
oc exec -n $NAMESPACE deployments/automation-analytics-api-fastapi-v2 -- bash -c "./entrypoint ./tower_analytics_report/management/commands/tenants_metrics.py"
