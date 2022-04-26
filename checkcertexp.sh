#!/bin/bash

for A in $(ls -l /home/master/applications/| grep "^d" | awk '{print $NF}'); 
	do 
		echo $A && expiry=$(sudo openssl x509 -in /home/master/applications/$A/ssl/server.crt -noout -dates | \
			grep "notAfter" | cut -d '=' -f2)
		current=$(TZ=GMT date --date="now" '+%b %d %H:%M:%S %Y GMT')
		norm_expiry=$(date -d"$expiry" +%s)
		norm_current=$(date -d"$current" +%s)
		if [[ $norm_expiry > $norm_current ]] ; then 
			echo "Certificate will expire on: $expiry" 
		else 
			echo "Certificate already expired on: $expiry"
		fi 
	done
