#!/bin/bash
hostip=$1
username=admin
pwd=aerohive
num=0
echo "start telnet $hostip..."
(
  sleep 1
  echo $username
  sleep 1
  echo $pwd
  sleep 1
  for ((num=1;num<63;num++));
        do
           echo "security-object autocwp walled-garden hostname wall$qaauto.aerohive.com"
           sleep 1
    done
        sleep 1
 ) | telnet $1 