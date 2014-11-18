puts "ahIxNapi.tcl Initialed"
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

set allPortHandListIxN [ list ]

set protocolStackIxn [ list ]

# for port statistic
set stListIxN [ list ]
# for Qos statistic
#set qossStList [ list ]
# for Multi stream statistic
set streamStListIxN [ list ]

set allIntfH [ list ]

#for all protocolStack/ethernetEndpoint range list
#like ::ixNet::OBJ-/vport:1/protocolStack/ethernetEndpoint:"c72a6da8-092b-4f6c-a9e8-f1868987dde1"/range:"747bd75c-b9e6-4e1e-b7f7-8100316edd2d"
#port.1/3/15.protoStack.ethEndPointH.rangeH = ::ixNet::OBJ-/vport:1/protocolStack/ethernetEndpoint:"c72a6da8-092b-4f6c-a9e8-f1868987dde1"/range:"747bd75c-b9e6-4e1e-b7f7-8100316edd2d"
#set protoStackEthEndPointL [ list ]
set rangeHandleL [ list ]

#for all iphandle list
set allIntfIpH [ list ]

#description:connect to chassis and occupy specified port forcely
#port format:chassis_number/card_number/port_number 1/3/15 means chassis 1，card 3，port 15；
#
proc ah_ixn_connect {args} {
	######### parameter process start
	set argformat {
		{ chassisIP 	chassisIP 	required string "chassisIP,like 10.155.33.216" }
		{ userName	userName 	required string "userName,like ahATclchen or ${job.user}${job.sid}" }
		{ portList	portList 	required string "portList,like 1/3/15 or like 1/3/15,1/3/16" }
		{ ixn_tcl_server	ixn_tcl_server	required string "ixn_tcl_server,it will be your IxNetwork GUI station IP " }
		{ def		def		optional string "set Port to factory default and clear exist stream,disable|enable,default is enable,disable is used for second connect when 1st connect is successful " }
		{ phyList	phyList		required string "config phy_mode,copper|fiber|10GE_fiber,multiport input like copper,copper or like fiber,fiber"}
		{ zcallExample	zcallExample	optional string "ah_ixn_connect -def enable -chassisIP 10.155.33.216 -ixn_tcl_server 10.155.41.8 -userName AH_ATUserHLT2 -portList 1/3/15,1/3/16 -phyList copper,copper"}
	}
	# set optional parameter default value
	set arg(ixn_tcl_server)	10.155.41.8
	set arg(def)	enable
	set arg(phyList)	copper
	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	array set arg $args

	#get the parameter In
	parray arg

	set chassisIP	$arg(chassisIP)
	set userName	$arg(userName)
	set portListIn	$arg(portList)
	set ixn_tcl_server	$arg(ixn_tcl_server)
	set phyListIn	$arg(phyList)
	set def		$arg(def)
	set portDefault $def
	#function start
	set phyList [split $phyListIn ","]
	set portList [pLconn $portListIn]
	puts "portList is $portList"
	set portHandle [pLhand $portListIn]
	puts "portHandle is $portHandle"

	#set connect_info [ixia::connect\
	#	-device 10.155.33.216\
	#	-username clchen_ixN_ATLinux2\
	#	-port_list {{3/15 3/16}}\
	#	-mode connect\
	#	-ixnetwork_tcl_server 10.155.41.8]
	
	#if [ expr { $portDefault == "enable"  } ] { 
	#	ixDisconnectTclServer
	#}
	
	if [ expr { $portDefault == "enable"  } ] {
		ixPuts "portDefault is $portDefault "
		set connect_info [ixia::connect\
			-device $arg(chassisIP)\
			-username $arg(userName)\
			-port_list [list $portList]\
			-reset \
			-ixnetwork_tcl_server $ixn_tcl_server]
		if [ expr { [keylget connect_info status]== $::SUCCESS } ] {
			#ixNet execute newConfig
			ixNet commit
			ixPuts "connect_info is $connect_info"
			ixPuts "Setting ports $portHandle to factory defaults and clear stream..."
		} else {
			ixPuts "connect to  ixn_tcl_server $ixn_tcl_server is failed"
			ixPuts "the connect_info is $connect_info"
		}

	}

	if [ expr { $portDefault == "disable"  } ] {
		set connect_info  [::ixia::connect -ixnetwork_tcl_server $arg(chassisIP):8009]
		ixPuts "connect_info is $connect_info"
		#keylset returnList status $::SUCCESS
		#puts "returnList is $returnList"
		#
		#{status 1} {vport_list {1/3/15 1/3/16}}
		#{port_handle {{10 {{155 {{33 {{216 {{3/15 1/3/15} {3/16 1/3/16}}}}}}}}}}}
		#{1/3/15 {{emulation_efm_config {{information_oampdu_id ::ixNet::OBJ-/vport:1}
		#	{event_notification_oampdu_id ::ixNet::OBJ-/vport:1}}}}}
		#{1/3/16 {{emulation_efm_config {{information_oampdu_id ::ixNet::OBJ-/vport:2}
		#	{event_notification_oampdu_id ::ixNet::OBJ-/vport:2}}}}}
		#{TI0-HLTAPI_TRAFFICITEM_540
		#	{{traffic_config {{status 1}
		#	{log {}}
		#	{stream_id TI0-HLTAPI_TRAFFICITEM_540}
		#	{traffic_item ::ixNet::OBJ-/traffic/trafficItem:3/configElement:1}
		#	{::ixNet::OBJ-/traffic/trafficItem:3/configElement:1
		#		{{headers {::ixNet::OBJ-/traffic/trafficItem:3/configElement:1/stack:"ethernet-1"
		#			::ixNet::OBJ-/traffic/trafficItem:3/configElement:1/stack:"ipv4-2"
		#			::ixNet::OBJ-/traffic/trafficItem:3/configElement:1/stack:"fcs-3"}}
		#			{stream_ids ::ixNet::OBJ-/traffic/trafficItem:3/highLevelStream:1}
		#			{::ixNet::OBJ-/traffic/trafficItem:3/highLevelStream:1
		#				{{headers {::ixNet::OBJ-/traffic/trafficItem:3/highLevelStream:1/stack:"ethernet-1"
		#					::ixNet::OBJ-/traffic/trafficItem:3/highLevelStream:1/stack:"ipv4-2"
		#					::ixNet::OBJ-/traffic/trafficItem:3/highLevelStream:1/stack:"fcs-3"}
		#				}}
		#			}
		#			{endpoint_set_id 1}
		#			{encapsulation_name Ethernet.IPv4}}
		#	}}}}
		#}
		#{traffic_config TI0-HLTAPI_TRAFFICITEM_540}
		#{vport_protocols_handle {::ixNet::OBJ-/vport:1/protocols ::ixNet::OBJ-/vport:2/protocols}}
		#%
		#taketakeownership
		set vportListInConnectInfo [keylget connect_info vport_list]
		ixPuts "connect ixnetwork_tcl_server $ixn_tcl_server, just to get handle for the port_list $vportListInConnectInfo connected successfully last time "
	}

}

proc ixn_emulation_8021x_config { args } {
	######### parameter process start
	set argformat {
		{ portList		portList 		required string "portList,like 1/3/15 or like 1/3/15,1/3/16" }
		{ mac_address		mac_address 		required string "mac_address,like 0000.0000.0015" }
		{ mac_addr_increment	mac_addr_increment 	optional string "mac_addr_increment,like 0.0.0.0.0.1" }
		{ mac_addr_count	mac_addr_count		optional string "mac_addr_count,like 1 or 2 ..." }
		{ protocol		protocol		optional string "protocol,like TLS, PEAPv0, PEAPv1, MD5, TTLS, and FAST" }
		{ username		username		optional string "username,like ahATclchen or ${job.user}${job.sid}" }
		{ password		password		optional string "password,like ahATclchen or ${job.user}${job.sid}" }
		{ ca_path		ca_path			optional string "ca_path,it is windows path"}
		{ key_path		key_path		optional string "key_path,it is windows path"}
		{ mode			mode			optional string "mode,it is create or modify,default is create"}
		{ range_handle	range_handle	optional string "range_handle,like ::ixNet::OBJ-/vport:1/protocolStack/ethernetEndpoint:'2d097f72-536f-49a5-bd80-88f434ae2a1f'/range:'a7b1010e-64f4-47a7-9271-5b351664747d' " }
		{ zcallExample	zcallExample	optional string "ixn_emulation_8021x_config -portList 1/3/15 \
		-mac_address 0000.0000.0015 \
		-mac_addr_increment 0.0.0.0.0.1 \
		-mac_addr_count 2 \
		-mac_protocol MD5 \
		-username ahATclchen\
		-password ahATclchen \
		-ca_path c:/aaa \
		-key_path c:/aaa
		"
		}
	}
	# set optional parameter default value
	#set arg(ixn_tcl_server)	10.155.41.8

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	#puts "original args is $args"
	array set arg $args

	#get the parameter In
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

	#prapare dashArgListFinal
	set dashArgList ""
	foreach { key value } $argListFinal {
		lappend dashArgList "-$key $value"
	}
	set varTemp ""
	foreach { key value } $argListFinal {
		append varTemp "-$key $value "
	}
	#puts "dashArgList is $dashArgList"

	#this append varTemp way last is the space
	set varTemp [string trim $varTemp]
	puts "varTemp now is $varTemp"

	#this lappend list the result is the list
	set spaceList " "
	set dashArgListFinal [join $dashArgList $spaceList]
	#puts "dashArgListFinal is $dashArgListFinal"

	#prepare portList for portListItem
	set portList $arg(portList)
	set portList [split $portList ","]

	#function start
	foreach item $portList {
		puts "Item in portList is $item"
		#set emulation_8021x_config_exeinfo [::ixia::emulation_8021x_config [join [concat -port_handle $item $dashArgListFinal ] ] ]
		set emulation_8021x_config_exeinfo  [::ixia::emulation_8021x_config -port_handle $item $varTemp]
		#set emulation_8021x_config_exeinfo  [::ixia::emulation_dhcp_over_8021x_config -port_handle $item $varTemp]
		puts "emulation_8021x_config_exeinfo is $emulation_8021x_config_exeinfo"
	}

}
#set interface_status [::ixia::interface_config \
#		-port_handle     1/3/15        \
#		-intf_ip_addr    12.1.3.116     \
#		-gateway         12.1.3.254    \
#		-netmask         255.255.255.0 \
#	-vlan 1\
#	-vlan_id 2\
#	-vlan_tpid 0x88A8 \
#	-vlan_user_priority 5\
#		-src_mac_addr    0000.0005.0016 ]
proc ixn_interface_create { args } {
	######### parameter process start
	set argformat {
		{ portList	portList	required	string "portList,like 1/3/15 or like 1/3/15,1/3/16" }
		{ mac_src	mac_src		required	string "-mac_src,like 0000.0000.0011" }
		{ intf_ip_addr	intf_ip_addr	optional	string "intf_ip_addr,like 10.1.1.3" }
		{ gateway		gateway			optional	string "gateway,like 10.1.1.254" }
		{ netmask		netmask			optional	string "netmask,like 255.255.255.0" }
		{ vlan			vlan			optional	string "enable vlan use 1,disable vlan use 0" }
		{ vlan_id		vlan_id			optional	string "vlan_id,like 1 or 2...4094" }
		{ vlan_tpid		vlan_tpid		optional	string "vlan_tpid,like 0x88A8 0x8100 0x9100 0x9200" }
		{ vlan_user_priority	vlan_user_priority		optional	string "vlan_user_priority,like 0 or 1...7" }
		{ zcallExample	zcallExample	optional	string "ixn_interface_create -portList 1/3/15 -src_mac_addr 0000.0000.0011" }
	}
	# set optional parameter default value
	#set arg(ixn_tcl_server)	10.155.41.8

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	#puts "original args is $args"
	array set arg $args

	#get the parameter In
	parray arg
	set mac_src $arg(mac_src)

	#prepare argListFinal
	set varTemp [argStringConv [array get arg] portList]
	puts "varTemp is $varTemp"
	set varTemp2 [argStringConv $varTemp mac_src]
	puts "varTemp2 is $varTemp2"
	##set tmpList [array get arg]
	##set portListIdx [lsearch $tmpList portList*]
	##set portListBeforeIdx [ expr {$portListIdx-1} ]
	##set portListValueAfterIdx [ expr {$portListIdx+2} ]
	##set argList1 [lrange $tmpList  $portListValueAfterIdx end]
	###puts "argList1 is $argList1"
	##set argList2 [lrange $tmpList 0 $portListBeforeIdx]
	###puts "argList2 is $argList2"
	##set argListFinal [concat $argList1 $argList2]
	##puts "argListFinal is $argListFinal"
    ##
	###prapare dashArgListFinal
	##set dashArgList ""
	##foreach { key value } $argListFinal {
	##	lappend dashArgList "-$key $value"
	##}
	##set varTemp ""
	##foreach { key value } $argListFinal {
	##	append varTemp "-$key $value "
	##}
	###puts "dashArgList is $dashArgList"
	###this append varTemp way last is the space
	##set varTemp [string trim $varTemp]
	##puts "varTemp now is $varTemp"
    ##
	###this lappend list way the result is the list
	##set spaceList " "
	##set dashArgListFinal [join $dashArgList $spaceList]
	###puts "dashArgListFinal is $dashArgListFinal"
    ##
	
	#prepare portList for portListItem
	set portList $arg(portList)
	set portList [split $portList ","]

	#eval {set row} $row
	#function start
	foreach item $portList {
		global allIntfH
		puts "allIntfH start is $allIntfH"
		puts "Item in portList is $item"
		#set emulation_8021x_config_exeinfo [::ixia::emulation_8021x_config [join [concat -port_handle $item $dashArgListFinal ] ] ]
		#puts "::ixia::interface_config -port_handle $item -src_mac_addr $mac_src $varTemp2"
		set cmd "::ixia::interface_config -port_handle $item -src_mac_addr $mac_src $varTemp2"
		puts "cmd is $cmd"
		set interface_config_exeinfo  [ eval $cmd ]
		#::ixia::interface_config -port_handle $item -src_mac_addr $mac_src $varTemp2
		
		#puts "::ixia::interface_config -port_handle $item $varTemp"
		#set interface_config_exeinfo  [::ixia::interface_config -port_handle $item $varTemp]
		if { [keylget interface_config_exeinfo status] == $::SUCCESS } {
			set interface_handle [keylget interface_config_exeinfo interface_handle]
			puts "ixn_interface_create success"
			puts "port.$item.interface_handle.$mac_src=$interface_handle"
			set intfHkey "port.$item.interface_handle.$mac_src"
			#puts "intfHkey is $intfHkey"
			keylset allIntfH $intfHkey $interface_handle
			puts "interface_config_exeinfo is $interface_config_exeinfo"
		} else {
			puts "ixn_interface_create failed"
			puts "interface_config_exeinfo is $interface_config_exeinfo"
		}
		puts "allIntfH after is $allIntfH"
	}
}

proc ixn_interface_dhcp_config { args } {
	######### parameter process start
	set argformat {
		{ portList			portList			required	string "portList,like 1/3/15 or like 1/3/15,1/3/16" }
		{ interface_handle	interface_handle	optional	string "interface_handle,like ::ixNet::OBJ-/vport:1/interface:1" }
		{ enable			enable				required	string	"enable is like true or false" }
		{ zcallExample	zcallExample			optional	string "ixn_interface_dhcp_config -portList 1/3/15 -interface_handle ::ixNet::OBJ-/vport:1/interface:1 -enable true" }
	}
	# set optional parameter default value
	#set arg(ixn_tcl_server)	10.155.41.8

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	#puts "original args is $args"
	array set arg $args

	#get the parameter In
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

	#prapare dashArgListFinal
	set dashArgList ""
	foreach { key value } $argListFinal {
		lappend dashArgList "-$key $value"
	}
	set varTemp ""
	foreach { key value } $argListFinal {
		append varTemp "-$key $value "
	}
	#puts "dashArgList is $dashArgList"

	#this lappend list way the result is the list
	set spaceList " "
	set dashArgListFinal [join $dashArgList $spaceList]
	#puts "dashArgListFinal is $dashArgListFinal"

	#this append varTemp way last is the space
	set varTemp [string trim $varTemp]
	#puts "varTemp now is $varTemp"

	#prepare portList for portListItem
	set portList $arg(portList)
	set portList [split $portList ","]

	#function start
	foreach item $portList {
		puts "item in portList is $item"
		#::ixia::interface_dhcp_config -port_handle 1/3/15 -enable true -interface_handle ::ixNet::OBJ-/vport:1/interface:1

		set interface_dhcp_config_exeinfo  [::ixia::interface_dhcp_config -port_handle $item $varTemp]
		if { [keylget interface_dhcp_config_exeinfo status] == $::SUCCESS } {
			puts "interface_dhcp_config_exeinfo success on $item"
			puts "interface_dhcp_config_exeinfo is $interface_dhcp_config_exeinfo"
		} else {
			puts "interface_dhcp_config_exeinfo failed, port item is $item, rest parameter is $varTemp"
			puts "interface_dhcp_config_exeinfo is $interface_dhcp_config_exeinfo"
		}
	}
}

proc ixn_interface_dhcp_info { args } {
	######### parameter process start
	set argformat {
		{ portList			portList			required	string "portList,like 1/3/15 or like 1/3/15,1/3/16" }
		{ zcallExample	zcallExample			optional	string "ixn_interface_dhcp_info -portList 1/3/15 " }
	}
	# set optional parameter default value
	#set arg(ixn_tcl_server)	10.155.41.8

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	#puts "original args is $args"
	array set arg $args

	#get the parameter In
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
	#puts "argListFinal is $argListFinal"

	#prapare dashArgListFinal
	set dashArgList ""
	foreach { key value } $argListFinal {
		lappend dashArgList "-$key $value"
	}
	set varTemp ""
	foreach { key value } $argListFinal {
		append varTemp "-$key $value "
	}
	#puts "dashArgList is $dashArgList"

	#this lappend list way the result is the list
	set spaceList " "
	set dashArgListFinal [join $dashArgList $spaceList]
	#puts "dashArgListFinal is $dashArgListFinal"

	#this append varTemp way last is the space
	set varTemp [string trim $varTemp]
	puts "varTemp now is $varTemp"

	#prepare portList for portListItem
	set portList $arg(portList)
	set portList [split $portList ","]

	#function start
	foreach item $portList {
		puts "item in portList is $item"
		#::ixia::interface_dhcp_config -port_handle 1/3/15 -enable true -interface_handle ::ixNet::OBJ-/vport:1/interface:1
		set interface_dhcp_info_exeinfo  [::ixia::interface_dhcp_info2 -port_handle $item ]
		if { [keylget interface_dhcp_info_exeinfo status] == $::SUCCESS } {
			print_Report "ok on $item, result is $interface_dhcp_info_exeinfo" 0
		} else {
			print_Report "failed on $item, result is $interface_dhcp_info_exeinfo" 1
		}
	}
}

proc ixn_interface_ping_control { args } {
	######### parameter process start
	set argformat {
		{ intf_handleList	intf_handleList		required	string "interface_handleList,one like ::ixNet::OBJ-/vport:1/interface:1 two like ::ixNet::OBJ-/vport:1/interface:1,::ixNet::OBJ-/vport:1/interface:2" }
		{ destination_ip	destination_ip		required	string "destination_ip,like 172.16.130.254" }
		{ count				count				optional	string "count,ping send times,like 1 or 2 or 3...,dafult is 1" }
		{ interval			interval			optional	string "interval time,unit is millisecond,like 1000 or 2000,dafult is 1000." }
		{ zcallExample		zcallExample		optional	string "ixn_interface_ping_control -intf_handleList ::ixNet::OBJ-/vport:1/interface:1 \
			-destination_ip 172.16.130.254 \
			-count 4
			"
		}
	}
	# set optional parameter default value
		#set arg(ixn_tcl_server)	10.155.41.8
		set arg(count) 1
		set arg(interval) 1000

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	#puts "original args is $args"
	array set arg $args
	
	#get the parameter In
	parray arg

	#prepare argListFinal
	set tmpList [array get arg]
	set portListIdx [lsearch $tmpList intf_handle*]
	set portListBeforeIdx [ expr {$portListIdx-1} ]
	set portListValueAfterIdx [ expr {$portListIdx+2} ]
	set argList1 [lrange $tmpList  $portListValueAfterIdx end]
	#puts "argList1 is $argList1"
	set argList2 [lrange $tmpList 0 $portListBeforeIdx]
	#puts "argList2 is $argList2"
	set argListFinal [concat $argList1 $argList2]
	#puts "argListFinal is $argListFinal"
	
	#prapare dashArgListFinal
	set dashArgList ""
	foreach { key value } $argListFinal {
		lappend dashArgList "-$key $value"
	}
	set varTemp ""
	foreach { key value } $argListFinal {
			append varTemp "-$key $value "
		}
	#puts "dashArgList is $dashArgList"

	#this lappend list way the result is the list
	set spaceList " "
	set dashArgListFinal [join $dashArgList $spaceList]
	#puts "dashArgListFinal is $dashArgListFinal"
	
	#this append varTemp way last is the space
	set varTemp [string trim $varTemp]
	puts "varTemp now is $varTemp"
	
	#prepare portList for portListItem
	set intf_handleList $arg(intf_handleList)
	set intf_handleList [split $intf_handleList ","]
	
	#function start
	foreach item $intf_handleList {
		puts "item in interface_handleList is $item"
		#::ixia::interface_ping_control -interface_handle [keylget allIntfH port.1/2/5.interface_handle.0000.0000.0011] -destination_ip 172.16.130.254 -count 4
		set interface_ping_control_exeinfo  [::ixia::interface_ping_control -interface_handle $item $varTemp]
		if { [keylget interface_ping_control_exeinfo status] == $::SUCCESS } {
			print_Report "ok on $item, result is $interface_ping_control_exeinfo" 0
		} else {
			print_Report "failed on $item, result is $interface_ping_control_exeinfo" 1
		}
	}	
}

proc ixn_allprotocols_control { args } {
	######### parameter process start
	set argformat {
		{ action			action				required	string "action,like start or stop" }
		{ clearStatsEnable	clearStatsEnable	optional	string "clearStatsEnable,like enable or disable,default is disable" }
		{ zcallExample	zcallExample			optional	string "ixn_allprotocols_control -action start " }
	}
	# set optional parameter default value
		#set arg(ixn_tcl_server)	10.155.41.8

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	#puts "original args is $args"
	array set arg $args
	
	#get the parameter In
	parray arg
	
	#conv argstring to -option value style
	set varTemp [argStringConv [array get arg] action]
	#start
	set cmd "ah_allproto_control -action $arg(action) $varTemp"
	puts "cmd is $cmd"
	set ah_allproto_control_exeinfo  [ eval $cmd ]
	puts "ah_allproto_control_exeinfo is $ah_allproto_control_exeinfo"
	#ah_allproto_control -action $arg(action)
}

proc ixn_emulation_8021x_stats { args } {
	######### parameter process start
	set argformat {
		{ protocol		protocol			required	string "protocol,like md5 or tls or peap or ttls or fast" }
		{ zcallExample	zcallExample		optional	string "ixn_emulation_8021x_stats -protocol md5" }
	}
	# set optional parameter default value
	#set arg(ixn_tcl_server)	10.155.41.8

	# process the arguments
	if { [catch {ah_argparse $args $argformat} args] } {
		return -code error $args
	}
	# and insert them into the arg array.
	#puts "original args is $args"
	array set arg $args

	#get the parameter In
	parray arg

	#function start
	set ixn_emulation_8021x_stats_exeinfo  [::ixia::emulation_8021x_stats -protocol $arg(protocol)]
	if { [keylget ixn_emulation_8021x_stats_exeinfo status] == $::SUCCESS } {
		puts "ixn_emulation_8021x_stats_exeinfo ok, result is $ixn_emulation_8021x_stats_exeinfo"
	} else {
		puts "ixn_emulation_8021x_stats_exeinfo failed, result is $ixn_emulation_8021x_stats_exeinfo"
	}
}


#puts "source ahIxosapi.tcl end"
package provide ixia 1.0