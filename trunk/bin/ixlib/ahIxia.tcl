#!/usr/bin/tclsh8.5
#namespace eval ahGlob {
#   tclserver 10.155.30.164
#}

puts "ahIxia.tcl Initialed"
#puts "############source ahIxia start############"
#set env(IXIA_VERSION) HLTSET130
package req Ixia

# takeOwnership Port and Set port default
# inpara:
# chassisIPIn 10.155.33.216
# userNameIn ahATuser15
# portListIn 1/3/15,1/3/16
# tclservIn  10.155.30.164
# normal got Ownership and Set port default
# error info from ixialib
# call example takeOwnerAndSetportdefault 10.155.33.216 ahATuser15 1/3/15,1/3/16 10.155.30.164
proc takeOwnerAndSetportdefault {chassisIPIn userNameIn portListIn {tclservIn $::gTclserver} } {
	package req IxTclHal

	#package req Ixia
	set userName $userNameIn
	set hostname $chassisIPIn
	#puts "tclservIn is $tclservIn"
	set tclservTemp $tclservIn
	eval set tclserver $tclservTemp
	#set tclserver [expr { $tclservIn }]
	#glob gtclserver
	#upvar $tclservIn tclserver
	#eval { set tclserver $::tclserver }
	#set tclserver ${tclservIn}
	#set tclserver 10.155.33.216
	#puts "tclservIn2 tclserver is $tclserver"
	set retCode $::TCL_OK
	set clock_str1 [clock format  [clock seconds] -format %Y-%m-%d,%T]
	puts "str1 is: $clock_str1"
	if {[isUNIX]} {
		set retCode [ixConnectToTclServer $tclserver]
	}
	ixLogin $userName
	ixPuts "\nUser logged in as: $userName"
	set retCode [ixConnectToChassis $hostname]
	if {$retCode != $::TCL_OK} {
		return $retCode
	}
	set chasId [ixGetChassisID $hostname]
	puts "chasId is: $chasId"
	set clock_str2 [clock format  [clock seconds] -format %Y-%m-%d,%T]
	puts "str2 is: $clock_str2"
	#set card $cardIn
	#set port1 $port1In
	#set port2 $port2In
	#Assume transmit from port1 to port2 on same card for this example
	#process portListIn 1/3/15,1/3/16,1/3/17
	#set portL [split $portListIn ","]
	#set i 0
	#list portList ""
	#while {$i < [llength $portL] } {
	##puts "i is $i"
	#lappend portList [split [lindex $portL $i] "/"]
	#set i [expr {$i + 1}]
	#}
	set portList [pLproc $portListIn]
	puts "portList is $portList"
	#portList is {1 3 15} {1 3 16}
	#set portList [list [list $chasId $card $port1] [list $chasId $card $port2]]
	#set txPortList [list [list $chasId $card $port1] ]
	#set rxPortList [list [list $chasId $card $port2] ]
	if [ixTakeOwnership $portList force] {
		return $::TCL_ERROR
	}
	ixPuts "Setting ports to factory defaults..."
	SetPortDefaultValue $portList
	#keep the owner ship clean field
	#ixClearOwnership $portList
	#ixDisconnectFromChassis 10.155.33.216
	#after cleanUp udf etc cmd can't use
	#cleanUp
}

# find a parameter,return its value,provide others to process
# argList like $argV,
# argToFind like -ChassisIP
# normal return the value of the matched item
# error return ""

proc ahixGetArgument { argList argToFind } \
{

	set retValue ""

	if {[llength $argList] == 0 } {
		errorMsg "Error - empty argument list"
		return $retValue
	}

	# Put on the dash if it is missing.
	if {[string index $argToFind 0] != "-"} {
		set argToFind [format "-%s" $argToFind]
	}

	set index [lsearch $argList $argToFind=*]

	if {$index != -1} {
		# Just in case they passed a list with the argument, then nothing
		# after it, this will return null in that case.
		if {[catch {lindex [split [lindex $argList [expr $index + 0] ] "="] 1} retValue]} {
			set retValue ""
		}
	} else {
		puts "can't find the parameter name $argToFind,maybe use default value"
		#exit 1
	}
	return $retValue
}

#array get arg
#mac 00:00:01 chassis 10.1.1.3 ixn_tcl_server 10.155.41.8
#
#% argStringConv [array get arg] mac
#argStringIn start is mac 00:00:01 chassis 10.1.1.3 ixn_tcl_server 10.155.41.8
#argListFinal is chassis 10.1.1.3 ixn_tcl_server 10.155.41.8
#argStringIn end is -chassis 10.1.1.3 -ixn_tcl_server 10.155.41.8
#-chassis 10.1.1.3 -ixn_tcl_server 10.155.41.8
#
proc argStringConv { argStringIn filterOutPara } {
	puts "argStringIn start is $argStringIn"
	#prepare argListFinal
	#set tmpList [join $argStringIn]
	set tmpList $argStringIn
	set portListIdx [lsearch $tmpList *$filterOutPara*]
	set portListBeforeIdx [ expr {$portListIdx-1} ]
	set portListValueAfterIdx [ expr {$portListIdx+2} ]
	set argList1 [lrange $tmpList  $portListValueAfterIdx end]
	#puts "argList1 is $argList1"
	set argList2 [lrange $tmpList 0 $portListBeforeIdx]
	#puts "argList2 is $argList2"
	set argListFinal [concat $argList1 $argList2]
	puts "argListFinal is $argListFinal"

	#prapare dashArgListFinal
	set dashArgList ""
	foreach { key value } $argListFinal {
		lappend dashArgList "-$key $value"
	}
	set varTemp ""
	foreach { key value } $argListFinal {
		if { [expr { [string index $key 0] == "-" } ]  } {
			append varTemp "$key $value "
		} else {
			append varTemp "-$key $value "
		}
	}
	#puts "dashArgList is $dashArgList"

	#this append varTemp way last is the space
	set varTemp [string trim $varTemp]
	#puts "varTemp now is $varTemp"

	#this lappend list the result is the list
	set spaceList " "
	set dashArgListFinal [join $dashArgList $spaceList]
	#puts "dashArgListFinal is $dashArgListFinal"

	set argStringIn $varTemp
	puts "argStringIn end is $argStringIn"
	return $argStringIn
}

#inf_descr "1/2/5 - 00 00 00 00 00 12 - 2" to
#inf_descr "1/2/5.00:00:00:00:00:12.2"
#the splitCharOut is -
#the splitCharIn is " "
#connectChar is :
#call example
#intf_descr_mac_conv  "1/2/5 - 00 00 00 00 00 12 - 2" "-" " " ":"
#intf_descr_mac_conv  "1/2/5 - 00 00 00 00 00 12 - 2" "-" " " "."
#output intf_descr_mac_conved is 1/2/5.0000.0000.0012
#return 1/2/5.0000.0000.0012
proc intf_descr_mac_conv { stringIn splitCharOut splitCharIn connectChar } {
	#set inf_descr ""
	#set inf_descr "1/2/5 - 00 00 00 00 00 12 - 2"
	set inf_descr $stringIn
	puts "inf_descr is $inf_descr"
	if { $inf_descr != "" } {
		set infAft [split $inf_descr $splitCharOut]
		puts "infAft is $infAft"
		set s0 [string trim [lindex $infAft 0] ]
		set s2 [string trim [lindex $infAft 2] ]
		#set temp [lindex $infAft 1]
		#set m2 00 00 00 00 00 12
		#conver it to 00:00:00:00:00:02
		#set init value before convert
		set varTemp [lindex $infAft 1]
		set m2 [string trim $varTemp]
		puts "m2 is $m2"
		set incrTemp [split $m2 " "]
		set m2Length [ expr { [llength $incrTemp]-1 } ]
		set convMacInc ""
		for { set i 0 } { $i <= $m2Length } { incr i } {
			set strDecTemp [lindex $incrTemp $i]
			if { [expr { [string length $strDecTemp] <= 1 } ] } {
				set temp $strDecTemp
				set aTemp "0$temp"
				append convMacInc $aTemp
				if { $i%2 == 1 } {
					append convMacInc $connectChar
				}
			} elseif { [expr { [string length $strDecTemp] == 2 } ] } {
				append convMacInc $strDecTemp
				if { $i%2 == 1 } {
					append convMacInc $connectChar
				}
			} else {
				puts "mac_addr_increment input is error"
			}
		}
		#puts "convMacInc orig is $convMacInc"
		#remove the last connectChar
		set convMacInc [string range $convMacInc 0 end-1 ]
		puts "convMacInc is $convMacInc"
		#remove $s2 interface sequence number
		#set intf_descr_mac_conved "$s0.$convMacInc.$s2"
		set intf_descr_mac_conved "$s0.$convMacInc"
		puts "intf_descr_mac_conved is $intf_descr_mac_conved"
		return $intf_descr_mac_conved
	} else {
		puts "inf_descr is $inf_descr, inputs inf_descr error"
		return 1
	}

}

#clchen comment: 1/3/15,1/3/16 to 1/3/15 1/3/16
proc pLhand { portListIn} {
	#set portListIn 1/3/15,1/3/16
	set portL [split $portListIn ","]
	return $portL
}

# input vaule like 1/3/15,1/3/16
# return value like {1 3 15} {1 3 16}
proc pLproc { portListIn } {
	set portL [split $portListIn ","]
	set i 0
	list portList ""
	while {$i < [llength $portL] } {
		#puts "i is $i"
		lappend portList [split [lindex $portL $i] "/"]
		set i [expr {$i + 1}]
	}
	#puts "portList is $portList"
	return $portList
}

# use for convert portListIn format:
# in:portListIn like 1/3/15,1/3/16
# out: 3/15 3/16
proc pLconn { portListIn } {
	set portL [split $portListIn ","]
	#set portL $portListIn
	set i 0
	list portList ""
	while {$i < [llength $portL] } {
		#puts "i is $i"
		set idxpL [lindex $portL $i]
		#puts "idxpL is $idxpL"
		set plEle [string range $idxpL 2 end]
		#puts "plEle is $plEle"
		lappend portList $plEle
		#puts "portList is $portList"
		set i [expr {$i + 1}]
	}
	puts "portList after pLconn is $portList"
	return $portList
}

#  {1 3 15} {1 3 16}  to 1/3/15 1/3/16
proc pLToHandles { portList } {
	#call result example
	#portList before pLToHandles is {1 3 15}
	#portList after pLToHandles is 1/3/15

	#puts "portList before pLToHandles is $portList"
	set portL $portList
	#set lenportL [llength $portL]
	set i 0
	list portList5 ""
	while {$i < [llength $portL] } {
		#puts "i is $i"
		#puts "lindex portL $i is [lindex $portL $i]"
		set chasId [lindex [lindex $portL $i] 0]
		set cardId [lindex [lindex $portL $i] 1]
		set portId [lindex [lindex $portL $i] 2]
		lappend portList5 [list $chasId/$cardId/$portId]
		#puts "portList5 on index $i is $portList5 "
		set i [expr {$i + 1}]
	}
	#puts "portList after pLToHandles is $portList5"
	return $portList5
}

# 1/3/15 1/3/16 to {1 3 15} {1 3 16}
proc pLhandToportList { pLhandles } {
	set portL $pLhandles
	#set lenportL [llength $portL]
	set i 0
	list portList5 ""
	while {$i < [llength $portL] } {
		#puts "i is $i"
		#puts "lindex portL $i is [lindex $portL $i]"
		lappend portList5 [split [lindex $portL $i] "/"]
		#puts "portList5 on index $i is $portList5 "
		set i [expr {$i + 1}]
	}
	#puts "pLhandles after pLhandToPortList is $portList5"
	return $portList5
}

#SetDefaultValue for port properities
#just do, not return if normal
proc SetPortDefaultValue { argportList} {
	foreach item $argportList {
		scan $item "%d %d %d" chasId card port
		if [port setFactoryDefaults $chasId $card $port] {
			errorMsg "Error setting factory defaults on $chasId.$card.$port]."
			return $::TCL_ERROR
		}
		if [port set $chasId $card $port] {
			errorMsg "set defaults Error on $chasId.$card.$port]."
			return $::TCL_ERROR
		}
		if [port write $chasId $card $port] {
			errorMsg "write defaults to HW Error on $chasId.$card.$port]."
			return $::TCL_ERROR
		}
	}
}

proc print_Report {strReport flag} {
	#global Regkey
	if {$flag==1} {
		set strFlag "Error"
	} else {
		set strFlag "Log"
	}
	set level [expr [info level] - 1]
	if {$level > 0} {
		set levelStr "[lindex [info level $level] 0]: "
	} else {
		set levelStr "Print_Report:"
	}

	#set rs 1
	#set strInfo "$retValue != $expValue in frame No:$randNum!"

	ixPuts "$flag^$levelStr$strFlag-> $strReport"

	#registry set $Regkey "Result" "$flag^$levelStr$strFlag->$strReport"
	#registry set $Regkey "Function" "$levelStr"

	#return $flag
	return "$flag^$levelStr$strFlag->\n$strReport"
}

proc setRecvModeToCaptureMode { portListIn } {
	puts "portListIn in setRecvModeToCaptureMode is $portListIn"
	set pl [pLproc $portListIn]
	#set pltemp [pLproc $portListIn]
	#set pl $pltemp
	puts "pl in setRecvModeToCaptureMode is $pl"

	if [ixSetCaptureMode pl write] {
		return [print_Report "ixSetCaptureMode $pl" 1]
	}
	#if [ixStartCapture pl] {
	#	return [print_Report "ixStartCapture $pl" 1]
	#}
}

proc startCap { portListIn } {
	set pl [pLproc $portListIn]
	puts "pl in startCap is $pl"
	#may config capture parameter before start capture
	#ixStartCapture pl
	if [ixStartCapture pl] {
		return [print_Report "ixStartCapture $pl" 1]
	} else {
		return [print_Report "ixStartCapture $pl" 0]
	}
}

proc stopCap { portListIn } {
	puts "portListIn is $portListIn"
	set pl [pLproc $portListIn]
	#set pltemp [pLproc $portListIn]
	#set pl $pltemp
	puts "pl in stopCapture is $pl"
	#ixStopCapture pl
	if [ixStopCapture pl] {
		return [print_Report "ixStopCapture $pl" 1]
	} else {
		return [print_Report "ixStopCapture $pl" 0]
	}
}

proc getCaptureBufferAndSaveToFile { portListInOnePort fileName } {
	#set portList [pLproc $portListIn]
	set portList [split $portListInOnePort "/"]
	puts "\n portList before in getCaptureBufferAndSaveToFile is $portList"
	set chasId [lindex $portList 0]
	puts "chasId is $chasId"
	set cardId [lindex $portList 1]
	puts "cardId is $cardId"
	set portId [lindex $portList 2]
	puts "portId is $portId"

	set retVal 0

	#make sure stopCapture
	set pl [list [list $chasId $cardId $portId ] ]
	if { [ixStopCapture pl] } {
		puts "ixStopCapture $pl in getCaptureBufferAndSaveToFile failed"
		set retVal 1
	}

	#pre_process the input fileName
	#w+ way to open the file
	#if fileName exist, clear the content of the file
	#else create new blank file
	if { [catch { set f [open $fileName w+] } openFileError ] } {
		puts "openFileError is $openFileError in getCaptureBufferAndSaveToFile"
		exit 1
	} else {
		close $f
	}
	#set f [open $filename w+]

	puts "capture get $chasId $cardId $portId start"
	if {[capture get $chasId $cardId $portId]} {
		set retVal 1
		ixPuts -blue "get capture from  $chasId $cardId $portId failed..."
	} else {
		set PktCnt [capture cget -nPackets]
		ixPuts -blue "total $PktCnt available packets captured"
	}
	if {[captureBuffer get $chasId $cardId $portId 1 $PktCnt]} {
		set retVal 1
		ixPuts -red "Failed to get $PktCnt packets to captureBuffer"
	} else {
		#set captureBuffer1 [showCmd captureBuffer]
		#puts "showCmd captureBuffer is $captureBuffer1"
		if { [catch { captureBuffer export $fileName } myerror] } {
			set retVal $myerror
			puts "myerror is $myerror in captureBuffer export"
		}
	}
	puts "getCaptureBufferAndSaveToFile end"
	return $retVal
}

#add by clchen 2014/3/7
#call example portDefaultCheck 1 2 9 
#make sure port 1 2 9 portTransmitMode is portTxPacketStreams, just try one time to set
proc portDefaultCheck { chas card port } {
	#get port current config
	if { [port get $chas $card $port] } {
		return [print_Report "error getting port $chas $card $port" 1]
	}
	set transmitModeVaule [port cget -transmitMode]
	if { [ expr $transmitModeVaule != 0 ] } {
			portTransmitModeSet $chas/$card/$port -transmitMode portTxPacketStreams
			return [print_Report "call portTransmitModeSet to portTxPacketStreams for $chas $card $port" 0]
	} else {
		return [print_Report "not need call portTransmitModeSet for $chas $card $port" 0]
	}
}
#
#portTxPacketStreams		0
#portTxPacketFlows 		1 set up hardware to use packet flows
#portTxModeAdvancedScheduler 	4 set up hardware to use the advancedscheduler
#portTxModeBert 		5 set up the hardware to use Bit Error Rate patterns
#portTxModeBertChannelized 	6 set up the hardware to use channelized BERT
#portTxModeEcho 		7 sets up port to echo received packets
#portTxModeDccStreams 		8 sets up the port to only transmit DCC packets as a stream
#portTxModeDccAvancedScheduler 	9 sets up the port to only transmit DCC packets as advanced streams
#portTxModeDccFlowsSpe Streams	10 sets up the port to transmit DCC packets as flows and SPE packets as streams
#portTxModeDccFlowsSpeAdvancedScheduler
# portIn like one port 1/3/15
#call example
#portTransmitModeSet 1/3/15 -transmitMode portTxModeAdvancedScheduler
proc portTransmitModeSet {portIn args } {
	set retVal 0
	set portInTemp [split $portIn "/"]
	set chas [lindex $portInTemp 0]
	set card [lindex $portInTemp 1]
	set port [lindex $portInTemp 2]
	set portList [ list [ list $chas $card $port ]]
	#puts "portList is $portList"

	#get port current config
	if { [port get $chas $card $port] } {
		return [print_Report "error getting port $chas $card $port" 1]
	}

	if { [llength $args] <= 1 && [llength $args] >= 0 } {
		puts "args $args input error"
		set retVal 1
	}

	#start config
	while { [llength $args] >=2  } {
		set cmdx [lindex $args 0]
		set argx [lindex $args 1]
		set args [lreplace $args 0 1]
		#transmitMode when test Qos,it inputted should be portTxModeAdvancedScheduler
		case $cmdx {
			-transmitMode {
				port config -transmitMode $argx
			}
			default {
				set retVal 1
				ixPuts -red "Error : cmd option $cmdx does not exist"
				#return $retVal
				return [print_Report "Error : cmd option $cmdx does not exist" $retVal ]
			}
		}
	}

	#if [ixSetPortPacketFlowMode $chas $card $port write] {
	#	return [print_Report "Set Port to PortPacketFlowMode Failed" 1]
	#}

	# used for debug
	#puts "showCmd port is [showCmd port]"
	#catch {port set $chas $card $port} myerror
	#puts "myerror is $myerror"

	if { [port set $chas $card $port] } {
		puts "showCmd port is [showCmd port]"
		catch {port set $chas $card $port} myerror
		puts "myerror is $myerror"
		return [print_Report "failed to set port configuration on port $chas $card $port" 1]
	}
	if { [port write $chas $card $port] } {
		return [print_Report "failed to write port configuration on port $chas $card $port to hardware" 1]
	}

	#after port config,take some time to negotiate
	#set portListIdx [lsearch $args portList*]
	after 3000
	return [print_Report "portTransmitModeSet $chas $card $port " $retVal]
}

#Option Value Usage call like portReceiveModeSet 1/3/16 -receiveMode portRxModeWidePacketGroup
#portRxModeNone 			0	The displayed value for ports that do not support receive mode. Using this option for
#					ports that DO support receiveMode has no effect.
#portCapture			0x0001	(default) use normal capture buffer
#portPacketGroup			0x0002	get real time latency on received packets
#portRxTcpSessions		0x0004 use TCP session
#portRxTcpRoundTrip		0x0008 do TCP Round trip
#portRxDataIntegrity		0x0010 do data integrity
#portRxFirstTimeStamp		0x0020 get the first receive time
#portRxSequenceChecking		0x0040 do sequence checking
#portRxModeBert			0x0080 Bit Error Rate testing mode
#portRxModeIsl			0x0100 Expect ISL encapsulation
#portRxModeBertChannelized 	0x0200 Channelized BIT Error rate testing mode
#portRxModeEcho			0x0400 Gigabit echo mode
#portRxModeDcc			0x0800 DCC packets are received from the SONET overhead.
#portRxModeWidePacketGroup 	0x1000 Latency mode using wide packet groups
#portRxModePrbs 			0x2000 Enable capture of PRBS packets Note: Wide packet group must be enabled when using PRBS.
#					Note: When selected, if Data Integrity was
#					previously selected, it is disabled and a
#					message logs to the Tcl event log to note
#					the change in the receive mode.
#portRxModeRateMonitoring	0x4000 Enable capture of Rate Monitoring packets
#					Note: Wide packet group must be enabled when using Rate Monitoring.
#					Note: When selected, if Sequence
#					Checking was previously selected, it is
#					disabled and a message logs to the Tcl
#					event log to note the change in the receive
#					mode.
#portRxModePerFlowErrorStats 	0x8000 Enables capture of per-PGID checksum error stats.
#					Note: When selected, Wide Packet Groups
#					is automatically enabled.
#portRxModeWidePacketGroup
# call like portReceiveModeSet 1/3/16 -receiveMode portRxModeWidePacketGroup
proc portReceiveModeSet {portIn args } {
	set retVal 0
	set portInTemp [split $portIn "/"]
	set chas [lindex $portInTemp 0]
	set card [lindex $portInTemp 1]
	set port [lindex $portInTemp 2]
	set portList [ list [ list $chas $card $port ]]
	#puts "portList is $portList"

	#get port current config
	if { [port get $chas $card $port] } {
		return [print_Report "error getting port $chas $card $port" 1]
	}

	if { [llength $args] <= 1 && [llength $args] >= 0 } {
		puts "args $args input error"
		set retVal 1
	}
	#start config
	while { [llength $args] >= 2  } {
		set cmdx [lindex $args 0]
		set argx [lindex $args 1]
		set args [lreplace $args 0 1]
		# when test Qos,transmitMode inputted should be portTxModeAdvancedScheduler on txPort
		# and receiveMode inputted shoulde be portRxModeWidePacketGroup
		case $cmdx {
			-receiveMode {
				port config -receiveMode $argx
			}
			default {
				set retVal 1
				ixPuts -red "Error : cmd option $cmdx does not exist"
				#return $retVal
				return [print_Report "Error : cmd option $cmdx does not exist" $retVal ]
			}
		}
	}

	#if [ixSetPortPacketFlowMode $chas $card $port write] {
	#	return [print_Report "Set Port to PortPacketFlowMode Failed" 1]
	#}

	# used for debug
	#puts "showCmd port is [showCmd port]"
	#catch {port set $chas $card $port} myerror
	#puts "myerror is $myerror"

	if { [port set $chas $card $port] } {
		puts "showCmd port is [showCmd port]"
		catch {port set $chas $card $port} myerror
		puts "myerror is $myerror"
		return [print_Report "failed to set port configuration on port $chas $card $port" 1]
	}
	if { [port write $chas $card $port] } {
		return [print_Report "failed to write port configuration on port $chas $card $port to hardware" 1]
	}

	#after port config,take some time to negotiate
	#set portListIdx [lsearch $args portList*]
	after 3000
	return [print_Report "portReceiveModeSet $chas $card $port " $retVal]
}

#call example portStatModeSet 1/3/15 -statMode statQos -qosPacketType vlan
#portIn			input like 1/3/15, only support one port input
#-statMode 		input like statQos
#statMode inputted like statQos|statNormal|statStreamTrigger|statModeChecksumErrors|statModeDataIntegrity
#-qosPacketType 		input like vlan|ipEthernetII
#-qosByteOffset		input like 15
#-qosPatternMatch	input like 80
proc portStatModeSet {portIn args } {
	set retVal 0
	set portInTemp [split $portIn "/"]
	set chas [lindex $portInTemp 0]
	set card [lindex $portInTemp 1]
	set port [lindex $portInTemp 2]
	set portList [ list [ list $chas $card $port ]]
	#puts "portList is $portList"

	#get port current config
	if { [port get $chas $card $port] } {
		return [print_Report "error getting port $chas $card $port" 1]
	}

	if { [llength $args] <= 1 && [llength $args] >= 0 } {
		puts "args $args input error"
		set retVal 1
	}
	#start config
	#puts "1 showCmd stat is [showCmd qos]"
	#found that it packetType default is vlan
	while { [llength $args] >=2  } {
		set cmdx [lindex $args 0]
		set argx [lindex $args 1]
		set args [lreplace $args 0 1]
		# when test Qos,transmitMode inputted should be portTxModeAdvancedScheduler on txPort
		# and receiveMode inputted shoulde be portRxModeWidePacketGroup
		# statMode inputted like statQos|statNormal|statStreamTrigger|statModeChecksumErrors|statModeDataIntegrity
		# qosPacketType inputted like vlan|ipEthernetII|custom
		#qos setup custom
		#qos config -packetType                         custom
		#qos config -byteOffset                         18
		#qos config -patternOffset                      19
		#qos config -patternMatch                       "20 20"
		#qos config -patternMask                        "00 11"

		case $cmdx {
			-statMode {
				#stat config -mode                               statQos
				stat config -mode $argx
			}
			-qosPacketType {
				#qos setup vlan|ipEthernetII
				qos setup $argx
				if { $argx == "ipEthernetII" } {
					qos config -packetType ipEthernetII
					qos config -byteOffset 15
					qos config -patternMatch "08 00"
				}
			}
			-qosByteOffset {
				#qos config -byteOffset                         15
				qos config -byteOffset $argx
			}
			-qosPatternMatch {
				#qos config -patternMatch                       "08 00"
				qos config -patternMatch $argx
			}
			default {
				set retVal 1
				ixPuts -red "Error : cmd option $cmdx does not exist"
				#return $retVal
				return [print_Report "Error : cmd option $cmdx does not exist" $retVal ]
			}
		}
	}

	#if [ixSetPortPacketFlowMode $chas $card $port write] {
	#	return [print_Report "Set Port to PortPacketFlowMode Failed" 1]
	#}

	#stat set
	if { [catch {stat set $chas $card $port} myerror ] } {
		puts "showCmd stat is [showCmd stat]"
		puts "myerror is $myerror"
		errorMsg "Error calling stat set $chas $card $port"
		set retCode $::TCL_ERROR
		return [print_Report "failed to stat set on port $chas $card $port" 1]
	}

	#qos set
	#puts "2 showCmd stat is [showCmd qos]"
	if { [catch {qos set $chas $card $port} myerror ] } {
		puts "showCmd stat is [showCmd qos]"
		puts "myerror is $myerror"
		errorMsg "Error calling qos set $chas $card $port"
		set retCode $::TCL_ERROR
		return [print_Report "failed to qos set on port $chas $card $port" 1]
	}

	#port set
	if { [catch {port set $chas $card $port} myerror] } {
		puts "showCmd port is [showCmd port]"
		#catch {port set $chas $card $port} myerror
		puts "myerror is $myerror"
		return [print_Report "failed to port set on port $chas $card $port" 1]
	}

	#port write
	if { [port write $chas $card $port] } {
		return [print_Report "failed to port write configuration on port $chas $card $port to hardware" 1]
	}

	#after port config,take some time to negotiate
	#set portListIdx [lsearch $args portList*]
	after 3000
	return [print_Report "portStatModeSet $chas $card $port " $retVal]
}

#in para
#portIn like 1/3/15
#speed 10|100|1000
#duplexMode half|full
#autoneg true|false
#advertiseAbilities portAdvertiseNone|portAdvertiseSend|portAdvertiseSendAndReceive|portAdvertiseSendAndOrReceive
#PhyMode copper|fiber
#10fullIn true|false
#10halfIn true|false
#100fullIn true|false
#100halfIn true|false
#1000fullIn true|false
# out 0 is ok
# out not 0 is error
proc ahPortConfig {portIn speed duplexMode autoneg advertiseAbilities {PhyMode 0} {10fullIn "true"} {10halfIn "true"} {100fullIn "true"} {100halfIn "true"} {1000fullIn "true"} {enableSimulateCableDisconnect "false"} {flowControl "false"} {waitTime 5000} } {
	set portInTemp [split $portIn "/"]
	set chas [lindex $portInTemp 0]
	set card [lindex $portInTemp 1]
	set port [lindex $portInTemp 2]
	set portList [ list [ list $chas $card $port ]]
	#puts "portList is $portList"

	#get
	if { [port get $chas $card $port] } {
		return [print_Report "error getting port $chas $card $port" 1]
	}

	# follow one is not valid
	# port setPhyMode $PhyMode $chas $card $port

	#config fiber port
	if { $PhyMode == "fiber" } {
		#Config Port Phy Mode
		if {[port setPhyMode $::portPhyModeFiber $chas $card $port]} {
			errorMsg "Error calling port $::portPhyModeFiber $PhyMode $chas $card $port"
			set retCode $::TCL_ERROR
			puts "retCode is $retCode"
		}
		if { $autoneg == "true" } {
			port config -autonegotiate  true
			port config -advertise10FullDuplex   false
			port config -advertise10HalfDuplex   false
			port config -advertise100FullDuplex  false
			port config -advertise100HalfDuplex  false
			port config -advertise1000FullDuplex true
			port config -speed 1000
			port config -operationModeList [list $::portOperationModeStream]
		} else {
			port config -autonegotiate  false
			if { $speed == 100 || $speed == 1000 } {
				port config -speed $speed
			}
			port config -advertise100FullDuplex   $100fullIn
			port config -advertise100HalfDuplex   $100halfIn
			port config -advertise1000FullDuplex  $1000fullIn
		}
		#config transmitMode for fiber mode
		#port config -transmitMode   portTxPacketFlows
		port config -transmitMode portTxModeAdvancedScheduler
		if [ixSetPortPacketFlowMode $chas $card $port write] {
			return [print_Report "Set Port to PortPacketFlowMode Failed" 1]
		}

	}

	#config copper port
	if { $PhyMode == "copper" } {
		#Config Port Phy Mode
		if {[port setPhyMode $::portPhyModeCopper $chas $card $port]} {
			errorMsg "Error calling port $::portPhyModeCopper $PhyMode $chas $card $port"
			set retCode $::TCL_ERROR
			puts "retCode is $retCode"
		}
		#start config
		port config -speed $speed
		port config -duplex $duplexMode
		port config -autonegotiate $autoneg

		port config -advertise10FullDuplex   $10fullIn
		port config -advertise10HalfDuplex   $10halfIn
		port config -advertise100FullDuplex   $100fullIn
		port config -advertise100HalfDuplex   $100halfIn
		port config -advertise1000FullDuplex  $1000fullIn

		#config transmitMode under copper mode
		port config -transmitMode   portTxPacketStreams
		#port config -transmitMode portTxModeAdvancedScheduler
		if [ixSetPortPacketFlowMode $chas $card $port write] {
			return [print_Report "Set Port to PortPacketFlowMode Failed" 1]
		}
		#config negotiateMasterSlave to autonegotiate under copper mode
		port config -negotiateMasterSlave	1

	}

	#config pub field
	port config -advertiseAbilities $advertiseAbilities
	#port config -advertiseAbilities portAdvertiseNone
	port config  -enableSimulateCableDisconnect $enableSimulateCableDisconnect
	#
	#config flowControl
	#default is false
	#port config -flowControl                        false
	#port config -directedAddress                    "01 80 C2 00 00 01"
	port config -flowControl                        $flowControl
	port config -directedAddress                    "01 80 C2 00 00 01"
	# used for debug
	#puts "showCmd port is [showCmd port]"
	#catch {port set $chas $card $port} myerror
	#puts "myerror is $myerror"

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
	#take waitTime to let port autonegotiate
	after $waitTime
	return [print_Report "port config $chas $card $port " 0]
}

#
#set portListIn 1/3/15,1/3/16
#set sequence 1
#portStatusGet $portListIn $sequence
proc portStatusGet {portListIn {sequence 0} } {
	set portList [split $portListIn ","]
	puts "portList is $portList"
	#add wait 3seconds in header
	after 3000
	foreach item $portList {

		#puts "interface_stats_result on $item is $interface_stats_result"
		#if { [expr { [keylget interface_stats_result status] == $::FAILURE }] } {
		#	puts "get interface_stats failed on port $item"
		#} else {
		#	puts "get interface_stats success on port $item"
		#}

		#the got value
		#scan $item "%d %d %d" chasId card port
		set itemTemp [split $item "/"]
		set chasId [lindex $itemTemp 0]
		set cardId [lindex $itemTemp 1]
		set portId [lindex $itemTemp 2]
		#get port config on current port
		puts "current port is  $chasId $cardId $portId"
		port get $chasId $cardId $portId
		set enableSimulateCableDisconnectValue [port cget -enableSimulateCableDisconnect]
		puts "enableSimulateCableDisconnectValue on $chasId $cardId $portId is $enableSimulateCableDisconnectValue"
		if { [expr {$enableSimulateCableDisconnectValue == 0} ] } {
			set adminState "adminUp"
		} elseif { [expr {$enableSimulateCableDisconnectValue == 1} ] } {
			set adminState "adminDown"
		}
		
		set interface_stats_result [ixia::interface_stats -port_handle $item]
		keylset interface_stats_list $sequence $interface_stats_result
		puts "current port is $item in portList"
		puts "sequence $sequence interface_stats_list under port $item is  $interface_stats_list"
		

		#set the value
		set link [ keylget interface_stats_list $sequence.$item.link ]
		if { [expr {$link != 0 && $link != 1 && $link != 25 }] } {
			#autoNegotiating now,sleep 30
			ixPuts "middle state now,sleep 30s"
			after 30000
			#reget the value
			ixPuts "reget the status value"
			set interface_stats_result [ixia::interface_stats -port_handle $item]
			keylset interface_stats_list $sequence $interface_stats_result
			puts "reget interface_stats_list under port $item is  $interface_stats_list"
			set link [ keylget interface_stats_list $sequence.$item.link ]
		}
		
		set duplex [ keylget interface_stats_list $sequence.$item.duplex ]
		set speed [ keylget interface_stats_list $sequence.$item.intf_speed ]
		set tx_frames [ keylget interface_stats_list $sequence.$item.tx_frames ]
		set rx_frames [ keylget interface_stats_list $sequence.$item.rx_frames ]
		set fcs_errors [ keylget interface_stats_list $sequence.$item.fcs_errors ]

		set state "-1"
		set upDown "-1"
		if { [expr {$link == 0 || $link == 25 } ] } {
			set state "Link Down"
			set upDown "down"
		} elseif { [expr {$link == 1} ] } {
			set state "Link Up"
			set upDown "up"
		} 
		
		#output the value
		ixPuts "$sequence.$item.link=$link"
		ixPuts "$sequence.$item.duplex=$duplex"
		ixPuts "$sequence.$item.speed=$speed"
		ixPuts "$sequence.$item.state=$state"
		ixPuts "$sequence.$item.tx_frames=$tx_frames"
		ixPuts "$sequence.$item.rx_frames=$rx_frames"
		ixPuts "$sequence.$item.fcs_errors=$fcs_errors"
		ixPuts "$sequence.$item.adminState=$adminState"
		ixPuts "$sequence.Port:$item; Speed:$speed; Duplex:$duplex; Link:$upDown"
		ixPuts "\n"
		#ixPuts -blue "output done \n"
		#ixPuts -red "output done \n"
	}
}

# clchen add 2013/07/26
proc streamStackVlanSetOnePort {onePort {streamIdL -1} {streamName all} {vlanOp "vlanStacked"} \
			{vlanIDOuter 1} {userPriorityOuter 0} {cfiOuter 0} {modeOuter "vIncrement"} {repeatOuter 1} {stepOuter 1} {protocolTagIdOuter "vlanProtocolTag8100"} \
			{vlanIDInner 1} {userPriorityInner 0} {cfiInner 0} {modeInner "vIncrement"} {repeatInner 1} {stepInner 1} {protocolTagIdInner "vlanProtocolTag8100"} } {
	set retVal 0
	set portInfo [ split $onePort "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	if { [port get $chasId $cardId $portId] } {
		puts "failed in port get $chasId $cardId $portId"
	}
	set portName [port cget -name]

	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	}
	#streamIdL input default is -1
	#set streamIdL -1
	#get first Match streamIdL with streamName
	for { set index 1 } { $index <= $streamCount } { incr index } {
		stream get $chasId $cardId $portId $index
		set strName [ stream cget -name ]
		if { [expr {$strName == $streamName }] } {
			puts "got it, streamIdL is $index with streamName $streamName"
			set streamIdL $index
			break
		}
	}
	if { [expr {$streamIdL == -1}] } {
		puts "not got streamIdL with streamName $streamName,or streamIdL is not filled in,error in streamStackVlanSet "
		exit 1
	}
	#set stream with streamIdL
	#puts "streamIdL is $streamIdL"
	if { [expr { $streamIdL != -1}] } {
		#stream modify start
		#puts "streamIdL in is $streamIdL"
		stream get $chasId $cardId $portId $streamIdL

		#enable vlan config
		# protocol config -enable802dot1qTag	vlanSinglge
		# default config enable stackVlan,vlanOp default is true
		protocol config -enable802dot1qTag	vlanStacked
		#protocol config -enable802dot1qTag	$vlanOp

		protocol setDefault
		protocol config -enable802dot1qTag                  vlanStacked

		# stream set to HAL
		set strName [ stream cget -name ]
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			return 1
		} else {
			puts "success: enable vlanStacked "
		}

		# write to hardware
		lappend portList [list $chasId $cardId $portId]
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			IxPuts -red "Unable to write config to hardware"
			set retVal 1
		}

		#get current stream
		stream get $chasId $cardId $portId $streamIdL

		#stackedVlan setDefault
		#set vlanPosition 1
		#vlan setDefault
		#vlan config -vlanID	                     1
		#vlan config -userPriority                       1
		#vlan config -cfi                                setCFI
		#vlan config -mode                               vIncrement
		#vlan config -repeat                             11
		#vlan config -step                               11
		#vlan config -maskval                            "0011XXXXXXXXXXXX"
		#vlan config -protocolTagId                      vlanProtocolTag9100
		#if {[stackedVlan setVlan $vlanPosition]} {
		#	errorMsg "Error calling stackedVlan setVlan $vlanPosition"
		#	set retCode $::TCL_ERROR
		#}
		#
		#
		#incr vlanPosition
		#vlan setDefault
		#vlan config -vlanID                             22
		#vlan config -userPriority                       2
		#vlan config -cfi                                setCFI
		#vlan config -mode                               vIncrement
		#vlan config -repeat                             22
		#vlan config -step                               22
		#vlan config -maskval                            "0101XXXXXXXXXXXX"
		#vlan config -protocolTagId                      vlanProtocolTag9200
		#if {[stackedVlan setVlan $vlanPosition]} {
		#	errorMsg "Error calling stackedVlan setVlan $vlanPosition"
		#	set retCode $::TCL_ERROR
		#}
		#
		#if {[stackedVlan set $chassis $card $port]} {
		#	errorMsg "Error calling stackedVlan set $chassis $card $port"
		#	set retCode $::TCL_ERROR
		#}
		#
		stackedVlan setDefault
		set vlanPosition 1
		vlan setDefault
		vlan config -vlanID                             $vlanIDOuter
		vlan config -userPriority                       $userPriorityOuter
		vlan config -cfi                                $cfiOuter
		vlan config -mode                               $modeOuter
		vlan config -repeat                             $repeatOuter
		vlan config -step                               $stepOuter
		vlan config -maskval                            "0011XXXXXXXXXXXX"
		vlan config -protocolTagId                      $protocolTagIdOuter
		if {[stackedVlan setVlan $vlanPosition]} {
			errorMsg "Error calling stackedVlan setVlan $vlanPosition"
			set retCode $::TCL_ERROR
		} else {
			puts "setting success: stackedVlan setVlan $vlanPosition"
		}

		incr vlanPosition
		vlan setDefault
		vlan config -vlanID                             $vlanIDInner
		vlan config -userPriority                       $userPriorityInner
		vlan config -cfi                                $cfiInner
		vlan config -mode                               $modeInner
		vlan config -repeat                             $repeatInner
		vlan config -step                               $stepInner
		vlan config -maskval                            "0101XXXXXXXXXXXX"
		vlan config -protocolTagId                      $protocolTagIdInner
		#showCmd vlan
		#puts "showCmd vlan is "
		#puts "stackedvlan setVlan 2 is: [stackedVlan setVlan $vlanPosition]"
		if {[stackedVlan setVlan $vlanPosition]} {
			errorMsg "Error calling stackedVlan setVlan $vlanPosition"
			set retCode $::TCL_ERROR
		} else {
			puts "setting success: stackedVlan setVlan $vlanPosition"
		}

		if {[stackedVlan set $chasId $cardId $portId]} {
			errorMsg "Error calling stackedVlan set $chasId $cardId $portId"
			set retCode $::TCL_ERROR
		}

		# stream set to HAL
		set strName [ stream cget -name ]
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,is streamStackVlanSet"
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			return 1
		}
		# write to hardware
		lappend portList [list $chasId $cardId $portId]
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			IxPuts -red "Unable to write config to hardware"
			set retVal 1
		}
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,streamStackVlanSet done "
		return $retVal
	}
}

#
#
# clchen add 2013/05/03
proc streamModifyOnePort {onePort {streamIdL -1} {streamName all} {vlanID 1} {userPriority 0} {cfi 0} {mode "vIncrement"} {repeat 1} {step 1} {protocolTagId "vlanProtocolTag8100"} {vlanOp "false"} } {
	set retVal 0
	set portInfo [ split $onePort "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	if { [port get $chasId $cardId $portId] } {
		puts "failed in port get $chasId $cardId $portId"
	}
	set portName [port cget -name]

	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	}
	#streamIdL input default is -1
	#set streamIdL -1
	#get first Match streamIdL with streamName
	for { set index 1 } { $index <= $streamCount } { incr index } {
		stream get $chasId $cardId $portId $index
		set strName [ stream cget -name ]
		if { [expr {$strName == $streamName }] } {
			puts "got it, streamIdL is $index with streamName $streamName"
			set streamIdL $index
			break
		}
	}
	if { [expr {$streamIdL == -1}] } {
		puts "not got streamIdL with streamName $streamName,or streamIdL is not filled in,error in streamModify "
		exit 1
	}
	#set stream with streamIdL
	#puts "streamIdL is $streamIdL"
	if { [expr { $streamIdL != -1}] } {
		#stream modify start
		#puts "streamIdL in is $streamIdL"
		stream get $chasId $cardId $portId $streamIdL

		#vlan setDefault
		#vlan config -vlanID		1
		#vlan config -userPriority	2
		#vlan config -cfi		setCFI
		#vlan config -mode		vIncrement
		#vlan config -repeat		3
		#vlan config -step		4
		#vlan config -maskval		"0101XXXXXXXXXXXX"
		#vlan config -protocolTagId	vlanProtocolTag8100

		vlan config -vlanID		$vlanID
		vlan config -userPriority	$userPriority
		vlan config -cfi		$cfi
		vlan config -mode		$mode
		vlan config -repeat		$repeat
		vlan config -step		$step
		#vlan config -maskval		"0101XXXXXXXXXXXX"
		vlan config -protocolTagId	$protocolTagId
		if {[vlan set $chasId $cardId $portId]} {
			errorMsg "Error calling vlan set  $chasId $cardId $portId"
			set retCode $::TCL_ERROR
		}
		#enable vlan config
		# protocol config -enable802dot1qTag	vlanSingle
		protocol config -enable802dot1qTag	$vlanOp
		# stream set to HAL
		set strName [ stream cget -name ]
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,is streamModifying"
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			return 1
		}
		# write to hardware
		lappend portList [list $chasId $cardId $portId]
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			IxPuts -red "Unable to write config to hardware"
			set retVal 1
		}
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,streamModify done "
		return $retVal
	}
}

proc streamPercentRateSet {onePort {streamIdL -1} {streamName all} {percentPacketRate "100"} } {
	set retVal 0
	set portInfo [ split $onePort "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	if { [port get $chasId $cardId $portId] } {
		puts "failed in port get $chasId $cardId $portId"
	}
	set portName [port cget -name]

	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	}
	#streamIdL input default is -1
	#set streamIdL -1
	#get first Match streamIdL with streamName
	for { set index 1 } { $index <= $streamCount } { incr index } {
		stream get $chasId $cardId $portId $index
		set strName [ stream cget -name ]
		if { [expr {$strName == $streamName }] } {
			puts "got it, streamIdL is $index with streamName $streamName"
			set streamIdL $index
			break
		}
	}
	if { [expr {$streamIdL == -1}] } {
		puts "not got streamIdL with streamName $streamName,or streamIdL is not filled in,error in streamTransmitMethodSet "
		exit 1
	}
	#set stream with streamIdL
	#puts "streamIdL is $streamIdL"
	if { [expr { $streamIdL != -1}] } {
		#stream modify start
		puts "streamIdL in is $streamIdL"
		stream get $chasId $cardId $portId $streamIdL
		puts "percentPacketRate is $percentPacketRate"
		#modify stream rate percent
		stream config -rateMode		streamRateModePercentRate
		stream config -percentPacketRate $percentPacketRate

		# stream set to HAL
		set strName [ stream cget -name ]
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,is percentPacketRateSetting"
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			return 1
		}
		# write to hardware
		lappend portList [list $chasId $cardId $portId]
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			ixPuts -red "Unable to write config to hardware"
			set retVal 1
		}
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,percentPacketRateSetting done "
		return $retVal
	}
}

proc streamTransmitMethodSet {onePort {streamIdL -1} {streamName all} {transmitMethod "contPacket"} {numFrames "100"} {numBursts "1"} } {
	set retVal 0
	set portInfo [ split $onePort "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	if { [port get $chasId $cardId $portId] } {
		puts "failed in port get $chasId $cardId $portId"
	}
	set portName [port cget -name]

	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	}
	#streamIdL input default is -1
	#set streamIdL -1
	#get first Match streamIdL with streamName
	for { set index 1 } { $index <= $streamCount } { incr index } {
		stream get $chasId $cardId $portId $index
		set strName [ stream cget -name ]
		if { [expr {$strName == $streamName }] } {
			puts "got it, streamIdL is $index with streamName $streamName"
			set streamIdL $index
			break
		}
	}
	if { [expr {$streamIdL == -1}] } {
		puts "not got streamIdL with streamName $streamName,or streamIdL is not filled in,error in streamTransmitMethodSet "
		exit 1
	}
	#set stream with streamIdL
	#puts "streamIdL is $streamIdL"
	if { [expr { $streamIdL != -1}] } {
		#stream modify start
		#puts "streamIdL in is $streamIdL"
		stream get $chasId $cardId $portId $streamIdL

		#modify stream transmit method contPacket|contBurst|stopStream|advance|gotoFirst|firstLoopCount
		stream config -dma $transmitMethod

		#if transmitMedtod is stopStream then can set  
		#stream config -numBursts                          1
		#stream config -numFrames                          100
		if { [expr { $transmitMethod != "contPacket" } ] } {
			stream config -numFrames $numFrames
		} 
		
		if { [expr { $transmitMethod != "contPacket" || $transmitMethod != "contBurst" } ] } {
			stream config -numBursts $numBursts
		} 
		
		
		# stream set to HAL
		set strName [ stream cget -name ]
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,is streamTransmitMethodSetting"
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			return 1
		}
		# write to hardware
		lappend portList [list $chasId $cardId $portId]
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			ixPuts -red "Unable to write config to hardware"
			set retVal 1
		}
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,streamTransmitMethodSet done "
		return $retVal
	}
}

proc streamPauseControlSet {onePort {streamIdL -1} {protocolName "pauseControl"} {pauseTime 255}  } {

	set retVal 0
	set portInfo [ split $onePort "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	if { [port get $chasId $cardId $portId] } {
		puts "failed in port get $chasId $cardId $portId"
	}
	set portName [port cget -name]

	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	}

	#set streamIdL with input value
	set streamIdL $streamIdL
	if { [expr {$streamIdL == -1}] } {
		puts "streamIdL is $streamIdL,streamIdL is not filled in "
		exit 1
	}

	###streamIdL input default is -1
	###set streamIdL -1
	###get first Match streamIdL with streamName
	##for { set index 1 } { $index <= $streamCount } { incr index } {
	##	stream get $chasId $cardId $portId $index
	##	set strName [ stream cget -name ]
	##	if { [expr {$strName == $streamName }] } {
	##		puts "got it, streamIdL is $index with streamName $streamName"
	##		set streamIdL $index
	##		break
	##	}
	##}
	##if { [expr {$streamIdL == -1}] } {
	##	puts "not got streamIdL with streamName $streamName,or streamIdL is not filled in,error in streamModify "
	##	exit 1
	##}

	###process streamIdL all
	##if { [expr { $streamIdL == "all"} ] } {
	##	for { set index 1 } { $index <= $streamCount } { incr index } {
	##		stream get $chasId $cardId $portId $index
	##
	##		#do some config
	##		protocol config -enable802dot1qTag	false
	##		if {[vlan set $chasId $cardId $portId]} {
	##			errorMsg "Error calling vlan set  $chasId $cardId $portId"
	##			set retCode $::TCL_ERROR
	##			set retVal 1
	##		}
	##		#set to HAL
	##		set strName [ stream cget -name ]
	##		puts "under $chasId $cardId $portId,streamId is $index,strName is $strName,is in setting"
	##		if {[catch {stream set $chasId $cardId $portId $index} my_Error]} {
	##			puts "Error $my_Error in stream set $chasId $cardId $portId $index^1"
	##			set retVal 1
	##		}
	##		# write to hardware
	##		lappend portList [list $chasId $cardId $portId]
	##		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
	##			IxPuts -red "Unable to write config to hardware"
	##			set retVal 1
	##		}
	##
	##		puts "under $chasId $cardId $portId,streamId is $index,strName is $strName, is done"
	##		return $retVal
	##	}
	##}
	##
	##

	#set stream with streamIdL
	#puts "streamIdL is $streamIdL"
	if { [expr { $streamIdL != -1 && $streamIdL != "all" }] } {
		#stream modify start
		#puts "streamIdL in is $streamIdL"
		stream get $chasId $cardId $portId $streamIdL

		#vlan setDefault
		#vlan config -vlanID		1
		#vlan config -userPriority	2
		#vlan config -cfi		setCFI
		#vlan config -mode		vIncrement
		#vlan config -repeat		3
		#vlan config -step		4
		#vlan config -maskval		"0101XXXXXXXXXXXX"
		#vlan config -protocolTagId	vlanProtocolTag8100

		#disable vlan
		protocol config -enable802dot1qTag	false

		if {[vlan set $chasId $cardId $portId]} {
			errorMsg "Error calling vlan set  $chasId $cardId $portId"
			set retCode $::TCL_ERROR
			set retVal 1
		}

		#config pause control
		#protocol setDefault
		#protocol config -name pauseControl
		#protocol config -ethernetType ethernetII
		#
		#pauseControl setDefault
		#pauseControl config -pauseTime 222

		#protocol setDefault
		#puts "protocolName is $protocolName"
		protocol config -name $protocolName
		protocol config -ethernetType ethernetII
		#puts "[showCmd protocol]"

		pauseControl setDefault
		#puts "pauseTime is $pauseTime"
		pauseControl config -pauseTime $pauseTime
		#puts "[showCmd pauseControl]"

		if {[pauseControl set $chasId $cardId $portId]} {
			errorMsg "Error calling pauseControl set $chassis $card $port"
			set retCode $::TCL_ERROR
			set retVal 1
		}

		# stream set to HAL
		#puts "[showCmd stream]"
		set strName [ stream cget -name ]
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,is streamPauseControlSetting"
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			set retVal 1
		}
		# write to hardware
		lappend portList [list $chasId $cardId $portId]
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			ixPuts -red "Unable to write config to hardware"
			set retVal 1
		}
		return [print_Report "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,streamPauseControlSet done" $retVal]

	}
}

#call example
#steamIpDSCPSet 1/3/15 -streamId 1 -dscpValue 0x3d -dscpMode ipV4DscpCustom
#steamIpDSCPSet 1/3/15 -streamId 2 -dscpValue 0x3d -destIpAddr 1.1.1.1 -sourceIpAddr 2.2.2.2
proc steamIpDSCPSet {portIn args } {
	set retVal 0
	set portInTemp [split $portIn "/"]
	set chasId [lindex $portInTemp 0]
	set cardId [lindex $portInTemp 1]
	set portId [lindex $portInTemp 2]
	set portList [ list [ list $chasId $cardId $portId ]]
	#puts "portList is $portList"
	set args [join $args ""]
	puts "args after join is $args"
	puts "llength args is [llength $args]"

	#get streamIdL from args
	if { [llength $args] <= 1 && [llength $args] >= 0 } {
		puts "args $args input error,args length should be more than 2"
		set retVal 1
		return [print_Report "args length should be more than 2" $retVal]
	} else {
		set streamIdLIdx [lsearch $args *streamId]
		if { $streamIdLIdx == -1 } {
			return [print_Report "get streamIdLIdx failed" 1]
		} else {
			set streamIdLValueIdx [ expr {$streamIdLIdx+1} ]
			set streamIdL [lindex $args $streamIdLValueIdx]
			puts "The got streamIdL is $streamIdL"
		}
	}

	#process the streamIdL on the input port
	if { [expr { $streamIdL != -1 && $streamIdL != "all" }] } {

		if {[catch {stream get $chasId $cardId $portId $streamIdL} my_Error]} {
			set retVal 1
			puts "Error $my_Error in stream get $chasId $cardId $portId $streamIdL"
			return [print_Report "stream get $chasId $cardId $portId $streamIdL error" $retVal]
		} else {
			set strName [ stream cget -name ]
			puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,is steamIpDSCPSetting"
		}

		#set protocol name as Ipv4 and ethernetII
		#protocol config -name $protocolName
		protocol config -name ipV4
		protocol config -ethernetType ethernetII
		#puts "[showCmd protocol]"

		#start config
		#ip config -precedence                         priority routine|priority|immediate|flash|flashOverride|criticEcp|internetControl|networkControl
		#ip config -delay                              lowDelay   0|1 normalDelay|lowDelay
		#ip config -throughput                         highThruput 0|1 normalThruput|highThruput
		#ip config -reliability                        1 0 1 normalReliability|highReliability
		#ip config -cost                               1 0 1 normalCost|lowCost
		#ip config -reserved                           1 0 1 Part of the Type of Service byte of the IP header datagram (bit 7 - 0/1) default=0
		#ip config -ipProtocol                         ipV4ProtocolReserved255
		#ip config -checksum                           "73 8d"
		#ip config -sourceIpAddr                       "2.2.2.2"
		#ip config -sourceIpAddrRepeatCount            10
		#ip config -sourceClass                        classA
		#ip config -destIpAddr                         "1.1.1.1"
		#ip config -destIpAddrRepeatCount              10
		#ip config -destClass                          classA
		#ip config -destMacAddr                        "00 DE BB 00 00 02"
		#ip config -destDutIpAddr                      "0.0.0.0"
		#for DSCP special
		#ip config -qosMode                            ipV4ConfigDscp 0|1 ipV4ConfigTos|ipV4ConfigDscp
		#ip config -dscpMode                           ipV4DscpCustom ipV4DscpDefault|ipV4DscpClassSelector|ipV4DscpAssuredForwarding|ipV4DscpExpeditedForwarding|ipV4DscpCustom
		#0 1 2 3 4
		#ip config -dscpValue                          0x3f    dscpValue If qosMode is set to ipv4ConfigDscp and dscpMode is set to ipV4DscpCustom,
		#then this holds the value of the TOS/DSCP byte

		#fixed ip config
		ip config -qosMode                            ipV4ConfigDscp

		#set default value for dscpMode
		ip config -dscpMode                           ipV4DscpCustom
		#ipV4DscpClass1|ipV4DscpClass2|ipV4DscpClass3|ipV4DscpClass4|ipV4DscpClass5|ipV4DscpClass6|ipV4DscpClass7
		while { [llength $args] >=2  } {
			set cmdx [lindex $args 0]
			set argx [lindex $args 1]
			set args [lreplace $args 0 1]
			#config IpDSCP
			# -exact
			#string range $str 1 end
			#set cmdxTemp [string range $cmdx 1 end]
			switch -exact $cmdx {
				streamId {
					#puts ""
				}
				dscpMode {
					ip config -dscpMode $argx
				}
				dscpValue {
					set dscpValueHex [dectohex $argx]
					ip config -dscpValue $dscpValueHex
				}

				classSelector {
					ip config -classSelector $argx
				}
				destIpAddr {
					ip config -destIpAddr $argx
				}
				destIpAddrRepeatCount {
					puts "destIpAddrRepeatCount argx is $argx"
					ip config -destIpAddrRepeatCount $argx
				}
				sourceIpAddr {
					ip config -sourceIpAddr $argx
				}
				sourceIpAddrRepeatCount {
					ip config -sourceIpAddrRepeatCount $argx
				}
				default {
					set retVal 1
					ixPuts -red "Error : cmd option $cmdx does not exist"
					#return $retVal
					return [print_Report "Error : cmd option $cmdx does not exist" $retVal]
				}
			}
		}
		if {[ip set $chasId $cardId $portId]} {
			errorMsg "Error calling ip set $chasId $cardId $portId"
			set retCode $::TCL_ERROR
		}

		#vlan settings
		#disable vlan
		#protocol config -enable802dot1qTag	false
		#if {[vlan set $chasId $cardId $portId]} {
		#	errorMsg "Error calling vlan set  $chasId $cardId $portId"
		#	set retCode $::TCL_ERROR
		#	set retVal 1
		#}

		#pasueControl settings
		#pauseControl setDefault
		#puts "pauseTime is $pauseTime"
		#pauseControl config -pauseTime $pauseTime
		#puts "[showCmd pauseControl]"
		#if {[pauseControl set $chasId $cardId $portId]} {
		#	errorMsg "Error calling pauseControl set $chassis $card $port"
		#	set retCode $::TCL_ERROR
		#	set retVal 1
		#}

		# stream set to HAL
		#puts "[showCmd stream]"
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			set retVal 1
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL"
			return [print_Report "stream set $chasId $cardId $portId $streamIdL error" $retVal]
		}
		# write to hardware
		lappend portList [list $chasId $cardId $portId]
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			ixPuts -red "Unable to write config to hardware"
			set retVal 1
			return [print_Report "ixWriteConfigToHardware $chasId $cardId $portId error" $retVal]
		}
		return [print_Report "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,steamIpDSCPSet done" $retVal]
	}

}

# Copyright 2013, clchen, Aerohive
# Version: 1.0
# Date: 2013-03-21
#
# History:
#  version 1.0: 2013.03.21 by clchen, clchen@aerohive.com
#
# Description:
#  udf config by low api
#
# -portList			   $portList					 like {{1 3 15} {1 3 16}}
# -udf_offset          $udf_offset		             (optional) default 56，56 is max on udf_value 32bit
# -udf_value           $udf_value                    (optional) default 0xBDBDBDBD or
# call example
#	set portList {{1 3 15} {1 3 16}}
#	udf_config $portList 64 0xB3BDBDB3
#	udf_config {{1 3 15}} 64 0xB3BDBD33
#		udf_config -pL $portList -udf_offset 64 -udf_value 0xB3BDBDB3
#	proc udf_config { portList {udf_offset 56} {udf_value 0xBDBDBDBD}} {
proc udf_config {args} {
	set retV 0
	set argformat {
		{ pL portList required string "Port Lists,like {{1 3 15} {1 3 16}} or {{1 3 15}} " }
		{ udf_offset udf_offset optional string "UDF Offset,like 56" }
		{ udf_value udf_value optional string "UDF Value,like 0xBDBDBDBD" }
		{ streamID streamID optional string "defaut 1"}
	}
	# set optional parameter default value
	set arg(udf_offset) 56
	set arg(udf_value) 0xBDBDBDBD
	set arg(streamID) 1
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#set portList [pLproc $arg(portList)]
	set portList $arg(portList)
	#puts "portList is $portList"
	set udf_offset $arg(udf_offset)
	puts "udf_offset is $udf_offset"
	set udf_value $arg(udf_value)
	puts "udf_value is $udf_value"
	set streamID $arg(streamID)

	package req IxTclHal

	#set portList [pLproc $portListIn]
	#puts "portList before set udf is $portList"
	#portList is {1 3 15} {1 3 16}
	foreach item $portList {
		scan $item "%d %d %d" chasId card port
		stream get $chasId $card $port $streamID
		# if {[vlan set $chasId $card $port]} {
		# ixPuts $::ixErrorInfo
		# return $::TCL_ERROR
		# }
		set udfReserve 0
		for { set index 1 } { $index <= 5 } { incr  index } {

			udf get $index
			set used [ udf cget -enable ]
			if { $used } {
				continue
			} else {
				set udfReserve 1
				break
			}
		}
		if [expr {$udfReserve == 1}] {
			set  udfNum $index
			puts "got unUsed udf number,it is $udfNum"
			udf setDefault
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
			if { [udf set $udfNum] } {
				errorMsg "Error calling udf set $udfNum"
				set retV $::TCL_ERROR
				return $retV
			}
		} else {
			puts "can't get availabe udfNum"
			set retV 1
			return $retV
		}
		if {[stream set $chasId $card $port $streamID]} {
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		}
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		} else {
			puts "write stream  udf config for $chasId/$card/$port to haradware^0"
			set retV 0
			return $retV
		}
	}
}

#
#
# Copyright 2013, clchen, Aerohive
# Version: 1.0
# Date: 2013-03-25
#
# History:
#  version 1.0: 2013.03.25 by clchen, clchen@aerohive.com
#
# Description:
#  trafficConfigEth2 to build eth2 packet

# -portList			$portListIN			(mandatory) like {1/3/15} {1/3/16}
# -mac_dst_addr		$mac_dst_addr		(mandatory) 0000.0000.0016
# -mac_dst_count	$mac_dst_count		(optional) default 1
# -mac_dst_step		$mac_dst_step		(optional) default 0.0.0.0.0.1
# -mac_src_addr		$mac_src_addr		(mandatory)
# -mac_src_count	$mac_src_count		(optional) default 1
# -mac_src_step		$mac_src_step		(optional) default 0.0.0.0.0.1
# -vlan 			$vlan_switch 		(optional) default disable
# -vlan_id			$vlan_id_first		(optional) default 1, (0-4095)
# -vlan_dot1p		$vlan_dot1p (0-7)	(optional) must enable -vlan first if use this parameter
# -vlan_cfi			$vlan_cfi			(optional)	{0|1} default 0
# -eth2_protocol	$eth2_protocol_type		(optional) default 0x0800
# -frame_length		$frame_length		(optional) L2 frame length, default 68bytes
# ##-rate_percent		$rate_percent		(optional) no default like 0.1  not support
# -udf_offset		$udf_offset			(optional) default 54
# -udf_value		$udf_value			(optional) default 0xBDBDBDBD
# -rate_pps 		$rate_pps			(optional) default 10 pps
#
proc trafficConfigEth2 {portListIn mac_dst_addr mac_dst_count mac_dst_step\
				mac_src_addr mac_src_count mac_src_step vlan_switch vlan_id_first vlan_dot1p\
				vlan_cfi vlan_repeatCount vlan_step vlan_protocolID\
				eth2_protocol_type frame_length udf_offset udf_value rate_pps} {
	#set portListIn 1/3/15,1/3/16
	set portHandle [pLhand $portListIn]
	#puts "portHandle is $portHandle"
	set portList [pLproc $portListIn]
	#puts "portList is $portList"
	#for remove exist stream under the $portHandle
	#foreach phandle $portHandle {
	#	set traffic_info [ixia::traffic_config \
	#	-mode reset \
	#	-port_handle $phandle\
	#	-traffic_generator ixos\
	#	-vlan disable ]
	#	if {[keylget traffic_info status] == $::FAILURE} {
	#	puts "Failed to remove exist traffic streams: \
	#	[keylget traffic_info log]"
	#	return
	#	}
	#}
	#create a stream under the $portHandle
	#set mac_dst_addr 		0000.0000.0016
	#puts "mac_dst_addr is $mac_dst_addr"
	#set mac_dst_count 		6
	#set mac_dst_step 		0.0.0.0.0.16
	#set mac_src_addr 		0000.0000.0015
	#puts "mac_src_addr is $mac_src_addr"
	#set mac_src_count		5
	#set mac_src_step		0.0.0.0.0.15
	#set vlan_switch			disable
	#set vlan_id_first		41
	#set vlan_dot1p			7
	#set vlan_cfi			1
	#set eth2_protocol_type	0x08a8
	#set frame_length		68
	#set rate_percent		0.2
	#set rate_pps			2000
	set mac_dst_addr 		$mac_dst_addr
	set mac_dst_count 		$mac_dst_count
	set mac_dst_step 		$mac_dst_step
	set mac_src_addr 		$mac_src_addr
	set mac_src_count		$mac_src_count
	set mac_src_step		$mac_src_step
	set vlan_switch			$vlan_switch
	#puts "vlan_switch is $vlan_switch"
	set vlan_id_first		$vlan_id_first
	set vlan_dot1p			$vlan_dot1p
	set vlan_cfi			$vlan_cfi
	set eth2_protocol_type	$eth2_protocol_type
	set frame_length		$frame_length
	#set rate_percent		0.2
	set rate_pps			$rate_pps

	#set default retV as 0
	set retV 0
	foreach phandle $portHandle {
		set stream_info [ixia::traffic_config\
			-traffic_generator	ixos\
			-mode			create\
			-port_handle	$phandle\
			-l3_protocol	none\
			-transmit_mode	continuous\
			-mac_dst		$mac_dst_addr\
			-mac_dst_count	$mac_dst_count\
			-mac_dst_step	$mac_dst_step \
			-mac_dst_mode	increment\
			-mac_src		$mac_src_addr\
			-mac_src_count	$mac_src_count\
			-mac_src_step	$mac_src_step\
			-mac_src_mode	increment\
			-vlan 			$vlan_switch\
			-vlan_cfi  		$vlan_cfi\
			-vlan_id 		$vlan_id_first\
			-vlan_id_mode	increment\
			-vlan_user_priority		$vlan_dot1p \
			-ethernet_type		ethernetII\
			-ethernet_value		$eth2_protocol_type\
			-frame_size		$frame_length\
			-rate_pps			$rate_pps\
			-vlan_id_count		$vlan_repeatCount\
			-vlan_id_step		$vlan_step\
			-vlan_protocol_tag_id	$vlan_protocolID\
			-enable_time_stamp 0\
			-enable_pgid 0\
			-enable_auto_detect_instrumentation 0\
		]
		# checking stream creation  $FAILURE
		puts "stream_info status is [keylget stream_info status]"
		if {[keylget stream_info status] == $::FAILURE} {
			puts "Failed to create a traffic streams: \
			[keylget stream_info log]"
			set retV 1
			return $retV
		}
		# obtain the stream ID for reference
		set streamIDH [keylget stream_info stream_id]
		if {[keylget stream_info status] == $::FAILURE} {
			puts "Failed in keylget stream_info stream_id: \
			[keylget stream_info log]"
			set retV 1
			return $retV
		}

		#puts "streamIDH under port $phandle is  $streamIDH"
		set streamIDLow [getPortStreamIdFromHltapi $phandle $streamIDH]
		if { [expr { $streamIDLow == -1 }] } {
			puts "Failed in getPortStreamIdFromHltapi"
			set retV 1
			return $retV
		}
		#set streamIDLow 1
		puts "streamIDLow under port $phandle is $streamIDLow"
		set pL [pLhandToportList $phandle]
		puts "pL is $pL"
		set udfConfigInfo [udf_config -pL $pL -udf_offset $udf_offset -udf_value $udf_value -streamID $streamIDLow]
		if { [expr { $udfConfigInfo != 0 }] } {
			puts "Failed in udf_config"
			set retV 1
			return $retV
		}
	}
	return $retV
	#放在外面udf config 已经证明是可行的；
	#udf_config -pL $portList -udf_offset 54 -udf_value 0xB1B1B1B1 -streamID 1
	# udf_config -pL $portList -udf_offset $udf_offset -udf_value $udf_value -streamID 1
}

#onePort input like 1/3/15
#file_name input like /opt/Mainline/cases/1_samples/conf/potr4.str
proc streamImport {onePort fileName} {
	set portIn [split $onePort "/"]
	#puts "portIn is $portIn"
	set chas [lindex $portIn 0]
	set card [lindex $portIn 1]
	set port [lindex $portIn 2]
	set portList [list [list $chas $card $port]]
	#puts "port is $port"
	if [port reset $chas $card $port] {
		return [print_Report "port reset $chas $card $port" 1]
	}
	if [stream import $fileName $chas $card $port] {
		return [print_Report "stream import $fileName $chas $card $port " 1]
	}
	if [ixWriteConfigToHardware portList -noProtocolServer] {
		return [print_Report "ixWriteConfigToHardware $portList" 1]
	}
	return [print_Report "port $onePort stream import with the file $fileName" 0]
}

#diableStream -onePort 1/3/15 -streamIdL all
#diableStream in one port
proc diableStream { onePort {streamIdL "all"} } {
	set retVal 0
	set portInfo [ split $onePort "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	port get $chasId $cardId $portId
	set portName [port cget -name]

	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	}

	#start disable function
	if { [expr { $streamIdL == "all"} ] } {
		for { set index 1 } { $index <= $streamCount } { incr index } {
			stream get $chasId $cardId $portId $index
			stream config -enable false
			if {[catch {stream set $chasId $cardId $portId $index} my_Error]} {
				puts "Error $my_Error in stream set $chasId $cardId $portId $index^1"
				return 1
			}
			#stream set $chasId $cardId $portId $index
			set strName [ stream cget -name ]
			puts "under $chasId $cardId $portId,streamId is $index,strName is $strName, is stream setting"
		}
	}
	if { [expr { $streamIdL != "all"} && { $streamIdL != ""} ] } {
		if { [expr { $streamIdL <= 0 || $streamIdL > $streamCount }] } {
			puts "input streamIdL $streamIdL is illegal,streamIdL should >=1 and < streamCount $streamCount"
			return 1
		}
		stream get $chasId $cardId $portId $streamIdL
		stream config -enable false
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			return 1
		}
		#stream set $chasId $cardId $portId $streamIdL
		set strName [ stream cget -name ]
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName, is stream setting"
	}

	lappend portList [list $chasId $cardId $portId]
	if {[ixWriteConfigToHardware portList -noProtocolServer]} {
		IxPuts -red "Unable to write config to hardware"
		set retVal 1
	}
	return $retVal
}

# enableStream -onePort 1/3/15 -streamIdL all
# enableStream in one port
proc enableStream { onePort {streamIdL "all"} } {
	set retVal 0
	set portInfo [ split $onePort "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	port get $chasId $cardId $portId
	set portName [port cget -name]

	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	}

	#start disable function
	if { [expr { $streamIdL == "all"} ] } {
		for { set index 1 } { $index <= $streamCount } { incr index } {
			stream get $chasId $cardId $portId $index
			stream config -enable true
			if {[catch {stream set $chasId $cardId $portId $index} my_Error]} {
				puts "Error $my_Error in stream set $chasId $cardId $portId $index^1"
				return 1
			}
			#stream set $chasId $cardId $portId $index
			set strName [ stream cget -name ]
			puts "under $chasId $cardId $portId,streamId is $index,strName is $strName, is stream setting"
		}
	}
	if { [expr { $streamIdL != "all"} && { $streamIdL != ""} ] } {
		if { [expr { $streamIdL <= 0 || $streamIdL > $streamCount }] } {
			puts "input streamIdL $streamIdL is illegal,streamIdL should >=1 and < streamCount $streamCount"
			return 1
		}
		stream get $chasId $cardId $portId $streamIdL
		stream config -enable true
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			return 1
		}
		#stream set $chasId $cardId $portId $streamIdL
		set strName [ stream cget -name ]
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName, is stream setting"
	}

	lappend portList [list $chasId $cardId $portId]
	if {[ixWriteConfigToHardware portList -noProtocolServer]} {
		IxPuts -red "Unable to write config to hardware"
		set retVal 1
	}
	return $retVal
}

proc maintanceStreamWithName {onePort streamName maintanceOp} {
	set retVal 0
	set portInfo [ split $onePort "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	if { [port get $chasId $cardId $portId] } {
		puts "failed in port get $chasId $cardId $portId"
	}
	set portName [port cget -name]

	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "streamCount is $streamCount under port $chasId $cardId $portId "
	}
	set streamIdL -1
	#get first Match streamIdL with streamName
	for { set index 1 } { $index <= $streamCount } { incr index } {
		stream get $chasId $cardId $portId $index
		set strName [ stream cget -name ]
		if { [expr {$strName == $streamName }] } {
			puts "got it, streamIdL is $index with streamName $streamName"
			set streamIdL $index
			break
		}
	}
	if { [expr {$streamIdL == -1}] } {
		puts "not got streamIdL with streamName $streamName,error in maintanceStreamWithName "
		return 1
	}
	#set stream with streamIdL
	#puts "streamIdL is $streamIdL"
	if { [expr { $streamIdL != -1}] } {
		#puts "streamIdL in is $streamIdL"
		stream get $chasId $cardId $portId $streamIdL
		if { [expr { $maintanceOp == "disable"} ] } {
			set maintanceValue "false"
		}
		if { [expr { $maintanceOp == "enable"} ] } {
			set maintanceValue "true"
		}
		stream config -enable $maintanceValue
		set strName [ stream cget -name ]
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName, is stream setting"
		if {[catch {stream set $chasId $cardId $portId $streamIdL} my_Error]} {
			puts "Error $my_Error in stream set $chasId $cardId $portId $streamIdL^1"
			return 1
		}

		lappend portList [list $chasId $cardId $portId]
		if {[ixWriteConfigToHardware portList -noProtocolServer]} {
			IxPuts -red "Unable to write config to hardware"
			set retVal 1
		}
		puts "under $chasId $cardId $portId,streamId is $streamIdL,strName is $strName,$maintanceOp stream done "
		return $retVal
	}
}

#portIn like onport 1/3/15, streamId only support "all"
#call example streamDelete 1/3/15 all
proc streamDelete {portIn streamId } {
	set retVal 0
	set portInTemp [split $portIn "/"]
	set Chas [lindex $portInTemp 0]
	set Card [lindex $portInTemp 1]
	set Port [lindex $portInTemp 2]
	set portList [ list [ list $Chas $Card $Port ]]

	if { $streamId == "all" } {
		ixPuts -blue "Deleting all the streams in $Chas $Card $Port"
		port reset $Chas $Card $Port
	} else {
		##ixPuts -blue "Deleting ID=$sList streams in $Chas $Card $Port"
		##set saveStrm {}
		##set strm 1
		##while {![stream get $Chas $Card $Port $strm] } {
		##	if {[lsearch -exact $sList $strm] != -1} {
		##		incr strm
		##		continue;
		##	}
		##	set filename "stream_$strm"
		##	stream export $filename $Chas $Card $Port $strm $strm
		##	lappend saveStrm $filename
		##	incr strm
		##}
		##port reset $Chas $Card $Port
		##set strm 1
		##foreach filename $saveStrm {
		##	stream import $filename $Chas $Card $Port
		##	file delete $filename
		##	incr strm
		##}
	}

	#lappend portList [list $Chas $Card $Port]
	if {[ixWriteConfigToHardware portList -noProtocolServer]} {
		ixPuts -red "Unable to write config to hardware"
		set retVal 1
	}
	return $retVal
}

proc getPortStreamIdFromHltapi { port_handle stream_idH } {
	puts "call getPortStreamIdFromHltapi start "
	set nameH "Stream $stream_idH"
	#puts "nameH is $nameH"
	set portInfo [ split $port_handle "/" ]
	set chasId [ lindex $portInfo 0 ]
	#puts "chasId is $chasId"
	set cardId [ lindex $portInfo 1 ]
	#puts "cardId is $cardId"
	set portId [ lindex $portInfo 2 ]
	#puts "portId is $portId"
	port get $chasId $cardId $portId
	set portName [port cget -name]
	#puts "portName is $portName"
	if { $portName != "" } {
		set streamCount [ port getStreamCount $chasId $cardId $portId $portName ]
		puts "portName is $portName, streamCount is $streamCount"
	} else {
		set streamCount [ port getStreamCount $chasId $cardId $portId ]
		puts "portName is null, streamCount is $streamCount"
	}
	set streamIdL -1
	for { set index $streamCount } { $index >= 1 } { incr index -1 } {
		puts "now index=$index,streamCount=$streamCount"
		stream get $chasId $cardId $portId $index
		set strName [ stream cget -name ]
		set enableState [stream cget -enable]
		puts "cget strName is $strName,enableState is $enableState under $chasId $cardId $portId"
		if { [expr { $strName == $nameH && $enableState == 1 }] } {
			set streamIdL $index
			break
		}
	}
	puts "call getPortStreamIdFromHltapi end "
	return $streamIdL
}

proc getPortHandleFromHltapi { stream_idH } {
	global allPortHandList

	set portHandle "NA"
	foreach portH $allPortHandList {
		if { [ getPortStreamIdFromHltapi $portH $stream_idH ] > 0 } {
			set portHandle $portH
			break
		}

	}

	return $portHandle
}

#
# in:	portListIn 		like {{1 3 15} {1 3 16}}
#		rxPattern		like "BD BD BD BD"
#		patternOffset2	like 54
# normal:just done
# error: return $::TCL_ERROR
# set portListIn {{1 3 15} {1 3 16}}
# set rxPattern "BD BD BD BD"
# set patternOffset2 54
# palletteFilterConfig $portListIn $rxPattern $patternOffset2
#
proc palletteFilterConfig { portListIn rxPattern patternOffset2 {pattern1 "DE ED EF FE AC CA"} {patternMask1 "00 00 00 00 00 00"} {patternOffset1 12} {userDefinedStat2Pattern "pattern2"} } {
	set portList $portListIn
	foreach item $portList {
		scan $item "%d %d %d" chassis card port
		puts "setting palletteFilterConfig on port $chassis $card $port"
		filter setDefault
		filter config -captureTriggerDA                   anyAddr
		filter config -captureTriggerSA                   anyAddr
		filter config -captureTriggerPattern              anyPattern
		filter config -captureTriggerError                errAnyFrame
		filter config -captureTriggerFrameSizeEnable      false
		filter config -captureTriggerFrameSizeFrom        64
		filter config -captureTriggerFrameSizeTo          1518
		filter config -captureTriggerCircuit              filterAnyCircuit
		filter config -captureFilterDA                    anyAddr
		filter config -captureFilterSA                    anyAddr
		filter config -captureFilterPattern               anyPattern
		filter config -captureFilterError                 errAnyFrame
		filter config -captureFilterFrameSizeEnable       false
		filter config -captureFilterFrameSizeFrom         64
		filter config -captureFilterFrameSizeTo           1518
		filter config -captureFilterCircuit               filterAnyCircuit
		filter config -userDefinedStat1DA                 anyAddr
		filter config -userDefinedStat1SA                 anyAddr
		filter config -userDefinedStat1Pattern            anyPattern
		filter config -userDefinedStat1Error              errAnyFrame
		filter config -userDefinedStat1FrameSizeEnable    false
		filter config -userDefinedStat1FrameSizeFrom      64
		filter config -userDefinedStat1FrameSizeTo        1518
		filter config -userDefinedStat1Circuit            filterAnyCircuit
		filter config -userDefinedStat2DA                 anyAddr
		filter config -userDefinedStat2SA                 anyAddr
		filter config -userDefinedStat2Pattern            $userDefinedStat2Pattern
		filter config -userDefinedStat2Error              errGoodFrame
		filter config -userDefinedStat2FrameSizeEnable    0
		filter config -userDefinedStat2FrameSizeFrom      64
		filter config -userDefinedStat2FrameSizeTo        1518
		filter config -userDefinedStat2Circuit            filterAnyCircuit
		filter config -asyncTrigger1DA                    anyAddr
		filter config -asyncTrigger1SA                    anyAddr
		filter config -asyncTrigger1Pattern               anyPattern
		filter config -asyncTrigger1Error                 errAnyFrame
		filter config -asyncTrigger1FrameSizeEnable       false
		filter config -asyncTrigger1FrameSizeFrom         64
		filter config -asyncTrigger1FrameSizeTo           1518
		filter config -asyncTrigger1Circuit               filterAnyCircuit
		filter config -asyncTrigger2DA                    anyAddr
		filter config -asyncTrigger2SA                    anyAddr
		filter config -asyncTrigger2Pattern               anyPattern
		filter config -asyncTrigger2Error                 errAnyFrame
		filter config -asyncTrigger2FrameSizeEnable       false
		filter config -asyncTrigger2FrameSizeFrom         64
		filter config -asyncTrigger2FrameSizeTo           1518
		filter config -asyncTrigger2Circuit               filterAnyCircuit
		filter config -captureTriggerEnable               true
		filter config -captureFilterEnable                true
		filter config -userDefinedStat1Enable             false
		filter config -userDefinedStat2Enable             true
		filter config -asyncTrigger1Enable                false
		filter config -asyncTrigger2Enable                false
		filter config -userDefinedStat1PatternExpressionEnable false
		filter config -userDefinedStat2PatternExpressionEnable false
		filter config -captureTriggerPatternExpressionEnable false
		filter config -captureFilterPatternExpressionEnable false
		filter config -asyncTrigger1PatternExpressionEnable false
		filter config -asyncTrigger2PatternExpressionEnable false
		filter config -userDefinedStat1PatternExpression  ""
		filter config -userDefinedStat2PatternExpression  ""
		filter config -captureTriggerPatternExpression    ""
		filter config -captureFilterPatternExpression     ""
		filter config -asyncTrigger1PatternExpression     ""
		filter config -asyncTrigger2PatternExpression     ""
		if {[filter set $chassis $card $port]} {
			errorMsg "Error calling filter set $chassis $card $port"
			set retCode $::TCL_ERROR
		}
		filterPallette setDefault
		filterPallette config -DA1                                "00 00 00 00 00 00"
		filterPallette config -DAMask1                            "00 00 00 00 00 00"
		filterPallette config -DA2                                "00 00 00 00 00 00"
		filterPallette config -DAMask2                            "00 00 00 00 00 00"
		filterPallette config -SA1                                "00 00 00 00 00 00"
		filterPallette config -SAMask1                            "00 00 00 00 00 00"
		filterPallette config -SA2                                "00 00 00 00 00 00"
		filterPallette config -SAMask2                            "00 00 00 00 00 00"
		#filterPallette config -pattern1                          "DE ED EF FE AC CA"
		filterPallette config -pattern1                           $pattern1
		#filterPallette config -patternMask1                      "00 00 00 00 00 00"
		filterPallette config -patternMask1                       $patternMask1
		#filterPallette config -pattern2                          "BE EF 03 0F"
		filterPallette config -pattern2                           $rxPattern
		filterPallette config -patternMask2                       "00 00 00 00"
		#filterPallette config -patternOffset1                    12
		filterPallette config -patternOffset1                     $patternOffset1
		filterPallette config -patternOffset2                     $patternOffset2
		filterPallette config -matchType1                         matchUser
		filterPallette config -matchType2                         matchUser
		filterPallette config -patternOffsetType1                 filterPalletteOffsetStartOfFrame
		filterPallette config -patternOffsetType2                 filterPalletteOffsetStartOfFrame
		filterPallette config -gfpErrorCondition                  gfpErrorsOr
		filterPallette config -enableGfptHecError                 true
		filterPallette config -enableGfpeHecError                 true
		filterPallette config -enableGfpPayloadCrcError           true
		filterPallette config -enableGfpBadFcsError               true
		filterPallette config -circuitList                        ""
		if {[filterPallette set $chassis $card $port]} {
			errorMsg "Error calling filterPallette set $chassis $card $port"
			set retCode $::TCL_ERROR
		}
	}
	if {[ixWriteConfigToHardware portList -noProtocolServer]} {
		ixPuts $::ixErrorInfo
		return $::TCL_ERROR
	}
}

#portListIn like 1/3/15,1/3/16
#2013/05/17 by clchen
proc stopTransmit {portListIn} {
	set portList [pLproc $portListIn]
	if {[ixStopTransmit portList] != 0} {
		ixPuts "In stopTransmit, Could not ixStopTransmit on $portList"
		return -code error
	} else {
		#ixPuts "In stopTransmit, ixStopTransmit  $portList ok"
	}
	# ensure Transmission is complete,some time found it is not stop,so add this 2013/4/23
	if {[ixCheckTransmitDone portList] == $::TCL_ERROR} {
		ixPuts "In stopTransmit, Transmit have not been done on $portList"
		return -code error
	} else {
		ixPuts "In stopTransmit, stop on port $portList ok"
	}
}

#portListIn like 1/3/15,1/3/16
#2013/05/17 by clchen
proc clearStatistic {portListIn} {
	set portList [pLproc $portListIn]
	# Zero all statistic counters on portList

	if { [catch { ixClearStats portList } myerror] } {
		puts "In clearStatistic, myerror is $myerror"
		ixPuts "In clearStatistic, Could not clearStatistic on $portList"
		exit 1
		#return -code error
	} else {
		ixPuts "In clearStatistic, clearStatistic on port $portList ok"
	}
}

#portListIn like 1/3/15,1/3/16
#2013/05/17 by clchen
#firstTryFlag true or false default is true
proc startTransmit {portListIn {firstTryFlag "true"} } {
	set portList [pLproc $portListIn]

	if { [ expr {$firstTryFlag == "true"} ] } {
		#first start for 3s
		if [ixStartTransmit portList] {
			ixPuts "1 Could not start Transmit on $portList"
			return -code error
		} else {
			#ixPuts "Start transmit..."
		}
		after 3000

		#stop it
		if {[ixStopTransmit portList] != 0} {
			ixPuts "2 Could not stop Transmit on $portList"
			return -code error
		} else {
			#ixPuts "2 ixStopTransmit  $portList ok"
		}
		# ensure Transmission is complete,some time found it is not stop,so add this 2013/4/23
		if {[ixCheckTransmitDone portList] == $::TCL_ERROR} {
			ixPuts "2 Transmit have not been done on  $portList"
			return -code error
		} else {
			#ixPuts "2 Transmission is complete on txPortList $txPortList ok"
		}
	} else {
		ixPuts "firstTryFlag $firstTryFlag is not true, so do not start Transmit for a try"
	}

	#start it
	if [ixStartTransmit portList] {
		ixPuts "In startTransmit, Could not ixStartTransmit on $portList"
		return -code error
	} else {
		ixPuts "In startTransmit, start on port $portList ok"
	}
}

#only input one port
#call examples streamStatsTx 1/3/15
proc streamStatsTx { portIn } {
	set portInTemp [split $portIn "/"]
	set Chas [lindex $portInTemp 0]
	set Card [lindex $portInTemp 1]
	set Port [lindex $portInTemp 2]
	set portList [ list [ list $Chas $Card $Port ]]
	set retVal 0
	set maxTxStreams  255
	set maxRxStreams  4096

	if {[info exists streamid] } {
	} else {
		set streamid "all"
	}

	if {$streamid == "all" } {
		set streamnum [port getStreamCount $Chas $Card $Port]
		for {set i 1} {$i <= $streamnum } {incr i} {
			stream get $Chas $Card $Port $i
			set enableState [stream cget -enable]
			##if { [expr { $enableState == 1 } ] } {
			stream config -enableTimestamp                    true
			packetGroup setDefault

			packetGroup config -signatureOffset                    48
			packetGroup config -signature                          "08 71 18 05"
			packetGroup config -insertSignature                    true
			packetGroup config -ignoreSignature                    false
			packetGroup config -enableInsertPgid                   true
			packetGroup config -insertSequenceSignature            false
			packetGroup config -groupId                            $i
			packetGroup config -groupIdOffset                      52

			packetGroup setTx $Chas $Card $Port $i
			if { [ stream write $Chas $Card $Port $i ] } {
				ixPuts -red "Can't write stream $Chas $Card $Port $i"
				set retVal 1
			}

			#}

		}
	}
	return [print_Report "streamStatsTx $portIn" $retVal]
}

#ixStartPortPacketGroups $portIn
#only input one port
#call examples streamStatsTx 1/3/16
proc streamStatsRx { portIn } {
	set portInTemp [split $portIn "/"]
	set Chas [lindex $portInTemp 0]
	set Card [lindex $portInTemp 1]
	set Port [lindex $portInTemp 2]
	set portList [ list [ list $Chas $Card $Port ]]
	set retVal 0
	set maxTxStreams  255
	set maxRxStreams  4096
	if { [catch { ixStopPortPacketGroups $Chas $Card $Port } myerror] } {
		puts "ixStopPortPacketGroups $Chas $Card $Port error, myerror is $myerror"
		set retVal 1
	}

	if { [ixStartPortPacketGroups $Chas $Card $Port] != 0 } {
		ixPuts -red "Error, Could not start packet groups on $Chas: $Card :$Port"
		set retVal 1
	}
	return [print_Report "streamStatsRx $portIn" $retVal]
}

#portListIn like 1/3/15,1/3/16
#call examples getStreamStatistic 1/3/15,1/3/16 $sequence
proc getStreamStatistic { portListIn {sequence 0} } {
	set retVal 0
	set portList [split $portListIn ","]
	##Get  streams stats for specify PortList
	foreach portHandleItem $portList {
		puts "  Current Port is $portHandleItem"
		set portIn $portHandleItem
		set portInTemp [split $portHandleItem "/"]
		set Chas [lindex $portInTemp 0]
		set Card [lindex $portInTemp 1]
		set Port [lindex $portInTemp 2]
		set portList [ list [ list $Chas $Card $Port ]]
		if { $sequence == "" } {
			set sequence 0
		}

		set maxTxStreams  255
		set maxRxStreams  4096

		if {[info exists streamid] } {
		} else {
			set streamid "all"
		}
		## Output the statistics of all streams under the port by default.
		if { $streamid == "all" } {

			##TX
			##Fetchs the statistics of the transmitting streams on the port
			streamTransmitStats get $Chas $Card $Port 1 $maxTxStreams

			# Get all of the stream stats again for a vaild reading
			if [streamTransmitStats get  $Chas $Card $Port 1 $maxTxStreams] {
				errorMsg "Error getting streamTransmitStats on port $Chas $Card $Port"
				return "FAIL"
			}

			set numStreams [ streamTransmitStats cget -numGroups]
			puts "tx numGroups under $Chas $Card $Port is $numStreams"
			##Make sure the stream is configured on the specified port.
			if { $numStreams == 0 } {
				ixPuts -blue "No Tx stream on $Chas $Card $Port."
				#set retVal 1
			}
			for { set i 1 } {$i <= $numStreams} {incr i} {
				puts "tx numGroups $i"
				streamTransmitStats getGroup $i

				#puts "\n showCmd streamTransmitStats $i port $Chas $Card $Port is"
				#set tempL [showCmd streamTransmitStats]
				#puts "tempL is $tempL \n"

				getAndSetStreamStList $portHandleItem $i "framesSent" "tx.port" $sequence
				getAndSetStreamStList $portHandleItem $i "frameRate" "tx.port" $sequence
			}

			##RX
			##Fetchs the statistics of the streams on the received port
			##Fetchs twice just ensure that the rxByteRate/rxFrameRate/rxBitRate always own an value.

			#packetGroupStats get $Chas $Card $Port 1 $maxRxStreams
			#after 500
			packetGroupStats get $Chas $Card $Port 1 $maxRxStreams
			packetGroupStats get $Chas $Card $Port 1 $maxRxStreams

			set numStreams [packetGroupStats cget -numGroups]
			puts "rx numGroups under $Chas $Card $Port is $numStreams"
			if {$numStreams == 0} {
				#ixPuts -blue  " No Rx stream on $Chas $Card $Port,please ensure the option of \"wide packet groups\" in port's receive mode is enabled.or oppsite port have't transmitted anything"
				ixPuts "Warning...,packetGroupStats cget -numGroups is 0, so do not to get packetGroupStats"
				set retVal 0
			}

			for {set i 1 } { $i <= $numStreams } {incr i} {
				puts "rx numGroups $i"
				packetGroupStats get $Chas $Card $Port $i $i
				packetGroupStats getGroup $i

				#puts "\n showCmd packetGroupStats $i under port $Chas $Card $Port  is"
				#set tempL [showCmd packetGroupStats]
				#puts "tempL is $tempL \n"

				#getAndSetStreamStList $portHandleItem $i "frameRate" "rx.port" $sequence

				#change totalFrames to framesReceived,because tx side is using framesSent
				#getAndSetStreamStList $portHandleItem $i "totalFrames" "rx.port" $sequence
				getAndSetStreamStList $portHandleItem $i "framesReceived" "rx.port" $sequence
				getAndSetStreamStList $portHandleItem $i "frameRate" "rx.port" $sequence
				getAndSetStreamStList $portHandleItem $i "bitRate" "rx.port" $sequence
			}
		}
	}
	return [print_Report "getStreamStatistic $portListIn $sequence" $retVal]
}

#call example getAndSetStreamStList $portIn $streamIdLow "frameRate" "rx.port" $sequence
proc getAndSetStreamStList { portIn streamIdLow cgetOption roleIn  {sequence 0} } {
	set portInTemp [split $portIn "/"]
	set Chas [lindex $portInTemp 0]
	set Card [lindex $portInTemp 1]
	set Port [lindex $portInTemp 2]
	set portList [ list [ list $Chas $Card $Port ]]

	set i $streamIdLow
	#puts "i is $i"

	global streamStList
	#global stList
	#get and set RX frameRate
	if { $roleIn == "rx.port" } {
		#puts "\n showCmd packetGroupStats $i under port $Chas $Card $Port  is"
		#set tempL [showCmd packetGroupStats]
		#puts "tempL is $tempL \n"

		#set cgetOption "frameRate"
		if { $cgetOption == "framesReceived" } {
			set cgetOptionV [packetGroupStats cget -totalFrames]
		} else {
			set cgetOptionV [packetGroupStats cget -$cgetOption]
		}
		ixPuts "$sequence.$roleIn.$portIn.$i.$cgetOption=$cgetOptionV"
		#set it to stListStream
		set keyO $cgetOption
		set keyV $cgetOptionV
		set role $roleIn
		set retv [keylset streamStList $sequence.$role.$portIn.$i.$keyO $keyV]
	}

	#get and set TX frameRate
	if { $roleIn == "tx.port" } {
		#puts "\n showCmd streamTransmitStats $i port $Chas $Card $Port is"
		#set tempL [showCmd streamTransmitStats]
		#puts "tempL is $tempL \n"

		#set cgetOption "frameRate"
		set cgetOptionV [streamTransmitStats cget -$cgetOption]
		ixPuts "$sequence.$roleIn.$portIn.$i.$cgetOption=$cgetOptionV"
		#set it to stListStream
		set keyO $cgetOption
		set keyV $cgetOptionV
		set role $roleIn
		set retv [keylset streamStList $sequence.$role.$portIn.$i.$keyO $keyV]
	}
	if [expr { $retv == "" } ] {
		#puts "set stList status for 1"
		keylset stList status 1
		return 0
		#puts $stList
	} else {
		keylset stList status 0
		puts "set $sequence.$role.$pHandleItem.$i.$keyO $keyV failed"
		return 1
	}
}

#call example startTransAndGetStreamStats 1/3/15 1/3/16 3 "true" 0
proc startTransAndGetStreamStats { txPortListIn rxPortListIn {durationIn 3} {firstTryFlag "true" } {sequence 0} } {
	set txPortList [split $txPortListIn ","]
	set rxPortList [split $rxPortListIn ","]
	set portHandleList [concat $txPortList $rxPortList]
	puts "portHandleList in startTransAndGetStreamStats is $portHandleList"

	#set streams for MultiStreams statistic
	foreach portHandleItem $portHandleList {
		#must portTransmitModeSet portReceiveModeSet first, ifelse numGroups will be return 0
		#
		#portTransmitModeSet 1/3/15 -transmitMode portTxModeAdvancedScheduler
		#portTransmitModeSet 1/3/16 -transmitMode portTxModeAdvancedScheduler
		#portReceiveModeSet 1/3/15 -receiveMode portRxModeWidePacketGroup
		#portReceiveModeSet 1/3/16 -receiveMode portRxModeWidePacketGroup
		portTransmitModeSet $portHandleItem -transmitMode portTxModeAdvancedScheduler
		portReceiveModeSet $portHandleItem -receiveMode portRxModeWidePacketGroup
		#streamStatsTx 1/3/15
		#streamStatsTx 1/3/16
		#streamStatsRx 1/3/15
		#streamStatsRx 1/3/16
		streamStatsTx $portHandleItem
		streamStatsRx $portHandleItem

	}

	#first try startTransmit for 2s
	stop_transmit -portList $txPortListIn,$rxPortListIn
	after 100
	#start_transmit -portList $txPortListIn,$rxPortListIn -firstTryFlag false
	#after 2000
	#stop_transmit -portList $txPortListIn,$rxPortListIn

	#start Transmint
	clear_statistic -portList $txPortListIn,$rxPortListIn
	after 100

	#must dual direction transmit because rx stats in 1/3/15 rx should be to get
	#start_transmit -portList $txPortListIn,$rxPortListIn -firstTryFlag $firstTryFlag

	#unidirection transmit
	start_transmit -portList $txPortListIn -firstTryFlag $firstTryFlag

	after [expr 1000*$durationIn]
	stop_transmit -portList $txPortListIn,$rxPortListIn
	after 500

	##get statistics
	#use global list
	global streamStList
	#global stList
	puts "in startTransAndGetStreamStats,streamStList before is $streamStList"

	##Get  streams stats for txPortList
	puts "\n \n Get streamStats in txPortListIn  $txPortListIn"
	getStreamStatistic $txPortListIn $sequence
	##Get  streams stats for rxPortList
	puts "\n \n Get streamStats in rxPortListIn $rxPortListIn"
	getStreamStatistic $rxPortListIn $sequence

	puts "\n in startTransAndGetStreamStats,streamStList after is "
	puts "$streamStList"
	puts "\n"
	return [print_Report "startTransAndGetStreamStats" 0]
}

#txPortListIn like 1/3/15,1/3/16
#rxPortListIn like 1/3/15,1/3/16
#2013/05/17 by clchen
proc getStatistic {txPortListIn rxPortListIn {sequence 0} } {
	#input txPortlistIn like 1/3/15,1/3/16
	set txPortList [ pLproc $txPortListIn ]
	puts "txPortList is $txPortList"
	#set rxPortList {{1 3 16}}
	set rxPortList [ pLproc $rxPortListIn ]
	puts "rxPortList is $rxPortList"
	set portList [ concat $txPortList $rxPortList ]
	puts "portList (concat $txPortList $rxPortList) is $portList"

	global stList
	#list stList ""
	#########################get stats############################3
	ixPuts "get tx frame and rx frame with portList"
	#cget option value
	# Here you may retrieve the stats for both tx and rx ports at the same time, then compare.
	#first,Retreive the total number of transmitted frames from the tx port.ixRequestStats to statList, use statList get and statList cget
	if { [ixRequestStats portList] != $::TCL_OK } {
		ixPuts "ixRequestStats portList failed"
		return -code error
	} else {
		ixPuts "ixRequestStats portList is OK"
	}

	#for txPortLisixPuts
	ixPuts "\n get tx port stats with UDS2"
	#ixPuts "\n get tx rx port stats with getAndSetStList"
	puts "\n stList before is $stList \n"
	foreach item $txPortList {
		scan $item "%d %d %d" chasId card port
		puts "current port is $chasId $card $port in txPortList"
		#if { [statList get $chasId $card $port] } {
		#	errorMsg "Error - statList get $chasId $card $port failed in txPortList"
		#	return $::TCL_ERROR
		#}

		#convert item to in list form,adapt to use pLToHandles
		#portList before pLToHandles is {1 3 15}
		#portList after pLToHandles is 1/3/15
		set item [list $item]
		set pHandleItem [pLToHandles $item]

		getAndSetStList $pHandleItem "framesSent" "tx.port" $sequence
		getAndSetStList $pHandleItem "framesReceived" "tx.port" $sequence
		getAndSetStList $pHandleItem "userDefinedStat2" "tx.port" $sequence

		getAndSetStList $pHandleItem "bytesSent" "tx.port" $sequence
		getAndSetStList $pHandleItem "bytesReceived" "tx.port" $sequence
		getAndSetStList $pHandleItem "bitsSent" "tx.port" $sequence
		getAndSetStList $pHandleItem "bitsReceived" "tx.port" $sequence

		getAndSetStList $pHandleItem "oversize" "tx.port" $sequence

		puts "\n"
	}
	foreach item $rxPortList {
		scan $item "%d %d %d" chasId card port
		puts "current port is $chasId $card $port in rxPortList"
		#if {[statList get $chasId $card $port]} {
		#	errorMsg "Error - statList get $chasId $card $port failed in rxPortList"
		#
		#return $::TCL_ERROR
		#}

		#convert item to in list form,adapt to use pLToHandles
		#portList before pLToHandles is {1 3 15}
		#portList after pLToHandles is 1/3/15
		set item [list $item]
		set pHandleItem [pLToHandles $item]

		getAndSetStList $pHandleItem "framesSent" "rx.port" $sequence
		getAndSetStList $pHandleItem "framesReceived" "rx.port" $sequence
		getAndSetStList $pHandleItem "userDefinedStat2" "rx.port" $sequence

		getAndSetStList $pHandleItem "bytesSent" "rx.port" $sequence
		getAndSetStList $pHandleItem "bytesReceived" "rx.port" $sequence
		getAndSetStList $pHandleItem "bitsSent" "rx.port" $sequence
		getAndSetStList $pHandleItem "bitsReceived" "rx.port" $sequence

		getAndSetStList $pHandleItem "oversize" "rx.port" $sequence
		puts "\n"
	}
	#puts "\n stList is $stList \n"

	#according status to return different result
	if [ expr { [keylget stList status] == 1 } ] {
		puts "get stats and set stList success"
		puts "stList is $stList"
		return $stList
	} else {
		puts "get stats and set stList failed"
	}
}

#cgetOption valid like framesReceived framesSent userDefinedStat2
#roleIn valid like tx.port or rx.port
#portListIn like 1/3/15,1/3/16
#call example getAndSetStList 1/3/15 "framesReceived" "tx.port"
##2013/05/17 by clchen
proc getAndSetStList { portListIn cgetOption roleIn {sequence 0} } {
	# call example
	# puts "\n getAndSetStList 1/3/15 framesReceived tx.port"
	#set sequence 0
	global stList
	set portList [ pLproc $portListIn ]
	foreach item $portList {
		scan $item "%d %d %d" chasId card port
		#puts "current port is $chasId $card $port in $roleIn portList"
		if {[statList get $chasId $card $port]} {
			errorMsg "Error - statList get $chasId $card $port failed in $roleIn portList"
			return $::TCL_ERROR
		}
		#convert item to in list form,adapt to use pLToHandles
		#portList before pLToHandles is {1 3 15}
		#portList after pLToHandles is 1/3/15
		set item [list $item]
		set pHandleItem [pLToHandles $item]

		#get framesReceived
		set cgetOptionV [statList cget -$cgetOption]
		#ixPuts "$roleIn.$chasId.$card.$port.$cgetOption=$cgetOptionV"

		#modify by clchen 2013/05/13 move $sequence to top level
		#ixPuts "$roleIn.$sequence.$pHandleItem.$cgetOption=$cgetOptionV"
		ixPuts "$sequence.$roleIn.$pHandleItem.$cgetOption=$cgetOptionV"
		#write framesReceived to stList
		set keyO $cgetOption
		set keyV $cgetOptionV
		set role $roleIn
		#set retv [keylset stList $role.$chasId.$card.$port.$keyO $keyV]

		#modify by clchen 2013/05/13 move $sequence to top level
		#set retv [keylset stList $role.$sequence.$pHandleItem.$keyO $keyV]
		set retv [keylset stList $sequence.$role.$pHandleItem.$keyO $keyV]

		if [expr { $retv == "" } ] {
			#puts "set stList status for 1"
			keylset stList status 1
			#puts $stList
		} else {
			keylset stList status 0
			puts "set $sequence.$role.$pHandleItem.$keyO $keyV failed"
		}
	}
}

#
#set txPortListIn {{1 3 15}}
#set rxPortListIn {{1 3 16}}
#set durationIn 5
# call exmple :	startTransAndGetStats $txPortListIn $rxPortListIn $durationIn
# description: start transmit txPortListIn, get all statistics for both tx and rx;
# return a stList
proc startTransAndGetStats {txPortListIn rxPortListIn durationIn {sequence 0} } {
	#set portList {{1 3 15} {1 3 16}}
	#set txPortList {{1 3 15}}
	#set rxPortList {{1 3 16}}
	#puts "portList is $portList"
	#set duration	5
	set portList [concat $txPortListIn $rxPortListIn ]
	puts "portList is $portList"
	set txPortList $txPortListIn
	puts "txPortList is $txPortList"
	#set rxPortList {{1 3 16}}
	set rxPortList $rxPortListIn
	puts "rxPortList is $rxPortList"
	set duration	$durationIn
	puts "duration is $duration"
	set transmitDuration [expr {$duration*1000}]
	puts "sequence is $sequence"

	set portHandleList [pLToHandles $portList]
	puts "portHandleList in startTransAndGetStats is $portHandleList"

	#set port Stat Mode this will impact port down and up
	#foreach portHandleItem $portHandleList {
	#	portStatModeSet $portHandleItem -statMode statNormal
	#}

	#txPortList Transmit start 3s than stop
	if {[ixCheckLinkState portList] !=0 } {
		ixPuts "1 May be linkDown on portList $portList"
		return -code error
	} else {
		ixPuts "1 ixCheckLinkState portList $portList ok"
	}

	# sometime found it can't stop txPortList 2013/4/18
	#if {[ixStopTransmit txPortList] != 0} {
	#	ixPuts "1 Could not stop Transmit on $txPortList"
	#	return -code error
	#} else {
	#	#ixPuts "Stop transmit"
	#}
	if [ixStartTransmit txPortList] {
		ixPuts "1 Could not start Transmit on $txPortList"
		return -code error
	} else {
		#ixPuts "Start transmit..."
	}
	after 3000

	#after $transmitDuration
	if {[ixStopTransmit portList] != 0} {
		ixPuts "2 Could not stop Transmit on portList $portList"
		return -code error
	} else {
		ixPuts "2 ixStopTransmit portList $portList ok"
	}
	# no need 2013/4/18
	# ensure Transmission is complete,some time found it is not stop,so add this 2013/4/23
	if {[ixCheckTransmitDone txPortList] == $::TCL_ERROR} {
		ixPuts "2 Transmit have not been done on txPortList $txPortList"
		return -code error
	} else {
		ixPuts "2 Transmission is complete on txPortList $txPortList ok"
	}

	# Zero all statistic counters on ports and start transmit
	if [ixClearStats portList] {
		ixPuts "2 Failed in ixClearStats portList $txPortList"
		return -code error
	} else {
		ixPuts "2 ixClearStats portList $portList ok"
	}
	# no need to write for Zero all statistic
	#if [ixWriteConfigToHardware portList -noProtocolServer] {
	#	return -code error
	#} else {
	#	#ixPuts "write config to haradware"
	#}

	# no need for this, because above step have done ixStopTransmit txPortList
	#if {[ixStopTransmit txPortList] != 0} {
	#	ixPuts "Could not stop Transmit on txPortList $txPortList"
	#	return -code error
	#} else {
	#	#ixPuts "Stop transmit"
	#}

	#second start for 3s
	#txPortList Transmit start
	if [ixStartTransmit txPortList] {
		ixPuts "3 Could not start Transmit on txPortList $txPortList"
		return -code error
	} else {
		ixPuts "3 Start transmit on txPortList $txPortList ok"
	}
	#default use 1+2 second
	after 1000
	after $transmitDuration
	#stop Transmit portList
	if {[ixStopTransmit portList] != 0} {
		ixPuts "3 Could not stop Transmit on portList $portList"
		return -code error
	} else {
		ixPuts "3 Stop transmit portList $portList ok"
	}

	# no need for this
	# ensure Transmission is complete add by clchen 2013/4/23
	if {[ixCheckTransmitDone txPortList] == $::TCL_ERROR} {
		ixPuts "3 Transmit have not been done on txPortList $txPortList"
		return -code error
	} else {
		ixPuts "3 Transmission is complete on txPortList $txPortList ok"
	}

	#########################get stats############################3
	ixPuts "get tx frame and rx frame with portList"
	#cget option value
	# Here you may retrieve the stats for both tx and rx ports at the same time, then compare.
	#first,Retreive the total number of transmitted frames from the tx port.
	if { [ixRequestStats portList] != $::TCL_OK } {
		ixPuts "ixRequestStats portList failed"
		return -code error
	} else {
		ixPuts "ixRequestStats portList is OK"
	}
	ixPuts "\n get tx port stats with UDS2"
	#for txPortList

	#set stList [ list ]
	global stList
	puts "in startTransAndGetStats,stList before is $stList"
	#list stList ""
	foreach item $txPortList {
		scan $item "%d %d %d" chasId card port
		puts "current port is $chasId $card $port in txPortList"
		if { [statList get $chasId $card $port] } {
			errorMsg "Error - statList get $chasId $card $port failed in txPortList"
			return $::TCL_ERROR
		}

		#convert item to in list form,adapt to use pLToHandles
		#portList before pLToHandles is {1 3 15}
		#portList after pLToHandles is 1/3/15
		set item [list $item]
		set pHandleItem [pLToHandles $item]

		set framesSent1 [statList cget -framesSent]
		ixPuts "tx.port.$chasId.$card.$port.framesSent=$framesSent1"
		#set chasId 1
		#set card 3
		#set port 15
		set keyO framesSent
		set keyV $framesSent1
		set role tx.port
		#commented by clchen 2013/05/08
		#set retv [keylset stList $role.$chasId.$card.$port.$keyO $keyV]
		#set retv [keylset stList $role.$sequence.$pHandleItem.$keyO $keyV]
		set retv [keylset stList $sequence.$role.$pHandleItem.$keyO $keyV]
		if [expr { $retv == "" } ] {
			#puts "set stList status for 1"
			keylset stList status 1
			#puts $stList
		} else {
			keylset stList status 0
			puts "set $role.$chasId.$card.$port.$keyO $keyV failed"
		}

		set framesReceived1 [statList cget -framesReceived]
		ixPuts "tx.port.$chasId.$card.$port.framesReceived=$framesReceived1"
		set keyO framesReceived
		set keyV $framesReceived1
		set role tx.port
		#commented by clchen 2013/05/08
		#set retv [keylset stList $role.$chasId.$card.$port.$keyO $keyV]
		#set retv [keylset stList $role.$sequence.$pHandleItem.$keyO $keyV]
		set retv [keylset stList $sequence.$role.$pHandleItem.$keyO $keyV]
		if [expr { $retv == "" } ] {
			#puts "set stList status for 1"
			keylset stList status 1
			#puts $stList
		} else {
			keylset stList status 0
			puts "set $role.$chasId.$card.$port.$keyO $keyV failed"
		}

		set userDefinedStat2_1 [statList cget -userDefinedStat2]
		ixPuts "tx.port.$chasId.$card.$port.userDefinedStat2=$userDefinedStat2_1"
		set keyO userDefinedStat2
		set keyV $userDefinedStat2_1
		set role tx.port
		#commented by clchen 2013/05/08
		#set retv [keylset stList $role.$chasId.$card.$port.$keyO $keyV]
		#set retv [keylset stList $role.$sequence.$pHandleItem.$keyO $keyV]
		set retv [keylset stList $sequence.$role.$pHandleItem.$keyO $keyV]

		if [expr { $retv == "" } ] {
			#puts "set stList status for 1"
			keylset stList status 1
			#puts $stList
		} else {
			keylset stList status 0
			puts "set $role.$chasId.$card.$port.$keyO $keyV failed"
		}
		#add old framesSent framesReceived userDefinedStat2 use uniform output format
		getAndSetStList $pHandleItem "framesSent" "tx.port" $sequence
		getAndSetStList $pHandleItem "framesReceived" "tx.port" $sequence
		getAndSetStList $pHandleItem "userDefinedStat2" "tx.port" $sequence

		#add get bytesSent bytesReceived bitsSent bitsReceived
		getAndSetStList $pHandleItem "bytesSent" "tx.port" $sequence
		getAndSetStList $pHandleItem "bytesReceived" "tx.port" $sequence
		getAndSetStList $pHandleItem "bitsSent" "tx.port" $sequence
		getAndSetStList $pHandleItem "bitsReceived" "tx.port" $sequence

		#add get oversize option and set to stList in tx.port side
		getAndSetStList $pHandleItem "oversize" "tx.port" $sequence
	}
	#for rxPortList ixRequestStats rxPortList
	ixPuts "\n get rx port stats with UDS2"
	foreach item $rxPortList {
		scan $item "%d %d %d" chasId card port
		puts "current port is $chasId $card $port in rxPortList"
		if {[statList get $chasId $card $port]} {
			errorMsg "Error - statList get $chasId $card $port failed in rxPortList"
			return $::TCL_ERROR
		}

		#convert item to in list form,adapt to use pLToHandles
		#portList before pLToHandles is {1 3 15}
		#portList after pLToHandles is 1/3/15
		set item [list $item]
		set pHandleItem [pLToHandles $item]

		set framesSent2 [statList cget -framesSent]
		ixPuts "rx.port.$chasId.$card.$port.framesSent=$framesSent2"
		set keyO framesSent
		set keyV $framesSent2
		set role rx.port
		#commented by clchen 2013/05/08
		#set retv [keylset stList $role.$chasId.$card.$port.$keyO $keyV]
		#set retv [keylset stList $role.$sequence.$pHandleItem.$keyO $keyV]
		set retv [keylset stList $sequence.$role.$pHandleItem.$keyO $keyV]
		if [expr { $retv == "" } ] {
			#puts "set stList status for 1"
			keylset stList status 1
			#puts $stList
		} else {
			keylset stList status 0
			puts "set $role.$chasId.$card.$port.$keyO $keyV failed"
		}

		set framesReceived2 [statList cget -framesReceived]
		ixPuts "rx.port.$chasId.$card.$port.framesReceived=$framesReceived2"
		set keyO framesReceived
		set keyV $framesReceived2
		set role rx.port
		#commented by clchen 2013/05/08
		#set retv [keylset stList $role.$chasId.$card.$port.$keyO $keyV]
		#set retv [keylset stList $role.$sequence.$pHandleItem.$keyO $keyV]
		set retv [keylset stList $sequence.$role.$pHandleItem.$keyO $keyV]
		if [expr { $retv == "" } ] {
			#puts "set stList status for 1"
			keylset stList status 1
			#puts $stList
		} else {
			keylset stList status 0
			puts "set $role.$chasId.$card.$port.$keyO $keyV failed"
		}

		set userDefinedStat2_2 [statList cget -userDefinedStat2]
		ixPuts "rx.port.$chasId.$card.$port.userDefinedStat2=$userDefinedStat2_2"
		set keyO userDefinedStat2
		set keyV $userDefinedStat2_2
		set role rx.port
		#commented by clchen 2013/05/08
		#set retv [keylset stList $role.$chasId.$card.$port.$keyO $keyV]
		#set retv [keylset stList $role.$sequence.$pHandleItem.$keyO $keyV]
		set retv [keylset stList $sequence.$role.$pHandleItem.$keyO $keyV]
		if [expr { $retv == "" } ] {
			#puts "set stList status for 1"
			keylset stList status 1
			#puts $stList
		} else {
			keylset stList status 0
			puts "set $role.$chasId.$card.$port.$keyO $keyV failed"
		}
		#add old framesSent framesReceived userDefinedStat2 use uniform output format
		getAndSetStList $pHandleItem "framesSent" "rx.port" $sequence
		getAndSetStList $pHandleItem "framesReceived" "rx.port" $sequence
		getAndSetStList $pHandleItem "userDefinedStat2" "rx.port" $sequence

		#add get bytesSent bytesReceived bitsSent bitsReceived
		getAndSetStList $pHandleItem "bytesSent" "rx.port" $sequence
		getAndSetStList $pHandleItem "bytesReceived" "rx.port" $sequence
		getAndSetStList $pHandleItem "bitsSent" "rx.port" $sequence
		getAndSetStList $pHandleItem "bitsReceived" "rx.port" $sequence

		#add get oversize option and set to stList in rx.port side
		getAndSetStList $pHandleItem "oversize" "rx.port" $sequence
	}
	#according status to return different result
	if [ expr { [keylget stList status] == 1 } ] {
		puts "get tx and rx stList success"
		puts "in startTransAndGetStats,stList after is $stList"
		return $stList
	} else {
		puts "get tx and rx stList failed"
	}

}

#call example
#checkStreamEqualTxWithRX 1/3/15 2 1/3/16 2 framesSent framesReceived
#equalFlag -1 default
#			1 equal
#			2 not equal
#			3 block
proc checkStreamEqualTxWithRX  {oneTxPort txStreamId oneRxPort rxStreamId { framesSent "framesSent" } { userDefinedStat2 "framesReceived" } {sequence 0} } {
	#process in oneTxPort like 1/3/16 oneRxPort like 1/3/16
	puts "oneTxPort is $oneTxPort"
	puts "oneRxPort is $oneRxPort"
	#set oneTxPort 1/3/15
	#set oneRxPort 1/3/16
	set oneTxPortIn [ split $oneTxPort "/" ]
	set chasIdTx [ lindex $oneTxPortIn 0 ]
	set cardIdTx [ lindex $oneTxPortIn 1 ]
	set portIdTx [ lindex $oneTxPortIn 2 ]

	set oneRxPortIn [ split $oneRxPort "/" ]
	set chasIdRx [ lindex $oneRxPortIn 0 ]
	set cardIdRx [ lindex $oneRxPortIn 1 ]
	set portIdRx [ lindex $oneRxPortIn 2 ]

	#got statistics from global stList or streamStList
	global streamStList
	#puts "stList in checkEqualTxWithRX is $stList"
	#puts "streamStList in checkStreamEqualTxWithRX is $streamStList"
	set equalFlag -1
	#set sentPara framesSent
	#set recvPara userDefinedStat2
	set sentPara $framesSent
	set recvPara $userDefinedStat2
	#puts "tx.port.chasIdTx.cardIdTx.portIdTx.sentPara is tx.port.$chasIdTx.$cardIdTx.$portIdTx.$sentPara"
	#modify 2013/05/08 by clchen use sequence comment the old way
	#set cmp1 [keylget stList tx.port.$chasIdTx.$cardIdTx.$portIdTx.$sentPara]
	#puts "cmp1 is $cmp1"
	#set cmp1 [keylget stList tx.port.$sequence.$oneTxPort.$sentPara]
	if { [catch { set cmp1 [keylget streamStList $sequence.tx.port.$oneTxPort.$txStreamId.$sentPara] } my_Error] } {
		return [print_Report "my_Error is $my_Error,keylget streamStList $sequence.tx.port.$oneTxPort.$txStreamId.$sentPara failed" 1]
	} else {
		puts "cmp1 is $cmp1"
	}
	#set cmp2 [keylget stList rx.port.$chasIdRx.$cardIdRx.$portIdRx.$recvPara]
	#puts "cmp2 is $cmp2"
	#set cmp2 [keylget stList rx.port.$sequence.$oneRxPort.$recvPara]
	if { [catch { set cmp2 [keylget streamStList $sequence.rx.port.$oneRxPort.$rxStreamId.$recvPara] } my_Error] } {
		return [print_Report "my_Error is $my_Error,keylget streamStList $sequence.rx.port.$oneRxPort.$rxStreamId.$recvPara failed" 1]
	} else {
		puts "cmp2 is $cmp2"
	}

	#do compare
	if { [ expr { $cmp1 == $cmp2 } ] && [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 != 0 } ] } {
		set equalFlag 1 ;#euqal
	} elseif { [ expr { $cmp1 != $cmp2 } ] && [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 != 0 } ] } {
		set equalFlag 2 ;#not equal
	} elseif { [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 == 0 } ] } {
		set equalFlag 3 ;#blocked
	}
	#puts "equalFlag is $equalFlag"
	if { [expr {$equalFlag == 1} ]} {
		puts "sequence $sequence checkStreamEqualTxWithRX $oneTxPort $txStreamId $oneRxPort $rxStreamId $framesSent $userDefinedStat2 result is equal^0"
		return 0
	} elseif { [expr {$equalFlag == 2} ] } {
		puts "sequence $sequence checkStreamEqualTxWithRX $oneTxPort $txStreamId $oneRxPort $rxStreamId $framesSent $userDefinedStat2 result is not equal^0"
		return 0
	} elseif { [expr {$equalFlag == 3} ] } {
		puts "sequence $sequence checkStreamEqualTxWithRX $oneTxPort $txStreamId $oneRxPort $rxStreamId $framesSent $userDefinedStat2 result is blocked^0"
		return 0
	} else {
		puts "sequence $sequence checkStreamEqualTxWithRX $oneTxPort $txStreamId $oneRxPort $rxStreamId $framesSent $userDefinedStat2 result is abnormal^1"
		return 1
	}
}

#
#in oneTxPort framesSent oneRxPort userDefinedStat2
#out: checkEqualTxWithRX result is true, return is 0
#						 result is false, return is 1
#call example
#checkEqualTxWithRX 1/3/15 framesSent 1/3/16 userDefinedStat2 is deprecated on 2013/4/18
#checkEqualTxWithRX 1/3/15 1/3/16
#checkEqualTxWithRX 1/3/15 1/3/16 framesSent userDefinedStat2
#equalFlag -1 default
#			1 equal
#			2 not equal
#			3 block
proc checkEqualTxWithRX  {oneTxPort  oneRxPort { framesSent "framesSent" } { userDefinedStat2 "userDefinedStat2" } {sequence 0} } {
	#process in oneTxPort like 1/3/16 oneRxPort like 1/3/16
	puts "oneTxPort is $oneTxPort"
	puts "oneRxPort is $oneRxPort"
	#set oneTxPort 1/3/15
	#set oneRxPort 1/3/16
	set oneTxPortIn [ split $oneTxPort "/" ]
	set chasIdTx [ lindex $oneTxPortIn 0 ]
	set cardIdTx [ lindex $oneTxPortIn 1 ]
	set portIdTx [ lindex $oneTxPortIn 2 ]

	set oneRxPortIn [ split $oneRxPort "/" ]
	set chasIdRx [ lindex $oneRxPortIn 0 ]
	set cardIdRx [ lindex $oneRxPortIn 1 ]
	set portIdRx [ lindex $oneRxPortIn 2 ]

	#got statistics from global stList
	global stList
	#puts "stList in checkEqualTxWithRX is $stList"
	set equalFlag -1
	#set sentPara framesSent
	#set recvPara userDefinedStat2
	set sentPara $framesSent
	set recvPara $userDefinedStat2
	#puts "tx.port.chasIdTx.cardIdTx.portIdTx.sentPara is tx.port.$chasIdTx.$cardIdTx.$portIdTx.$sentPara"
	#modify 2013/05/08 by clchen use sequence comment the old way
	#set cmp1 [keylget stList tx.port.$chasIdTx.$cardIdTx.$portIdTx.$sentPara]
	#puts "cmp1 is $cmp1"
	#set cmp1 [keylget stList tx.port.$sequence.$oneTxPort.$sentPara]
	set cmp1 [keylget stList $sequence.tx.port.$oneTxPort.$sentPara]
	puts "cmp1 is $cmp1"
	#set cmp2 [keylget stList rx.port.$chasIdRx.$cardIdRx.$portIdRx.$recvPara]
	#puts "cmp2 is $cmp2"
	#set cmp2 [keylget stList rx.port.$sequence.$oneRxPort.$recvPara]
	set cmp2 [keylget stList $sequence.rx.port.$oneRxPort.$recvPara]
	puts "cmp2 is $cmp2"

	if { [ expr { $cmp1 == $cmp2 } ] && [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 != 0 } ] } {
		set equalFlag 1 ;#euqal
	} elseif { [ expr { $cmp1 != $cmp2 } ] && [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 != 0 } ] } {
		set equalFlag 2 ;#not equal
	} elseif { [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 == 0 } ] } {
		set equalFlag 3 ;#blocked
	}
	#puts "equalFlag is $equalFlag"
	if { [expr {$equalFlag == 1} ]} {
		puts "sequence $sequence checkEqualTxWithRX $oneTxPort $oneRxPort $framesSent $userDefinedStat2 result is equal^0"
		return 0
	} elseif { [expr {$equalFlag == 2} ] } {
		puts "sequence $sequence checkEqualTxWithRX $oneTxPort $oneRxPort $framesSent $userDefinedStat2 result is not equal^0"
		return 0
	} elseif { [expr {$equalFlag == 3} ] } {
		puts "sequence $sequence checkEqualTxWithRX $oneTxPort $oneRxPort $framesSent $userDefinedStat2 result is blocked^0"
		return 0
	} else {
		puts "sequence $sequence checkEqualTxWithRX $oneTxPort $oneRxPort $framesSent $userDefinedStat2 result is abnormal^1"
		return 1
	}
}

#checkSumEqualTxWithRx 1/3/15,1/3/16 framesSent,framesSent 1/3/15,1/3/16 userDefinedStat2,userDefinedStat2
#checkSumEqualTxWithRx 1/3/15,1/3/16 framesSent,framesSent 1/3/16 userDefinedStat2
#checkSumEqualTxWithRx 1/3/15 framesSent 1/3/15,1/3/16 userDefinedStat2,userDefinedStat2
proc checkSumEqualTxWithRx {txPortList1 txStParaList1 rxPortList1 rxStParaList1 {sequence 0} } {
	#got statistics from global stList
	global stList
	set equalFlag -1

	#for tx
	set txPortList [split $txPortList1 ","]
	set txStParaList [split $txStParaList1 ","]
	set cmp1Sum 0
	foreach txPortListItem $txPortList txStParaListItem $txStParaList {
		set txPortListItemIn [ split $txPortListItem "/" ]
		set chasIdTx [ lindex $txPortListItemIn 0 ]
		set cardIdTx [ lindex $txPortListItemIn 1 ]
		set portIdTx [ lindex $txPortListItemIn 2 ]
		set sentPara $txStParaListItem
		#modify 2013/05/08 by clchen use sequence comment the old way
		#set cmp1 [keylget stList tx.port.$chasIdTx.$cardIdTx.$portIdTx.$sentPara]
		#puts "cmp1 $sentPara under $chasIdTx.$cardIdTx.$portIdTx is $cmp1"
		#set cmp1 [keylget stList tx.port.$sequence.$txPortListItem.$sentPara]
		set cmp1 [keylget stList $sequence.tx.port.$txPortListItem.$sentPara]
		puts "cmp1 $sentPara under $txPortListItem is $cmp1"
		set cmp1Sum [expr {$cmp1Sum+$cmp1}]
	}
	puts "cmp1Sum is $cmp1Sum"

	#for rx
	set rxPortList [split $rxPortList1 ","]
	set rxStParaList [split $rxStParaList1 ","]
	set cmp2Sum 0
	foreach rxPortListItem $rxPortList rxStParaListItem $rxStParaList {
		set rxPortListItemIn [ split $rxPortListItem "/" ]
		set chasIdRx [ lindex $rxPortListItemIn 0 ]
		set cardIdRx [ lindex $rxPortListItemIn 1 ]
		set portIdRx [ lindex $rxPortListItemIn 2 ]
		set recvPara $rxStParaListItem
		#modify 2013/05/08 by clchen use sequence comment the old way
		#set cmp2 [keylget stList rx.port.$chasIdRx.$cardIdRx.$portIdRx.$recvPara]
		#puts "cmp2 $recvPara under $chasIdRx.$cardIdRx.$portIdRx is $cmp2"
		#set cmp2 [keylget stList rx.port.$sequence.$rxPortListItem.$recvPara]
		set cmp2 [keylget stList $sequence.rx.port.$rxPortListItem.$recvPara]
		puts "cmp2 $recvPara under $rxPortListItem is $cmp2"
		set cmp2Sum [expr {$cmp2Sum+$cmp2}]
	}
	puts "cmp2Sum is $cmp2Sum"

	set cmp1 $cmp1Sum
	set cmp2 $cmp2Sum
	if { [ expr { $cmp1 == $cmp2 } ] && [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 != 0 } ] } {
		set equalFlag 1 ;#euqal
	} elseif { [ expr { $cmp1 != $cmp2 } ] && [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 != 0 } ] } {
		set equalFlag 2 ;#not equal
	} elseif { [ expr { $cmp1 != 0 } ] && [ expr { $cmp2 == 0 } ] } {
		set equalFlag 3 ;#blocked
	}
	#puts "equalFlag is $equalFlag"
	if { [expr {$equalFlag == 1} ]} {
		puts "sequence $sequence check_sum_equal_tx_with_rx $txPortList1 $txStParaList1 $rxPortList1 $rxStParaList1 result is equal^0"
		return 0
	} elseif { [expr {$equalFlag == 2} ] } {
		puts "sequence $sequence check_sum_equal_tx_with_rx $txPortList1 $txStParaList1 $rxPortList1 $rxStParaList1 result is not equal^0"
		return 0
	} elseif { [expr {$equalFlag == 3} ] } {
		puts "sequence $sequence check_sum_equal_tx_with_rx $txPortList1 $txStParaList1 $rxPortList1 $rxStParaList1 result is blocked^0"
		return 0
	} else {
		puts "sequence $sequence check_sum_equal_tx_with_rx $txPortList1 $txStParaList1 $rxPortList1 $rxStParaList1 result is abnormal^1"
		return 1
	}
}

# argment parse function
proc ah_argparse { argv argfmt } {
	# Copyright 2013, Kun Li, Aerohive
	# Version: 1.0
	# Date: 2013-03-19
	#
	# History:
	#  version 1.0: 2013.03.19 by Kun, kunli@aerohive.com
	#
	# Description:
	#
	# Source this code in your script.  call ah_argparse with $argv and
	# an argument format string.  ah_argparse will return an array (in
	# array get format) with keys and values from your argument format string
	# if they exist in argv.
	#
	# argfmt is:
	# {{ arg key required type comment }...}
	#
	# arg: the letter or letters of the argument
	# key: array name in arg that is set with the value
	# required: either optional or required
	# type:
	#  bool - takes no argument, arg(key) is either set, or not.
	#  int - takes one argument, must be a number.
	#  string - one argument, can be anything.
	#  help - prints ah_arghelp.
	# comment: the string displayed in help.
	#
	# Example argument format:
	#
	# set ArgFt { \
	#  { V verbose optional bool "Be verbose" } \
	#  { i interactive optional bool "Use interactive mode"} \
	#  { v version optional string "Distribution version to use"} \
	#  { r retry required int "number of repititions"} \
	#  { u username required string "username to use"} \
	#  { p password required string "password to use"} \
	# }

	# -h parameter was available for each API, no need add in argformat
	lappend argfmt { h help optional help "Display the help information"}

	set argc [llength $argv]
	for { set idx 0 } { $idx < $argc } { incr idx } {
		set thisarg [lindex $argv $idx]
		set gotit 0
		if { [string range $thisarg 0 0] == "-" } {
			# do short arg parsing.
			set thisarg [string range $thisarg 1 end]
			# input format 0: -arg value. Example: -vlan_id 10
			# input format 1: -arg=value. Example: -vlan_id=10
			if {[string first "=" $thisarg]!=-1} {
				set arg_input_ft 1
				set thisarg_arg [string range $thisarg 0 [expr [string first "=" $thisarg]-1]]
				set thisarg_value [string range $thisarg [expr [string first "=" $thisarg]+1] end]
			} else {
				set arg_input_ft 0
				set thisarg_arg $thisarg
			}
			foreach fmt $argfmt {
				set fmt_key [lindex $fmt 1]
				set fmt_type [lindex $fmt 3]
				set fmt_arg [lindex $fmt 0]
				set fmt_comment [lindex $fmt 4]
				if { $thisarg_arg == $fmt_arg || $thisarg_arg == "-$fmt_key" } {
					switch $fmt_type {
						bool {
							set arg($fmt_key) 1
							set gotit 1
						} int {
							if { $arg_input_ft==0 } {
								incr idx
								set thisarg_value [lindex $argv $idx]
								if { $thisarg_value == "" || ![string is integer $thisarg_value] } {
									set msg "The $thisarg argument requires an integer."
									return -code error $msg
								}
							}
							set arg($fmt_key) $thisarg_value
							set gotit 1
						} string {
							if { $arg_input_ft==0 } {
								incr idx
								set thisarg_value [lindex $argv $idx]
							}
							set arg($fmt_key) $thisarg_value
							set gotit 1
						} help {
							return -code error [ah_arghelp $argfmt]
						} default {
							return -code error "The $thisarg argument type was $fmt_type: Unknown argument type?"
						}
					}
				}
			}
		}
	}
	foreach fmt $argfmt {
		set fmt_key [lindex $fmt 1]
		set fmt_req [lindex $fmt 2]
		if { $fmt_req == "required" } {
			if { ! [info exists arg($fmt_key)] } {
				return -code error [ah_arghelp $argfmt]
			}
		}
	}
	return [array get arg]
}

proc ah_arghelp { argfmt } {
	# Copyright 2013, Kun Li, Aerohive
	# Version: 1.0
	# Date: 2013-03-19
	#
	# History:
	#  version 1.0: 2013.03.19 by Kun, kunli@aerohive.com
	#
	# Description:
	#
	# The function of this proc was to print the help information of API.
	#It was called by ah_argparse.

	set msg ""
	set argfmt [lsort $argfmt]
	append msg "Usage: [info script]\n\n"
	foreach fmt $argfmt {
		set fmt_key [lindex $fmt 1]
		set fmt_type [lindex $fmt 3]
		set fmt_arg [lindex $fmt 0]
		set fmt_comment [lindex $fmt 4]
		set fmt_req [lindex $fmt 2]
		if { $fmt_req == "required" } {
			set opt [format "%-2s %-18s %-30s" * -$fmt_arg, --$fmt_key]
		} else {
			set opt [format "%-2s %-18s %-30s" "" -$fmt_arg, --$fmt_key]
		}
		set opt2 ""
		switch $fmt_type {
			string { set opt2 "<string> " }
			int { set opt2 "<integer> " }
		}
		set opt [format "%-33s %10s" $opt $opt2]
		append msg "$opt : $fmt_comment \n"
	}
	append msg "\nOptions marked with a '*' are required.\n"
	return $msg
}

proc Ah_ArgParse_Test { args } {

	# Copyright 2013, Kun Li, Aerohive
	# Version: 1.0
	# Date: 2013-03-19
	#
	# History:
	#  version 1.0: 2013.03.19 by Kun, kunli@aerohive.com
	#
	# Description:
	#  Example for call ah_argparse
	#

	# define the format for the args to this command
	set argformat {
		{ mac_src mac_addr_source required string "Ethernet Source MAC" }
		{ mac_dst mac_addr_destination required string "Ethernet Destination MAC" }
		{ eth_type ethernet_protocol_type optional string "Ethernet Type" }
		{ vlan_enable vlan_tag_enable optional bool "Enable VLAN or NOT"}
		{ vlan_id  vlan_tag_id optional int "VLAN TAG ID"}
	}

	# Set any default values.
	set arg(ethernet_protocol_type) "0x0800"
	set arg(vlan_tag_enable) 0
	set arg(vlan_tag_id) 1

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args
	foreach fmt $argformat {
		set fmt_key [lindex $fmt 1]
		puts "The frame $fmt_key was: $arg($fmt_key) \r"
	}
}

#puts "############source ahIxia end############"

package provide ixia 1.0