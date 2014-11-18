puts "ahIxosapi.tcl Initialed"
#puts "source ahIxosapi.tcl start"
# 
# ixia_connect 10.155.33.216 AH_ATUserHLT 1/3/15,1/3/16 10.155.30.164
# proc  ixia_connect {args} {
##proc  ixia_connect {chassisIPIn userName portListIn tclServer} {
##	set portList [pLconn $portListIn]
##	puts "portList is $portList"
##	set connect_info [ixia::connect\
##	-device $chassisIPIn\
##	-username $userName\
##	-port_list $portList\
##	-tcl_server $tclServer]
##	#ixPuts "connect_info is:$connect_info"
##	set portList2 [pLproc $portListIn]
##	SetPortDefaultValue $portList2
##	ixPuts "Setting ports $portList2 to factory defaults..."
##}

set allPortHandList [ list ]
# for port statistic
set stList [ list ]
# for Qos statistic
#set qossStList [ list ]
# for Multi stream statistic
set streamStList [ list ]
set ixNConnetedFlag "False"
#
#description:connect to chassis and occupy specified port forcely
#port format:chassis_number/card_number/port_number 1/3/15 means chassis 1，card 3，port 15；
#
proc ah_ixia_connect {args} {
	######### parameter process start
	set argformat {
		{ chassisIP 	chassisIP 	required string "chassisIP,like 10.155.33.216" }
		{ userName	userName 	required string "userName,like ahATclchen or ${job.user}${job.sid}" }
		{ portList	portList 	required string "portListIn,like 1/3/15 or like 1/3/15,1/3/16" }
		{ tclServerIP	tclServerIP	required string "tclServerIP,now it is 10.155.30.164" }
		{ def		def		optional string "set Port to factory default and clear exist stream,disable|enable,default is enable" }
		{ timeOut	timeOut	optional string "set timeOut, default is 180" }
		{ phyList	phyList		required string "config phy_mode,copper|fiber|10GE_fiber,multiport input like copper,copper or like fiber,fiber"}
		{ zcallExample	zcallExample	optional string "ah_ixia_connect -def enable -chassisIP 10.155.33.216 -tclServerIP 10.155.30.178 -userName AH_ATUserHLT2 -portList 1/3/15,1/3/16 -phyList copper,copper"}
	}
	# set optional parameter default value
	set arg(tclServerIP)	10.155.30.164
	set arg(def)	enable
	set arg(phyList)	copper
	set arg(timeOut) 180
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	set chassisIP	$arg(chassisIP)
	puts "chassisIP is $chassisIP" 
	set userName	$arg(userName)
	set portListIn	$arg(portList)
	set tclServerIP	$arg(tclServerIP)
	set phyListIn	$arg(phyList)
	puts "phyListIn is $phyListIn"
	puts "tclServerIP $tclServerIP"
	puts "arg(def) is $arg(def)"
	set def			$arg(def)
	puts "def is $def"
	set timeOut $arg(timeOut)
	puts "timeOut is $timeOut"
	
	set portDefault $def
	#function start
	set phyList [split $phyListIn ","]
	set portList [pLconn $portListIn]
	puts "portList is $portList"
	set portHandle [pLhand $portListIn]
	
	#if [ expr { $portDefault == "enable"  } ] { 
	#	ixDisconnectTclServer
	#}
	
	set time1 [clock seconds]
	set connect_info [ixia::connect\
	-device $chassisIP\
	-username $userName\
	-port_list $portList\
	-connect_timeout $arg(timeOut)\
	-tcl_server $tclServerIP]
	set time2 [clock seconds]
	set detT [expr {$time2 - $time1}] 
	puts "--ixia::connect Elapsed time is $detT --"
	
	if { [keylget connect_info status] != 1 } {
		ixPuts "ixia::connect is failed, the connect_info is:$connect_info"
		exit 1
	} else {
		ixPuts "the connect_info is $connect_info"
	}
	global allPortHandList
	
	foreach port $portList {
		lappend allPortHandList [keylget connect_info port_handle.$chassisIP.$port]
		#puts "allPortHandList before is $allPortHandList"
		set allPortHandList [lsort -unique $allPortHandList]
		#puts "allPortHandList unique after is $allPortHandList"
	}
	puts "allPortHandList now is $allPortHandList"
	
	set portList2 [pLproc $portListIn]
	#set a [expr { $portDefault == "enable" }]
	#puts "a is $a"
	#set b [ expr { $portDefault == "disable" }]
	#puts "b is $b"
	if [ expr { $portDefault == "enable"  } ] {
		#SetPortDefaultValue $portList2
		#for remove exist stream under the $portHandle
		foreach phandle $portHandle {
			#puts "phandle $phandle is resetting to default phy"
			
			#set traffic_info [ixia::traffic_config \
			#	-mode reset \
			#	-port_handle $phandle\
			#	-traffic_generator ixos\
			#	-vlan disable ]
			#if {[keylget traffic_info status] == $::FAILURE} {
			#	puts "Failed to remove exist traffic streams in ah_ixia_connect: \
			#	[keylget traffic_info log]"
			#	return
			#} else {
			#	puts "phandle $phandle reset to default success,$traffic_info"
			#}
			
			set phListItem [split $phandle /]
			puts "phListItem is $phListItem"
			scan $phListItem "%d %d %d" chassis card port
			if [port setFactoryDefaults $chassis $card $port] {
				puts "Error setting factory defaults on $chassis.$card.$port]."
				return $::TCL_ERROR
			}
			set portListTemp1 [list [list $chassis $card $port] ]
			if {[ixWritePortsToHardware portListTemp1]} {
				puts "Error ixWritePortsToHardware on portListTemp1 $portListTemp1"
				return $::TCL_ERROR
			}
			
			if [port reset $chassis $card $port] {
				puts "port reset $chassis $card $port failed"
			} else {
				puts "ports reset $chassis $card $port ok"
			}
			if [port write $chassis $card $port] {
				puts "port write $chassis $card $port failed"
			} else {
				puts "ports write $chassis $card $port ok"
			}
			after 500
			#check portTransmitMode is portTxPacketStreams
			portDefaultCheck $chassis $card $port 
		}
		
		#clear stream sepcial process for 10GE_fiber port
		
		#foreach phandleItem $portHandle phyItem $phyList {
		#	if { [expr {$phyItem=="10GE_fiber"}] } {
		#		puts "phandleItem $phandleItem is under clearing streams"
		#		set phListItem [split $phandleItem /]
		#		puts "phListItem is $phListItem"
		#		scan $phListItem "%d %d %d" chassis card port
		#		port setFactoryDefaults $chassis $card $port
		#		port reset $chassis $card $port
		#		port set $chassis $card $port
		#		#write
		#		if { [port write $chassis $card $port] } {
		#			return [print_Report "failed to write port configuration on port $chassis $card $port to hardware" 1]
		#		}
		#		#portDeleteStreams $chassis $card $port ""
		#	}
		#}
		
		ixPuts "Setting ports $portList2 to factory defaults and clear stream..."
	}
	
	if [ expr { $portDefault == "disable" } ] {
		ixPuts "keep $portList2 with previous settings,just take them"
	}
	
	
	#add -phy option,will write config to hardware by ccl 2013/4/12, 
	#set phList [list {1 3 15} {1 3 16}]
			#set portHandle [list 1/3/15 1/3/16]
			#puts "portHandle is $portHandle"
			#set phyList [list fiber fiber]
			#puts "phyList is $phyList"
	#dfault not to set copper
	set execFlag 0
	foreach phandleItem $portHandle phyItem $phyList {
		if { [expr {$phyItem == ""}] } {
			puts "phyItem is null,it is not correct input"
			exit 1
		}
		if { [expr {$phyItem == "copper" && $execFlag == 1 && $portDefault == "enable"}] } {
			puts "phandleItem $phandleItem is setting phy to copper mode when execFlag 1"
			set phListItem [split $phandleItem /]
			puts "phListItem is $phListItem"
			scan $phListItem "%d %d %d" chassis card port
				#scan $item "%d %d %d" chasId card port
				#set chassis [lindex $phListItem 0]
				#set card [lindex $phListItem 1]
				#set port [lindex $phListItem 2]
				#set chassis 1
				#set card 3
				#set port 16
			puts "chassis is $chassis"
			puts "card is $card"
			puts "port is $port"
			
			##clchen 2014/1/20 port 1 2 1 and port 1 2 3 can't be effective on port's property
			#port reset $chassis $card $port
			#port write $chassis $card $port
			#after 1000
			
			##can't overwrite exist config
			##port setFactoryDefaults $chassis $card $port
			if {[port setPhyMode $::portPhyModeCopper $chassis $card $port]} {
				errorMsg "Error calling port setPhyMode $::portPhyModeCopper $chassis $card $port"
				set retCode $::TCL_ERROR
			}
			port config -speed                              1000
			port config -duplex                             full
			port config -flowControl                        false
			port config -loopback                           portNormal
			port config -transmitMode                       portTxPacketStreams
			port config -receiveMode                        [expr $::portCapture]
			port config -autonegotiate                      true
			port config -advertise100FullDuplex             true
			port config -advertise100HalfDuplex             true
			port config -advertise10FullDuplex              true
			port config -advertise10HalfDuplex              true
			port config -advertise1000FullDuplex            true
			port config -portMode                           portEthernetMode
			port config -enableDataCenterMode               false
			port config -dataCenterMode                     eightPriorityTrafficMapping
			port config -flowControlType                    ieee8023x
			port config -pfcEnableValueListBitMatrix        ""
			port config -pfcResponseDelayEnabled            0
			port config -pfcResponseDelayQuanta             0
			port config -rxTxMode                           gigNormal
			port config -ignoreLink                         false
			port config -advertiseAbilities                 portAdvertiseNone
			port config -timeoutEnable                      true
			port config -negotiateMasterSlave               1
			port config -masterSlave                        portSlave
			if {[port set $chassis $card $port]} {
				errorMsg "Error calling port set $chassis $card $port"
				set retCode $::TCL_ERROR
			}
			set portListT [list [list $chassis $card $port] ]
			if {[ixWritePortsToHardware portListT -noProtocolServer]} {
				ixPuts "ixWritePortsToHardware error on $portListT"
				return $::TCL_ERROR
			}
			
			##in loop can not check state
			##	if {[ixCheckLinkState portListT] !=0 } {
			##		ixPuts "May be linkDown on $portListT"
			##		return -code error
			##	}
		}
		
		if { [expr {$phyItem=="fiber" && $portDefault == "enable"}] } {
			puts "phandleItem $phandleItem is setting phy to fiber mode"
			#set interface_info [::ixia::interface_config \
			#-port_handle $phandleItem \
			#-mode config \
			#-autonegotiation 1\
			#-phy_mode fiber ]
			#if {[keylget interface_info status] == $::FAILURE} {
			#puts "Failed to set phy_mode in ah_ixia_connect: \
			#[keylget interface_info log]"
			#return 1
			#}
			
			
			set portListItemTemp [split $phandleItem "/"]
			set chas [lindex $portListItemTemp 0]
			set card [lindex $portListItemTemp 1]
			set port [lindex $portListItemTemp 2]  
			#get
			if { [port get $chas $card $port] } {
				return [print_Report "error getting port $chas $card $port" 1]
			}
			#Config Port Phy Mode
			if {[port setPhyMode $::portPhyModeFiber $chas $card $port]} {
				errorMsg "Error calling port $::portPhyModeFiber $phyItem $chas $card $port"
				set retCode $::TCL_ERROR
				puts "retCode is $retCode"
			}
			#config fiber mode with defaut value
			port config -autonegotiate  true
			port config -advertise10FullDuplex   false
			port config -advertise10HalfDuplex   false
			port config -advertise100FullDuplex  false
			port config -advertise100HalfDuplex  false
			port config -advertise1000FullDuplex true
			port config -speed 1000
			port config -operationModeList [list $::portOperationModeStream]

			#config transmitMode under fiber mode
				#port config -transmitMode   portTxPacketFlows 
			port config -transmitMode portTxModeAdvancedScheduler
			if [ixSetPortPacketFlowMode $chas $card $port write] {
				return [print_Report "Set Port to PortPacketFlowMode Failed" 1]
			}
			#config pub field
			port config -advertiseAbilities portAdvertiseNone
			port config  -enableSimulateCableDisconnect false
			
			if { [port set $chas $card $port] } {
				puts "showCmd port is [showCmd port]"
				catch {port set $chas $card $port} myerror 
				puts "myerror is $myerror"
				return [print_Report "failed to set port configuration on port $chas $card $port" 1]
			}
			
			if { [stat set $chas $card $port] } {
				return [print_Report "failed to set stat configuration on port $chas $card $port" 1]
			}
					
			if { [port write $chas $card $port] } {
				return [print_Report "failed to write port configuration on port $chas $card $port to hardware" 1]
			}
			#ah_port_config -onePort $phandleItem -speed 1000  -phyMode fiber -waitTime 3
		}
		
		if { [expr {$phyItem=="10GE_fiber"}]  } {
			puts "phandleItem $phandleItem is setting phy to 10GEfiber mode"
			
			
			set portListItemTemp [split $phandleItem "/"]
			set chassis [lindex $portListItemTemp 0]
			set card [lindex $portListItemTemp 1]
			set port [lindex $portListItemTemp 2] 
			
			
			#port setFactoryDefaults $chassis $card $port
			port get $chassis $card $port
			port config -speed                              10000
			port config -duplex                             full
			port config -flowControl                        true
			port config -directedAddress                    "01 80 C2 00 00 01"
			port config -multicastPauseAddress              "01 80 C2 00 00 01"
			port config -loopback                           portNormal
			port config -transmitMode                       portTxPacketStreams
			port config -receiveMode                        [expr $::portCapture]
			port config -autonegotiate                      false
			port config -advertise100FullDuplex             false
			port config -advertise100HalfDuplex             false
			port config -advertise10FullDuplex              false
			port config -advertise10HalfDuplex              false
			port config -advertise1000FullDuplex            false
			port config -portMode                           port10GigLanMode
			port config -enableDataCenterMode               false
			port config -dataCenterMode                     eightPriorityTrafficMapping
			port config -flowControlType                    ieee8023x
			port config -pfcEnableValueListBitMatrix        ""
			port config -pfcResponseDelayEnabled            0
			port config -pfcResponseDelayQuanta             0
			port config -rxTxMode                           gigNormal
			port config -ignoreLink                         false
			port config -advertiseAbilities                 portAdvertiseNone
			port config -timeoutEnable                      true
			port config -negotiateMasterSlave               0
			port config -masterSlave                        portSlave
			port config -pmaClock                           pmaClockAutoNegotiate
			port config -enableSimulateCableDisconnect      false
			port config -enableAutoDetectInstrumentation    false
			port config -autoDetectInstrumentationMode      portAutoInstrumentationModeEndOfFrame
			port config -enableRepeatableLastRandomPattern  false
			port config -transmitClockDeviation             0
			port config -transmitClockMode                  portClockInternal
			port config -preEmphasis                        preEmphasis0
			port config -transmitExtendedTimestamp          0
			port config -operationModeList                  [list $::portOperationModeStream]
			port config -MacAddress                         "00 de bb 00 00 01"
			port config -DestMacAddress                     "00 de bb 00 00 02"
			port config -name                               ""
			port config -numAddresses                       1
			port config -enableManualAutoNegotiate          false
			port config -enablePhyPolling                   true
			port config -enableTxRxSyncStatsMode            false
			port config -txRxSyncInterval                   0
			port config -enableTransparentDynamicRateChange false
			port config -enableDynamicMPLSMode              false
			port config -enablePortCpuFlowControl           false
			port config -portCpuFlowControlDestAddr         "01 80 C2 00 00 01"
			port config -portCpuFlowControlSrcAddr          "00 00 01 00 02 00"
			port config -portCpuFlowControlPriority         "1 1 1 1 1 1 1 1"
			port config -portCpuFlowControlType             0
			port config -enableWanIFSStretch                false
			port config -enableRestartStream                false
			#config to HAL
			if {[port set $chassis $card $port]} {
				errorMsg "Error calling port set $chassis $card $port"
				set retCode $::TCL_ERROR
			}
			#write
			if { [port write $chassis $card $port] } {
				return [print_Report "failed to write port configuration on port $chassis $card $port to hardware" 1]
			}
		}
		
		
	}

}


#decription:configure port's negotiation property
#in para
#onePort like 1/3/15
#speed 10|100|1000
#duplexMode half|full
#autonegotiate true|false
#advertiseAbilities portAdvertiseNone|portAdvertiseSend|portAdvertiseSendAndReceive|portAdvertiseSendAndOrReceive
#phyMode copper|fiber
#10fullIn true|false
#10halfIn true|false
#100fullIn true|false
#100halfIn true|false
#1000fullIn true|false
# out 0 is ok
# out not 0 is error
proc ah_port_config {args} {
	######### parameter process start
	set argformat {
		{onePort	onePort	required	string	"onePort,like 1/3/15"}
		{speed		speed	optional	string	"speed default is 1000,10|100|1000"}
		{duplexMode	duplexMode	optional	string	"duplexMode,half|full,default is full"}
		{autonegotiate	autonegotiate	optional	string	"autonegotiate,true|false,default is true"}
		{advertiseAbilities	advertiseAbilities	optional	string	"advertiseAbilities,portAdvertiseNone|portAdvertiseSend|portAdvertiseSendAndReceive|portAdvertiseSendAndOrReceive,default is portAdvertiseSendAndOrReceive"}
		{phyMode	phyMode	optional	string	"phyMode,copper|fiber,default is copper"}
		{10fullIn	10fullIn	optional	string	"10fullIn,true|false,default is true"}
		{10halfIn	10halfIn	optional	string	"10halfIn,true|false,default is true"}
		{100fullIn	100fullIn	optional	string	"100fullIn,true|false,default is true"}
		{100halfIn	100halfIn	optional	string	"100halfIn,true|false,default is true"}
		{1000fullIn	1000fullIn	optional	string	"1000fullIn,true|false,default is true"}
		{cable		cable		optional	string	"Simulate cable disconnect or connect,default is connect,valid is connect|disconnect"}
		{flowControl	flowControl	optional	string	"flowControl,default is false,valid is true|false"}
		{waitTime	waitTime	optional	string	"take waitTime to let port autonegotiate,default is 5,it means 5 seconds"}
		{zcallexample	zcallexample	optional	string	"ah_port_config -onePort 1/3/16  -autonegotiate true  -advertiseAbilities portAdvertiseSendAndReceive -flowControl true"}
	}
	# set optional parameter default value
	set arg(speed)	1000
	set arg(duplexMode)	full
	set arg(autonegotiate)	true
	set arg(advertiseAbilities) portAdvertiseSendAndOrReceive
	set arg(phyMode) copper
	set arg(10fullIn) true
	set arg(10halfIn) true
	set arg(100fullIn) true
	set arg(100halfIn) true
	set arg(1000fullIn) true
	set arg(cable) connect
	set arg(flowControl) false
	set arg(waitTime) 5
	
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	set onePort	$arg(onePort)
	puts "onePort is $onePort"
	set speed	$arg(speed)
	puts "speed is $speed"
	set duplexMode $arg(duplexMode)
	puts "duplexMode is $duplexMode"
	set autonegotiate $arg(autonegotiate)
	puts "autonegotiate is $autonegotiate"
	set advertiseAbilities $arg(advertiseAbilities)
	puts "advertiseAbilities is $advertiseAbilities"
	set phyMode $arg(phyMode)
	puts "phyMode is $phyMode"
	set 10fullIn $arg(10fullIn)
	puts "10fullIn is $10fullIn"
	set 10halfIn $arg(10halfIn)
	puts "10halfIn is $10halfIn"
	set 100fullIn $arg(100fullIn)
	puts "100fullIn is $100fullIn"
	set 100halfIn $arg(100halfIn)
	puts "100halfIn is $100halfIn"
	set 1000fullIn $arg(1000fullIn)
	puts "1000fullIn is $1000fullIn"
	set cable $arg(cable)
	puts "cable is $arg(cable)"
	if { [expr {$cable=="disconnect"}] } {
		set enableSimulateCableDisconnect "true"
	} elseif { [expr {$cable=="connect"}] } {
		set enableSimulateCableDisconnect "false"
	} else {
		puts "cable value input is illegal,the valid value is disconnect or connect"
	}
	set flowControl $arg(flowControl)
	puts "flowControl is $flowControl"
	
	set waitTime [expr {$arg(waitTime)*1000}]
	puts "waitTime is $waitTime"
	
	set ret [ahPortConfig $onePort $speed $duplexMode $autonegotiate $advertiseAbilities $phyMode $10fullIn $10halfIn $100fullIn $100halfIn $1000fullIn $enableSimulateCableDisconnect $flowControl $waitTime]
	
	puts "ah_port_config result is $ret"
	return $ret
}
# Copyright 2014, clchen, Aerohive
# Version: 1.0
# Date: 2014-10-17
#
# History:
#  version 1.0: 2014.10.17 by clchen, clchen@aerohive.com
#
# Description:
#  specify udf number to complete udf config, without udf setDefault
#
# -portList			$portList			like 1/1/13,1/1/14
# -streamId 		$streamId			(optional) default 56， 0 is firt number,start from 56byte,it will be filled with udf_value of 32bit
# -udfNum			$udfNum				(optional) default 3, it will set for udf3 by default
# -udf_value		$udf_value			(optional) default 0xBDBDBDBD
# call example
# ah_udf_config -portList 1/1/13 -streamId 1 -udf_num 4 -udf_offset 60 -udf_value 0xAABBCCDD
proc ah_udf_config {args} {
	set retV 0
	set argformat {
		{ portList portList required string "portList,like 1/1/13,1/1/14 " }
		{ streamId streamId required string "defaut 1,like 1,2 or 3 ..."}
		{ udf_num udf_num optional string "default 3,like 3 or 4" }
		{ udf_offset udf_offset optional string "UDF Offset,default 56,0 is firt number" }
		{ udf_value udf_value optional string "UDF Value,default 0xBDBDBDBD" }
		{ zcallExample	zcallExample	optional	string	"ah_udf_config -portList 1/1/13,1/1/14 -streamId 1 -udf_num 4 -udf_offset 60 -udf_value 0xAABBCCDD "}
	}
	# set optional parameter default value
	set arg(udf_offset) 56
	set arg(udf_value) 0xBDBDBDBD
	set arg(streamId) 1
	set arg(udf_num) 3
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	parray arg

	#set portList [pLproc $arg(portList)]
	set portListIn $arg(portList)
	puts "portListIn is $portListIn"
	set udf_offset $arg(udf_offset)
	puts "udf_offset is $udf_offset"
	set udf_value $arg(udf_value)
	puts "udf_value is $udf_value"
	set streamId $arg(streamId)
	set udfNum $arg(udf_num)

	#package req IxTclHal

	#set portList [pLproc $portListIn]
	#puts "portList before set udf is $portList"
	#portList is {1 3 15} {1 3 16}
	set portHandleTemp [split $portListIn ","]
	puts "portHandleTemp is $portHandleTemp "
	foreach item $portHandleTemp {
		puts "item is $item"
		set phListItem [split $item "/"]
		puts "phListItem is $phListItem"
		scan $phListItem "%d %d %d" chasId card port
		puts "chasId card port is $chasId $card $port"
		
		puts "chasId card port streamId is $chasId $card $port $streamId"
		puts "begin set udf $udfNum"
		udf get $udfNum
		#udf setDefault
		if [expr {$udf_offset !="" && $udf_offset != 56 }] {
			udf config -offset $udf_offset
		} else {
			udf config -offset 56
			#eval udf config -offset $::gUdf_offset
		}
		if [expr {$udf_value !="" && $udf_value != 0xBDBDBDBD }] {
			udf config -initval $udf_value
		} else {
			udf config -initval 0xBDBDBDBD
			#eval udf config -initval $::gUdf_value
		}
		
		#others set the default
		udf config -enable				true
		udf config -continuousCount		false
		udf config -counterMode			udfCounterMode
		udf config -chainFrom			udfNone
		udf config -bitOffset			0
		udf config -udfSize				32
		udf config -updown				uuuu
		udf config -repeat				1
		udf config -cascadeType			udfCascadeNone
		udf config -enableCascade		false
		udf config -step				1
		#udf config -enable true
		#udf config -offset 42
		#udf config -initval $udfPattern
		#udf config -countertype c32 #recommend udf config -udfSize
		#udf config -repeat 1
		udf config -maskselect {00 00 00 00}
		udf config -maskval {00 00 00 00}
		udf config -random false
		udf config -continuousCount false
		set tmpErr 0
		if { [catch {udf set $udfNum} tmpErr] } {
			puts "udf set $udfNum error,tmpErr is $tmpErr"	
			return 1
		} else {
			puts "udf set $udfNum ok"
		}
		if { [stream set $chasId $card $port $streamId] } {
			puts "stream set $chasId $card $port $streamId error"	
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		} else {
			puts "stream set $chasId $card $port $streamId is ok"
		}
		
		set portListLow2d [list [list $chasId $card $port]]
		puts "portListLow2d is $portListLow2d"
		if {[ixWriteConfigToHardware portListLow2d -noProtocolServer]} {
			puts "ixWriteConfigToHardware portListLow2d -noProtocolServer error"
			return 1
		} else {
			puts "write stream  udf config for $chasId/$card/$port to haradware^0"
		}
		puts "write stream  udf config for $chasId/$card/$port udfNum $udfNum to haradware end"
	}
}
#descrtption: set port's stat mode,like Normal mode,Qos mode and others;
#set port's stat mode, it will affect port link down and up
#call example call example portStatModeSet 1/3/15 -statMode statQos -qosPacketType vlan
#port_stat_mode_set -portList 1/3/15,1/3/16 -statMode statNormal
#port_stat_mode_set -portList 1/3/15,1/3/16 -statMode statQos -qosPacketType vlan
proc port_stat_mode_set { args } {
	## parameter process start
	set argformat {
		{portList	portList	required	string	"portList,like 1/3/15,two ports like 1/3/15,1/3/16"}
		{statMode	statMode	optional	string	"statMode,statMode input like statQos|statNormal|statStreamTrigger|statModeChecksumErrors|statModeDataIntegrity"}
		{qosPacketType	qosPacketType	optional	string	"qosPacketType,input like vlan|ipEthernetII"}
		{zcallexample	zcallexample	optional	string	"port_stat_mode_set -portList 1/3/15,1/3/16 -statMode statQos"}
	}
	# set optional parameter default value
	set arg(statMode)	statNormal
	
	#set arg(qosPacketType)	vlan
	#set arg(qosByteOffset)	0
	#set arg(qosPatternMatch) 0
	
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	parray arg
	#get the parameter In
	set portList $arg(portList)
	set portList [split $portList ","]
	#puts "portList is $portList"
	set statMode $arg(statMode)
	#set qosPacketType $arg(qosPacketType)
	
	
	#start function
	foreach item $portList {
		portStatModeSet $item -statMode $statMode
	}
}

#description:get port's status,like 
#state
#duplex 
#speed
#tx_frames
#rx_frames
#fcs_errors
#and print them to stdout like as follow;
#ixPuts "$sequence.$item.speed=$speed"
#ixPuts "$sequence.$item.duplex=$duplex"
#ixPuts "$sequence.$item.state=$state"
#ixPuts "$sequence.$item.tx_frames=$tx_frames"
#ixPuts "$sequence.$item.rx_frames=$rx_frames"
#ixPuts "$sequence.$item.fcs_errors=$fcs_errors"
#ixPuts "$sequence.Port:$item; Speed:$speed; Duplex:$duplex; Link:$upDown"
#port_status_get -portList 1/3/15,1/3/16 -sequence 1
proc port_status_get { args } {
	## parameter process start
	set argformat {
		{portList	portList	required	string	"portList,like 1/3/15,two ports like 1/3/15,1/3/16"}
		{sequence	sequence	optional	int	"sequence default is 0,it is a number"}
		{zcallexample	zcallexample	optional	string	"port_status_get -portList 1/3/15,1/3/16 -sequence 1"}
	}
	# set optional parameter default value
	set arg(sequence)	0

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	set portList $arg(portList)
	puts "portList is $portList"
	set sequence $arg(sequence)
	puts "sequence is $sequence"
	
	#start portStatusGet function
	portStatusGet $portList $sequence
}

#descripton:prepare setting port for multi stream statistic
proc port_multi_stream_statistic_set { args } {
	## parameter process start
	set argformat {
		{portList	portList	required	string	"portList,like 1/3/15,two ports like 1/3/15,1/3/16"}
		{zcallexample	zcallexample	optional	string	"port_multi_stream_statistic_set -portList 1/3/15,1/3/16"}
	}
	# set optional parameter default value
	set arg(sequence)	0

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	set portList $arg(portList)
	puts "portList is $portList"
	set portListTemp [split $portList ","]
	
	#set transmitMode $arg(transmitMode)
	#puts "transmitMode is $transmitMode"
	
	#start function
	foreach item $portListTemp {
		portTransmitModeSet $item -transmitMode portTxModeAdvancedScheduler
		portReceiveModeSet $item -receiveMode portRxModeWidePacketGroup
		streamStatsTx $item
		streamStatsRx $item
	}
}

#descripton: setting port's transmit mode,like portTxModeAdvancedScheduler|portTxPacketStreams
proc port_transmit_mode_set { args } {
	## parameter process start
	set argformat {
		{portList	portList	required	string	"portList,like 1/3/15,two ports like 1/3/15,1/3/16"}
		{transmitMode	transmitMode	required	string 	"transmitMode valid value is portTxModeAdvancedScheduler|portTxPacketStreams"}
		{zcallexample	zcallexample	optional	string	"port_transmit_mode_set -portList 1/3/15,1/3/16 -transmitMode portTxModeAdvancedScheduler"}
	}
	# set optional parameter default value
	set arg(sequence)	0

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	set portList $arg(portList)
	puts "portList is $portList"
	set portListTemp [split $portList ","]
	
	set transmitMode $arg(transmitMode)
	puts "transmitMode is $transmitMode"
	
	#start function
	foreach item $portListTemp {
		portTransmitModeSet $item -transmitMode $transmitMode
	}
}


#descripton:import stream to ixia port from a file
#the stream file is saved from GUI,and the postfix is str,like potr4.str
#onePort input like 1/3/15
#fileName input like /opt/Mainline/cases/1_samples/conf/potr4.str
#stream_import -onePort 1/3/15 -fileName /opt/Mainline/cases/1_samples/conf/potr4.str
#2013/4/28 clchen
proc stream_import {args} {
	set argformat {
		{onePort	onePort		required	string	"onePort,like 1/3/15"}
		{fileName	fileName	required	string	"fileName,like ${case.dir}/conf/potr4.str"}
		{zcallExample	zcallExample	optional	string	"stream_import -onePort 1/3/15 -fileName /opt/Mainline/cases/1_samples/conf/potr4.str"}
	}
	# set optional parameter default value
		#set arg(onePort)	1/3/15
		#set arg(fileName)	/opt/Mainline/cases/1_samples/conf/potr4.str
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
		}
	# and insert them into the arg array.
	array set arg $args
	#get the parameter In
	set onePort	$arg(onePort)
	puts "onePort is $onePort"
	set fileName	$arg(fileName)
	puts "fileName is $fileName" 
	streamImport $onePort $fileName
}

#
#description:disable or enable stream under a port
# in 
# -onePort	1/3/15
# -streamId	1
# -maintanceOp	disable or enable
# call example 
# stream_maintance -onePort 1/3/15 -streamId all -maintanceOp disable
# stream_maintance -onePort 1/3/15 -streamId all -maintanceOp enable
# stream_maintance -onePort 1/3/15 -streamId 2 -maintanceOp disable
# stream_maintance -onePort 1/3/15 -streamId 2 -maintanceOp enable
# out
# success return 0
# error return !0
proc stream_maintance { args } { 
	#two para stream_id  maintanceOp
		######### parameter process start
	set argformat {
		{onePort	onePort		required	string	"onePort,like 1/3/15"}
		{streamId	streamId	required	string	"streamId default is all,other valide value is a number,like 1 or 2 or 3 ..."}
		{maintanceOp	maintanceOp	required	string	"maintanceOp,disable|enable, can disable or enable assign streamId"}
		{zcallExample	zcallExample	optional	string	"stream_maintance -onePort 1/3/15 -streamId all -maintanceOp disable|stream_maintance -onePort 1/3/15 -streamId 1 -maintanceOp enable"}
	}
	# set optional parameter default value
	set arg(streamId)	all
	set arg(maintanceOp)	disable
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	set onePort	$arg(onePort)
	puts "onePort is $onePort"
	set streamId	$arg(streamId)
	puts "streamId is $streamId" 
	set maintanceOp	$arg(maintanceOp)
	puts "maintanceOp is $maintanceOp"
	if { [expr { $maintanceOp == "disable"} ] } {
		set op_info  [diableStream $onePort $streamId]
		return $op_info
		}
	if { [expr { $maintanceOp == "enable"} ] } {
		set op_info [enableStream $onePort $streamId]
		return $op_info
	}
}

#description:
#setting stack vlan(QinQ) for an exsit stream,if optional parameter is not input,it will use the default value
#the streamId is just a number,it is like 1 or 2 or 3 ...,
# by clchen 2013/07/25 add stream_stack_vlan_set to set stackVlan(QinQ) for specified exist stream
proc stream_stack_vlan_set { args } { 
	######### parameter process start
	set argformat {
		{portList		portList		required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{streamId		streamId		required	string	"streamId is a number,like 1 or 2 or 3 ...,streamId must be input"}
		{vlan			vlan			optional	string	"vlanSinglge|vlanStacked,default is vlanStacked"}
		{vlan_id_outer		vlan_id_outer		optional	string	"0-4095,default 1"}
		{vlan_dot1p_outer	vlan_dot1p_outer	optional	string	"0-7,default 0"}
		{vlan_cfi_outer		vlan_cfi_outer		optional	string	"0|1,default 0"}
		{vlan_mode_outer	vlan_mode_outer		optional	string	"vlan_mode_outer,default is vIncrement"}
		{vlan_repeatCount_outer	vlan_repeatCount_outer	optional	string	"vlan_repeatCount_outer,number,default is 1"}
		{vlan_step_outer	vlan_step_outer		optional	string	"vlan_step_outer,number,default is 1"}
		{vlan_protocolID_outer	vlan_protocolID_outer	optional	string	"vlan_protocolID_outer,default 0x8100,others like 0x88A8|0x9100|0x9200|0x9300 "}
		{vlan_id_inner		vlan_id_inner		optional	string	"0-4095,default 1"}
		{vlan_dot1p_inner	vlan_dot1p_inner	optional	string	"0-7,default 0"}
		{vlan_cfi_inner		vlan_cfi_inner		optional	string	"0|1,default 0"}
		{vlan_mode_inner	vlan_mode_inner		optional	string	"vlan_mode_inner,default is vIncrement"}
		{vlan_repeatCount_inner	vlan_repeatCount_inner	optional	string	"vlan_repeatCount_inner,number,default is 1"}
		{vlan_step_inner	vlan_step_inner		optional	string	"vlan_step_inner,number,default is 1"}
		{vlan_protocolID_inner	vlan_protocolID_inner	optional	string	"vlan_protocolID_inner,default 0x8100,others like 0x88A8|0x9100|0x9200|0x9300 "}
		{zcallExample	zcallExample	optional	string	"stream_stack_vlan_set -portList 1/3/15,1/3/16 -streamId 1 -vlan vlanStacked\
			-vlan_id_outer 11 -vlan_dot1p_outer 1 -vlan_cfi_outer 1 -vlan_repeatCount_outer 10 -vlan_step 10 -vlan_protocolID_outer 0x9100\
			-vlan_id_inner 22 -vlan_dot1p_inner 2 -vlan_cfi_inner 2 -vlan_repeatCount_inner 20 -vlan_step 20 -vlan_protocolID_inner 0x9200"}
	}
	# set optional parameter default value
	#{streamName	streamName	optional	string	"streamName,is a string,streamId or streamName must selet one to input"}
	set arg(portListIn) ""
	set arg(portList) ""
	set arg(streamId)	-1
	set arg(streamName)	""
	set arg(vlan)	vlanStacked
	
	set arg(vlan_id_outer) 1
	set arg(vlan_dot1p_outer) 0
	set arg(vlan_cfi_outer) 0
	set arg(vlan_mode_outer) vIncrement
	set arg(vlan_repeatCount_outer) 1
	set arg(vlan_step_outer) 1
	set arg(vlan_protocolID_outer) vlanProtocolTag8100
	
	set arg(vlan_id_inner) 1
	set arg(vlan_dot1p_inner) 0
	set arg(vlan_cfi_inner) 0
	set arg(vlan_mode_inner) vIncrement
	set arg(vlan_repeatCount_inner) 1
	set arg(vlan_step_inner) 1
	set arg(vlan_protocolID_inner) vlanProtocolTag8100

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	parray arg
	
	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portListIn $arg(portListIn)
	set portList2 $arg(portList)
	if { [expr {$portListIn == "" && $portList2 == ""} ] } { 
		puts "error,-portList in stream_stack_vlan_set input failed"
		exit 1
	}
	if { [expr {$portListIn != "" && $portList2 != ""} ] } { 
		puts "error,-portList in stream_stack_vlan_set input failed,only allow input -portList or -portListIn,not the same input"
		exit 1
	} 
	
	if { [expr {$portListIn != ""} ] } { 
		puts "portListIn is $portListIn"
		set portList [split $portListIn ","]
	} elseif { [expr {$portList2 != ""} ] } {
		puts "portList is $portList2"
		set portList [split $portList2 ","]
	}
	
	set streamId	$arg(streamId)
	puts "streamId is $streamId" 
	set streamName	$arg(streamName)
	#puts "streamName is $streamName"
	
	set vlan $arg(vlan)
	#puts "vlan is $vlan"
	#if { [expr {$vlan == "enable"}] } {
	#	set vlanOp "true"
	#} elseif { [expr {$vlan == "disable"}] } {
	#	set vlanOp "false"
	#}
		
	#set vlan_id $arg(vlan_id)
	#puts "vlan_id is $vlan_id"
	#set vlan_dot1p $arg(vlan_dot1p)
	#puts "vlan_dot1p is $vlan_dot1p"
	#set vlan_cfi $arg(vlan_cfi)
	#puts "vlan_cfi is $vlan_cfi"
	#set vlan_mode $arg(vlan_mode)
	#puts "vlan_mode is $vlan_mode"
	#set vlan_repeatCount $arg(vlan_repeatCount)
	#puts "vlan_repeatCount is $vlan_repeatCount"
	#set vlan_step $arg(vlan_step)
	#puts "vlan_step is $vlan_step"
	#set vlan_protocolID $arg(vlan_protocolID)
	#puts "vlan_protocolID is $vlan_protocolID"
	#function start
	foreach item $portList {
		streamStackVlanSetOnePort $item $streamId $streamName $arg(vlan) \
		$arg(vlan_id_outer) $arg(vlan_dot1p_outer) $arg(vlan_cfi_outer) $arg(vlan_mode_outer) $arg(vlan_repeatCount_outer) $arg(vlan_step_outer) $arg(vlan_protocolID_outer) \
		$arg(vlan_id_inner) $arg(vlan_dot1p_inner) $arg(vlan_cfi_inner) $arg(vlan_mode_inner) $arg(vlan_repeatCount_inner) $arg(vlan_step_inner) $arg(vlan_protocolID_inner)
	}	
}


#description:
#settting vlan property for an exsit stream,if optional parameter is not input,it will use the default value
#the streamId is just a number,it is like 1 or 2 or 3 ...,
# by clchen 2013/05/13 add stream_modify to modify exist stream
proc stream_modify { args } { 
	######### parameter process start
	set argformat {
		{portListIn	portListIn	optional	string	"portListIn,one like 1/3/15,two like 1/3/15,1/3/16,must select portList or portListIn"}
		{portList	portList	optional	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16,must select portList or portListIn"}
		{streamId	streamId	optional	string	"streamId is a number,like 1 or 2 or 3 ...,streamId must be input"}
		{vlan		vlan		optional	string	"disable|enable,default disable mean use untag packet,enable mean use tag packet"}
		{vlan_id	vlan_id		optional	string	"0-4095,default 1,must enable -vlan first if use this parameter"}
		{vlan_dot1p	vlan_dot1p	optional	string	"0-7,must enable -vlan first if use this parameter,default 0"}
		{vlan_cfi	vlan_cfi	optional	string	"0|1,default 0,must enable -vlan first if use this parameter "}
		{vlan_mode	vlan_mode	optional	string	"vlan_mode,default is vIncrement"}
		{vlan_repeatCount	vlan_repeatCount	optional	string	"vlan_repeatCount,number,default is 1"}
		{vlan_step	vlan_step	optional	string	"vlan_step,number,default is 1"}
		{vlan_protocolID	vlan_protocolID		optional	string	"vlan_protocolID,default 0x8100,others like 0x88A8|0x9100|0x9200|0x9300 "}
		{zcallExample	zcallExample	optional	string	"stream_modify -portListIn 1/3/15,1/3/16 -streamId 1 -vlan enable -vlan_id 11 -vlan_dot1p 2 -vlan_cfi 1 -vlan_repeatCount 30 -vlan_step 20"}
	}
	# set optional parameter default value
	#{streamName	streamName	optional	string	"streamName,is a string,streamId or streamName must selet one to input"}
	set arg(portListIn) ""
	set arg(portList) ""
	set arg(streamId)	-1
	set arg(streamName)	all
	set arg(vlan_id) 1
	set arg(vlan_dot1p) 0
	set arg(vlan_cfi) 0
	set arg(vlan_mode) vIncrement
	set arg(vlan_repeatCount) 1
	set arg(vlan_step) 1
	set arg(vlan_protocolID) vlanProtocolTag8100
	set arg(vlan) disable
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	#parray arg
	
	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portListIn $arg(portListIn)
	set portList2 $arg(portList)
	if { [expr {$portListIn == "" && $portList2 == ""} ] } { 
		puts "error,-portList in stream_modify input failed"
		exit 1
	}
	if { [expr {$portListIn != "" && $portList2 != ""} ] } { 
		puts "error,-portList in stream_modify input failed,only allow input -portList or -portListIn,not the same input"
		exit 1
	} 
	
	if { [expr {$portListIn != ""} ] } { 
		puts "portListIn is $portListIn"
		set portList [split $portListIn ","]
	} elseif { [expr {$portList2 != ""} ] } {
		puts "portList is $portList2"
		set portList [split $portList2 ","]
	}
	
	set streamId	$arg(streamId)
	puts "streamId is $streamId" 
	set streamName	$arg(streamName)
	puts "streamName is $streamName"
	
	set vlan $arg(vlan)
	puts "vlan is $vlan"
	if { [expr {$vlan == "enable"}] } {
		set vlanOp "true"
	} elseif { [expr {$vlan == "disable"}] } {
		set vlanOp "false"
	}
	set vlan_id $arg(vlan_id)
	puts "vlan_id is $vlan_id"
	set vlan_dot1p $arg(vlan_dot1p)
	puts "vlan_dot1p is $vlan_dot1p"
	set vlan_cfi $arg(vlan_cfi)
	puts "vlan_cfi is $vlan_cfi"
	set vlan_mode $arg(vlan_mode)
	puts "vlan_mode is $vlan_mode"
	set vlan_repeatCount $arg(vlan_repeatCount)
	puts "vlan_repeatCount is $vlan_repeatCount"
	set vlan_step $arg(vlan_step)
	puts "vlan_step is $vlan_step"
	set vlan_protocolID $arg(vlan_protocolID)
	puts "vlan_protocolID is $vlan_protocolID"
	#function start
	foreach item $portList {
		streamModifyOnePort $item $streamId $streamName $vlan_id $vlan_dot1p $vlan_cfi $vlan_mode $vlan_repeatCount $vlan_step $vlan_protocolID $vlanOp
	}	
}

#description:stream percent rate set
#streamId can't use all,just one number,like 1 or 2 or 3...
proc stream_percent_rate_set { args } { 
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{streamId	streamId	required	string	"streamId is a number,like 1 or 2 or 3 ...,streamId must be input"}
		{percentRate	percentRate	optional	string	"percentRate,is a number,1 to 100"}
		{zcallExample	zcallExample	optional	string	"stream_percent_rate_set -portList 1/3/15,1/3/16 -streamId 1 -percentRate 100"}
	}
	# set optional parameter default value
	#{streamName	streamName	optional	string	"streamName,is a string,streamId or streamName must selet one to input"}
	set arg(streamId)	-1
	set arg(streamName)	all
	set arg(percentRate)	100

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portList $arg(portList)
	set portList [split $portList ","]
	puts "portList is $portList"
	
	set streamId	$arg(streamId)
	puts "streamId is $streamId" 
	set streamName	$arg(streamName)
	#puts "streamName is $streamName"
	set percentRate $arg(percentRate)
	puts "percentRate is $percentRate"
	
	#function start
	foreach item $portList {
		streamPercentRateSet  $item $streamId $streamName $percentRate
	}	
}

#description:transmit method set for exsit stream under specified port
#streamId can't use all,just one number,like 1 or 2 or 3...
proc stream_transmit_method_set { args } { 
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{streamId	streamId	optional	string	"streamId is a number,like 1 or 2 or 3 ...,streamId must be input"}
		{transmitMethod	transmitMethod	optional	string	"transmitMethod,contPacket|contBurst|stopStream|advance|gotoFirst|firstLoopCount,default is contPacket"}
		{numFrames	numFrames	optional	string	"numFrames default is 100, is the frames number of the per burst"}
		{numBursts	numBursts	optional	string	"numBursts default is 1, is the frequency of the burst"}
		{zcallExample	zcallExample	optional	string	"stream_transmit_method_set -portList 1/3/15,1/3/16 -streamId 1 -transmitMethod contBurst"}
	}
	# set optional parameter default value
	#{streamName	streamName	optional	string	"streamName,is a string,streamId or streamName must selet one to input"}
	set arg(streamId)	-1
	set arg(streamName)	all
	set arg(transmitMethod) contPacket
	set arg(numFrames)	100
	set arg(numBursts)	1

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portList $arg(portList)
	set portList [split $portList ","]
	puts "portList is $portList"
	
	set streamId	$arg(streamId)
	puts "streamId is $streamId" 
	set streamName	$arg(streamName)
	puts "streamName is $streamName"
	set transmitMethod $arg(transmitMethod)
	puts "transmitMethod is $transmitMethod"
	set numFrames $arg(numFrames)
	puts "numFrames is $numFrames"
	set numBursts $arg(numBursts)
	puts "numBursts is $numBursts"
	
	#function start
	foreach item $portList {
		streamTransmitMethodSet  $item $streamId $streamName $transmitMethod $numFrames $numBursts
	}	
}
#description:pause control set for exsit stream under specified port
#streamId can't use all,just one number,like 1 or 2 or 3...
proc stream_pause_control_set  { args } {
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{streamId	streamId	optional	string	"streamId is a number,like 1 or 2 or 3 ...,streamId must be input"}
		{protocolName	protocolName	optional	string	"protocolName,mac|ip|ipV4|ipx|pauseControl|ipV6|fcoe|nativeFc,default is pauseControl"}
		{pauseTime	pauseTime	optional	string	"pauseTime,1-255,default is 255"}
		{zcallExample	zcallExample	optional	string	"stream_pause_control_set -portList 1/3/15,1/3/16 -streamId 1 -pauseTime 222"}
	}
	# set optional parameter default value
	set arg(streamId)	-1
	set arg(protocolName)	pauseControl
	set arg(pauseTime)	255
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	puts "\n stream_pause_control_set start"
	set portList $arg(portList)
	set portList [split $portList ","]
	puts "portList is $portList"
	set streamId	$arg(streamId)
	puts "streamId is $streamId"
	
	set protocolName $arg(protocolName)
	puts "protocolName is $protocolName"
	set pauseTime $arg(pauseTime)
	puts "pauseTime is $pauseTime"
	
	#function start
	foreach item $portList {
		streamPauseControlSet $item $streamId $protocolName $pauseTime
	}	
}

#proc stream_pause_control_set  { args } {
#	######### parameter process start
#	set argformat {
#		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
#		{streamId	streamId	optional	string	"streamId is a number,like 1 or 2 or 3 ..."}
#		{protocolName	protocolName	optional	string	"protocolName,mac|ip|ipV4|ipx|pauseControl|ipV6|fcoe|nativeFc,default is pauseControl"}
#		{pauseTime	pauseTime	optional	string	"pauseTime,1-255,default is 255"}
#		{zcallExample	zcallExample	optional	string	"stream_pause_control_set -portList 1/3/15,1/3/16 -streamId 1 -pauseTime 222"}
#	}
#	# set optional parameter default value
#	set arg(streamId)	-1
#	set arg(protocolName)	pauseControl
#	set arg(pauseTime)	255
#	# process the arguments
#	if { [catch {ah_argparse $args $argformat} args] } {
#		return -code error $args
#	}
#	# and insert them into the arg array.
#	array set arg $args
#
#	#get the parameter In
#	
#	#set onePort	$arg(onePort)
#	#puts "onePort is $onePort"
#	puts "\n stream_pause_control_set start"
#	set portList $arg(portList)
#	set portList [split $portList ","]
#	puts "portList is $portList"
#	set streamId	$arg(streamId)
#	puts "streamId is $streamId"
#	
#	set protocolName $arg(protocolName)
#	puts "protocolName is $protocolName"
#	set pauseTime $arg(pauseTime)
#	puts "pauseTime is $pauseTime"
#	
#	#function start
#	foreach item $portList {
#		streamPauseControlSet $item $streamId $protocolName $pauseTime
#	}	
#}

#
#description:
#setting ipv4 header for exist stream
#streamId can't use all,just one number,like 1 or 2 or 3...
#
#steamIpDSCPSet 1/3/15 -streamId 1 -dscpValue 0x3d -dscpMode ipV4DscpCustom
#stream_ipv4_header_set -portList 1/3/15,1/3/16 -streamId 1 -dscpValue 1
proc stream_ipv4_header_set  { args } {
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{streamId	streamId	required	string	"streamId is a number,like 1 or 2 or 3 ..."}
		{dscpValue	dscpValue	optional	string	"dscpValue,decimal number,like 0 or 63,the min is 0,the max is 63"}
		{destIpAddr	destIpAddr	optional	string	"destIpAddr,like 127.0.0.1"}
		{sourceIpAddr	sourceIpAddr	optional	string	"sourceIpAddr,like 127.0.0.1"}
		{zcallExample	zcallExample	optional	string	"stream_ipv4_header_set -portList 1/3/15,1/3/16 -streamId 1 -dscpValue 1"}
	}
	# set optional parameter default value
	set arg(streamId)	-1
	set arg(dscpValue)	0
	set arg(destIpAddr)	127.0.0.1
	set arg(sourceIpAddr)	127.0.0.1
	
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	parray arg
	
	#prepare argListFinal
	set tmpList [array get arg]
	set portListIdx [lsearch $tmpList portList*]
	set portListBeforeIdx [ expr {$portListIdx-1} ]
	set portListValueAfterIdx [ expr {$portListIdx+2} ]
	set argList1 [lrange $tmpList  $portListValueAfterIdx end]
	#puts "argList1 is $argList1"
	set argList2 [lrange $tmpList 0 $portListBeforeIdx]
	#puts "argList2 is $argList2"
	set argListFinal [concat $argList1 $argList2]
	puts "argListFinal is $argListFinal"
	
	
	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	#puts "\n stream_pause_control_set start"
	set portList $arg(portList)
	set portList [split $portList ","]
	#puts "portList is $portList"
		#set streamId	$arg(streamId)
	#puts "streamId is $streamId"
	
		#set hexDscpValue [dectohex $arg(dscpValue)]
		#set dscpValue $hexDscpValue
	#puts "dscpValue is $dscpValue"
	
	
	
	#function start
	foreach item $portList {
		#steamIpDSCPSet $item -streamId $streamId -dscpValue $dscpValue -destIpAddr $arg(destIpAddr) -sourceIpAddr $arg(sourceIpAddr)
		steamIpDSCPSet $item $argListFinal
		
	}	
}


#description: delete all exsit streams under port
#stream_delete_all
#delete all exist streams on the assigned port
#stream_delete_all -portList 1/3/15,1/3/16
proc stream_delete_all  { args } {
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{zcallExample	zcallExample	optional	string	"delete all exist streams on the specify port, call example stream_delete_all -portList 1/3/15,1/3/16"}
	}
	# set optional parameter default value
	set arg(streamId)	all

	
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	parray arg
	
	#get the parameter In
	
	set portList $arg(portList)
	set portList [split $portList ","]
	
	#function start
	foreach item $portList {
		#steamIpDSCPSet $item -streamId $streamId -dscpValue $dscpValue -destIpAddr $arg(destIpAddr) -sourceIpAddr $arg(sourceIpAddr)
		streamDelete $item $arg(streamId)
		
	}	
}



#
# Copyright 2013, clchen, Aerohive
# Version: 1.0
# Date: 2013-03-21
# 
# History:
#  version 1.0: 2013.03.21 by clchen, clchen@aerohive.com
#
# Description: build a new eth2 stream under a port
#  traffic_configure_eth2 to build eth2 packet
# -txportList		$txportList	(deprecated)
# -rxportList		$rxportList	(deprecated)
# -portList			$portList			(mandatory) like 1/3/15,1/3/16
# -mac_dst_addr		$mac_dst_first		(mandatory) like 0000.0000.0016
# -mac_dst_count	$mac_dst_count		(optional) default 1
# -mac_dst_step		$mac_dst_step		(optional) default 0.0.0.0.0.1
# -mac_src_addr		$mac_src_first		(mandatory) like 0000.0000.0015
# -mac_src_count	$mac_src_count		(optional) default 1
# -mac_src_step		$mac_src_step		(optional) default 0.0.0.0.0.1
# -vlan 			$vlan_switch 		(optional) default disable
# -vlan_id			$vlan_id_first		(optional) default no vlan, (0-4095)
# -vlan_dot1p		$vlan_dot1p (0-7)	(optional) must enable -vlan first if use this parameter
# -vlan_cfi			$vlan_cfi			(optional)	{0|1} default 0
# -eth2_protocol	$eth2_protocol_type		(optional) default 0x0800
# -frame_length		$frame_length		(optional) L2 frame length, default 68bytes
# #-rate_percent		$rate_percent		(optional) default 0.1
# -udf_offset		$udf_offset_bytes	(optional) default 54
# -udf_value		$udf_value			(optional) default 0xBDBDBDBD
# -rate_pps 		$rate_pps			(optional) default 10 pps
# #{ rate_percent	rate_percent 	optional string "can not use rate_pps at the same time,default,0.1"
proc traffic_configure_eth2 {args} {
	# ######## parameter process start
	set argformat {
		{portListIn	portListIn	optional	string	"portListIn,one port like 1/3/15,two ports like 1/3/15,1/3/16,must select portList or portListIn,not input the same"}
		{portList	portList	optional	string	"portList,one port like 1/3/15,two ports like 1/3/15,1/3/16,must select portList or portListIn,not input the same"}
		{mac_dst	mac_dst_addr	required	string	"like 0000.0000.0015"}
		{mac_dst_count	mac_dst_count	optional	int	"default 1"}
		{mac_dst_step	mac_dst_step	optional	string	"default 0.0.0.0.0.1"}
		{mac_src	mac_src_addr	required	string	"like 0000.0000.0016"}
		{mac_src_count	mac_src_count	optional	int	"default 1"}
		{mac_src_step	mac_src_step	optional	string "default 0.0.0.0.0.1"}
		{vlan		vlan_switch	optional	string	"disable|enable,default disable mean use untag packet,enable mean use tag packet"}
		{vlan_id	vlan_id_first	optional	int	"0-4095,default 1,must enable -vlan first if use this parameter"}
		{vlan_dot1p	vlan_dot1p	optional	int	"0-7,must enable -vlan first if use this parameter,default 0"}
		{vlan_cfi	vlan_cfi	optional	int	"0|1,default 0,must enable -vlan first if use this parameter"}
		{vlan_repeatCount	vlan_repeatCount	optional	int "vlan_repeatCount,number,default is 1"}
		{vlan_step	vlan_step	optional	int	"vlan_step,number,default is 1"}
		{vlan_protocolID	vlan_protocolID	optional	string	"vlan_protocolID,default 0x8100,others like 0x88A8|0x9100|0x9200|0x9300"}
		
		{eth2_protocol	eth2_protocol_type	optional	string	"default,0x0800"}
		{frame_length	frame_length	optional	int	"L2 frame length, default 68"}

		{udf_offset	udf_offset	optional	int	"default 40"}
		{udf_value	udf_value	optional	string	"default 0xBDBDBDBD,must be 4 bytes"}
		{rate_pps	rate_pps	optional	string	"can not use rate_percent at the same time,default 10"}
		{patternOffset2 patternOffset2 optional	int	"default 40"}
		{rxPattern	rxPattern	optional	string	"default 0xBDBDBDBD,must be 4 bytes"}
		
		{pattern1In	pattern1In	optional	string	"default 0xBDBDBDBD,must be 4 bytes"}
		{patternMask1In	patternMask1In	optional	string	"default 0x00000000,must be 4 bytes"}
		{patternOffset1	patternOffset1	optional	string	"default 12,it is number"}
		{userDefinedStat2Pattern	userDefinedStat2Pattern	optional	string	"default pattern2, pattern1AndPattern2|notPattern2|pattern2|notPattern1|pattern1|pattern1OrPattern2"}
		{zcallexample	zcallexample	optional	string	"traffic_configure_eth2 -portList	1/3/15,1/3/16\
		-mac_dst	0000.0000.0015\
		-mac_dst_count	1\
		-mac_dst_step	0.0.0.0.0.1\
		-mac_src	0000.0000.0016\
		-mac_src_count	1\
		-mac_src_step	0.0.0.0.0.1\
		-vlan	enable\
		-vlan_id	1\
		-vlan_dot1p	0\
		-vlan_cfi	0\
		-eth2_protocol	0x0800\
		-frame_length	68\
		-udf_offset	54\
		-udf_value	0xBDBDBDBD\
		-rate_pps	10\
		-patternOffset2 54\
		-rxPattern	0xBDBDBDBD"}
	}
	
	# set optional parameter default value
	set arg(portListIn) ""
	set arg(portList) ""
	set arg(mac_dst_count)		1
	set arg(mac_dst_step)		0.0.0.0.0.1
	set arg(mac_src_count)		1
	set arg(mac_src_step)		0.0.0.0.0.1
	set arg(vlan_switch)		disable
	set arg(vlan_id_first)		1
	set arg(vlan_dot1p)		0
	set arg(vlan_cfi)		0
	set arg(vlan_repeatCount)	1
	set arg(vlan_step)		1
	set arg(vlan_protocolID)	0x8100
	
	set arg(eth2_protocol_type)	0x0800
	#2013/4/23 change frame_length from 68 to 128 by clchen
	set arg(frame_length)		128
	#set arg(rate_percent)		0.1
	set arg(udf_offset) 		40
	set arg(udf_value) 			0xBDBDBDBD
	set arg(rate_pps)			10
	set arg(patternOffset2)		40
	set arg(rxPattern)			0xBDBDBDBD
	#for pattern1
	set arg(pattern1In)			0xBDBDBDBD
	set arg(patternMask1In)		0x00000000
	set arg(patternOffset1)		12
	set arg(userDefinedStat2Pattern)	pattern2
		#	may be one of the below value
	#	"pattern1AndPattern2"
	#	"notPattern2"
	#	"pattern2"
	#	"notPattern1"
	#	"pattern1"
	
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	
	#get the parameter In
		#procees portListIn and portList
	set portListIn1 $arg(portListIn)
	set portList2 $arg(portList)
	if { [expr {$portListIn1 == "" && $portList2 == ""} ] } { 
		puts "error,-portList in stream_modify input failed,input like -portList 1/3/15,1/3/16 "
		exit 1
	}
	if { [expr {$portListIn1 != "" && $portList2 != ""} ] } { 
		puts "error,-portList in stream_modify input failed,only allow input -portList or -portListIn,not the same input"
		exit 1
	} 
	if { [expr {$portListIn1 != ""} ] } { 
		puts "portListIn is $portListIn1"
		set portListIn $portListIn1
	} elseif { [expr {$portList2 != ""} ] } {
		puts "portList is $portList2"
		set portListIn $portList2
	}
	
	#set portListIn	$arg(portListIn)
	#puts "portListIn is $portListIn"
	
	
	
	set portHandle [pLhand $portListIn]
	puts "portHandle is $portHandle"
	#set portHandle2 [split $portListIn "," ]
	#puts "portHandle2 is $portHandle2"
	set portList [pLproc $portListIn]
	puts "portList is $portList"
	set mac_dst_addr 	$arg(mac_dst_addr)
	puts "mac_dst_addr is $mac_dst_addr"
	set mac_dst_count 	$arg(mac_dst_count)
	puts "mac_dst_count is $mac_dst_count"
	set mac_dst_step 	$arg(mac_dst_step)
	puts "mac_dst_step is $mac_dst_step"
	
	set mac_src_addr 	$arg(mac_src_addr)
	puts "mac_src_addr is $mac_src_addr"
	set mac_src_count	$arg(mac_src_count)
	puts "mac_src_count is $mac_src_count"
	set mac_src_step	$arg(mac_src_step)
	puts "mac_src_step is $mac_src_step"
	
	set vlan_switch		$arg(vlan_switch)
	puts "vlan_switch is $vlan_switch "
	set vlan_id_first	$arg(vlan_id_first)
	puts "vlan_id_first is $vlan_id_first"
	set vlan_dot1p		$arg(vlan_dot1p)
	puts "vlan_dot1p is $vlan_dot1p"
	set vlan_cfi		$arg(vlan_cfi)
	puts "vlan_cfi is $vlan_cfi"
	set vlan_repeatCount	$arg(vlan_repeatCount)
	puts "vlan_repeatCount is $vlan_repeatCount"
	set vlan_step		$arg(vlan_step)
	puts "vlan_step is $vlan_step"
	set vlan_protocolID	$arg(vlan_protocolID)
	puts "vlan_protocolID is $vlan_protocolID"
	
	set eth2_protocol	$arg(eth2_protocol_type)
	puts "eth2_protocol is $eth2_protocol"
	set frame_length	$arg(frame_length)
	puts "frame_length is $frame_length"
	
	#set rate_percent	$arg(rate_percent)
	set udf_offset 		$arg(udf_offset)
	puts "udf_offset is $udf_offset"
	set udf_value 		$arg(udf_value)
	puts "udf_value is $udf_value"
	
	set rate_pps		$arg(rate_pps)
	puts "rate_pps is $rate_pps"
	
	#patternOffset2 default 54
	set patternOffset2	$arg(patternOffset2)
	puts "patternOffset2 is $patternOffset2"
	set rxPattern		$arg(rxPattern)
	puts "rxPattern is $rxPattern"
	
	#pattern1
	set pattern1In $arg(pattern1In)
	puts "pattern1In is $pattern1In"
	set patternMask1In $arg(patternMask1In)
	puts "patternMask1In is $patternMask1In"
	set patternOffset1 $arg(patternOffset1)
	puts "patternOffset1 is $patternOffset1"
	set userDefinedStat2Pattern $arg(userDefinedStat2Pattern)
	puts "userDefinedStat2Pattern is $userDefinedStat2Pattern"
	
	####parameter process end
	####function start,
	set trafficConfigEth2_info [trafficConfigEth2 $portListIn $mac_dst_addr $mac_dst_count $mac_dst_step\
		$mac_src_addr $mac_src_count $mac_src_step\
		$vlan_switch $vlan_id_first $vlan_dot1p $vlan_cfi\
		$vlan_repeatCount $vlan_step $vlan_protocolID\
		$eth2_protocol $frame_length $udf_offset $udf_value $rate_pps] 
			#puts "trafficConfigEth2_info is $trafficConfigEth2_info"
		# $rxPattern like 0xbdbdbdbd,convert to "bd bd bd bd"
	
	#set rxPatternConverted 0xabcdefab for pattern2
	set a [string range $rxPattern 2 3]
	set b [string range $rxPattern 4 5]
	set c [string range $rxPattern 6 7]
	set d [string range $rxPattern 8 9]
	set rxPatternConverted "$a $b $c $d"

	#pattern1 para process
	#set pattern1 "DE ED EF FE AC CA"
	#set patternMask1 "00 00 00 00 00 00"
	#set patternOffset1 12
	#set userDefinedStat2Pattern "pattern2"
		#set pattern1In 0x12345678
	set a [string range $pattern1In 2 3]
	set b [string range $pattern1In 4 5]
	set c [string range $pattern1In 6 7]
	set d [string range $pattern1In 8 9]
	set pattern1 "$a $b $c $d"
	
		#set patternMask1In 0x00000000
	set a [string range $patternMask1In 2 3]
	set b [string range $patternMask1In 4 5]
	set c [string range $patternMask1In 6 7]
	set d [string range $patternMask1In 8 9]
	set patternMask1 "$a $b $c $d"
		#set patternOffset1 13
	set patternOffset1 $patternOffset1
		#set userDefinedStat2Pattern "pattern1AndPattern2"
	set userDefinedStat2Pattern $userDefinedStat2Pattern
	puts "userDefinedStat2Pattern is $userDefinedStat2Pattern"

	set palletteFilterConfig_info [palletteFilterConfig $portList $rxPatternConverted $patternOffset2 $pattern1 $patternMask1 $patternOffset1 $userDefinedStat2Pattern]
	
	#if { [expr { $userDefinedStat2Pattern != "Pattern2" }] } {
	#	set palletteFilterConfig_info [palletteFilterConfig $portList $rxPatternConverted $patternOffset2 $pattern1 $patternMask1 $patternOffset1 $userDefinedStat2Pattern]
	#} else {
	#	set palletteFilterConfig_info [palletteFilterConfig $portList $rxPatternConverted $patternOffset2]
	#}
	
	#puts "palletteFilterConfig_info is $palletteFilterConfig_info"
	##udf config
	#udf_config -pL $portList -udf_offset $udf_offset -udf_value $udf_value -streamID 1
}

#description:
#start capture on specified port
proc start_capture {args} { 
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{zcallExample	zcallExample	optional	string	"start_capture -portList 1/3/15,1/3/16"}
	}
	# set optional parameter default value
		#set arg(streamId)	-1


	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portList $arg(portList)
	puts "portList in start_capture is $portList"
	
	#start function do
	setRecvModeToCaptureMode $portList
	startCap $portList
}

#description:
#stop capture on specified port
proc stop_capture {args} {
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{zcallExample	zcallExample	optional	string	"stop_capture -portList 1/3/15,1/3/16"}
	}
	# set optional parameter default value
		#set arg(streamId)	-1


	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portList $arg(portList)
	puts "portList in stop_capture is $portList"
	
	#start function do
	stopCap $portList
}

#description:
#save capture to a file under specified port
proc save_capture {args} {
	######### parameter process start
	set argformat {
		{onePort	onePort		required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{fileName	fileName	required	string	"fileName to save the capture Buffer,the valid like /opt/Mainline/cases/1_samples/conf/capFlieName.enc or ${case.dir}/conf/capFlieName.enc"}
		{zcallExample	zcallExample	optional	string	"save_capture -onePort 1/3/15 -fileName /opt/Mainline/cases/1_samples/conf/capFlieName.enc  need to clear capFlieName.enc first"}
	}
	# set optional parameter default value
		#set arg(streamId)	-1


	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	set onePort	$arg(onePort)
	puts "onePort in save_capture is $onePort"
	set fileName $arg(fileName)
	puts "fileName in save_capture is $fileName"
	#start function
	getCaptureBufferAndSaveToFile $onePort $fileName
}

#description:
#stop transmit on specified port
proc stop_transmit {args} {
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{zcallExample	zcallExample	optional	string	"stop_transmit -portList 1/3/15,1/3/16"}
	}
	# set optional parameter default value
		#set arg(streamId)	-1


	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portList $arg(portList)
	puts "portList in stop_transmit is $portList"
	stopTransmit $portList

}

#description:
#clear statistic on specified port
proc clear_statistic {args} {
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{zcallExample	zcallExample	optional	string	"clear_statistic -portList 1/3/15,1/3/16"}
	}
	# set optional parameter default value
		#set arg(streamId)	-1


	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portList $arg(portList)
	puts "portList in clear_statistic is $portList"
	clearStatistic $portList

}

#description:
#start transmit on specified port
proc start_transmit {args} {
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{firstTryFlag	firstTryFlag	optional	string	"firstTryFlag default is true,valid is true|false"}
		{zcallExample	zcallExample	optional	string	"start_transmit -portList 1/3/15,1/3/16"}
	}
	# set optional parameter default value
		#set arg(streamId)	-1
	set arg(firstTryFlag) "true"

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set portList $arg(portList)
	puts "portList in start_transmit is $portList"
	set firstTryFlag $arg(firstTryFlag)
	puts "firstTryFlag in start_transmit is $firstTryFlag"
	#firstTryFlag true or false default is true
	startTransmit $portList $firstTryFlag

}

#description:
#wait time for a while, the unit is second
#call example wait_time -second 10
proc wait_time {args} {
	######### parameter process start
	set argformat {
		{second		second		optional	string	"wait time,defaut is 3s,the unit is second"}
		{zcallExample	zcallExample	optional	string	"wait_time -second 10"}
	}
	# set optional parameter default value
		set arg(second)	3


	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set second $arg(second)
	puts "wait second is $second s"
	set duration [expr {$second*1000}]
	after $duration

}

#description:
#get stream statistic on specified port,it is used for stream based statistic
proc get_stream_statistic {args} {
	######### parameter process start
	set argformat {
		{portList	portList	required	string	"portList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{sequence	sequence	optional	int	"sequence is number,default is 0,like 0,1,2... "}
		{zcallExample	zcallExample	optional	string	"get_stream_statistic -portList 1/3/15 -sequence 0"}
	}
	# set optional parameter default value
		#set arg(streamId)	-1
	set arg(sequence) 0


	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	#set txPortList $arg(txPortList)
	#puts "txPortList in get_stream_statistic is $txPortList"
	set portList $arg(portList)
	puts "portList in get_stream_statistic is $portList"
	#set rxPortList $arg(rxPortList)
	#puts "rxPortList in get_stream_statistic is $rxPortList"
	set sequence $arg(sequence)
	#will get statistic and set them to global streamStList
	#getStreamStatistic $txPortList,$rxPortList $sequence
	getStreamStatistic $portList $sequence
	#getStatistic  $sequence
}

#description:
#get statistic on specified port,it is used for port based statistic
proc get_statistic {args} {
	######### parameter process start
	set argformat {
		{txPortList	txPortList	required	string	"txPortList,one like 1/3/15,two like 1/3/15,1/3/16"}
		{rxPortList	rxPortList	required	string	"rxPortList,one like 1/3/16,two like 1/3/15,1/3/16"}
		{sequence	sequence	optional	int	"sequence is number,default is 0,like 0,1,2... "}
		{zcallExample	zcallExample	optional	string	"get_statistic -txPortList 1/3/15,1/3/16 -rxPortList 1/3/15,1/3/16 -sequence 0"}
	}
	# set optional parameter default value
		#set arg(streamId)	-1
	set arg(sequence) 0


	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	
	#set onePort	$arg(onePort)
	#puts "onePort is $onePort"
	set txPortList $arg(txPortList)
	puts "txPortList in get_statistic is $txPortList"
	set rxPortList $arg(rxPortList)
	puts "rxPortList in get_statistic is $rxPortList"
	set sequence $arg(sequence)
	#will get statistic and set them to global stList
	getStatistic $txPortList $rxPortList $sequence
}

#description:
#start stream transmit on Tx port,then get statistic on Tx and Rx port ,it is used for stream based statistic
proc start_stream_trans_getstats {args} {
	######### parameter process start
	set argformat {
		{txPortList	txPortList		required	string	"Tx Port Lists,one port like 1/3/15 two ports like 1/3/15,1/3/16"}
		{rxPortList	rxPortList		required	string	"Rx Port Lists,one port like 1/3/16 two ports like 1/3/15,1/3/16"}
		{sequence	sequence		optional	int	"sequence is number,default is 0,like 1,2,3..."}
		{firstTryFlag	firstTryFlag		optional	string	"firstTryFlag in start_transmint function,default is true,valid is true|false."}
		{duration	duration		optional	int	"unit is second,default 2"}
		{zcallExample	zcallExample		optional	string	"start_stream_trans_getstats -txPortList 1/3/15 -rxPortList 1/3/16 -duration 3 -firstTryFlag false -sequence 0"}
	}
	# set optional parameter default value
	set arg(duration)	2
	set arg(firstTryFlag)	true
	set arg(sequence)	0
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	parray arg
	#get the parameter In
			#set txPortListIn $arg(txPortList)
			#puts "txPortListIn is $txPortListIn"
			#set	txPortList [pLproc $arg(txPortList)]
	set	txPortList $arg(txPortList)
		#puts "txPortList is $txPortList"
			#set rxPortListIn $arg(rxPortList)
			#puts "rxPortListIn is $rxPortListIn"
			#set rxPortList [pLproc $arg(rxPortList)]
	set rxPortList $arg(rxPortList)
		#puts "rxPortList is $rxPortList"
	set duration $arg(duration)
	set firstTryFlag $arg(firstTryFlag)
	set sequence $arg(sequence)
	
	startTransAndGetStreamStats $txPortList $rxPortList $duration $firstTryFlag $sequence
}

#description:
#start transmit on Tx port,then get statistic on Tx and Rx port,it is used for port based statistic
proc start_trans_getstats {args} {
	######### parameter process start
	set argformat {
		{txPortList	txPortList		required	string	"Tx Port Lists,one port like 1/3/15 two ports like 1/3/15,1/3/16"}
		{rxPortList	rxPortList		required	string	"Rx Port Lists,one port like 1/3/16 two ports like 1/3/15,1/3/16"}
		{sequence	sequence		optional	int	"sequence is number,default is 0,like 1,2,3..."}
		{duration	duration		optional	int	"unit is second,default 2"}
		{zcallExample	zcallExample		optional	string	"start_trans_getstats -txPortList 1/3/15 -rxPortList 1/3/16 -sequence 0"}
	}
	# set optional parameter default value
	set arg(duration)	2
	set arg(sequence)	0
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
			#set txPortListIn $arg(txPortList)
			#puts "txPortListIn is $txPortListIn"
	set	txPortList [pLproc $arg(txPortList)]
		#puts "txPortList is $txPortList"
			#set rxPortListIn $arg(rxPortList)
			#puts "rxPortListIn is $rxPortListIn"
	set rxPortList [pLproc $arg(rxPortList)]
		#puts "rxPortList is $rxPortList"
	set duration $arg(duration)
	set sequence $arg(sequence)
	
	startTransAndGetStats $txPortList $rxPortList $duration $sequence
	#puts "portListIn is $portListIn"
	#set portHandle [pLhand $arg(portListIn)]
	#puts "portHandle is $portHandle"
	#set portList [pLproc $arg(portListIn)]
	#puts "portList is $portList"
	#set txPortListIn {{1 3 15}}
	#set rxPortListIn {{1 3 16}}
	#set durationIn 5
	# call exmple :	startTransAndGetStats $txPortListIn $rxPortListIn $durationIn
}


#
#description:
#check stream level equal tx with rx,it is used for stream based statistic
#
#checkStreamEqualTxWithRX 1/3/15 2 1/3/16 2 framesSent framesReceived
# check_stream_equal_tx_with_rx -oneTxPort 1/3/15 -txStreamId 1 -oneRxPort 1/3/16 -rxStreamId 1 framesSent framesReceived
# check_stream_equal_tx_with_rx -oneTxPort 1/3/15 -txStreamId 1 -oneRxPort 1/3/16 -rxStreamId 1 framesSent framesReceived -sequence 0
proc check_stream_equal_tx_with_rx {args} {
	set argformat {
		{oneTxPort	oneTxPort	required	string	"one Tx Port, one port like 1/3/15,use framesSent to check"}
		{txStreamId	txStreamId	required	string	"txStreamId,like 1 or 2 or 3 ... "}
		{oneRxPort	oneRxPort	required	string	"one Rx Port, one port like 1/3/16,use framesReceived to check"}
		{rxStreamId	rxStreamId	required	string	"rxStreamId,like 1 or 2 or 3 ... "}
		{sequence	sequence	optional	string	"sequence,it is number,like 1 or 2 or 3 ... default is 0"}
		{txStPara	txStPara	optional	string	"default is framesSent,valid value is framesSent|framesReceived"}
		{rxStPara	rxStPara	optional	string	"default is framesReceived,valid value is framesSent|framesReceived"}
		{zcallexample	zcallexample	optional	string	"check_stream_equal_tx_with_rx -oneTxPort 1/3/15 -txStreamId 1 -oneRxPort 1/3/16 -rxStreamId 1 framesSent framesReceived"}
	}
	# set optional parameter default value
	set arg(txStPara) framesSent
	set arg(rxStPara) framesReceived
	set arg(sequence) 0
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	parray arg
	#get the parameter In
	set oneTxPort $arg(oneTxPort)
	set txStreamId $arg(txStreamId)
	set oneRxPort $arg(oneRxPort)
	set rxStreamId $arg(rxStreamId)
	set txStParaIn $arg(txStPara)
	set rxStParaIn $arg(rxStPara)
	set sequence $arg(sequence)
	#checkEqualTxWithRX $oneTxPort $oneRxPort $txStParaIn $rxStParaIn $sequence
	checkStreamEqualTxWithRX $oneTxPort $txStreamId $oneRxPort $rxStreamId $txStParaIn $rxStParaIn
}

#
#description:
#check port level equal tx with rx,it is used for port based statistic
#
#checkEqualTxWithRX oneTxPort  oneRxPort framesSent userDefinedStat2
# check_equal_tx_with_rx -oneTxPort 1/3/15 -oneRxPort 1/3/16
# check_equal_tx_with_rx -oneTxPort 1/3/15 -oneRxPort 1/3/16 -sequence 1
#checkEqualTxWithRX 1/3/15 1/3/16 
proc check_equal_tx_with_rx {args} {
	set argformat {
		{oneTxPort	oneTxPort	required	string	"one Tx Port, one port like 1/3/15,use framesSent to check"}
		{oneRxPort	oneRxPort	required	string	"one Rx Port, one port like 1/3/16,use userDefinedStat2 to check"}
		{sequence	sequence	optional	string	"sequence,it is number,like 1 or 2 or 3 ... default is 0"}
		{txStPara	txStPara	optional	string	"default is framesSent,valid value is framesSent|userDefinedStat2|framesReceived|oversize"}
		{rxStPara	rxStPara	optional	string	"default is userDefinedStat2,valid value is framesSent|userDefinedStat2|framesReceived|oversize"}
		{zcallexample	zcallexample	optional	string	"check_equal_tx_with_rx -oneTxPort 1/3/15 -oneRxPort 1/3/16 -txStPara framesSent -rxStPara userDefinedStat2"}
	}
	# set optional parameter default value
	set arg(txStPara) framesSent
	set arg(rxStPara) userDefinedStat2
	set arg(sequence) 0
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	
	#get the parameter In
	set oneTxPort $arg(oneTxPort)
	set oneRxPort $arg(oneRxPort)
	set txStParaIn $arg(txStPara)
	set rxStParaIn $arg(rxStPara)
	set sequence $arg(sequence)
	checkEqualTxWithRX $oneTxPort $oneRxPort $txStParaIn $rxStParaIn $sequence
}

#
#description:
#check port equal tx with rx,it is used for multi port based statistic
#
#check_sum_equal_tx_with_rx -txPortList 1/3/15,1/3/16 -txStParaList framesSent,framesSent -rxPortList 1/3/15,1/3/16 -rxStParaList userDefinedStat2,userDefinedStat2 -sequence 1
#check_sum_equal_tx_with_rx -txPortList 1/3/15,1/3/16 -txStParaList framesSent,framesSent -rxPortList 1/3/15,1/3/16 -rxStParaList userDefinedStat2,userDefinedStat2
proc check_sum_equal_tx_with_rx {args} {
	set argformat {
		{txPortList	txPortList	required	string	"txPortList one port like 1/3/15 two ports like 1/3/15,1/3/16" }
		{txStParaList	txStParaList	required	string	"txStParaList,valid value is framesSent|userDefinedStat2|framesReceived|oversize,one tx Statistic Parameter like framesSent if two like framesSent,framesSent" }
		{rxPortList	rxPortList	required	string	"rxPortList one port like 1/3/15 two ports like 1/3/15,1/3/16"}
		{rxStParaList	rxStParaList	required	string	"rxStParaList,valid value is framesSent|userDefinedStat2|framesReceived|oversize,one tx Statistic Parameter like userDefinedStat2 if two like userDefinedStat2,userDefinedStat2"}
		{sequence	sequence	optional	string	"sequence,it is number,like 1 or 2 or 3 ... default is 0"}
		{zcallexample	zcallexample	optional	string	"check_sum_equal_tx_with_rx -txPortList 1/3/15,1/3/16 -txStParaList framesSent,framesSent -rxPortList 1/3/15,1/3/16 -rxStParaList userDefinedStat2,userDefinedStat2 -sequence 1"}
	}
	# set optional parameter default value
	set arg(sequence) 0
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	#get the parameter In
	set txPortList $arg(txPortList)
	set txStParaList $arg(txStParaList)
	set rxPortList $arg(rxPortList)
	set rxStParaList $arg(rxStParaList)
	set sequence $arg(sequence)
	checkSumEqualTxWithRx $txPortList $txStParaList $rxPortList $rxStParaList $sequence
}


#puts "source ahIxosapi.tcl end"
package provide ixia 1.0