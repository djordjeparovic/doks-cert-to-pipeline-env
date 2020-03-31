#!/usr/bin/env bash

if [ "${VERBOSE}" == "true" ]; then
    set -x
    CURL="curl -v"
    DOCTL="./doctl -v"
else
    CURL="curl"
    DOCTL="./doctl"
fi

# check if all env variables are defined
for v in \
    CODE_COLLABORATION_TOOL \
    DIGITALOCEAN_ACCESS_TOKEN \
    BITBUCKET_USERNAME \
    BITBUCKET_PASSWORD \
    BITBUCKET_TEAM \
    REPO_SLUG \
    VARIABLE_NAME \
    VARIABLE_PROTECTED \
    DOKS_NAME \
    VERBOSE \
; do
    if [ -z "${!v}" ]; then
        echo "$v is not defined, please configure it as an env variable. Exiting."
        exit 1;
    fi
done

# get the cert from DOKS and save it to /root/.kube/config
${DOCTL} kubernetes cluster kubeconfig save "${DOKS_NAME}"

if [ $? -ne 0 ]; then
    echo "Cant save certificate from DOKS. Exiting."
    exit 2;
fi
variable_value=`base64 /root/.kube/config | tr -d '\n'`

# find Bitbucket Pipeline variable we want to update
variable_uuid_dirty=`
    ${CURL} -u "${BITBUCKET_USERNAME}:${BITBUCKET_PASSWORD}" \
    https://api.bitbucket.org/2.0/repositories/${BITBUCKET_TEAM}/${REPO_SLUG}/pipelines_config/variables/ \
    | jq ".values[] | select(.key == \"${VARIABLE_NAME}\") | .uuid"
`

if [ -z "${variable_uuid_dirty}" ]; then
        echo "We cant find variable $VARIABLE_NAME. Exiting."
        exit 3;
fi

variable_uuid_url=`printf "%s" ${variable_uuid_dirty} | tr -d '"' | sed 's/{/%7B/' | sed 's/}/%7D/'`
variable_uuid_clean=`printf "%s" ${variable_uuid_dirty} | sed 's/["{}]//g'`

# update variable
${CURL} -XPUT -H 'Content-Type: application/json' \
    -u "${BITBUCKET_USERNAME}:${BITBUCKET_PASSWORD}" \
    "https://api.bitbucket.org/2.0/repositories/${BITBUCKET_TEAM}/${REPO_SLUG}/pipelines_config/variables/${variable_uuid_url}" \
    -d "
    {
        \"uuid\": \"${variable_uuid_clean}\",
        \"value\": \"${variable_value}\",
        \"key\":\"${VARIABLE_NAME}\",
        \"secured\": ${VARIABLE_PROTECTED}
    }"

if [ $? -eq 0 ]; then
    # Todo: do check response status code as well
    echo "Variable ${VARIABLE_NAME} updated successfully!"
else
    echo "Error updating ${VARIABLE_NAME} variable! Exiting."
    exit 1
fi
