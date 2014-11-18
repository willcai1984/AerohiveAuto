puts "ahSifos.tcl loaded"

#set ::tclserver 10.155.30.164
#set gTclserver 10.155.30.164

#sfs_connect proc:
#input tclserver host ip, port 6900
#example sfs_connect 10.155.31.27 6900
set s "global s for_conneted_socket"
proc sfs_connect {host port} {
	global s 
	set s [socket $host $port]
	fconfigure $s -buffering line
	return $s
}

#example cmd_sent "psa_config"
##proc cmd_sent { cmdString {socketH "NA"} {degbug "dbgoff"} } {
##	if { $degbug != "dbgoff" } {
##		puts "socketH is $socketH"
##	}
##	if { $socketH == "NA" } {
##		#puts "use the global s"
##		global s
##		set socketH $s
##		if { $degbug != "dbgoff" } {
##			puts "socketH now is $socketH"
##		}
##		
##		puts $socketH $cmdString
##		set resp [gets $socketH]
##		return $resp
##		
##	} else {
##		
##		if { $degbug != "dbgoff" } {
##			puts "socketH now is $socketH"
##		}
##		
##		puts $socketH $cmdString
##		set resp [gets $socketH]
##		return $resp
##	}
##}

#example cmd "psa_config" for much short character
proc cmd { cmdString {socketH "NA"} {degbug "dbgoff"} } {
	if { $degbug != "dbgoff" } {
		puts "socketH is $socketH"
	}
	if { $socketH == "NA" } {
		#puts "use the global s"
		global s
		set socketH $s
		if { $degbug != "dbgoff" } {
			puts "socketH now is $socketH"
		}
		
		puts $socketH $cmdString
		#flush the buffer
		flush $socketH
		set resp [gets $socketH]
		return $resp
		
	} else {
		
		if { $degbug != "dbgoff" } {
			puts "socketH now is $socketH"
		}
		
		puts $socketH $cmdString
		set resp [gets $socketH]
		return $resp
	}
}
#puts "source ahGlob.tcl end"
package provide ahsfs 1.0

