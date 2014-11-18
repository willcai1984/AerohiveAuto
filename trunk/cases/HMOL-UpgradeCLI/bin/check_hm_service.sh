#!/bin/bash
http_code=$(curl -k -o /dev/null -s -w "%{http_code}\n" "https://$1/hm/authenticate.action")
echo $http_code