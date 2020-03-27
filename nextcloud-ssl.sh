#!/bin/bash

PORT=$(( 11000 + (($UID - 1000) * 50) + 39))
DOMAIN="$USER.$(hostname).usbx.me"

echo "location = /.well-known/carddav {
    return 301 https://\$host/nextcloud/remote.php/dav;
}

location = /.well-known/caldav {
    return 301 https://\$host/nextcloud/remote.php/dav;
}

location /nextcloud {
    return 301 https://\$host/nextcloud/;
}

location ^~ /nextcloud/ {
    rewrite /nextcloud(.*) \$1 break;
    proxy_pass https://127.0.0.1:$PORT;

    proxy_max_temp_file_size 2048m;

    proxy_set_header Range \$http_range;
    proxy_set_header If-Range \$http_if_range;
    proxy_set_header Connection \$http_connection;
    proxy_redirect off;
    proxy_ssl_session_reuse off;

    proxy_hide_header X-Frame-Options;
    add_header Strict-Transport-Security 'max-age=15552000; includeSubDomains';
}" > ~/.apps/nginx/proxy.d/nextcloud.conf
chmod 755 ~/.apps/nginx/proxy.d/nextcloud.conf

echo "<?php
\$CONFIG = array (
  'memcache.local' => '\\OC\\Memcache\APCu',
  'datadirectory' => '/data',
  'trusted_domains' =>
  array (
    0 => '$DOMAIN',
  ),
  'trusted_proxies' =>
  array (
    0 => '172.17.0.1',
  ),
  'overwritehost' => '$DOMAIN',
  'overwriteprotocol' => 'https',
  'overwritewebroot' => '/nextcloud',
  'overwrite.cli.url' => 'https://$DOMAIN/nextcloud',
);" > ~/.config/nextcloud/www/nextcloud/config/config.php

app-nginx restart
app-nextcloud restart
