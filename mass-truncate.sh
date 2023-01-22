#!/bin/bash
count=0
APP_DIR="/home/$HOSTNAME"
for app in $(ls -l $APP_DIR/| awk '/^d/ {print $NF}');
	do
		app_type=$(awk '/server_name/ {split($2,a,"-") ; print a[1]; exit}' $APP_DIR/$app/conf/server.nginx)
		if [[ $app_type =~ ^wo ]]; then
			. /etc/profile
			webroot="$(awk '/DocumentRoot/ {print $2}' /etc/apache2/sites-available/${app}.conf)"
			echo "App $app is $app_type. Truncating the comments tables."
			prefix="$(sudo /usr/bin/awk -F "'" '/table_prefix/ {print $2}' {webroot}/wp-config.php)"
			sudo mysql -e "TRUNCATE ${app}.${prefix}commentmeta;"
			sudo mysql -e "TRUNCATE ${app}.${prefix}comments;"
			count=$((count+1))
		else
			echo "App $app is $app_type. Skipping..."
		fi
	done
echo "Total WP/WC app processed: $count"
