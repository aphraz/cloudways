#!/bin/bash

_bold=$(tput bold)
_underline=$(tput sgr 0 1)
_red=$(tput setaf 1)
_green=$(tput setaf 76)
_blue=$(tput setaf 38)
_reset=$(tput sgr0)
export TERM=xterm-256color

function _success ()
{
	printf '%s✔ %s%s\n' "$_green" "$@" "$_reset"
}

function _error () {
    printf '%s✖ %s%s\n' "$_red" "$@" "$_reset"
}

function _note ()
{
    printf '%s%s%sNote:%s %s%s%s\n' "$_underline" "$_bold" "$_blue" "$_reset" "$_blue" "$@" "$_reset"
}

for A in $(ls -l /home/master/applications/| grep "^d" | awk '{print $NF}'); 
	do 
		echo $A && expiry=$(sudo openssl x509 -in /home/master/applications/$A/ssl/server.crt -noout -dates | \
			grep "notAfter" | cut -d '=' -f2)
		current=$(TZ=GMT date --date="now" '+%b %d %H:%M:%S %Y GMT')
		norm_expiry=$(date -d"$expiry" +%s)
		norm_current=$(date -d"$current" +%s)
		if [[ $norm_expiry > $norm_current ]] ; then 
			_note "Certificate will expire on: $expiry" 
		else 
			_error "Certificate expired on: $expiry"
		fi 
	done
