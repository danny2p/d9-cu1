#!/bin/bash
DB_BAK_PATH="db_backups"
mkdir -p DB_BAK_PATH
for site in $(terminus org:site:list --upstream=95dd5ea4-a2a8-4608-946a-38bd3a5eb19e --field=name -- 90644669-f536-4de0-8eba-2085302afa76); 
do 
  echo "$site"; 
  DEFAULT_PATH="web/sites/local"
  SITE_PATH="web/sites/$site.lndo.site"
  SITE_SETTINGS="$SITE_PATH/settings.php"

  #check if settings file exists
  #if not, initialize site and pull in database backup
  if [ ! -f "$SITE_SETTINGS" ];
  then
    #copy default settings template
    cp -R $DEFAULT_PATH $SITE_PATH
    echo "Site Directory Made at $SITE_PATH"

    #insert machine name into settings file
    sed -i "s/{uninitialized}/$site" $SITE_SETTINGS

    echo "Importing dev datbase backup"
    #optionally could also pull files here

    #if we're creating site for the first time, grab a DB backup
    terminus backup:get $site.dev --element=db --to=$DB_BAK_PATH/$site.sql
    echo "Importing dev datbase backup"
    lando db-import $DB_BAK_PATH/$site.sql --host $site
    rm $DB_BAK_PATH/$site.sql

  fi
    #insert machine name into settings file
    sed -i "" "s/{uninitialized}/$site/" "$SITE_SETTINGS"

done
