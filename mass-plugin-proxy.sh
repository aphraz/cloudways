#!/bin/bash
# The script to be placed on proxy server to be used in conjuction with mass plugin install script. 
# Prepare a file with a new-line delimted list of IPs e.g. ipfile.txt 
# Usage: ./mass-plugin-proxy.sh ipfile.txt


read -p "Enter the URL: " url
{ while read line
do
    echo "Running on: $line" ; ssh -p22 -o StrictHostKeyChecking=no systeam@"$line" URL=${url}  'bash -s' <<'EOF'
/usr/bin/curl -s https://raw.githubusercontent.com/aphraz/cloudways/master/mass-test.sh | sudo bash -s "${URL}"
EOF
echo "Completed on $line"
done < "$1" 
} | tee pluginout.txt
awk '/problem running/{print "App with wp-cli errors: "$2;getline;print "Error log: " $NF}' pluginout.txt
