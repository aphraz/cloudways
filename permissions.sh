#!/bin/bash
FPM=php$(php -v  | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm
appsDir=/home/master/applications
if grep -q "UMask=0002" /lib/systemd/system/$FPM.service
then
    echo "The UMask is already added"
else
    sed -i -e '/PIDFile/aUMask=0002' /lib/systemd/system/$FPM.service
    systemctl daemon-reload
    /etc/init.d/$FPM restart 
fi
source ~/.bashrc
for i in $(ls -l $appsDir/| grep '^d' | awk '{print $9}')
do 
    echo 'Fixing permissions for' $i 
    chown -R $i:www-data $appsDir/$i/public_html
    find $appsDir/$i/public_html/ \
        -type d -not -perm 775 -print0 | xargs -0 chmod 775
    find $appsDir/$i/public_html/ \
        -type f -not -perm 664 -print0 | xargs -0 chmod 664
done
