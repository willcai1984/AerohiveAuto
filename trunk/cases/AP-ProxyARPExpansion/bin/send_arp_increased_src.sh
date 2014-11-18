#!/bin/sh

# Send a lot of arp request packets to dst-ip, who's src-mac and src-ip is increased.
# $1: parameter of pkt -i,  specify outgoing interface
# $2: parameter of pkt -d,  set destination ip
# $3: parameter of pkt -N, set destination mac address
# $4: packet numbet you want to send
a=0
b=0
mac=0
for (( i=0; i<$4; i=i+1 )) 
do
   b=$(($b+1))
   mac=$(($mac+1))
   if [ "254" == "$b" ]; then
       a=$(($a+1))
       b=0
   fi
  
   length=$(echo `printf '%x' $mac` | awk '{print length()}')
   if [ $length -le 2 ]; then
       c=0
       d=$(echo `printf '%x' $mac`)
   fi
 
   if [ $length -eq 3 ]; then
       c=$(echo `printf '%x' $mac` | awk '{printf substr($0, length()-2, 1)}')
       d=$(echo `printf '%x' $mac` | awk '{printf substr($0, length()-1, 2)}')
   fi

   if [ $length -eq 4 ]; then
       c=$(echo `printf '%x' $mac` | awk '{printf substr($0, length()-3, 2)}')
       d=$(echo `printf '%x' $mac` | awk '{printf substr($0, length()-1, 2)}')
   fi

   echo $c
   echo $d

   nohup pkt -i $1 -d $2 -m 192.168.$a.$b -N $3 -M 00:11:22:33:$c:$d -p arpreq &
done

