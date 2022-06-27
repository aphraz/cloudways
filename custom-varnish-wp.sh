#!/bin/bash
count=0
APP_DIR="/home/$HOSTNAME"
for app in $(ls -l $APP_DIR/| awk '/^d/ {print $NF}');
	do
		app_type=$(awk '/server_name/ {split($2,a,"-") ; print a[1]; exit}' $APP_DIR/$app/conf/server.nginx)
		if [[ $app_type =~ ^wo ]]; then
			echo "App $app is $app_type. Adding custom VCL."
			cat <<- _EOF_ >> $APP_DIR/$app/conf/custom-recv.vcl
			if (req.url ~ "/(contact)") {
			return (pipe);
			}
			_EOF_
			count=$((count+1))
		else
			echo "The app is $app_type"
		fi
	done
echo "Total WP/WC app processed: $count"
/etc/init.d/varnish restart
