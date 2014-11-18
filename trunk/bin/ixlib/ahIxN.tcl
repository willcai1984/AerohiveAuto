#!/usr/bin/tclsh8.5
#namespace eval ahGlob {
#   tclserver 10.155.30.164
#}

puts "ahIxN.tcl Initialed"

namespace eval ::ixia {
	namespace export *

	proc GetStandardReturn {} {
		set result ""
		set status $::SUCCESS
		set log ""
		keylset result status $status
		keylset result log $log
		return $result
	}

	proc GetErrReturn { log } {
		set result ""
		set status $::FAILURE
		keylset result status $status
		keylset result log $log
		return $result
	}

	set Debug 0

	proc Deputs { value } {
		global Debug
		set timeVal  [ clock format [ clock seconds ] -format %T ]
		set clickVal [ clock clicks ]
		puts "\[<IXIA>TIME:$timeVal\]$value"
		#	   set logIO [open "log.txt" a+]
		#	   puts $logIO "\[<IXIA>TIME:$timeVal\]$value"
		#	   close $logIO
	}

	proc IxDebugOn { { log 0 } } {
		global Debug
		set Debug 1
	}

	proc IxDebugOff { } {
		global Debug
		set Debug 0
	}

	proc emulation_8021x_config_old {args} {
		set log ""
		set status $::SUCCESS
		set argsToString [join $args]
		puts "emulation_8021x_config argsToString is $argsToString"

		foreach { key value } $argsToString {
			set key [string tolower $key]
			switch -exact -- $key {
				-port_handle {
					set port_handle $value
				}
				-mac_address {
					#set mac_address1 0000.0000.0014
					#conver it to 00:00:00:00:00:14
					set mac_address1 $value
					set m [split $mac_address1 "."]
					set mLength [ expr { [llength $m]-1 } ]
					set convMac ""
					for { set i 0 } { $i <= $mLength } { incr i } {
						set str4Temp [lindex $m $i]
						append convMac [string range $str4Temp 0 1]
						append convMac ":"
						append convMac [string range $str4Temp 2 3]
						append convMac ":"
					}
					set convMac [string range $convMac 0 end-1 ]
					puts "convMac is $convMac"

					#set mac_address $value
					set mac_address $convMac
					#set mac_address $value
				}
				-mac_addr_increment {
					#set m2 0.0.0.0.0.2
					#conver it to 00:00:00:00:00:02
					set m2 $value
					set incrTemp [split $m2 "."]
					set m2Length [ expr { [llength $incrTemp]-1 } ]
					set convMacInc ""
					for { set i 0 } { $i <= $m2Length } { incr i } {
						set strDecTemp [lindex $incrTemp $i]
						if { [expr { [string length $strDecTemp] <= 1 } ] } {
							set temp $strDecTemp
							set aTemp "0$temp"
							append convMacInc $aTemp
							append convMacInc ":"
						} elseif { [expr { [string length $strDecTemp] == 2 } ] } {
							append convMacInc $strDecTemp
							append convMacInc ":"
						} else {
							puts "mac_addr_increment input is error"
						}
					}
					set convMacInc [string range $convMacInc 0 end-1 ]
					puts "convMacInc is $convMacInc"

					#set mac_addr_increment $value
					set mac_addr_increment $convMacInc
					#set mac_addr_increment $value
				}
				-mac_addr_count {
					set mac_addr_count $value
				}
				-mtu {
					set mtu $value
				}
				-protocol {
					set protocol $value
				}
				-username {
					set username $value
				}
				-password {
					set password $value
				}
				-ca_path {
					set ca_path $value
				}
				-key_path {
					set key_path $value
				}
				-default {
					set log "parameter unsupported...$key"
					set status $::FAILURE
				}

			}
		}

		if { [ info exists port_handle ] == 0 } {
			set status $::FAILURE
			set log "Madatory parameter port_handle needed."
		}

		if { [ catch {
					set targetCard [ lindex [ split $port_handle "/" ] 1 ]
					set targetPort [ lindex [ split $port_handle "/" ] 2 ]
					set findPort 0
					set root [ixNet getRoot]
					foreach hPort [ ixNet getL $root vport ] {

						set connectionInfo	[ ixNet getA $hPort -connectionInfo ]
						regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
						regexp {card=\"(\d+)\"} $connectionInfo match card
						regexp {port=\"(\d+)\"} $connectionInfo match port

						if { ( $card == $targetCard ) && ( $port == $targetPort ) } {
							set findPort 1
							set handle $hPort
							break
						}
					}

					if { [ llength [ixNet getL $hPort/protocolStack ethernetEndpoint] ] > 0 } {
						set sg_ethernet [ lindex [ixNet getL $hPort/protocolStack ethernetEndpoint] 0 ]
					} else {
						set sg_ethernet [ixNet add $hPort/protocolStack ethernetEndpoint]
						ixNet commit
						set sg_ethernet [ixNet remapIds $sg_ethernet]
					}

					if { [ llength [ixNet getL $sg_ethernet dot1x] ] > 0 } {
						set sg_dot1x [ lindex [ixNet getL $sg_ethernet dot1x] 0 ]
					} else {
						set sg_dot1x [ixNet add $sg_ethernet dot1x]
						ixNet commit
						set sg_dot1x [ixNet remapIds $sg_dot1x]
					}

					if { [ llength [ixNet getL $sg_ethernet range] ] > 0 } {
						set sg_range [ lindex [ixNet getL $sg_ethernet range] 0 ]
					} else {
						set sg_range [ixNet add $sg_ethernet range]
						ixNet commit
						set sg_range [ixNet remapIds $sg_range]
					}

					ixNet setMultiAttrs $sg_range/macRange \
						-enabled True

					ixNet setMultiAttrs $sg_range/vlanRange \
						-enabled False

					ixNet commit

					if {  [info exists mac_address] || [ info exists mtu] } {
						if { [info exists mac_addr_increment] == 0 } {
							set mac_addr_increment {00:00:00:00:00:01}
						}
						if { [info exists mac_addr_count] == 0 } {
							set mac_addr_count 1
						}
						if { [info exists mtu] == 0 } {
							set mtu 1500
						}
						ixNet setMultiAttrs $sg_range/macRange \
							-mac $mac_address   \
							-incrementBy $mac_addr_increment \
							-count $mac_addr_count    \
							-mtu $mtu

						ixNet commit

					}

					if { [ llength [ixNet getL $sg_range dot1xRange] ] > 0 } {
						set sg_dot1xRange [ lindex [ixNet getL $sg_range dot1xRange] 0 ]
					} else {
						set sg_dot1xRange [ixNet add $sg_range dot1xRange]
						ixNet commit
						set sg_dot1xRange [ixNet remapIds $sg_dot1xRange]
					}

					if { [ info exists protocol ] || [ info exists username ] || [ info exists password ]  } {
						if { [info exists protocol ]} {
							ixNet setA $sg_dot1xRange \
								-protocol $protocol
						}
						if { [info exists username] } {
							ixNet setA $sg_dot1xRange \
								-userName $username
						}
						if {[ info exists password ]} {
							ixNet setA $sg_dot1xRange \
								-userPassword $password
						}
						ixNet commit
					}

					if {  [ info exists ca_path ] || [ info exists key_path ]  } {
						if { [ llength [ixNet getL $root/globals/protocolStack dot1xGlobals] ] > 0 } {
							set sg_dot1xGlobal [ lindex [ixNet getL $root/globals/protocolStack dot1xGlobals] 0 ]
						} else {
							set sg_dot1xGlobal [ixNet add $root/globals/protocolStack dot1xGlobals]
							ixNet commit
							set sg_dot1xGlobal [ixNet remapIds $sg_dot1xGlobal]
						}
						if { [info exists ca_path] } {
							ixNet setA $sg_dot1xGlobal/certInfo \
								-certPath $ca_path
						}
						if { [info exists key_path] } {
							ixNet setA $sg_dot1xGlobal/certInfo \
								-keyPath $key_path
						}
						ixNet commit

					}
				}  err] } {
			return [ GetErrReturn $err]
		} else {
			set log "router_handle: $sg_ethernet"
			keylset result status $status
			keylset result log $log
			return $result

		}

	}

	proc emulation_8021x_config {args} {
		set log ""
		set status $::SUCCESS
		set argsToString [join $args]
		puts "emulation_8021x_config argsToString is $argsToString"

		foreach { key value } $argsToString {
			set key [string tolower $key]
			switch -exact -- $key {
				-port_handle {
					set port_handle $value
				}
				-mode {
					set mode $value
				}
				-range_handle {
					set range_handle $value
				}
				-mac_address {
					#set mac_address1 0000.0000.0014
					#conver it to 00:00:00:00:00:14
					set mac_address1 $value
					set m [split $mac_address1 "."]
					set mLength [ expr { [llength $m]-1 } ]
					set convMac ""
					for { set i 0 } { $i <= $mLength } { incr i } {
						set str4Temp [lindex $m $i]
						append convMac [string range $str4Temp 0 1]
						append convMac ":"
						append convMac [string range $str4Temp 2 3]
						append convMac ":"
					}
					set convMac [string range $convMac 0 end-1 ]
					puts "convMac is $convMac"

					#set mac_address $value
					set mac_address $convMac
					#set mac_address $value
				}
				-mac_addr_increment {
					#set m2 0.0.0.0.0.2
					#conver it to 00:00:00:00:00:02
					set m2 $value
					set incrTemp [split $m2 "."]
					set m2Length [ expr { [llength $incrTemp]-1 } ]
					set convMacInc ""
					for { set i 0 } { $i <= $m2Length } { incr i } {
						set strDecTemp [lindex $incrTemp $i]
						if { [expr { [string length $strDecTemp] <= 1 } ] } {
							set temp $strDecTemp
							set aTemp "0$temp"
							append convMacInc $aTemp
							append convMacInc ":"
						} elseif { [expr { [string length $strDecTemp] == 2 } ] } {
							append convMacInc $strDecTemp
							append convMacInc ":"
						} else {
							puts "mac_addr_increment input is error"
						}
					}
					set convMacInc [string range $convMacInc 0 end-1 ]
					puts "convMacInc is $convMacInc"

					#set mac_addr_increment $value
					set mac_addr_increment $convMacInc
					#set mac_addr_increment $value
				}
				-mac_addr_count {
					set mac_addr_count $value
				}
				-mtu {
					set mtu $value
				}
				-protocol {
					set protocol $value
				}
				-username {
					set username $value
				}
				-password {
					set password $value
				}
				-ca_path {
					set ca_path $value
				}
				-key_path {
					set key_path $value
				}
				-default {
					set log "parameter unsupported...$key"
					set status $::FAILURE
				}

			}
		}

		if { [ info exists port_handle ] == 0 } {
			set status $::FAILURE
			set log "Madatory parameter port_handle needed."
		}
		if { [info exists mode] == 0 } {
			set mode "create"
		}
		if { [ catch {
					set targetCard [ lindex [ split $port_handle "/" ] 1 ]
					set targetPort [ lindex [ split $port_handle "/" ] 2 ]
					set findPort 0
					set root [ixNet getRoot]
					foreach hPort [ ixNet getL $root vport ] {

						set connectionInfo	[ ixNet getA $hPort -connectionInfo ]
						regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
						regexp {card=\"(\d+)\"} $connectionInfo match card
						regexp {port=\"(\d+)\"} $connectionInfo match port

						if { ( $card == $targetCard ) && ( $port == $targetPort ) } {
							set findPort 1
							set handle $hPort
							break
						}
					}

					if { [ llength [ixNet getL $hPort/protocolStack ethernetEndpoint] ] > 0 } {
						set sg_ethernet [ lindex [ixNet getL $hPort/protocolStack ethernetEndpoint] 0 ]
					} else {
						set sg_ethernet [ixNet add $hPort/protocolStack ethernetEndpoint]
						ixNet commit
						set sg_ethernet [ixNet remapIds $sg_ethernet]
					}

					if { [ llength [ixNet getL $sg_ethernet dot1x] ] > 0 } {
						set sg_dot1x [ lindex [ixNet getL $sg_ethernet dot1x] 0 ]
					} else {
						set sg_dot1x [ixNet add $sg_ethernet dot1x]
						ixNet commit
						set sg_dot1x [ixNet remapIds $sg_dot1x]
					}

					# if { [ llength [ixNet getL $sg_ethernet range] ] > 0 } {
					# set sg_range [ lindex [ixNet getL $sg_ethernet range] 0 ]
					# } else {
					# set sg_range [ixNet add $sg_ethernet range]
					# ixNet commit
					# set sg_range [ixNet remapIds $sg_range]

					# }
					if { $mode == "create" } {
						set sg_range [ixNet add $sg_ethernet range]
						ixNet commit
						set sg_range [ixNet remapIds $sg_range]
						puts "range_handle.$mac_address1=$sg_range"
						set rgHandleMac "range_handle.$mac_address1"
						#set status $::SUCCESS
						#set log "create sg_range ok "
						#keylset result status $status
						#keylset result log $log
						keylset result range_handle $sg_range
						global rangeHandleL
						puts "rangeHandleL before is $rangeHandleL"
						keylset rangeHandleL $rgHandleMac $sg_range
						puts "rangeHandleL after is $rangeHandleL"
						#puts "ret temp is $result"
					} elseif { $mode == "modify" } {
						if {[info exists range_handle]} {
							set sg_range $range_handle
						} else {
							set status $::FAILURE
							set log "There is no range_handle,can not be modified"
							keylset result status $status
							keylset result log $log
							return $result
						}
					} else {
						set status $::FAILURE
						set log "The mode $mode is not valid,valid is create or modify"
						keylset result status $status
						keylset result log $log
						return $result
					}

					ixNet setMultiAttrs $sg_range/macRange \
						-enabled True

					ixNet setMultiAttrs $sg_range/vlanRange \
						-enabled False

					ixNet commit

					if {  [info exists mac_address] || [ info exists mtu] } {
						if { [info exists mac_addr_increment] == 0 } {
							set mac_addr_increment {00:00:00:00:00:01}
						}
						if { [info exists mac_addr_count] == 0 } {
							set mac_addr_count 1
						}
						if { [info exists mtu] == 0 } {
							set mtu 1500
						}
						ixNet setMultiAttrs $sg_range/macRange \
							-mac $mac_address   \
							-incrementBy $mac_addr_increment \
							-count $mac_addr_count    \
							-mtu $mtu

						ixNet commit

					}

					if { [ llength [ixNet getL $sg_range dot1xRange] ] > 0 } {
						set sg_dot1xRange [ lindex [ixNet getL $sg_range dot1xRange] 0 ]
					} else {
						set sg_dot1xRange [ixNet add $sg_range dot1xRange]
						ixNet commit
						set sg_dot1xRange [ixNet remapIds $sg_dot1xRange]
					}

					if { [ info exists protocol ] || [ info exists username ] || [ info exists password ]  } {
						if { [info exists protocol ]} {
							set einfo [ixNet setA $sg_dot1xRange \
								-protocol $protocol]
							puts "einfo is $einfo"
						}
						if { [info exists username] } {
							ixNet setA $sg_dot1xRange \
								-userName $username
						}
						if {[ info exists password ]} {
							ixNet setA $sg_dot1xRange \
								-userPassword $password
						}
						ixNet commit
					}

					if {  [ info exists ca_path ] || [ info exists key_path ]  } {
						if { [ llength [ixNet getL $root/globals/protocolStack dot1xGlobals] ] > 0 } {
							set sg_dot1xGlobal [ lindex [ixNet getL $root/globals/protocolStack dot1xGlobals] 0 ]
						} else {
							set sg_dot1xGlobal [ixNet add $root/globals/protocolStack dot1xGlobals]
							ixNet commit
							set sg_dot1xGlobal [ixNet remapIds $sg_dot1xGlobal]
						}
						if { [info exists ca_path] } {
							ixNet setA $sg_dot1xGlobal/certInfo \
								-certPath $ca_path
						}
						if { [info exists key_path] } {
							ixNet setA $sg_dot1xGlobal/certInfo \
								-keyPath $key_path
						}
						ixNet commit

					}
				}  err] } {
			return [ GetErrReturn $err]
		} else {
			set log "router_handle: $sg_ethernet"
			keylset result status $status
			keylset result log $log
			return $result

		}

	}

	proc emulation_dhcp_over_8021x_config {args} {
		#puts "now is in emulation_8021x_config, the args is $args"
		set argsToString [join $args]
		puts "now argsToString is $argsToString"
		set log ""
		set status $::SUCCESS

		foreach { key value } $argsToString {
			#puts "\n key is $key,and \n value is $value"
			set key [string tolower $key]
			switch -exact -- $key {
				-port_handle {
					set port_handle $value
				}
				-mac_address {
					#set mac_address1 0000.0000.0014
					#conver it to 00:00:00:00:00:14
					set mac_address1 $value
					set m [split $mac_address1 "."]
					set mLength [ expr { [llength $m]-1 } ]
					set convMac ""
					for { set i 0 } { $i <= $mLength } { incr i } {
						set str4Temp [lindex $m $i]
						append convMac [string range $str4Temp 0 1]
						append convMac ":"
						append convMac [string range $str4Temp 2 3]
						append convMac ":"
					}
					set convMac [string range $convMac 0 end-1 ]
					puts "convMac is $convMac"

					#set mac_address $value
					set mac_address $convMac
				}
				-mac_addr_increment {
					#set m2 0.0.0.0.0.2
					#conver it to 00:00:00:00:00:02
					set m2 $value
					set incrTemp [split $m2 "."]
					set m2Length [ expr { [llength $incrTemp]-1 } ]
					set convMacInc ""
					for { set i 0 } { $i <= $m2Length } { incr i } {
						set strDecTemp [lindex $incrTemp $i]
						if { [expr { [string length $strDecTemp] <= 1 } ] } {
							set temp $strDecTemp
							set aTemp "0$temp"
							append convMacInc $aTemp
							append convMacInc ":"
						} elseif { [expr { [string length $strDecTemp] == 2 } ] } {
							append convMacInc $strDecTemp
							append convMacInc ":"
						} else {
							puts "mac_addr_increment input is error"
						}
					}
					set convMacInc [string range $convMacInc 0 end-1 ]
					puts "convMacInc is $convMacInc"

					#set mac_addr_increment $value
					set mac_addr_increment $convMacInc
				}
				-mac_addr_count {
					set mac_addr_count $value
				}
				-mtu {
					set mtu $value
				}
				-protocol {
					set protocol $value
				}
				-username {
					set username $value
				}
				-password {
					set password $value
				}
				-ca_path {
					set ca_path $value
					#puts "ca_path is $ca_path"
				}
				-key_path {
					set key_path $value
					#puts "key_path is $key_path"
				}
				-default {
					set log "parameter unsupported...$key"
					set status $::FAILURE
				}

			}
		}

		if { [ info exists port_handle ] == 0 } {
			set status $::FAILURE
			set log "Madatory parameter port_handle needed."
		}

		if { [ catch {
					set targetCard [ lindex [ split $port_handle "/" ] 1 ]
					set targetPort [ lindex [ split $port_handle "/" ] 2 ]
					set findPort 0
					set root [ixNet getRoot]
					foreach hPort [ ixNet getL $root vport ] {

						set connectionInfo	[ ixNet getA $hPort -connectionInfo ]
						regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
						regexp {card=\"(\d+)\"} $connectionInfo match card
						regexp {port=\"(\d+)\"} $connectionInfo match port

						if { ( $card == $targetCard ) && ( $port == $targetPort ) } {
							set findPort 1
							set handle $hPort
							break
						}
					}

					if { [ llength [ixNet getL $hPort/protocolStack ethernet] ] > 0 } {
						set sg_ethernet [ lindex [ixNet getL $hPort/protocolStack ethernet] 0 ]
					} else {
						set sg_ethernet [ixNet add $hPort/protocolStack ethernet]
						ixNet commit
						set sg_ethernet [ixNet remapIds $sg_ethernet]
					}

					if { [ llength [ixNet getL $sg_ethernet dhcpEndpoint] ] > 0 } {
						set sg_dhcpEndpoint [ lindex [ixNet getL $sg_ethernet dhcpEndpoint] 0 ]
					} else {
						set sg_dhcpEndpoint [ixNet add $sg_ethernet dhcpEndpoint]
						ixNet commit
						set sg_dhcpEndpoint [ixNet remapIds $sg_dhcpEndpoint]
					}

					if { [ llength [ixNet getL $sg_dhcpEndpoint range] ] > 0 } {
						set sg_range [ lindex [ixNet getL $sg_dhcpEndpoint range] 0 ]
					} else {
						set sg_range [ixNet add $sg_dhcpEndpoint range]
						ixNet commit
						set sg_range [ixNet remapIds $sg_range]
					}

					ixNet setMultiAttrs $sg_range/macRange \
						-enabled True

					ixNet setMultiAttrs $sg_range/vlanRange \
						-enabled False \

					ixNet commit

					if {  [info exists mac_address] || [ info exists mtu] } {
						if { [info exists mac_addr_increment] == 0 } {
							set mac_addr_increment {00:00:00:00:00:01}
						}
						if { [info exists mac_addr_count] == 0 } {
							set mac_addr_count 1
						}
						if { [info exists mtu] == 0 } {
							set mtu 1500
						}
						ixNet setMultiAttrs $sg_range/macRange \
							-mac $mac_address   \
							-incrementBy $mac_addr_increment \
							-count $mac_addr_count    \
							-mtu $mtu

						ixNet commit

					}

					if { [ llength [ixNet getL $sg_range dot1xRange] ] > 0 } {
						set sg_dot1xRange [ lindex [ixNet getL $sg_range dot1xRange] 0 ]
					} else {
						set sg_dot1xRange [ixNet add $sg_range dot1xRange]
						ixNet commit
						set sg_dot1xRange [ixNet remapIds $sg_dot1xRange]
					}

					if { [ info exists protocol ] || [ info exists username ] || [ info exists password ]  } {
						if { [info exists protocol ]} {
							ixNet setA $sg_dot1xRange \
								-protocol $protocol
						}
						if { [info exists username] } {
							ixNet setA $sg_dot1xRange \
								-userName $username
						}
						if {[ info exists password ]} {
							ixNet setA $sg_dot1xRange \
								-userPassword $password
						}
						ixNet commit
					}

					if {  [ info exists ca_path ] || [ info exists key_path ]  } {
						if { [ llength [ixNet getL $root/globals/protocolStack dot1xGlobals] ] > 0 } {
							set sg_dot1xGlobal [ lindex [ixNet getL $root/globals/protocolStack dot1xGlobals] 0 ]
						} else {
							set sg_dot1xGlobal [ixNet add $root/globals/protocolStack dot1xGlobals]
							ixNet commit
							set sg_dot1xGlobal [ixNet remapIds $sg_dot1xGlobal]
						}
						if { [info exists ca_path] } {
							puts "info exists ca_path"
							if { [ catch { ixNet setA $sg_dot1xGlobal/certInfo \
											-certPath $ca_path } exeInfo ] } {
								puts "exeInfo certPath is $exeInfo"
							} else {
								puts "exeInfo certPath is $exeInfo"
							}
						}
						if { [info exists key_path] } {
							puts "info exists key_path"
							if { [ catch { ixNet setA $sg_dot1xGlobal/certInfo \
											-keyPath $key_path } exeInfo2 ] } {
								puts "exeInfo key_path is $exeInfo2"
							} else {
								puts "exeInfo key_path is $exeInfo2"
							}
						}
						ixNet commit

					}
				}  err] } {
			return [ GetErrReturn $err]
		} else {
			return [ GetStandardReturn ]
		}

	}

	proc emulation_8021x_stats { args } {
		set log ""
		set status $::SUCCESS
		set argsToString [join $args]
		puts "now argsToString is $argsToString"
		foreach { key value } $argsToString {
			set key [string tolower $key]
			switch -exact -- $key {
				-protocol {
					set protocol $value
				}

			}
		}
		# {::ixNet::OBJ-/statistics/view:"Port Statistics"}
		# {::ixNet::OBJ-/statistics/view:"Tx-Rx Frame Rate Statistics"}
		# {::ixNet::OBJ-/statistics/view:"Port CPU Statistics"}
		# {::ixNet::OBJ-/statistics/view:"Global Protocol Statistics"}
		# {::ixNet::OBJ-/statistics/view:"Protocol Summary"}
		# ::ixNet::OBJ-/statistics/view:"802.1x"
		# {::ixNet::OBJ-/statistics/view:"802.1x - All Ports"}
		# {::ixNet::OBJ-/statistics/view:"802.1x EAP Frame Statistics"}
		# {::ixNet::OBJ-/statistics/view:"802.1x EAP Frame Statistics - All Ports"}
		# {::ixNet::OBJ-/statistics/view:"802.1x MD5 Authentication Statistics"}
		# {::ixNet::OBJ-/statistics/view:"802.1x TLS Authentication Statistics"}
		# {::ixNet::OBJ-/statistics/view:"802.1x PEAP Authentication Statistics"}
		# {::ixNet::OBJ-/statistics/view:"802.1x TTLS Authentication Statistics"}
		# {::ixNet::OBJ-/statistics/view:"802.1x FAST Authentication Statistics"}
		# {::ixNet::OBJ-/statistics/view:"802.1x Machine Authentication Statistics"}
		# {::ixNet::OBJ-/statistics/view:"802.1x NAC Statistics"}
		# ::ixNet::OBJ-/statistics/view:"DHCPv4"
		# {::ixNet::OBJ-/statistics/view:"DHCPv4 - All Ports"}

		# if { [ info exists handle ] == 0 } {
		# set status $::FAILURE
		# set log "Madatory parameter handle needed."
		# }

		set root [ixNet getRoot]
		set protocol [string tolower $protocol]
		switch -exact -- $protocol {
			md5 {
				set view [lindex [ ixNet getF $root/statistics view -caption "802.1x MD5 Authentication Statistics" ] 0]
			}
			tls {
				set view [lindex [ ixNet getF $root/statistics view -caption "802.1x TLS Authentication Statistics" ] 0]
			}
			peap {
				set view [lindex [ ixNet getF $root/statistics view -caption "802.1x PEAP Authentication Statistics"] 0]
			}
			ttls {
				set view [lindex [ ixNet getF $root/statistics view -caption "802.1x TTLS Authentication Statistics"] 0]
			}
			fast {
				set view [lindex [ixNet getF $root/statistics view -caption "802.1x FAST Authentication Statistics" ] 0]
			}

		}

		set captionList   [ ixNet getA $view/page -columnCaptions ]
		#{Stat Name} {MD5 Sessions} {MD5 Success} {MD5 Timeout Failed} {MD5 EAP Failed} {MD5 Max Latency [ms]} {MD5 Min Latency [ms]} {MD5 Avg Latency [ms]}
		set success_index       [ lsearch -glob $captionList *Success ]
		set failed_index        [ lsearch -glob $captionList *EAP\ Failed ]
		set stats [ ixNet getA $view/page -rowValues ]

		set ret ""

		foreach row $stats {
			eval {set row} $row
			set statsItem   [ lindex $captionList 0 ]
			set statsVal    [ lindex $row 0 ]

			keylset ret $statsItem    $statsVal

			set statsItem   [ lindex $captionList $success_index ]
			set statsVal    [ lindex $row $success_index ]
			keylset ret $statsItem    $statsVal
			set statsItem   [ lindex $captionList $failed_index  ]
			set statsVal    [ lindex $row $failed_index  ]
			keylset ret $statsItem    $statsVal
		}

		keylset result status $status
		keylset result log $ret
		return $result

	}

	proc interface_dhcp_config { args } {
		#puts "b"
		set log ""
		set status $::SUCCESS
		set argsToString [join $args]
		puts "now argsToString is $argsToString"

		foreach { key value } $argsToString {
			set key [string tolower $key]
			switch -exact -- $key {
				-port_handle {
					set port_handle $value
				}
				-interface_handle {
					set interface_handle $value
				}
				-enable {
					set enable $value
				}

			}

		}

		if { [ catch {
					set targetCard [ lindex [ split $port_handle "/" ] 1 ]
					set targetPort [ lindex [ split $port_handle "/" ] 2 ]
					set findPort 0
					set root [ixNet getRoot]
					foreach hPort [ ixNet getL $root vport ] {

						set connectionInfo	[ ixNet getA $hPort -connectionInfo ]
						regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
						regexp {card=\"(\d+)\"} $connectionInfo match card
						regexp {port=\"(\d+)\"} $connectionInfo match port

						if { ( $card == $targetCard ) && ( $port == $targetPort ) } {
							set findPort 1
							set handle $hPort
							break
						}
					}

					if { [info exists interface_handle]} {
						ixNet setA $interface_handle -enabled True
						ixNet setA $interface_handle/dhcpV4Properties \
							-enabled $enable
						ixNet commit

					} else {
						set intLen [ llength [ ixNet getList $handle interface ] ]

						if { $intLen == 0 } {
							set newInt  [ ixNet add $handle interface ]
							ixNet setA $newInt -enabled True
							ixNet setA $newInt/dhcpV4Properties \
								-enabled $enable
							ixNet commit
						} else {
							set interface [ ixNet getList $handle interface ]
							foreach int $interface {
								ixNet setA $int -enabled True
								ixNet setA $int/dhcpV4Properties \
									-enabled $enable
								ixNet commit
							}

						}
					}
				}  err] } {
			return [ GetErrReturn $err]
		} else {
			return [ GetStandardReturn ]
		}

	}

	proc interface_dhcp_info_old { args } {
		set log ""
		set status $::SUCCESS
		set argsToString [join $args]
		puts "now argsToString is $argsToString"

		foreach { key value } $argsToString {
			set key [string tolower $key]
			switch -exact -- $key {
				-port_handle {
					set port_handle $value
				}
			}

		}
		if { [catch {
					set root [ixNet getRoot]
					set view [lindex [ ixNet getF $root/statistics view -caption "DHCPv4"] 0]

					set captionList   [ ixNet getA $view/page -columnCaptions ]

					set success_index        [ lsearch -glob $captionList {Sessions Succeeded} ]
					set failed_index         [ lsearch -glob $captionList {Sessions Failed} ]

					set stats [ ixNet getA $view/page -rowValues ]

					set ret ""

					foreach row $stats {
						eval {set row} $row
						set statsItem   [ lindex $captionList 0 ]
						set statsVal    [ lindex $row 0 ]

						keylset ret $statsItem    $statsVal

						set statsItem   [ lindex $captionList $success_index ]
						set statsVal    [ lindex $row $success_index ]
						keylset ret $statsItem    $statsVal
						set statsItem   [ lindex $captionList $failed_index  ]
						set statsVal    [ lindex $row $failed_index  ]
						keylset ret $statsItem    $statsVal
					}
				} err] } {
			set status $::FAILURE
			set ret $err
		}

		if { [catch {
					set interface_address ""
					set targetCard [ lindex [ split $port_handle "/" ] 1 ]
					set targetPort [ lindex [ split $port_handle "/" ] 2 ]
					set findPort 0
					set root [ixNet getRoot]
					foreach hPort [ ixNet getL $root vport ] {

						set connectionInfo	[ ixNet getA $hPort -connectionInfo ]
						regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
						regexp {card=\"(\d+)\"} $connectionInfo match card
						regexp {port=\"(\d+)\"} $connectionInfo match port

						if { ( $card == $targetCard ) && ( $port == $targetPort ) } {
							set findPort 1
							set handle $hPort
							break
						}
					}

					if {[ixNet getL $handle interfaceDiscoveredAddress] == ""} {
						set interface_address ""
					} else {
						set discinf [ixNet getL $handle interfaceDiscoveredAddress]
						foreach inf $discinf {
							set description   [ixNet getA $inf -description  ]
							set ipaddr    [ ixNet getA $inf -ipAddress  ]
							keylset interface_address $description   $ipaddr

						}

					}
				} err ]} {
			set status $::FAILURE
			set interface_address $err

		}

		keylset result status $status
		keylset result log $ret
		keylset result inf_addr $interface_address
		return $result

	}

	proc interface_dhcp_info2 { args } {
		set log ""
		set status $::SUCCESS
		set argsToString [join $args]
		puts "now argsToString is $argsToString"

		foreach { key value } $argsToString {
			set key [string tolower $key]
			switch -exact -- $key {
				-port_handle {
					set port_handle $value
				}
				-interface_handle {
					set interface_handle $value
				}
			}

		}
		if { [catch {
					set root [ixNet getRoot]
					set view [lindex [ ixNet getF $root/statistics view -caption "DHCPv4"] 0]
					puts "view is $view"
					set captionList   [ ixNet getA $view/page -columnCaptions ]
					puts "captionList is $captionList"
					set success_index        [ lsearch -glob $captionList {Sessions Succeeded} ]
					set failed_index         [ lsearch -glob $captionList {Sessions Failed} ]
					puts "success_index is $success_index, failed_index is $failed_index"
					set stats [ ixNet getA $view/page -rowValues ]
					puts "stats is $stats"
					set ret ""

					foreach row $stats {
						eval {set row} $row
						set statsItem   [ lindex $captionList 0 ]
						set statsVal    [ lindex $row 0 ]
						puts "statsItem1 is $statsItem, statsVal1 is $statsVal"
						keylset ret $statsItem    $statsVal
						puts "statsItem1 after"
						set statsItem   [ lindex $captionList $success_index ]
						set statsVal    [ lindex $row $success_index ]
						puts "statsItem2 is $statsItem, statsVal2 is $statsVal"
						keylset ret $statsItem    $statsVal
						puts "statsItem2 after"
						set statsItem   [ lindex $captionList $failed_index  ]
						set statsVal    [ lindex $row $failed_index  ]
						puts "statsItem3 is $statsItem, statsVal3 is $statsVal"
						keylset ret $statsItem    $statsVal
						puts "statsItem3 after"
					}
				} err] } {
			print_Report "foreach row stats set statsItem statsVal failed, err is $err" 1
			set status $::FAILURE
			set ret $err
		}

		if { [catch {
					set interface_address ""
					set targetCard [ lindex [ split $port_handle "/" ] 1 ]
					set targetPort [ lindex [ split $port_handle "/" ] 2 ]
					set findPort 0
					set root [ixNet getRoot]
					foreach hPort [ ixNet getL $root vport ] {

						set connectionInfo	[ ixNet getA $hPort -connectionInfo ]
						regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
						regexp {card=\"(\d+)\"} $connectionInfo match card
						regexp {port=\"(\d+)\"} $connectionInfo match port

						if { ( $card == $targetCard ) && ( $port == $targetPort ) } {
							set findPort 1
							set handle $hPort
							break
						}
					}
					puts "handle is $handle"
					if {[ixNet getL $handle interfaceDiscoveredAddress] == ""} {
						set interface_address ""
					} else {
						set discinf [ixNet getL $handle interfaceDiscoveredAddress]
						puts "discinf is $discinf"
						foreach inf $discinf {
							set description   [ixNet getA $inf -description  ]
							set ipaddr    [ ixNet getA $inf -ipAddress  ]
							puts "description is $description"
							puts "ipaddr is $ipaddr"
							keylset interface_address $description   $ipaddr

							#process by clchen futher
							set descriConved [intf_descr_mac_conv $description "-" " " "."]
							set descriConvedAddip "$descriConved.ip"
							puts "descriConvedAddip is $descriConvedAddip"

							keylset interface_address $descriConvedAddip $ipaddr
							puts "$descriConvedAddip=$ipaddr"
							global allIntfIpH
							puts "allIntfIpH bef is $allIntfIpH"
							keylset allIntfIpH $descriConvedAddip $ipaddr
							puts "allIntfIpH aft is $allIntfIpH"
						}

					}
					puts "interface_address last is $interface_address"
				} err ]} {
			print_Report "foreach inf discinf failed, err is $err" 1
			set status $::FAILURE
			set interface_address $err

		}

		keylset result status $status
		keylset result log $ret
		keylset result inf_addr $interface_address
		return $result

	}

	proc interface_ping_control { args } {
		set argsToString [join $args]
		puts "now argsToString is $argsToString"
		set count 		1
		set interval 	1000

		foreach { key value } $argsToString {
			set key [string tolower $key]
			switch -exact -- $key {
				-interface_handle {
					set interface_handle $value
				}
				-destination_ip {
					if { [ IsIPv4Address $value ] } {
						set destination_ip $value
					} else {
						error "$errNumber(1) key:$key value:$value"
					}
				}
				-count {
					if { [ string is integer $value ] } {
						set count $value
					} else {
						error "$errNumber(1) key:$key value:$value"
					}
				}
				-interval {
					if { [ string is integer $value ] } {
						set interval    $value

					} else {
						error "$errNumber(1) key:$key value:$value"
					}
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}

		set pingTrue	0
		set pingFalse	0

		set pingResult [ list ]
		for { set index 0 } { $index < $count } { incr index } {

			foreach int $interface_handle {
				#% ixNet getA ::ixNet::OBJ-/vport:1/interface:1 -description
				#1/3/15 - 00 00 00 00 00 11 - 1
				#% 
				#description
				set intfdesc [ixNet getA $int -description]
				set intfdesc_conved [intf_descr_mac_conv $intfdesc "-" " " "."]
				#intfdesc_conved like 1/3/15.0000.0000.0011
				lappend pingResult [ ixNet exec sendPing $int $destination_ip ]
				puts "from interface_handle $int $intfdesc_conved to $destination_ip pingResultItem is $pingResult"
			}

			after $interval
		}

		set pingPass	0
		foreach result $pingResult {
			if { [ regexp {failed} $result ] } {
				incr pingFalse
				set pingPass 0
			} else {
				incr pingTrue
				set pingPass 1
			}
		}

		if { $pingPass } {
			return [ GetStandardReturn ]
		} else {
			set err " pingpass:$pingTrue ;pingfaile: $pingFalse"
			return [ GetErrReturn $err]
		}

	}

	proc IsIPv4Address { value } {

		if { [ regexp -nocase {(\d+)\.(\d+)\.(\d+)\.(\d+)} $value ip a b c d ] } {

			if { ( $a > 255 ) || ( $b > 255 ) || ( $c > 255 ) || ( $d > 255 ) } {
				return 0
			}
			return 1
		} else {

			return 0
		}
	}

}

#ah_allproto_control -action start
#ah_allproto_control -action stop
proc ah_allproto_control { args } {
	set argsToString [join $args]
	puts "now argsToString is $argsToString"

	foreach { key value } $argsToString {
		set key [string tolower $key]
		puts "key is $key"
		puts "vaule is $value"
		switch -exact -- $key {
			-action {
				set action $value
			}
			-clearstatsenable {
				set clearstatsenable $value
				puts "clearstatsenable recv is $clearstatsenable"
			}
			default {
				set log "parameter unsupported...$key"
				set status $::FAILURE
			}
		}
	}
	if { [ info exists clearstatsenable ] == 0 } {
		set clearstatsenable "disable"
	}
	if { [ expr { $clearstatsenable == "enable" } ] }  {
		set exeClearInfo [ixNet exec clearStats]
		after 1000
		puts "exeClearInfo is $exeClearInfo"
	} elseif { [ expr { $clearstatsenable == "disable" } ] } {
		puts "clearstatsenable is $clearstatsenable"
	} else {
		puts "clearstatsenable valid value is enable or disable"
	}
	
	#start or stop function begin
	if { [ expr { $action == "start" } ] }  {
		set exeinfo [ixNet exec startAllProtocols]
		print_Report "exeinfo is $exeinfo" 0
	} elseif { [ expr { $action == "stop" } ] } {
		set exeinfo [ixNet exec stopAllProtocols]
		print_Report "exeinfo is $exeinfo" 0
	} else {
		print_Report "action input with $action is not valid" 1
	}

}

package provide ixia 1.0