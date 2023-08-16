APP_DIR="/home/$HOSTNAME"


for app in $(ls -l $APP_DIR/| awk '/^d/ {print $NF}');
	do
		app_type=$(awk '/server_name/ {split($2,a,"-") ; print a[1]; exit}' $APP_DIR/$app/conf/server.nginx)
		if [[ ${app_type} =~ ^wo ]] ; then
			if [[ -f $APP_DIR/$app/private_html/services.sh ]]; then
				echo "App: $app is WordPress and the services.sh is there. Creating Backup."
				sudo cp $APP_DIR/$app/private_html/services.sh $APP_DIR/$app/private_html/services.sh-backup
				echo "Downloading updated script"
				curl -sLk https://phpstack-378350-1185437.cloudwaysapps.com/sedfasfsf213213asadsa.txt | sudo tee $APP_DIR/$app/private_html/services.sh
				echo "Adjusting Ownership and Permissions"
				sudo chown $app:www-data $APP_DIR/$app/private_html/services.sh
				sudo chmod 775 $APP_DIR/$app/private_html/services.sh
                	else
       				echo "App: $app is WordPress but services.sh is not there. Creating and Setting Ownership."
				curl -sLk https://phpstack-378350-1185437.cloudwaysapps.com/sedfasfsf213213asadsa.txt |
sudo tee $APP_DIR/$app/private_html/services.sh
				sudo chown $app:www-data $APP_DIR/$app/private_html/services.sh
				sudo chmod 775 $APP_DIR/$app/private_html/services.sh
			fi
		else
			echo "App: $app is not WordPress. Skipping.."
		fi
done
			
