<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' =>
  array (
    0 =>
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 =>
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'overwrite.cli.url' => 'https://sub.domain.tld',
  'overwritehost' => 'sub.domain.tld',
  'trusted_proxies' =>
  array (
    0 => '123.45.6.7',
  ),
);
