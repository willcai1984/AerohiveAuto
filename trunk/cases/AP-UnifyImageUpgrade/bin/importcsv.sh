#!/bin/bash
usage="$(basename "$0") [-h]  program to import csv performance test result to database 

where:
    -h  show this help text

     $(basename "$0") <test result file> <pass:fail>  <build>  <testlog url>
     $(basename "$0")  qt_ap340_gre_inxp_20140107-8713.csv pass 'HiveOS 6.1r4 release build1547' 'http://www.log.com/link1'

     Note: result file should be in format of qt_PlatformName_TestName_Date"

        while getopts 'h' option; do
          case "$option" in
              h) echo "$usage"
                     exit
                     ;;
          esac
        done

#check if all the filed has been typed
if [ $# -ne 4 ]
then
 echo "$usage"
 exit  -1
fi

INPUT=$1
OLDIFS=$IFS
IFS=,
i=1
MYSQL=`which mysql`

who=HZ
result=$2
build=$3
testlog=$4
version=$(echo $3 | awk '{ print $2 }')

#set platform and test case name from result file
testAp=$(echo $1 | awk -F _ '{ print $2 }')
testname=$(echo $1 | egrep -o 'gre_inxp|l2vpn_client_to_server|l2vpn_server_to_client|l2_bridge_access|as_br_l3_lan_to_wan_nat|as_br_lan_to_vpn|as_br_vpn_to_lan|l2_lan_to_lan|l3_cross_vlan|l3_lan_to_wan_nat|lan_to_vpn|vpn_to_lan')


if [[ -z  "$version" ]]
then
 echo "No test version information $version"
  exit  -1
fi

if [[ -z  "$testAp" ]]
then
 echo "No platform information $testAp"
  exit  -1
fi

myvar=$($MYSQL -Dsystest -uroot -h10.16.129.151 -e "insert into TestInfo (Type_ID,submitter,Version,Build, platform,result,TestName,testlog ) values ( 3,'$who','$version','$build','$testAp','$result', '$testname','$testlog'); SELECT MAX(Test_ID) from TestInfo")

Test_ID=$(echo -e "$myvar" | awk 'NR==2')

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read Trial Framesize Iteration dummy1 dummy2 dummy3 dummy4 TxRateP RxThroughputP Rxfps  RxMbps TxC  RxC FrameLossC FrameLossP MinLatency MaxLatency AvgLatency SmallError BigError ReverseError TotalError DataIntegrityE
do
        test $i -eq 1 && ((i=i+1)) && continue
        $MYSQL systest -u root -h10.16.129.151 -e "insert into wired_perf(Test_ID,Trial,Framesize,Iteration,TxRateP,RxThroughputP,Rxfps,RxMbps,TxC,RxC,FrameLossC,FrameLossP,MinLatency,MaxLatency,AvgLatency,SmallError,BigError,ReverseError,TotalError,DataIntegrityE) values ('$Test_ID','$Trial','$Framesize','$Iteration','$TxRateP','$RxThroughputP','$Rxfps','$RxMbps','$TxC','$RxC','$FrameLossC','$FrameLossP','$MinLatency','$MaxLatency','$AvgLatency','$SmallError','$BigError','$ReverseError','$TotalError','$DataIntegrityE')"
done < $INPUT 
IFS=$OLDIFS
