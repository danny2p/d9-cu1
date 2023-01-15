<?php
#setting site name variable for local use
#creating a new multisite instance requires you to change this variable
#Be sure to change this to the same identifier that
#you use under ‘services’ in your .lando.yml file.
$site_name = "d9-cu-1";

/**
 * Load services definition file.
 */
$settings['container_yamls'][] = __DIR__ . '/services.yml';

/**
 * Include the Pantheon-specific settings file.
 *
 * n.b. The settings.pantheon.php file makes some changes
 *      that affect all environments that this site
 *      exists in.  Always include this file, even in
 *      a local development environment, to ensure that
 *      the site settings remain consistent.
 */
include __DIR__ . "../default/settings.pantheon.php";

/**
 * Skipping permissions hardening will make scaffolding
 * work better, but will also raise a warning when you
 * install Drupal.
 *
 * https://www.drupal.org/project/drupal/issues/3091285
 */
// $settings['skip_permissions_hardening'] = TRUE;

$lando_info = json_decode(getenv('LANDO_INFO'), TRUE);
if (!empty($lando_info)) {
  // Define this site's default database. Be sure to change ‘multisite1’ to the same identifier that
  // you use under ‘services’ in your .lando.yml file.
  $databases['default']['default'] = [
    'database' => $lando_info[$site_name]['creds']['database'],
    'username' => $lando_info[$site_name]['creds']['user'],
    'password' => $lando_info[$site_name]['creds']['password'],
    'host' => $site_name,
    'driver' => 'mysql',
  ];
 
  // Define file system settings.
  $conf['file_temporary_path'] = '/tmp';
  $settings['file_private_path'] = '/app/private-files/';
 
  // Trusted host pattern settings.
  $settings['trusted_host_patterns'][] = '\.lndo\.site$';
 
// Define this site's own config sync directory for local environment.
  $settings['config_sync_directory'] = '/app/config/'.$site_name; 
}