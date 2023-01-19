#!/bin/bash

echo "Please get api details from client's Dashboard first";
read -p "Please enter client's Email: " email <&1;
read -p "Please enter client's API key: " api_key <&1;
JQ="/usr/bin/jq"
if [[ -s $JQ ]]; then

    get_token=$(curl --silent -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' -d 'email='$email'&api_key='$api_key'' 'https://api.cloudways.com/api/v1/oauth/access_token' | jq -r '.access_token');

    temp_json=/tmp/$api_key.json
    json_data=$(curl -s -X GET -H "Authorization: Bearer $get_token" 'https://api.cloudways.com/api/v1/server' > $temp_json);

    server_details=$(cat $temp_json | jq -r '.servers[] | [.id, .public_ip, .label, .cloud, .region, .instance_type]| @csv');

    echo "Below you can see CSV output about servers and apps for client email: $email";
    echo "---------------------------------";
    echo "$server_details" | while read i; do 
    server_id=$(echo $i | cut -d "\"" -f 2); 
    server_ip=$(echo $i | cut -d "\"" -f 4); 
    server_label=$(echo $i | cut -d "\"" -f 6);
    server_provier=$(echo $i | cut -d "\"" -f 8);
    server_region=$(echo $i | cut -d "\"" -f 10);
    server_specs=$(echo $i | cut -d "\"" -f 12);
    echo "Server: ID: $server_id IP: $server_ip Name: $server_label Provider: $server_provier - $server_region ($server_specs)"; 

        for apps in $server_id; do 
            cat $temp_json | jq -r '.servers[] | select(.id == "'$server_id'") | .apps[] | [.id, .sys_user, .label, .app_fqdn, .cname, .application] | @csv';
        done
    done
    echo "---------------------------------";

    rm $temp_json;
    echo "";
else
    echo -n $'\U274E ';
    echo "jq seems to be missing. Please install it with $(tput bold)$(tput setaf 1)sudo apt install jq$(tput sgr0)";
    echo "" ;
fi
