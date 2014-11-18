#!/bin/bas
#EX: sh hppt_request.sh ipaddress cookie_tmp_hm1.txt
LOGINURL="https://$1/hm/authenticate.action"
#UPDATEURL="https://$1/hm/downloadInfo.action?operation=genConfig&amp;&amp;macList=08EA440C4700,0019778D0DC0,08EA440C4B40"
UPDATEURL="https://$1/hm/downloadInfo.action?operation=genConfig&amp;&amp;macPath=/home/auto_ap_mac/ap_mac_list.txt"
#cookie temp file
COOKIEFILE=/tmp/$2

#delete cookie file
if [ -f $COOKIEFILE ]; then
rm $COOKIEFILE
fi
# login
# -d your login information
# -c save cookie to a temp file
# -s silence mode
# -k Allow connections to SSL sites without certs
curl -k "$LOGINURL" -d "userName=admin&amp;password=aerohive&amp;autologin=1" -c $COOKIEFILE -s

# update
sleep 2
curl -k "$UPDATEURL" -b "$COOKIEFILE" -s
#delete cookie file
if [ -f $COOKIEFILE ]; then
rm $COOKIEFILE
fi