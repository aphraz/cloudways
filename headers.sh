#!/bin/bash

cat << _EOF_ >> /etc/nginx/additional_server_conf
add_header Content-Security-Policy "frame-ancestors 'self';";
add_header X-Frame-Options "SAMEORIGIN";
add_header Referrer-Policy "no-referrer-when-downgrade";
add_header X-XSS-Protection "1; mode=block";
add_header X-Content-Type-Options "nosniff";
_EOF_
/etc/init.d/nginx restart
