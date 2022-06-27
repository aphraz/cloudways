#!/bin/bash

APP_DIR="/home/$HOSTNAME"
for app in $(ls -l /home/master/applications/| awk '/^d/ {print $NF}');
	do
		app_type=$(awk '/server_name/ {split($2,a,"-") ; print a[1]; exit}' $APP_DIR/$app/conf/server.nginx)
		if [[ $app_type =~ ^wo ]]; then
			echo "App $app is $app_type. Adding custom VCL."
			cat <<- _EOF_ >> $APP_DIR/$app/conf/custom-recv.vcl
			if (req.url ~ "/(contact)") {
			return (pipe);
			}
			_EOF_
		else
			echo "The app is $app_type"
		fi
	done
/etc/init.d/varnish restart
