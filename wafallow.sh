#!/bin/bash

read -p "Enter the app DB name: " APP <&1
/usr/bin/awk '/set_real_ip/{print substr($NF, 1, length($NF)-1),"1;"}' \
	/etc/nginx/proxies/* > /etc/nginx/proxies/waf-allowedIPs
/bin/sed -i -e '1s|^|geo $realip_remote_addr $allowed {\
        proxy 127.0.0.1;\
        default 0;\
        include "\/etc\/nginx\/proxies\/waf-allowedIPs";\
        }\
|' -e '/location @backend /i\
  if ($allowed = 0){\
	return 403;\
  }' /etc/nginx/sites-available/"${APP}"

/etc/init.d/nginx restart
