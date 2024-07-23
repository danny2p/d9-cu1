#!/bin/bash

# just slack notifications - called from PR and branch workflows

# Exit on error
set -e

SITE=$1
SITE_ENV=$(echo "${CANARY_SITE}.${CI_BRANCH}")
START=$SECONDS

# Tell slack we're starting this site
SLACK_START="Started ${SITE} deployment"
curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK_START}'}" $SLACK_WEBHOOK
echo -e "Starting ${SITE}";

SLACK_DONE="Finished ${SITE} ${ENV} Deployment"
curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK_DONE}'}" $SLACK_WEBHOOK

# Report time to results.
DURATION=$(( SECONDS - START ))
TIME_DIFF=$(bc <<< "scale=2; $DURATION / 60")
MIN=$(printf "%.2f" $TIME_DIFF)
SITE_LINK="https://${CI_BRANCH-${CANARY_SITE}.pantheonsite.io";
SLACK=":white_check_mark: Finished ${CANARY_SITE} deployment in ${MIN} minutes. \n ${SITE_LINK}"
curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK}'}" $SLACK_WEBHOOK