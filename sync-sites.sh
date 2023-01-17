#!/bin/bash
#this script takes one argument.  valid values are init, db, onlysettings
#init will create all settings files and fetch database imports for all sites
#db will only pull in databases, perhaps add a flag here for individual site pull
#onlysettings will not pull databases, but will ensure local settings
#are set for each site
if [[ $# -eq 0 ]] ; then
  OPERATION="init"
else
  OPERATION=$1
fi

DB_BAK_PATH="db_backups"
mkdir -p DB_BAK_PATH
UPSTREAM="95dd5ea4-a2a8-4608-946a-38bd3a5eb19e"
ORG="90644669-f536-4de0-8eba-2085302afa76"
echo "Performing sync type: $OPERATION"

for SITE in $(terminus org:site:list --upstream=$UPSTREAM --field=name -- $ORG); 
do 
  echo "$SITE"; 
  DEFAULT_PATH="web/sites/local"
  SITE_PATH="web/sites/$SITE.lndo.site"
  SITE_SETTINGS="$SITE_PATH/settings.php"

  #check if Drupal settings file exists
  #if not, initialize site settings file
  if [ ! -f "$SITE_SETTINGS" ]
  then
    #copy default settings template
    cp -R $DEFAULT_PATH $SITE_PATH
    echo "Site Directory Made at $SITE_PATH"

    #insert machine name for this site into settings file
    sed -i "" "s/{uninitialized}/$SITE/" $SITE_SETTINGS
    #optionally could also pull files here
  fi

  #check for hostname of each site in lando file
  #if not, inject site hostname into lando.yml
  if ! grep -q "\- $SITE\.lndo\.site" .lando.yml
  then
    #insert hostname
    sed -i "" "s/appserver_nginx:/appserver_nginx:\\n    - $SITE\.lndo\.site/" .lando.yml
    echo "setting nginx hostname $SITE.lndo.site"
  fi

  #check for DB settings for each site in lando file
  #if not, inject site DB service lando.yml
  if ! grep -Fq "$SITE:" .lando.yml
  then
    #insert database
    sed -i "" "s/services:/services:\\n  $SITE: \\n    type: mariadb:10.4 \\n    portforward: TRUE/" .lando.yml
    echo "setting database service for $SITE"
  fi

  #if we're creating site for the first time, or specifying "db" grab a DB backup
  if [[ $OPERATION != onlysettings ]]
  then
    echo "Importing dev datbase backup"
    terminus backup:get $SITE.dev --element=db --to=$DB_BAK_PATH/$SITE.sql
    lando db-import $DB_BAK_PATH/$SITE.sql --host $SITE
    rm $DB_BAK_PATH/$SITE.sql
  fi
done