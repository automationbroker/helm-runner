#!/bin/bash

set -ex

ACTION=$1
if [[ $ACTION == provision ]]; then
    KUBECTL_COMMAND=create
elif [[ $ACTION == deprovision ]]; then
    KUBECTL_COMMAND=delete
elif [[ $ACTION == update ]]; then
    KUBECTL_COMMAND=apply
else
    echo "Action ($ACTION) not in [ provision, deprovision, update ]."
    exit 1
fi

shift
TARGET_NAMESPACE=$(echo $2 | jq -r .namespace)
INSTANCE_ID=$(echo $2 | jq -r ._apb_service_instance_id)
REPO_URL=$(echo $2 | jq -r .repo)
REPO_NAME="chartrepo"
CHART=$(echo $2 | jq -r .chart)
VERSION=$(echo $2 | jq -r .version)
NAME="helm-${INSTANCE_ID::8}"
VALUES_FILE=$(mktemp --tmpdir= values.XXXX)
echo "$2" | jq -r .values | tee $VALUES_FILE

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-apb}:x:$(id -u):0:${USER_NAME:-apb} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

### HELM
helm init --client-only
helm repo add $REPO_NAME $REPO_URL
helm fetch $REPO_NAME/$CHART --version=$VERSION --untar -d /opt/apb
helm template --name=$NAME -f $VALUES_FILE /opt/apb/$CHART | sed -n '/---/,$p' > /tmp/manifest
echo "##########################"
cat /tmp/manifest
echo "##########################"
kubectl $KUBECTL_COMMAND --namespace=$TARGET_NAMESPACE -f /tmp/manifest
###

EXIT_CODE=$?

set +ex
rm -f /tmp/secrets
set -ex

exit $EXIT_CODE
