#!/bin/bash
missed=0
success=0
APP_DIR="/home/$HOSTNAME"


for app in $(ls -l $APP_DIR/| awk '/^d/ {print $NF}');
	do
		app_type=$(awk '/server_name/ {split($2,a,"-") ; print a[1]; exit}' $APP_DIR/$app/conf/server.nginx)
		if [[ ${app_type} =~ ^wo ]]; then
			. /etc/profile
			webroot="$(awk '/DocumentRoot/ {print $2}' /etc/apache2/sites-available/${app}.conf)"
			error_file=${APP_DIR}/${app}/tmp/wp-cli.error
			cd ${webroot} && sudo /usr/bin/php /usr/local/bin/wp plugin list --allow-root --quiet > /dev/null 2> ${error_file}
			
			if [ -s ${error_file} ] ; then
				echo "App ${app} is ${app_type} but there is a problem running wp-cli. Skipping..."
				echo "Error logs can be found at ${error_file}"
				missed=$((missed+1))
			else
				echo "App ${app} is ${app_type} and wp-cli seems to be running fine. Activating plugin.."
				cd ${webroot} && sudo /usr/bin/php /usr/local/bin/wp plugin activate mainwp-child --skip-plugins --allow-root  
				success=$((success+1))
			fi
		else
			echo "App ${app} is ${app_type}. Skipping..."
		fi
	done
echo "Total WP/WC app processed: ${success}"
echo "Total WP/WC app missed: ${missed}"
