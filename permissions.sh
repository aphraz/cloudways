#!/bin/bash
FPM=php$(php -v  | head -n 1 | cut -d " " -f2 | cut -d "." -f1,2)-fpm    # Getting PHP version
appsDir=/home/master/applications
if grep -q "UMask=0002" /lib/systemd/system/$FPM.service                 # Making sure the line is not added already
then
    echo "The UMask is already added"                                    
else
    sed -i -e '/PIDFile/aUMask=0002' /lib/systemd/system/$FPM.service    # Setting appropriate Umask for PHP process
    systemctl daemon-reload
    /etc/init.d/$FPM restart 
fi

for i in $(ls -l $appsDir/| grep '^d' | awk '{print $9}')
do 
    echo 'Fixing permissions for' $i 
    chown -R $i:www-data $appsDir/$i/public_html                         # Setting ownership of everything under public_html to application user (Optional) 
    find $appsDir/$i/public_html/ \
        -type d -print0 | xargs -0 chmod 775                             # Correcting permissions for already files and directories
    find $appsDir/$i/public_html/ \
        -type f -print0 | xargs -0 chmod 664
done
