#!/bin/bash

# Usage
# ./dev-deploy.sh <site-name or uuid>

# Exit on error
set -e

SITE=$1
DEV=$(echo "${SITE}.dev")
START=$SECONDS

# Tell slack we're starting this site
SLACK_START="Started ${SITE} deployment"

curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK_START}'}" $SLACK_WEBHOOK
echo -e "Starting ${SITE}";

# Check site upstream for updates, apply
terminus site:upstream:clear-cache $1 -q

# terminus connection:set "${1}.dev" git
# STATUS=$(terminus upstream:update:status "${1}.dev")
terminus upstream:updates:apply $DEV --updatedb --accept-upstream -q
SLACK="Finished ${SITE} DEV Deployment"
curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK}'}" $SLACK_WEBHOOK

# Run drush config import, clear cache
# terminus drush "${1}.dev" -- cim -y
terminus env:clear-cache $site.dev

# Report time to results.
DURATION=$(( SECONDS - START ))
TIME_DIFF=$(bc <<< "scale=2; $DURATION / 60")
MIN=$(printf "%.2f" $TIME_DIFF)
SITE_LINK="https://dev-${SITE}.pantheonsite.io";
SLACK=":white_check_mark: Finished ${SITE} deployment in ${MIN} minutes. \n ${SITE_LINK}"
curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK}'}" $SLACK_WEBHOOK

