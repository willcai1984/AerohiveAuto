#!/root/ixos/bin/tclsh8.4
proc oneTx2oneRx {hostnameIn cardIn port1In port2In portVlanIDIn} {
	package req IxTclHal
	set userName IxiaTclUserAT1
	set hostname $hostnameIn
	set tclserver $hostnameIn
	#set tclserver 10.155.33.113
	set retCode $::TCL_OK
	if {[isUNIX]} {
		set retCode [ixConnectToTclServer $tclserver]
	}
	ixPuts "\n\tIxia Tcl Script demo"
	ixLogin $userName
	ixPuts "\nUser logged in as: $userName"
	set retCode [ixConnectToChassis $hostname]
	if {$retCode != $::TCL_OK} {
		return $retCode
	}
	set chasId [ixGetChassisID $hostname]
	puts "chasId is: $chasId"
	set card $cardIn
	set port1 $port1In
	set port2 $port2In
	set portVlanID $portVlanIDIn
	set framesize 66
	set transmitDuration 1000
	puts "portVlanID is: $portVlanID"
	#Assume transmit from port1 to port2 on same card for this example
	set portList [list [list $chasId $card $port1] [list $chasId $card $port2]]
	set txPortList [list [list $chasId $card $port1] ]
	set rxPortList [list [list $chasId $card $port2] ]
	if [ixTakeOwnership $portList] {
		return $::TCL_ERROR
	}
	#prepare clearOwnership DisconnectFromChassis and clean up
	proc clearOwnershipDisconnectCleanUp {portListIn hostNameIn} { 
		ixClearOwnership $portListIn
		ixDisconnectFromChassis $hostNameIn
		cleanUp
		ixPuts "cleanUp complete"
	}
	ixPuts "Setting ports to factory defaults..."
	foreach item $portList {
		scan $item "%d %d %d" chasId card port
		if [port setFactoryDefaults $chasId $card $port] {
			errorMsg "Error setting factory defaults on $chasId.$card.$port]."
			return $::TCL_ERROR
		}
	}
	# Writes port properties in hardware
	if {[ixWritePortsToHardware portList]} {
		clearOwnershipDisconnectCleanUp $portList $hostname
		return $::TCL_ERROR
	}
	# Check the link state of the ports
	if {[ixCheckLinkState portList]} {
		clearOwnershipDisconnectCleanUp $portList $hostname
		return $::TCL_ERROR
	}
	#prepare macAddress SA and DA stream Vlan
	set macAddress(sa,$chasId,$card,$port1) [format "be ef be ef %02x %02x" $card $port1]
	set macAddress(sa,$chasId,$card,$port2) [format "be ef be ef %02x %02x" $card $port2]
	set macAddress(da,$chasId,$card,$port1) $macAddress(sa,$chasId,$card,$port2)
	set macAddress(da,$chasId,$card,$port2) $macAddress(sa,$chasId,$card,$port1)
	ixGlobalSetDefault
	stream setDefault
	protocol setDefault
	vlan setDefault
	stream config -numFrames 12
	stream config -rateMode streamRateModePercentRate
	stream config -percentPacketRate 43
	#prepare single VLAN
	protocol config -name ipV4
	protocol config -ethernetType ethernetII
	protocol config -enable802dot1qTag vlanSingle
	vlan config -vlanID $portVlanID
	vlan config -mode vIdle
	foreach item $portList {
		scan $item "%d %d %d" chasId card port
		#config MAC
		stream config -sa $macAddress(sa,$chasId,$card,$port)
		stream config -da $macAddress(da,$chasId,$card,$port)
		#debug lines added by ccl 2013-3-5
		puts "debug info source MAC for port $port is:$macAddress(sa,$chasId,$card,$port)"
		puts "debug info destination MAC for port $port is:$macAddress(da,$chasId,$card,$port)"
		stream config -framesize  $framesize
		stream config -dma advance
		#prepare udf
		set udfPattern [lrange [stream cget -da] 2 end]
		puts "udfPattern is :$udfPattern"
		udf config -enable true
		udf config -offset 42
		udf config -initval $udfPattern
		udf config -countertype c32
		udf config -maskselect {00 00 00 00}
		udf config -maskval {00 00 00 00}
		udf config -random false
		udf config -continuousCount false
		udf config -repeat 1
		if [udf set 4] {
			errorMsg "Error setting UDF 4"
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		}
		if {[vlan set $chasId $card $port]} {
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		}
		if {[stream set $chasId $card $port 1]} {
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		}
		if {[ixWriteConfigToHardware portList]} {
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		} else {
			puts "write stream vlan udf config to haradware"
		}
		#prepare Pallette and filters
		set rxUdfPattern [lrange $macAddress(sa,$chasId,$card,$port) 2 end]
		filterPallette config -pattern2 $rxUdfPattern
		filterPallette config -patternOffset2 [udf cget -offset]
		filter config -userDefinedStat2Pattern pattern2
		filter config -userDefinedStat2Enable true
		filter config -userDefinedStat2Error errGoodFrame
		if [filterPallette set $chasId $card $port] {
			errorMsg "Error setting filter pallette for $chasId,$card,$port."
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		}
		if [filter set $chasId $card $port] {
			errorMsg "Error setting filters on $chasId,$card,$port."
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		}
		if {[ixWriteConfigToHardware portList]} {
			ixPuts $::ixErrorInfo
			return $::TCL_ERROR
		} else {
			puts "write Pallette fiters to haradware"
		}
	}
	
	# Zero all statistic counters on ports and start transmit
	#if [ixClearStats portList] {
	#	return -code error
	#}
	#if [ixWriteConfigToHardware portList] {
	#	return -code error
	#} else {
	#	#ixPuts "write config to haradware"
	#}
	#txPortList Transmit start and stop
	if {[ixStopTransmit txPortList] != 0} {
		ixPuts "Could not stop Transmit on $txPortList"
		return -code error
	} else {
		#ixPuts "Stop transmit"
	}
	if [ixStartTransmit txPortList] {
		ixPuts "Could not start Transmit on $txPortList"
		return -code error
	} else {
		#ixPuts "Start transmit..."
	}
	after 1000
	#after $transmitDuration
	if {[ixStopTransmit txPortList] != 0} {
		ixPuts "Could not stop Transmit on $txPortList"
		return -code error
	} else {
		#ixPuts "Stop transmit"
	}
	if {[ixCheckTransmitDone txPortList] == $::TCL_ERROR} {
		ixPuts "Transmit have not been done on $txPortList"
		return -code error
	} else {
		#ixPuts "Transmission is complete."
	}
	
	
	# Zero all statistic counters on ports and start transmit
	if [ixClearStats portList] {
		return -code error
	}
	if [ixWriteConfigToHardware portList] {
		return -code error
	} else {
		#ixPuts "write config to haradware"
	}
	if {[ixStopTransmit txPortList] != 0} {
		ixPuts "Could not stop Transmit on $txPortList"
		return -code error
	} else {
		#ixPuts "Stop transmit"
	}
	#txPortList Transmit start and stop
	if [ixStartTransmit txPortList] {
		ixPuts "Could not start Transmit on $txPortList"
		return -code error
	} else {
		ixPuts "Start transmit..."
	}
	#after 1000
	after $transmitDuration
	if {[ixStopTransmit txPortList] != 0} {
		ixPuts "Could not stop Transmit on $txPortList"
		return -code error
	} else {
		ixPuts "Stop transmit"
	}
	if {[ixCheckTransmitDone txPortList] == $::TCL_ERROR} {
		ixPuts "Transmit have not been done on $txPortList"
		return -code error
	} else {
		#ixPuts "Transmission is complete."
	}
	
	
	
	ixPuts "get tx frame and rx frame with UDS2"
	#cget option value
	# Here you may retrieve the stats for both tx and rx ports at the same time, then compare.
	#first,Retreive the total number of transmitted frames from the tx port.
	if { [ixRequestStats portList] != $::TCL_OK } {
		ixPuts "ixRequestStats portList failed"
		return -code error
	} else {
		ixPuts "ixRequestStats portList is OK"
	}
	#for port1
	if { [statList get $chasId $card $port1] } {
		errorMsg "Error - statList get $chasId $card $txPortList failed"
		return $::TCL_ERROR
	}
	set framesSent [statList cget -framesSent]
	ixPuts "port1 framesSent is: $framesSent"
	#for port2 ixRequestStats rxPortList
	#if { [ixRequestStats rxPortList] != $::TCL_OK } {
	#	ixPuts "ixRequestStats rxPortList failed"
	#	return -code error
	#} else {
	#	ixPuts "ixRequestStats rxPortList is OK"
	#}
	if {[statList get $chasId $card $port2]} {
		errorMsg "Error - statList get $chasId $card $rxPortList failed"
		return $::TCL_ERROR
	}
	set framesReceived [statList cget -framesReceived]
	ixPuts "port2 framesReceived is: $framesReceived"
	set userDS2Port2 [statList cget -userDefinedStat2]
	ixPuts "port2 userDS2Port2 is: $userDS2Port2"
	proc checkTxWithRX {framesSent1 framesReceived2} {
		if { [expr {$framesSent1== $framesReceived2 }] && [expr {$framesSent1!=0}] } {
			ixPuts "framesSent1 is: $framesSent1"
			ixPuts "framesReceived2 is: $framesReceived2"
			ixPuts "framesSent1 is equal with framesReceived2"
			return 0
		} else {
			ixPuts "framesSent1 is: $framesSent1"
			ixPuts "framesReceived2 is: $framesReceived2"
			ixPuts "port1 framesSent1 is not equal with port2 framesReceived2."
			return 1
		}
	}
	clearOwnershipDisconnectCleanUp $portList $hostname
	if { [checkTxWithRX $framesSent $userDS2Port2] != 0 } {
		ixPuts "not equal"
		exit 1
	} else {
		ixPuts "is equal"
		exit 0
	}
}

if [expr {$argc==0}] {
	puts "use one2oneDemo.tcl like this:"
	puts "tclsh8.4 one2oneDemo.tcl chasIP=10.155.33.114 cardID=1 txPort=7 rxPort=8 VlanID=10"
	exit 1
}
if [expr {$argc==1}] {
	if [expr { [lindex $argv 0] == "--help" } ] {
		puts "use one2oneDemo.tcl like this:"
		puts "tclsh8.4 one2oneDemo.tcl chasIP=10.155.33.114 cardID=1 txPort=7 rxPort=8 VlanID=10"
		exit 1
	}
}
if [expr {$argc==5}] {
	set hostnameIn [lindex [split [lindex $argv 0] "="] 1]
	#puts "hostname is- $hostname"
	set cardIn [lindex [split [lindex $argv 1] "="] 1]
	#puts "card is- $card"
	set port1In [lindex [split [lindex $argv 2] "="] 1]
	#puts "port1 is- $port1"
	set port2In [lindex [split [lindex $argv 3] "="] 1]
	#puts "port2 is- $port2"
	set portVlanIDIn [lindex [split [lindex $argv 4] "="] 1]
	#puts "VlanID is- $portVlanID"
	oneTx2oneRx $hostnameIn $cardIn $port1In $port2In $portVlanIDIn
} else {
	puts "use one2oneDemo.tcl like this:"
	puts "tclsh8.4 one2oneDemo.tcl chasIP=10.155.33.114 cardID=1 txPort=7 rxPort=8 VlanID=10"
	exit 1
}


