#!/bin/bash
cd /etc/nginx/sites-available
sed -i 's/error_page 502 = @backend/error_page 502 503 = @backend_502/g' *
sed -i '/server_name_in_redirect/a include "/etc/nginx/backends_502";' *
cat <<EOT >> /etc/nginx/backends_502
location @backend_502 {
	if (\$http_host ~* (.*\.cloudwaysapps.com)) {
		   add_header  X-Robots-Tag "noindex, nofollow" always;
	}
		   include /etc/nginx/nginx_proxy_params;
		   error_log off;
		   proxy_set_header X-Real-IP  \$remote_addr;
		   proxy_set_header X-Forwarded-For \$remote_addr;
		   proxy_set_header Host \$host;
		   proxy_pass http://ngx_backends_502;
		   proxy_set_header X-Forwarded-Proto \$real_scheme;
		   proxy_set_header X-Forwarded-Host \$http_host;
	}
EOT
if grep -q backends_502 /etc/nginx/conf.d/ngx_backends.conf; then
echo 'it is already added'
else cat <<EOT >> /etc/nginx/conf.d/ngx_backends.conf
   upstream ngx_backends_502{
server 127.0.0.1:8081;
}
EOT
fi
nginx -t
/etc/init.d/nginx restart
