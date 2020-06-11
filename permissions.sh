#!/bin/bash
FPM=php$(php -v  | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm
appsDir=/home/master/applications
sed -i -e '/PIDFile/aUMask=0002' /lib/systemd/system/$FPM.service
systemctl daemon-reload
/etc/init.d/php$(php -v  | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm restart 
for i in $(ls -l | grep '^d' | awk '{print $9}'); \
do echo 'Fixing permissions for' $i; \
chown -R $i:www-data $appsDir/$i/public_html; \
find $appsDir/$i/public_html/ \
\( \
-type d -not -perm 775 -exec chmod 775 {} \; \
\) \
-or \
\( \
-type f -not -perm 664 -exec chmod 664 {} \; \
\) \
; done
