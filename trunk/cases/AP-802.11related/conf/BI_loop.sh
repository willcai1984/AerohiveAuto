#!/bin/bash

 DUT1_WIFI01_MAC=$1
 JUNK_FORMER_TIMESTAMP=$2
 LOGFILE=$3
 U_COMMONBIN=$4
 G_CURRENTLOG=$5
 BEACON_INTERVAL=$6
 CLIENT=$7
 SSID=$8
 TSHARKLOG=$9
 
 if [ $TSHARKLOG ]
 then
     TSHARKLOG="ts_bi_no_default_client.log"
     echo "TSHARKLOG = $TSHARKLOG" > $G_CURRENTLOG/$LOGFILE 
 else
     TSHARKLOG="ts_bi_no_default_no_client.log"
     echo "TSHARKLOG = $TSHARKLOG" > $G_CURRENTLOG/$LOGFILE
 fi

 TEMP_FORMER_TIMESTAMP=$(perl $U_COMMONBIN/parse_pcap.pl -f $G_CURRENTLOG/$TSHARKLOG -k $DUT1_WIFI01_MAC -o "Arrival Time" )
 WIFI01_LATER_TIMESTAMP=$(perl $U_COMMONBIN/parse_pcap.pl -f $G_CURRENTLOG/$TSHARKLOG -k $DUT1_WIFI01_MAC -o "Arrival Time" -n 1)

echo "JUNK_FORMER_TIMESTAMP = $JUNK_FORMER_TIMESTAMP" >> $G_CURRENTLOG/$LOGFILE
echo "FORMER_TIMESTAMP = $TEMP_FORMER_TIMESTAMP" >> $G_CURRENTLOG/$LOGFILE
echo "LATER_TIMESTAMP = $WIFI01_LATER_TIMESTAMP" >> $G_CURRENTLOG/$LOGFILE


if [ $WIFI01_LATER_TIMESTAMP ]

then
     
      WIFI01_FORMER_SN=$(perl $U_COMMONBIN/parse_pcap.pl -f $G_CURRENTLOG/$TSHARKLOG -k $DUT1_WIFI01_MAC -o "Sequence number")
     
     echo "WIFI01_FORMER_SN = $WIFI01_FORMER_SN" >> $G_CURRENTLOG/$LOGFILE
     
      WIFI01_LATER_SN=$(perl $U_COMMONBIN/parse_pcap.pl -f $G_CURRENTLOG/$TSHARKLOG -k $DUT1_WIFI01_MAC -o "Sequence number" -n 1) 
     
     echo  "WIFI01_LATER_SN = $WIFI01_LATER_SN" >> $G_CURRENTLOG/$LOGFILE
     
     SN01=`expr $WIFI01_LATER_SN - $WIFI01_FORMER_SN`
     echo "SN01 = $SN01" >> $G_CURRENTLOG/$LOGFILE
     
     if [ $SSID ]
     then
            echo "SSID = $SSID" >> $G_CURRENTLOG/$LOGFILE
     		BI01=`echo "scale=6;$SN01*$BEACON_INTERVAL*3"|bc`
     		echo "BI01 = $BI01" >> $G_CURRENTLOG/$LOGFILE
     
     else
            echo "SSID = $SSID" >> $G_CURRENTLOG/$LOGFILE
     		BI01=`echo "scale=6;$SN01*$BEACON_INTERVAL"|bc`
     		echo "BI01 = $BI01" >> $G_CURRENTLOG/$LOGFILE
     fi
     
     TS01=`echo "scale=6;$WIFI01_LATER_TIMESTAMP-$TEMP_FORMER_TIMESTAMP"|bc`
     if [ -z $TS01 ]
     		then 
     		exit 0
     
     else		
	     echo "TS01 = $TS01" >> $G_CURRENTLOG/$LOGFILE
	     
	     ERR_RANGE01=`echo "scale=6;$BI01-$TS01"|bc`
	     echo "ERR_RANGE01 = $ERR_RANGE01" >> $G_CURRENTLOG/$LOGFILE
	     
	     ERR_RANGE01=${ERR_RANGE01#-}
	     echo "ERR_RANGE01 = $ERR_RANGE01" >> $G_CURRENTLOG/$LOGFILE
	     
	     ERR_RANGE_PERCENT01=`echo "scale=2;$ERR_RANGE01/$BI01"|bc`
	     echo "ERR_RANGE_PERCENT01 = $ERR_RANGE_PERCENT01" >> $G_CURRENTLOG/$LOGFILE
	     
	     if [ -z $CLIENT ]
	     then
	            echo "CLIENT = NO CLIENT" >> $G_CURRENTLOG/$LOGFILE
	           		if [ "$(echo "$ERR_RANGE_PERCENT01 > 2"|bc)" -eq "1" ]
	     		then 
	     			exit 1
	     		fi
	     else
	            echo "CLIENT = HAS CLIENT" >> $G_CURRENTLOG/$LOGFILE
	            if [ "$(echo "$ERR_RANGE_PERCENT01 > 0.2"|bc)" -eq "1" ]
	     		then 
	     			exit 1
	     		fi
	  		fi
	 fi
fi
  
exit 0 
     
