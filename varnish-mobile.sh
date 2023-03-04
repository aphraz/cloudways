#!/bin/bash

echo -e "Downloading the device detection VCL"
/usr/bin/curl -s https://raw.githubusercontent.com/aphraz/cloudways/master/devicedetect.vcl > /etc/varnish/devicedetect.vcl

echo -e "Adding necessary includes in and directives (vcl_recv,vcl_hash) /etc/varnish/cloudways.vcl for WordPress"

sed -i -e '/\/etc\/varnish\/vars.vcl/ainclude "/etc/varnish/devicedetect.vcl";' \
-e '/sub vcl_recv/acall devicedetect;' \
-e '/\/etc\/varnish\/https.vcl/i\\tif(req.http.X-UA-Device ~ "^(mobile|tablet)\-.+$") {\n\t\tset req.http.X-UA-Device = "mobile";\n\t} else {\n\t\tset req.http.X-UA-Device = "desktop";\n\t}' \
-e '/\/etc\/varnish\/hash\/geoip.vcl/i\\tif (!(req.url ~ ".(gif|jpg|jpeg|swf|flv|mp3|mp4|pdf|ico|png|gz|tgz|bz2)?($|\\?)")) {\n\t\thash_data(req.http.X-Device);\n\t}' /etc/varnish/cloudways.vcl

echo -e "Adding necessary directives for Magento 2 (/etc/varnish/hash/magento2.vcl)"

cat << _EOF_ >> /etc/varnish/hash/magento2.vcl
	if (!(req.url ~ ".(gif|jpg|jpeg|swf|flv|mp3|mp4|pdf|ico|png|gz|tgz|bz2)?($|\\?)")) {
    hash_data(req.http.X-Device);
  }
_EOF_

echo -e "Restarting Varnish"
echo -e "Please verify if everything is working correctly."
/etc/init.d/varnish restart

