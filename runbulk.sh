#!/bin/bash
read -p "Enter customer's primary email: " email
read -p "Enter the API key: " apikey
read -p "Enter the command to run: " runbulk
ipfile="$1"
echo -e "Retrieving Access Token"

accesstoken="$(curl -s -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data '{"email" : "'$email'", "api_key" : "'$apikey'"}'  'https://api.cloudways.com/api/v1/oauth/access_token'  | jq -r '.access_token')"

echo -e "Retrieving list of server IPs"

curl -s -X GET --header 'Accept: application/json' --header 'Authorization: Bearer '$accesstoken'' 'https://api.cloudways.com/api/v1/server' | jq -r '.servers[] | .public_ip' | tee $ipfile
if [[ -s $ipfile ]]; then 
	while read line
		do
    			echo "Running on: $line" ; ssh -p22 -o StrictHostKeyChecking=no systeam@"$line" "sudo su && sudo $runbulk && echo 'Finished running on: $line' && exit"  < /dev/null
	
	done < "$ipfile"
else
