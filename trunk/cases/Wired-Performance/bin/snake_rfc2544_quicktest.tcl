# output file: D:\QuickTest\SnakeTest_default.tcl
# IxNetwork version: 6.30.709.62
# time of scriptgen: 2013/6/17, 10:55

# IxNServer and IxNPort variables are used for Composer script gen and for connect statement
# Change the values of these variables to meet your environment's requirements
package require ixia
package require cmdline

set param {
    {name.arg "" "specify a name for the test"}
    {chassis.arg "" "specify chassis to connect"}
    {tclServer.arg "" "specify tcl server to use"}
    {tclPort.arg "" "specify port to connect tcl server"}
    {txPort.arg "" "specify tx ixia port"}
    {rxPort.arg "" "specify rx ixia port"}
    {frameSizeList.arg "" "specify custom framesize list"}
    {trials.arg "" "specify trials"}
    {duration.arg "" "specify duration"}
    {initialRate.arg "" "specify initial rate in binary interation mode"}
    {minRate.arg "" "specify minimal rate"}
    {maxRate.arg "" "specify maximal rate"}
    {resolution.arg "" "specify resolution"}
    {tolerance.arg "" "specify tolerance"}
    {srcIP.arg "" "specify source ip address"}
    {srcGateway.arg "" "specify gateway ip for source"}
    {dstIP.arg "" "specify destination ip address"}
    {dstGateway.arg "" "specify gateway ip for destination"}
    {L4Protocol.arg "" "specify type of L4Protocol, none or udp"}
    {BiDirectional.arg "" "specify type of traffic, True or False"}
}
array set arg [cmdline::getoptions argv $param]
parray arg

set chassis $arg(chassis)
set tmp [split $arg(txPort) "/"]
set txport "[lindex $tmp 1]:[lindex $tmp 2]"
set tmp [split $arg(rxPort) "/"]
set rxport "[lindex $tmp 1]:[lindex $tmp 2]"
set ::IxNserver $arg(tclServer)
set ::IxNport   $arg(tclPort)

set txport_conf [list ixia_port $txport \
                      eui64Id "02 D0 B0 FF FE 11 01 00" \
                      mac "00:d0:b0:11:01:00" \
                      gateway $arg(srcGateway) \
                      ip $arg(srcIP)]
set rxport_conf [list ixia_port $rxport \
                      eui64Id "02 D0 B0 FF FE 11 02 00" \
                      mac "00:d0:b0:11:02:00" \
                      gateway $arg(dstGateway) \
                      ip $arg(dstIP)]
set tx_vport {}
set rx_vport {}
set tx_interface {}
set rx_interface {}
set sg_trafficItem {}
set sg_rfc2544throughput {}

set t_list [list \
"ethernet.fcs-1" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ethernet.header.destinationAddress-1" [list "{00:00:00:00:00:00}" "True" "{{00:00:00:00:00:00}}" "{00:00:00:00:00:00}" "True" "{00:00:00:00:00:00}" "{00:00:00:00:00:00}" "{00:00:00:00:00:00}" "False" "{00:00:00:00:00:00}"] \
"ethernet.header.etherType-3" [list "{800}" "True" "{{0xFFFF}}" "{0xFFFF}" "False" "{0xFFFF}" "{800}" "{0xFFFF}" "False" "{0xFFFF}"] \
"ethernet.header.pfcQueue-4" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ethernet.header.sourceAddress-2" [list "{00:00:00:00:00:00}" "True" "{{00:00:00:00:00:00}}" "{00:00:00:00:00:00}" "False" "{00:00:00:00:00:00}" "{00:00:00:00:00:00}" "{00:00:00:00:00:00}" "False" "{00:00:00:00:00:00}"] \
"ipv4.header.checksum-26" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.dstIp-28" [list "{0.0.0.0}" "True" "{{0.0.0.0}}" "{0.0.0.0}" "False" "{0.0.0.0}" "{0.0.0.0}" "{0.0.0.0}" "False" "{0.0.0.0}"] \
"ipv4.header.flags.fragment-21" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{May fragment}" "{0}" "False" "{0}"] \
"ipv4.header.flags.lastFragment-22" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{Last fragment}" "{0}" "False" "{0}"] \
"ipv4.header.flags.reserved-20" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.fragmentOffset-23" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.headerLength-2" [list "{5}" "True" "{{0}}" "{0}" "False" "{0}" "{5}" "{0}" "False" "{0}"] \
"ipv4.header.identification-19" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.last-54" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.lsrr.length-37" [list "{8}" "False" "{{8}}" "{8}" "False" "{8}" "{8}" "{8}" "False" "{8}"] \
"ipv4.header.options.nextOption.option.lsrr.type-36" [list "{131}" "False" "{{131}}" "{131}" "False" "{131}" "{131}" "{131}" "False" "{131}"] \
"ipv4.header.options.nextOption.option.nop-29" [list "{1}" "False" "{{1}}" "{1}" "False" "{1}" "{1}" "{1}" "True" "{1}"] \
"ipv4.header.options.nextOption.option.pointer-38" [list "{4}" "False" "{{4}}" "{4}" "False" "{4}" "{4}" "{4}" "False" "{4}"] \
"ipv4.header.options.nextOption.option.recordRoute.length-43" [list "{8}" "False" "{{8}}" "{8}" "False" "{8}" "{8}" "{8}" "False" "{8}"] \
"ipv4.header.options.nextOption.option.recordRoute.type-42" [list "{7}" "False" "{{7}}" "{7}" "False" "{7}" "{7}" "{7}" "False" "{7}"] \
"ipv4.header.options.nextOption.option.routeData-39" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.routerAlert.length-56" [list "{4}" "False" "{{0x04}}" "{0x04}" "False" "{0x04}" "{4}" "{0x04}" "False" "{0x04}"] \
"ipv4.header.options.nextOption.option.routerAlert.type-55" [list "{94}" "False" "{{0x94}}" "{0x94}" "False" "{0x94}" "{94}" "{0x94}" "False" "{0x94}"] \
"ipv4.header.options.nextOption.option.routerAlert.value-57" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{Router shall examine packet}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.security.compartments-33" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.security.handling-34" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.security.length-31" [list "{11}" "False" "{{11}}" "{11}" "False" "{11}" "{11}" "{11}" "False" "{11}"] \
"ipv4.header.options.nextOption.option.security.security-32" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{Unclassified}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.security.tcc-35" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.security.type-30" [list "{130}" "False" "{{130}}" "{130}" "False" "{130}" "{130}" "{130}" "False" "{130}"] \
"ipv4.header.options.nextOption.option.ssrr.length-41" [list "{8}" "False" "{{8}}" "{8}" "False" "{8}" "{8}" "{8}" "False" "{8}"] \
"ipv4.header.options.nextOption.option.ssrr.type-40" [list "{137}" "False" "{{137}}" "{137}" "False" "{137}" "{137}" "{137}" "False" "{137}"] \
"ipv4.header.options.nextOption.option.streamId.id-46" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.streamId.length-45" [list "{4}" "False" "{{4}}" "{4}" "False" "{4}" "{4}" "{4}" "False" "{4}"] \
"ipv4.header.options.nextOption.option.streamId.type-44" [list "{136}" "False" "{{136}}" "{136}" "False" "{136}" "{136}" "{136}" "False" "{136}"] \
"ipv4.header.options.nextOption.option.timestamp.flags-51" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{Timestamps only, in consecutive 32-bit words}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.timestamp.length-48" [list "{12}" "False" "{{12}}" "{12}" "False" "{12}" "{12}" "{12}" "False" "{12}"] \
"ipv4.header.options.nextOption.option.timestamp.overflow-50" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.timestamp.pair.address-52" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.timestamp.pair.timestamp-53" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.options.nextOption.option.timestamp.pointer-49" [list "{5}" "False" "{{5}}" "{5}" "False" "{5}" "{5}" "{5}" "False" "{5}"] \
"ipv4.header.options.nextOption.option.timestamp.type-47" [list "{68}" "False" "{{68}}" "{68}" "False" "{68}" "{68}" "{68}" "False" "{68}"] \
"ipv4.header.options.pad-58" [list "{0}" "False" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.priority.ds.phb.assuredForwardingPHB.assuredForwardingPHB-14" [list "{10}" "True" "{{10}}" "{10}" "False" "{10}" "{Class 1, Low drop precedence}" "{10}" "False" "{10}"] \
"ipv4.header.priority.ds.phb.assuredForwardingPHB.unused-15" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.priority.ds.phb.classSelectorPHB.classSelectorPHB-12" [list "{8}" "True" "{{8}}" "{8}" "False" "{8}" "{Precedence 1}" "{8}" "False" "{8}"] \
"ipv4.header.priority.ds.phb.classSelectorPHB.unused-13" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.priority.ds.phb.defaultPHB.defaultPHB-10" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.priority.ds.phb.defaultPHB.unused-11" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.priority.ds.phb.expeditedForwardingPHB.expeditedForwardingPHB-16" [list "{46}" "True" "{{46}}" "{46}" "False" "{46}" "{46}" "{46}" "False" "{46}"] \
"ipv4.header.priority.ds.phb.expeditedForwardingPHB.unused-17" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.priority.raw-3" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"ipv4.header.priority.tos.delay-5" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{Normal}" "{0}" "True" "{0}"] \
"ipv4.header.priority.tos.monetary-8" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{Normal}" "{0}" "True" "{0}"] \
"ipv4.header.priority.tos.precedence-4" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{000 Routine}" "{0}" "True" "{0}"] \
"ipv4.header.priority.tos.reliability-7" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{Normal}" "{0}" "True" "{0}"] \
"ipv4.header.priority.tos.throughput-6" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{Normal}" "{0}" "True" "{0}"] \
"ipv4.header.priority.tos.unused-9" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "True" "{0}"] \
"ipv4.header.protocol-25" [list "{17}" "True" "{{61}}" "{61}" "False" "{61}" "{UDP}" "{61}" "False" "{61}"] \
"ipv4.header.srcIp-27" [list "{0.0.0.0}" "True" "{{0.0.0.0}}" "{0.0.0.0}" "False" "{0.0.0.0}" "{0.0.0.0}" "{0.0.0.0}" "False" "{0.0.0.0}"] \
"ipv4.header.totalLength-18" [list "{92}" "True" "{{20}}" "{20}" "False" "{20}" "{92}" "{20}" "False" "{20}"] \
"ipv4.header.ttl-24" [list "{64}" "True" "{{64}}" "{64}" "False" "{64}" "{64}" "{64}" "False" "{64}"] \
"ipv4.header.version-1" [list "{4}" "True" "{{4}}" "{4}" "False" "{4}" "{4}" "{4}" "False" "{4}"] \
"udp.header.checksum-4" [list "{0}" "True" "{{0}}" "{0}" "False" "{0}" "{0}" "{0}" "False" "{0}"] \
"udp.header.dstPort-2" [list "{63}" "True" "{{63}}" "{63}" "False" "{63}" "{Default}" "{63}" "False" "{63}"] \
"udp.header.length-3" [list "{72}" "True" "{{8}}" "{8}" "False" "{8}" "{72}" "{8}" "False" "{8}"] \
"udp.header.srcPort-1" [list "{63}" "True" "{{63}}" "{63}" "False" "{63}" "{Default}" "{63}" "False" "{63}"]]

if {$arg(L4Protocol) == "none"} {
    dict set t_list "ipv4.header.totalLength-18" [list "{84}" "True" "{{20}}" "{20}" "False" "{20}" "{84}" "{20}" "False" "{20}"]
    dict set t_list "ipv4.header.protocol-25" [list "{61}" "True" "{{61}}" "{61}" "False" "{61}" "{Any host internal protocol}" "{61}" "False" "{61}"]
}


#set ::IxNserver localhost
#set ::IxNport   8009

#package require IxTclNetwork
ixNet connect $::IxNserver -port $::IxNport -version 6.30

set sg_top [ixNet getRoot]

proc sg_commit {} {
    ixNet commit
}

# setting global options
proc set_global_options {} {
    global arg
    global sg_top
    
    ixNet rollback
    ixNet setSessionParameter version 6.30.709.62
    ixNet execute newConfig
    
    ixNet setMultiAttrs $sg_top/availableHardware \
        -offChassisHwM {} \
        -isOffChassis False
    ixNet setMultiAttrs $sg_top/globals/preferences \
        -connectPortsOnLoadConfig True \
        -rebootPortsOnConnect False
    ixNet setMultiAttrs $sg_top/globals/interfaces \
        -arpOnLinkup True \
        -nsOnLinkup True \
        -sendSingleArpPerGateway False \
        -sendSingleNsPerGateway False
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/checksums \
        -dropRxL2FcsErrors False \
        -correctTxL2FcsErrors False \
        -alwaysCorrectWhenModifying True \
        -correctTxChecksumOverIp False \
        -correctTxIpv4Checksum False
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/rxRateLimit \
        -enabled False \
        -value 8 \
        -units {kKilobitsPerSecond}
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/drop \
        -enabled False \
        -clusterSize 1 \
        -percentRate 0
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/reorder \
        -enabled False \
        -clusterSize 1 \
        -percentRate 0 \
        -skipCount 1
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/duplicate \
        -enabled False \
        -clusterSize 1 \
        -percentRate 0 \
        -duplicateCount 1
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/bitError \
        -enabled False \
        -logRate 3 \
        -skipEndOctets 0 \
        -skipStartOctets 0
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/delay \
        -enabled False \
        -value 300 \
        -units {kMicroseconds}
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/delayVariation \
        -uniformSpread 0 \
        -enabled False \
        -units {kMicroseconds} \
        -distribution {kUniform} \
        -exponentialMeanArrival 0 \
        -gaussianStandardDeviation 0
    ixNet setMultiAttrs $sg_top/impairment/defaultProfile/customDelayVariation \
        -enabled False \
        -name {}
    ixNet setMultiAttrs $sg_top/statistics \
        -additionalFcoeStat2 fcoeInvalidFrames \
        -csvLogPollIntervalMultiplier 1 \
        -pollInterval 2 \
        -guardrailEnabled True \
        -enableCsvLogging False \
        -dataStorePollingIntervalMultiplier 1 \
        -maxNumberOfStatsPerCustomGraph 16 \
        -additionalFcoeStat1 fcoeInvalidDelimiter \
        -timestampPrecision 3 \
        -enableDataCenterSharedStats False \
        -timeSynchronization syncTimeToTestStart \
        -enableAutoDataStore False
    ixNet setMultiAttrs $sg_top/statistics/measurementMode -measurementMode mixedMode
    ixNet setMultiAttrs $sg_top/eventScheduler -licenseServerLocation {127.0.0.1}
    ixNet setMultiAttrs $sg_top/traffic \
        -destMacRetryCount 1 \
        -maxTrafficGenerationQueries 500 \
        -enableStaggeredTransmit False \
        -learningFrameSize 64 \
        -useTxRxSync True \
        -enableDestMacRetry True \
        -enableMulticastScalingFactor False \
        -destMacRetryDelay 5 \
        -largeErrorThreshhold 2 \
        -refreshLearnedInfoBeforeApply False \
        -enableMinFrameSize False \
        -macChangeOnFly False \
        -waitTime 1 \
        -enableInstantaneousStatsSupport False \
        -learningFramesCount 10 \
        -globalStreamControl continuous \
        -displayMplsCurrentLabelValue False \
        -mplsLabelLearningTimeout 30 \
        -enableStaggeredStartDelay True \
        -enableDataIntegrityCheck True \
        -enableSequenceChecking False \
        -globalStreamControlIterations 1 \
        -enableStreamOrdering False \
        -frameOrderingMode none \
        -learningFramesRate 100
    ixNet setMultiAttrs $sg_top/traffic/statistics/latency \
        -enabled True \
        -mode cutThrough
    ixNet setMultiAttrs $sg_top/traffic/statistics/interArrivalTimeRate -enabled False
    ixNet setMultiAttrs $sg_top/traffic/statistics/delayVariation \
        -enabled False \
        -statisticsMode rxDelayVariationErrorsAndRate \
        -latencyMode storeForward \
        -largeSequenceNumberErrorThreshold 2
    ixNet setMultiAttrs $sg_top/traffic/statistics/sequenceChecking \
        -enabled True \
        -sequenceMode rxThreshold
    ixNet setMultiAttrs $sg_top/traffic/statistics/advancedSequenceChecking \
        -enabled False \
        -advancedSequenceThreshold 1
    ixNet setMultiAttrs $sg_top/traffic/statistics/cpdpConvergence \
        -enabled False \
        -dataPlaneJitterWindow 10485760 \
        -dataPlaneThreshold 95 \
        -enableDataPlaneEventsRateMonitor False \
        -enableControlPlaneEvents False
    ixNet setMultiAttrs $sg_top/traffic/statistics/packetLossDuration -enabled False
    ixNet setMultiAttrs $sg_top/traffic/statistics/dataIntegrity -enabled True
    ixNet setMultiAttrs $sg_top/traffic/statistics/errorStats -enabled False
    ixNet setMultiAttrs $sg_top/traffic/statistics/prbs -enabled False
    ixNet setMultiAttrs $sg_top/traffic/statistics/iptv -enabled False
    ixNet setMultiAttrs $sg_top/traffic/statistics/l1Rates -enabled False
    #quickTest global settings
    ixNet setMultiAttrs $sg_top/quickTest/globals \
        -productLabel $arg(name) \
        -serialNumber {Your switch/router serial number here} \
        -version {Your firmware version here} \
        -comments {} \
        -titlePageComments {} \
        -maxLinesToDisplay 100 \
        -enableCheckLinkState False \
        -enableAbortIfLinkDown False \
        -enableSwitchToStats True \
        -enableCapture False \
        -enableSwitchToResult True \
        -enableGenerateReportAfterRun False \
        -enableRebootCpu False \
        -saveCaptureBeforeRun False \
        -linkDownTimeout 5 \
        -sleepTimeAfterReboot 10 \
        -useDefaultRootPath True \
        -outputRootPath {C:\Users\Administrator\AppData\Local\Ixia\IxNetwork\data\result}
    sg_commit
    set sg_top [lindex [ixNet remapIds $sg_top] 0]
    #set ixNetSG_Stack(0) $sg_top
    puts "COMPLETED: global settings"
}


### /vport area
# configuring the object that corresponds to /vport:2/l1Config/rxFilters/uds:x
proc set_vport_uds {uds_root} {
    foreach index {1 2 3 4 5 6} {
        set sg_uds $uds_root/l1Config/rxFilters/uds:$index
        ixNet setMultiAttrs $sg_uds \
        -destinationAddressSelector anyAddr \
        -customFrameSizeTo 0 \
        -customFrameSizeFrom 0 \
        -error errAnyFrame \
        -patternSelector anyPattern \
        -sourceAddressSelector anyAddr \
        -isEnabled True \
        -frameSizeType any
        sg_commit
        #set sg_uds [lindex [ixNet remapIds $sg_uds] 0]
    }
    puts "COMPLETED: vport uds settings"
}
proc set_vport {} {
    global sg_top
    global chassis
    global tx_vport
    global rx_vport
    global txport_conf
    global rxport_conf

    foreach port [list $txport_conf $rxport_conf] vp [list tx_vport rx_vport] vi [list tx_interface rx_interface] {
        upvar $vp sg_vport
        upvar $vi sg_interface            
        set sg_vport [ixNet add $sg_top vport]
        ixNet setMultiAttrs $sg_vport \
            -transmitIgnoreLinkStatus False \
            -txGapControlMode averageMode \
            -type ethernet \
            -connectedTo ::ixNet::OBJ-null \
            -txMode interleaved \
            -isPullOnly False \
            -rxMode captureAndMeasure \
            -name "$chassis:[dict get $port ixia_port]-Ethernet"
        ixNet setMultiAttrs $sg_vport/l1Config \
            -currentType ethernet
        ixNet setMultiAttrs $sg_vport/l1Config/ethernet \
            -autoNegotiate True \
            -media copper \
            -loopback False \
            -enablePPM False \
            -autoInstrumentation endOfFrame \
            -speed speed100fd \
            -flowControlDirectedAddress "01 80 C2 00 00 01" \
            -ppm 0 \
            -enabledFlowControl False \
            -speedAuto {all}
        ixNet setMultiAttrs $sg_vport/l1Config/ethernet/oam \
            -tlvType {00} \
            -linkEvents False \
            -enabled False \
            -vendorSpecificInformation {00 00 00 00} \
            -macAddress "00:00:00:00:00:00" \
            -loopback False \
            -idleTimer 5 \
            -tlvValue {00} \
            -enableTlvOption False \
            -maxOAMPDUSize 64 \
            -organizationUniqueIdentifier {000000}
        ixNet setMultiAttrs $sg_vport/l1Config/ethernet/fcoe \
            -supportDataCenterMode False \
            -priorityGroupSize priorityGroupSize-8 \
            -pfcPauseDelay 1 \
            -pfcPriorityGroups {0 1 2 3 4 5 6 7} \
            -flowControlType ieee802.1Qbb \
            -enablePFCPauseDelay False
        ixNet setMultiAttrs $sg_vport/l1Config/OAM \
            -tlvType {00} \
            -linkEvents False \
            -enabled False \
            -vendorSpecificInformation {00 00 00 00} \
            -macAddress "00:00:00:00:00:00" \
            -loopback False \
            -idleTimer 5 \
            -tlvValue {00} \
            -enableTlvOption False \
            -maxOAMPDUSize 64 \
            -organizationUniqueIdentifier {000000}
        ixNet setMultiAttrs $sg_vport/l1Config/rxFilters/filterPalette \
            -sourceAddress1Mask {00:00:00:00:00:00} \
            -destinationAddress1Mask {00:00:00:00:00:00} \
            -sourceAddress2 {00:00:00:00:00:00} \
            -pattern2OffsetType fromStartOfFrame \
            -pattern2Offset 20 \
            -pattern1Mask {00} \
            -sourceAddress2Mask {00:00:00:00:00:00} \
            -destinationAddress2 {00:00:00:00:00:00} \
            -destinationAddress1 {00:00:00:00:00:00} \
            -sourceAddress1 {00:00:00:00:00:00} \
            -pattern1 {00} \
            -destinationAddress2Mask {00:00:00:00:00:00} \
            -pattern2Mask {00} \
            -pattern1Offset 20 \
            -pattern2 {00} \
            -pattern1OffsetType fromStartOfFrame
        ixNet setMultiAttrs $sg_vport/protocols/arp \
            -enabled True
        ixNet setMultiAttrs $sg_vport/protocols/bfd \
            -enabled False \
            -intervalValue 0 \
            -packetsPerInterval 0
        ixNet setMultiAttrs $sg_vport/protocols/bgp \
            -autoFillUpDutIp False \
            -disableReceivedUpdateValidation False \
            -enableAdVplsPrefixLengthInBits False \
            -enableExternalActiveConnect True \
            -enableInternalActiveConnect True \
            -enableVpnLabelExchangeOverLsp True \
            -enabled False \
            -externalRetries 0 \
            -externalRetryDelay 120 \
            -internalRetries 0 \
            -internalRetryDelay 120 \
            -mldpP2mpFecType 6 \
            -triggerVplsPwInitiation False
        ixNet setMultiAttrs $sg_vport/protocols/cfm \
            -enableOptionalLmFunctionality False \
            -enableOptionalTlvValidation True \
            -enabled False \
            -receiveCcm True \
            -sendCcm True \
            -suppressErrorsOnAis True
        ixNet setMultiAttrs $sg_vport/protocols/eigrp \
            -enabled False
        ixNet setMultiAttrs $sg_vport/protocols/elmi \
            -enabled False
        ixNet setMultiAttrs $sg_vport/protocols/igmp \
            -enabled False \
            -numberOfGroups 0 \
            -numberOfQueries 0 \
            -queryTimePeriod 0 \
            -sendLeaveOnStop True \
            -statsEnabled False \
            -timePeriod 0
        ixNet setMultiAttrs $sg_vport/protocols/isis \
            -allL1RbridgesMac "01:80:c2:00:00:40" \
            -emulationType isisL3Routing \
            -enabled False \
            -helloMulticastMac "01:80:c2:00:00:41" \
            -lspMgroupPdusPerInterval 0 \
            -nlpId 192 \
            -rateControlInterval 0 \
            -sendP2PHellosToUnicastMac True \
            -spbAllL1BridgesMac "09:00:2b:00:00:05" \
            -spbHelloMulticastMac "09:00:2b:00:00:05" \
            -spbNlpId 192
        ixNet setMultiAttrs $sg_vport/protocols/lacp \
            -enablePreservePartnerInfo False \
            -enabled False
        ixNet setMultiAttrs $sg_vport/protocols/ldp \
            -enableDiscardSelfAdvFecs False \
            -enableHelloJitter True \
            -enableVpnLabelExchangeOverLsp True \
            -enabled False \
            -helloHoldTime 15 \
            -helloInterval 5 \
            -keepAliveHoldTime 30 \
            -keepAliveInterval 10 \
            -p2mpCapabilityParam 1288 \
            -p2mpFecType 6 \
            -targetedHelloInterval 15 \
            -targetedHoldTime 45 \
            -useTransportLabelsForMplsOam False
        ixNet setMultiAttrs $sg_vport/protocols/linkOam \
            -enabled False
        ixNet setMultiAttrs $sg_vport/protocols/lisp \
            -burstIntervalInMs 0 \
            -enabled False \
            -ipv4MapRegisterPacketsPerBurst 0 \
            -ipv4MapRequestPacketsPerBurst 0 \
            -ipv4SmrPacketsPerBurst 0 \
            -ipv6MapRegisterPacketsPerBurst 0 \
            -ipv6MapRequestPacketsPerBurst 0 \
            -ipv6SmrPacketsPerBurst 0
        ixNet setMultiAttrs $sg_vport/protocols/mld \
            -enableDoneOnStop True \
            -enabled False \
            -mldv2Report type143 \
            -numberOfGroups 0 \
            -numberOfQueries 0 \
            -queryTimePeriod 0 \
            -timePeriod 0
        ixNet setMultiAttrs $sg_vport/protocols/mplsOam \
            -enabled False
        ixNet setMultiAttrs $sg_vport/protocols/mplsTp \
            -apsChannelType {00 02 } \
            -bfdCcChannelType {00 07 } \
            -delayManagementChannelType {00 05 } \
            -enableHighPerformanceMode True \
            -enabled False \
            -faultManagementChannelType {00 58 } \
            -lossMeasurementChannelType {00 04 } \
            -onDemandCvChannelType {00 09 } \
            -pwStatusChannelType {00 0B } \
            -y1731ChannelType {7F FA }
        ixNet setMultiAttrs $sg_vport/protocols/ospf \
            -enableDrOrBdr False \
            -enabled False \
            -floodLinkStateUpdatesPerInterval 0 \
            -rateControlInterval 0
        ixNet setMultiAttrs $sg_vport/protocols/ospfV3 \
            -enabled False
        ixNet setMultiAttrs $sg_vport/protocols/pimsm \
            -bsmFramePerInterval 0 \
            -crpFramePerInterval 0 \
            -dataMdtFramePerInterval 0 \
            -denyGrePimIpPrefix {0.0.0.0/32} \
            -enableDiscardJoinPruneProcessing False \
            -enableRateControl False \
            -enabled False \
            -helloMsgsPerInterval 0 \
            -interval 0 \
            -joinPruneMessagesPerInterval 0 \
            -registerMessagesPerInterval 0 \
            -registerStopMessagesPerInterval 0
        ixNet setMultiAttrs $sg_vport/protocols/ping \
            -enabled True
        ixNet setMultiAttrs $sg_vport/protocols/rip \
            -enabled False
        ixNet setMultiAttrs $sg_vport/protocols/ripng \
            -enabled False
        ixNet setMultiAttrs $sg_vport/protocols/rsvp \
            -enableControlLspInitiationRate False \
            -enableShowTimeValue False \
            -enableVpnLabelExchangeOverLsp True \
            -enabled False \
            -maxLspInitiationsPerSec 400 \
            -useTransportLabelsForMplsOam False
        ixNet setMultiAttrs $sg_vport/protocols/stp \
            -enabled False
        ixNet setMultiAttrs $sg_vport/rateControlParameters \
            -maxRequestsPerBurst 1 \
            -maxRequestsPerSec 100 \
            -minRetryInterval 10 \
            -retryCount 0 \
            -sendInBursts False \
            -sendRequestsAsFastAsPossible False
        ixNet setMultiAttrs $sg_vport/capture \
            -controlCaptureTrigger {} \
            -controlCaptureFilter {} \
            -hardwareEnabled False \
            -softwareEnabled False \
            -displayFiltersDataCapture {} \
            -displayFiltersControlCapture {} \
            -controlBufferSize 30 \
            -controlBufferBehaviour bufferLiveNonCircular
        ixNet setMultiAttrs $sg_vport/protocolStack/options \
            -routerSolicitationDelay 1 \
            -routerSolicitationInterval 4 \
            -routerSolicitations 3 \
            -retransTime 1000 \
            -dadTransmits 1 \
            -dadEnabled True \
            -ipv4RetransTime 3000 \
            -ipv4McastSolicit 4
        sg_commit
        set sg_vport [lindex [ixNet remapIds $sg_vport] 0]
        puts "COMPLETED: vport global settings"
        #set ixNetSG_ref(2) $sg_vport
        #set ixNetSG_Stack(1) $sg_vport
        # configuring the object that corresponds to /vport:1/interface:1
        set sg_interface [ixNet add $sg_vport interface]
        ixNet setMultiAttrs $sg_interface \
            -description {QT-ipv4-0} \
            -enabled True \
            -eui64Id  "[dict get $port eui64Id]" \
            -mtu 1500 \
            -type default
        ixNet setMultiAttrs $sg_interface/atm \
            -encapsulation llcBridgeFcs \
            -vci 32 \
            -vpi 0
        ixNet setMultiAttrs $sg_interface/dhcpV4Properties \
            -clientId {} \
            -enabled False \
            -renewTimer 0 \
            -requestRate 0 \
            -serverId 0.0.0.0 \
            -tlvs {} \
            -vendorId {}
        ixNet setMultiAttrs $sg_interface/dhcpV6Properties \
            -enabled False \
            -iaId 0 \
            -iaType temporary \
            -renewTimer 0 \
            -requestRate 0 \
            -tlvs {}
        ixNet setMultiAttrs $sg_interface/ethernet \
            -macAddress "[dict get $port mac]" \
            -mtu 1500 \
            -uidFromMac True
        ixNet setMultiAttrs $sg_interface/gre \
            -dest 0.0.0.0 \
            -inKey 0 \
            -outKey 0 \
            -source ::ixNet::OBJ-null \
            -useChecksum False \
            -useKey False \
            -useSequence False
        ixNet setMultiAttrs $sg_interface/unconnected \
            -connectedVia ::ixNet::OBJ-null
        ixNet setMultiAttrs $sg_interface/vlan \
            -tpid {0x8100} \
            -vlanCount 1 \
            -vlanEnable False \
            -vlanId {1} \
            -vlanPriority {0}
        sg_commit
        set sg_interface [lindex [ixNet remapIds $sg_interface] 0]
        puts "COMPLETED: vport interface settings"
        #set ixNetSG_ref(3) $sg_interface
        #set ixNetSG_Stack(2) $sg_interface
        # configuring the object that corresponds to /vport:1/interface:1/ipv4
        #
        set sg_ipv4 [ixNet add $sg_interface ipv4]
        ixNet setMultiAttrs $sg_ipv4 \
            -gateway [dict get $port gateway] \
            -ip [dict get $port ip] \
            -maskWidth 24
        sg_commit
        set sg_ipv4 [lindex [ixNet remapIds $sg_ipv4] 0]
        puts "COMPLETED: vport ipv4 settings"
        set_vport_uds $sg_vport
        
        puts "COMPLETED: vport settings"
    }
}

### /availableHardware area
proc set_availableHardware {} {
    global sg_top
    global tx_vport
    global rx_vport
    global chassis
    global txport
    global rxport
    
    set a [split $txport ":"]
    set b [split $rxport ":"]
    set card1 [lindex $a 0]
    set port1 [lindex $a 1]
    set card2 [lindex $b 0]
    set port2 [lindex $b 1]
    
    if {$card1 != $card2} {
        puts stderr "Two ixia port are not in one card"
        flush stderr
        exit 1
    }
    set card $card1
    
    # configuring the object that corresponds to /availableHardware/chassis:"10.155.33.216"
    set sg_chassis [ixNet add $sg_top/availableHardware chassis]
    ixNet setMultiAttrs $sg_chassis \
        -masterChassis {} \
        -sequenceId 1 \
        -cableLength 0 \
        -hostname $chassis
    sg_commit
    set sg_chassis [lindex [ixNet remapIds $sg_chassis] 0]
    
    # configuring the object that corresponds to /availableHardware/chassis:"10.155.33.216"/card:5
    set sg_card $sg_chassis/card:$card
    ixNet setMultiAttrs $sg_card -aggregationMode notSupported
    sg_commit
    set sg_card [lindex [ixNet remapIds $sg_card] 0]
    #clear port ownership
    ixNet exec clearOwnership $sg_card/port:$port1
    ixNet exec clearOwnership $sg_card/port:$port2
    #set ixNetSG_ref(21) $sg_card
    ixNet setMultiAttrs $tx_vport -connectedTo $sg_card/port:$port1
    sg_commit
    ixNet setMultiAttrs $rx_vport -connectedTo $sg_card/port:$port2
    sg_commit
    
    puts "COMPLETED: availableHardware settings"
}

### /impairment area
proc set_impairment {} {
    global sg_top
    
    # configuring the object that corresponds to /impairment/profile:3
    set sg_profile [ixNet add $sg_top/impairment profile]
    ixNet setMultiAttrs $sg_profile \
        -enabled False \
        -name {Impairment Profile 1} \
        -links {} \
        -allLinks True \
        -priority 1
    ixNet setMultiAttrs $sg_profile/checksums \
        -dropRxL2FcsErrors False \
        -correctTxL2FcsErrors False \
        -alwaysCorrectWhenModifying True \
        -correctTxChecksumOverIp False \
        -correctTxIpv4Checksum False
    ixNet setMultiAttrs $sg_profile/rxRateLimit \
        -enabled False \
        -value 8 \
        -units {kKilobitsPerSecond}
    ixNet setMultiAttrs $sg_profile/drop \
        -enabled True \
        -clusterSize 1 \
        -percentRate 0
    ixNet setMultiAttrs $sg_profile/reorder \
        -enabled False \
        -clusterSize 1 \
        -percentRate 0 \
        -skipCount 1
    ixNet setMultiAttrs $sg_profile/duplicate \
        -enabled False \
        -clusterSize 1 \
        -percentRate 0 \
        -duplicateCount 1
    ixNet setMultiAttrs $sg_profile/bitError \
        -enabled False \
        -logRate 3 \
        -skipEndOctets 0 \
        -skipStartOctets 0
    ixNet setMultiAttrs $sg_profile/delay \
        -enabled True \
        -value 300 \
        -units {kMicroseconds}
    ixNet setMultiAttrs $sg_profile/delayVariation \
        -uniformSpread 0 \
        -enabled False \
        -units {kMicroseconds} \
        -distribution {kUniform} \
        -exponentialMeanArrival 0 \
        -gaussianStandardDeviation 0
    ixNet setMultiAttrs $sg_profile/customDelayVariation \
        -enabled False \
        -name {}
    ixNet setMultiAttrs $sg_profile/accumulateAndBurst \
        -burstTimeoutUnit {kSeconds} \
        -burstSizeUnit {kKilobytes} \
        -enabled False \
        -interBurstGapValueUnit {kMilliseconds} \
        -packetCount 1000 \
        -interBurstGapValue 20 \
        -queueSize 1 \
        -queueAutoSizeEnabled True \
        -burstSize 1014 \
        -burstTimeout {5} \
        -interBurstGap {kTailToHead}
    sg_commit
    set sg_profile [lindex [ixNet remapIds $sg_profile] 0]
    
    # configuring the object that corresponds to /impairment/profile:3/fixedClassifier:1
    set sg_fixedClassifier [ixNet add $sg_profile fixedClassifier]
    sg_commit
    set sg_fixedClassifier [lindex [ixNet remapIds $sg_fixedClassifier] 0]
}

proc set_traffic_unit {obj_root obj_name} {
    global t_list
    
    set attr_list [dict get $t_list $obj_name]
    
    set sg_field $obj_root/field:"$obj_name"
    ixNet setMultiAttrs $sg_field \
        -singleValue [lindex $attr_list 0] \
        -seed {1} \
        -optionalEnabled [lindex $attr_list 1] \
        -fullMesh False \
        -valueList [lindex $attr_list 2] \
        -stepValue [lindex $attr_list 3] \
        -valueType singleValue \
        -trackingEnabled [lindex $attr_list 4] \
        -fixedBits [lindex $attr_list 5] \
        -fieldValue [lindex $attr_list 6] \
        -randomMask [lindex $attr_list 7] \
        -countValue {1} \
        -activeFieldChoice [lindex $attr_list 8] \
        -startValue [lindex $attr_list 9] \
        -auto [lindex $attr_list 10]
    sg_commit
    set sg_field [lindex [ixNet remapIds $sg_field] 0]
}
### /traffic area
proc set_traffic {} {
    global arg
    global sg_top
    global tx_interface
    global rx_interface
    global sg_trafficItem
    
    # configuring the object that corresponds to /traffic/trafficItem:1
    set sg_trafficItem [ixNet add $sg_top/traffic trafficItem]
    ixNet setMultiAttrs $sg_trafficItem \
        -hostsPerNetwork 1 \
        -transportRsvpTePreference one \
        -trafficItemType l2L3 \
        -maxNumberOfVpnLabelStack 2 \
        -biDirectional $arg(BiDirectional) \
        -mergeDestinations True \
        -transportLdpPreference two \
        -transmitMode interleaved \
        -ordinalNo 0 \
        -trafficType {ipv4} \
        -interAsLdpPreference two \
        -allowSelfDestined False \
        -enabled True \
        -name $arg(name) \
        -interAsBgpPreference one \
        -suspend False \
        -enableDynamicMplsLabelValues False \
        -routeMesh oneToOne \
        -egressEnabled False \
        -srcDestMesh oneToOne
    sg_commit
    set sg_trafficItem [lindex [ixNet remapIds $sg_trafficItem] 0]
    puts "COMPLETED: add /traffic/trafficItem:1"
    
    # configuring the object that corresponds to /traffic/trafficItem:1/endpointSet:1
    set sg_endpointSet [ixNet add $sg_trafficItem endpointSet]
    ixNet setMultiAttrs $sg_endpointSet \
        -destinations [list $rx_interface] \
        -destinationFilter {} \
        -sourceFilter {} \
        -name {Endpoint Set-1} \
        -trafficGroups {} \
        -sources [list $tx_interface]
    sg_commit
    set sg_endpointSet [lindex [ixNet remapIds $sg_endpointSet] 0]
    puts "COMPLETED: add /traffic/trafficItem:1/endpointSet:1"
    
    # configuring the object that corresponds to /traffic/trafficItem:1/configElement:1
    set sg_configElement $sg_trafficItem/configElement:1
    ixNet setMultiAttrs $sg_configElement \
        -preambleCustomSize 8 \
        -crc goodCrc \
        -enableDisparityError False \
        -preambleFrameSizeMode auto \
        -destinationMacMode manual
    ixNet setMultiAttrs $sg_configElement/frameSize \
        -weightedPairs {} \
        -incrementTo 1518 \
        -randomMin 64 \
        -incrementFrom 64 \
        -fixedSize 1024 \
        -randomMax 1518 \
        -quadGaussian {} \
        -type fixed \
        -presetDistribution cisco \
        -incrementStep 1
    ixNet setMultiAttrs $sg_configElement/frameRate \
        -bitRateUnitsType bitsPerSec \
        -rate 100 \
        -enforceMinimumInterPacketGap 0 \
        -type percentLineRate \
        -interPacketGapUnitsType nanoseconds
    ixNet setMultiAttrs $sg_configElement/framePayload \
        -type incrementByte \
        -customRepeat True \
        -customPattern {}
    ixNet setMultiAttrs $sg_configElement/frameRateDistribution \
        -streamDistribution splitRateEvenly \
        -portDistribution applyRateToAll
    ixNet setMultiAttrs $sg_configElement/transmissionControl \
        -frameCount 1 \
        -minGapBytes 12 \
        -interStreamGap 0 \
        -interBurstGap 0 \
        -interBurstGapUnits nanoseconds \
        -type fixedIterationCount \
        -duration 1 \
        -repeatBurst 1 \
        -enableInterStreamGap False \
        -startDelayUnits bytes \
        -iterationCount 1 \
        -burstPacketCount 1 \
        -enableInterBurstGap False \
        -startDelay 0
    sg_commit
    set sg_configElement [lindex [ixNet remapIds $sg_configElement] 0]
    
    # configuring the object that corresponds to /traffic/trafficItem:1/configElement:1/transmissionDistribution
    set sg_transmissionDistribution $sg_configElement/transmissionDistribution
    ixNet setMultiAttrs $sg_transmissionDistribution -distributions {}
    sg_commit
    
    # configuring the object that corresponds to /traffic/trafficItem:1/transmissionDistribution
    set sg_transmissionDistribution $sg_trafficItem/transmissionDistribution
    ixNet setMultiAttrs $sg_transmissionDistribution -distributions {}
    sg_commit
    
    # configuring the object that corresponds to /traffic/trafficItem:1/tracking
    set sg_tracking $sg_trafficItem/tracking
    ixNet setMultiAttrs $sg_tracking \
        -oneToOneMesh False \
        -trackBy {{trackingenabled0} {flowGroup0}} \
        -protocolOffset {Root.0} \
        -values {} \
        -offset 0 \
        -fieldWidth thirtyTwoBits
    ixNet setMultiAttrs $sg_tracking/egress \
        -customWidthBits 0 \
        -offset {Outer VLAN Priority (3 bits)} \
        -enabled False \
        -customOffsetBits 0 \
        -encapsulation {Ethernet}
    ixNet setMultiAttrs $sg_tracking/latencyBin \
        -enabled False \
        -binLimits {1 1.42 2 2.82 4 5.66 8 11.32} \
        -numberOfBins 8
    sg_commit
    set sg_tracking [lindex [ixNet remapIds $sg_tracking] 0]
    set sg_tracking $sg_tracking/egress
    
    # configuring the object that corresponds to /traffic/trafficItem:1/egressTracking:1
    set sg_egressTracking [ixNet add $sg_trafficItem egressTracking]
    ixNet setMultiAttrs $sg_egressTracking \
        -customWidthBits 0 \
        -offset {Outer VLAN Priority (3 bits)} \
        -customOffsetBits 0 \
        -encapsulation {Ethernet}
    sg_commit
    set sg_egressTracking [lindex [ixNet remapIds $sg_egressTracking] 0]
    
    foreach obj [list $sg_tracking $sg_egressTracking] {
        # configuring the object that corresponds to /traffic/trafficItem:1/.../fieldOffset/stack:"ethernet-1"
        set sg_stack $obj/fieldOffset/stack:"ethernet-1"
        sg_commit
        set sg_stack [lindex [ixNet remapIds $sg_stack] 0]
        #config stack:"ethernet-1"
        set obj_names [list "ethernet.header.destinationAddress-1" \
                            "ethernet.header.sourceAddress-2" \
                            "ethernet.header.etherType-3" \
                            "ethernet.header.pfcQueue-4"]
        foreach i $obj_names {
            set_traffic_unit $sg_stack $i
        }
        puts "COMPLETED: traffic stack:\"ethernet-1\" settings"
        
        # configuring the object that corresponds to /traffic/trafficItem:1/.../fieldOffset/stack:"ipv4-2"
        set sg_stack $obj/fieldOffset/stack:"ipv4-2"
        sg_commit
        set sg_stack [lindex [ixNet remapIds $sg_stack] 0]
        #config stack:"ipv4-2"
        set obj_names [list "ipv4.header.version-1" \
                            "ipv4.header.headerLength-2" \
                            "ipv4.header.priority.raw-3" \
                            "ipv4.header.priority.tos.precedence-4" \
                            "ipv4.header.priority.tos.delay-5" \
                            "ipv4.header.priority.tos.throughput-6" \
                            "ipv4.header.priority.tos.reliability-7" \
                            "ipv4.header.priority.tos.monetary-8" \
                            "ipv4.header.priority.tos.unused-9" \
                            "ipv4.header.priority.ds.phb.defaultPHB.defaultPHB-10" \
                            "ipv4.header.priority.ds.phb.defaultPHB.unused-11" \
                            "ipv4.header.priority.ds.phb.classSelectorPHB.classSelectorPHB-12" \
                            "ipv4.header.priority.ds.phb.classSelectorPHB.unused-13" \
                            "ipv4.header.priority.ds.phb.assuredForwardingPHB.assuredForwardingPHB-14" \
                            "ipv4.header.priority.ds.phb.assuredForwardingPHB.unused-15" \
                            "ipv4.header.priority.ds.phb.expeditedForwardingPHB.expeditedForwardingPHB-16" \
                            "ipv4.header.priority.ds.phb.expeditedForwardingPHB.unused-17" \
                            "ipv4.header.totalLength-18" \
                            "ipv4.header.identification-19" \
                            "ipv4.header.flags.reserved-20" \
                            "ipv4.header.flags.fragment-21" \
                            "ipv4.header.flags.lastFragment-22" \
                            "ipv4.header.fragmentOffset-23" \
                            "ipv4.header.ttl-24" \
                            "ipv4.header.protocol-25" \
                            "ipv4.header.checksum-26" \
                            "ipv4.header.srcIp-27" \
                            "ipv4.header.dstIp-28" \
                            "ipv4.header.options.nextOption.option.nop-29" \
                            "ipv4.header.options.nextOption.option.security.type-30" \
                            "ipv4.header.options.nextOption.option.security.length-31" \
                            "ipv4.header.options.nextOption.option.security.security-32" \
                            "ipv4.header.options.nextOption.option.security.compartments-33" \
                            "ipv4.header.options.nextOption.option.security.handling-34" \
                            "ipv4.header.options.nextOption.option.security.tcc-35" \
                            "ipv4.header.options.nextOption.option.lsrr.type-36" \
                            "ipv4.header.options.nextOption.option.lsrr.length-37" \
                            "ipv4.header.options.nextOption.option.pointer-38" \
                            "ipv4.header.options.nextOption.option.routeData-39" \
                            "ipv4.header.options.nextOption.option.ssrr.type-40" \
                            "ipv4.header.options.nextOption.option.ssrr.length-41" \
                            "ipv4.header.options.nextOption.option.recordRoute.type-42" \
                            "ipv4.header.options.nextOption.option.recordRoute.length-43" \
                            "ipv4.header.options.nextOption.option.streamId.type-44" \
                            "ipv4.header.options.nextOption.option.streamId.length-45" \
                            "ipv4.header.options.nextOption.option.streamId.id-46" \
                            "ipv4.header.options.nextOption.option.timestamp.type-47" \
                            "ipv4.header.options.nextOption.option.timestamp.length-48" \
                            "ipv4.header.options.nextOption.option.timestamp.pointer-49" \
                            "ipv4.header.options.nextOption.option.timestamp.overflow-50" \
                            "ipv4.header.options.nextOption.option.timestamp.flags-51" \
                            "ipv4.header.options.nextOption.option.timestamp.pair.address-52" \
                            "ipv4.header.options.nextOption.option.timestamp.pair.timestamp-53" \
                            "ipv4.header.options.nextOption.option.last-54" \
                            "ipv4.header.options.nextOption.option.routerAlert.type-55" \
                            "ipv4.header.options.nextOption.option.routerAlert.length-56" \
                            "ipv4.header.options.nextOption.option.routerAlert.value-57" \
                            "ipv4.header.options.pad-58"]
        foreach i $obj_names {
            set_traffic_unit $sg_stack $i
        }
        puts "COMPLETED: traffic stack:\"ipv4-2\" settings"
        
        if {$arg(L4Protocol) == "udp"} {
            # configuring the object that corresponds to /traffic/trafficItem:1/.../fieldOffset/stack:"udp-3"
            set sg_stack $obj/fieldOffset/stack:"udp-3"
            sg_commit
            set sg_stack [lindex [ixNet remapIds $sg_stack] 0]
            #config stack:"udp-3"
            set obj_names [list "udp.header.srcPort-1" \
                                "udp.header.dstPort-2" \
                                "udp.header.length-3" \
                                "udp.header.checksum-4"]
            foreach i $obj_names {
                set_traffic_unit $sg_stack $i
            }
            puts "COMPLETED: traffic stack:\"udp-3\" settings"
        }
        
        # configuring the object that corresponds to /traffic/trafficItem:1/.../fieldOffset/stack:"fcs-$in"
        if {$arg(L4Protocol) == "udp"} {
            set in "4"
        } else {
            set in "3"
        }
        set sg_stack $obj/fieldOffset/stack:"fcs-$in"
        sg_commit
        set sg_stack [lindex [ixNet remapIds $sg_stack] 0]
        #config stack:"fcs-$i"
        set obj_names [list "ethernet.fcs-1"]
        foreach i $obj_names {
            set_traffic_unit $sg_stack $i
        }
        puts "COMPLETED: traffic stack:\"fcs-$in\" settings"
    }
    
    # configuring the object that corresponds to /traffic/trafficItem:1/dynamicUpdate
    set sg_dynamicUpdate $sg_trafficItem/dynamicUpdate
    ixNet setMultiAttrs $sg_dynamicUpdate \
        -enabledSessionAwareTrafficFields {} \
        -enabledDynamicUpdateFields {}
    sg_commit
    set sg_dynamicUpdate [lindex [ixNet remapIds $sg_dynamicUpdate] 0]
    
    puts "COMPLETED: traffic settings"
}

### /quickTest area
proc set_quicktest_manualip {obj_root} {
    global arg
    global tx_vport
    global rx_vport   
    global txport_conf
    global rxport_conf
    
    foreach i [list 1 2] vp [list $tx_vport $rx_vport] pc [list $txport_conf $rxport_conf] {
        set sg_manualIp [ixNet add $obj_root manualIp]
        ixNet setMultiAttrs $sg_manualIp \
            -portId $vp \
            -assignConfig True \
            -inTest True \
            -addrPerPort 1 \
            -firstSrcMacMv {mvIncr {"[dict get $pc mac]" "00:00:00:00:00:01" 1}}
        ixNet setMultiAttrs $sg_manualIp/qos \
            -priority {tos} \
            -copyVlanPriority False \
            -fullMesh False
        foreach v [list precedence delay throughput reliability monetary] {
            ixNet setMultiAttrs $sg_manualIp/qos/tos/$v \
                -type {tos} \
                -displayName {$v} \
                -value {mvSingle {0}}
        }
        ixNet setMultiAttrs $sg_manualIp/qos/dscp/phb \
            -type {dscp} \
            -displayName {Default PHB} \
            -value {mvSingle {0}}
        ixNet setMultiAttrs $sg_manualIp/ip \
            -srcIpAddr {mvSingle {[dict get $pc ip]}} \
            -gwIpAddr {mvSingle {[dict get $pc gateway]}} \
            -mask 24
        ixNet setMultiAttrs $sg_manualIp/layer4 \
            -l4protocol $arg(L4Protocol) \
            -srcPortMv {mvSingle {7}} \
            -destPortMv {mvSingle {4321}} \
            -srcPortDistr port \
            -destPortDistr port
        ixNet setMultiAttrs $sg_manualIp/vlan/outer \
            -enabled False \
            -id {mvIncr {1 1 1}} \
            -priority 0 \
            -priorityMv {mvIncr {1 1 1}} \
            -idDistribution port \
            -fullMesh False
        ixNet setMultiAttrs $sg_manualIp/vlan/inner \
            -enabled False \
            -id {mvSingle {222}} \
            -priority 0 \
            -priorityMv {mvIncr {1 1 1}} \
            -idDistribution port \
            -fullMesh False
        ixNet setMultiAttrs $sg_manualIp/payload \
            -type incrementByte \
            -pattern {00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F} \
            -customPattern {55 AA} \
            -predefinedPattern {AA AA} \
            -repeat True
        sg_commit
        set sg_manualIp [lindex [ixNet remapIds $sg_manualIp] 0]
    }
}

proc set_quicktest_port {obj_root} {
    global tx_vport
    global rx_vport
    global txport_conf
    global rxport_conf
    
    foreach vp [list $tx_vport $rx_vport] pc [list $txport_conf $rxport_conf] {
        set sg_ports [ixNet add $obj_root ports]
        ixNet setMultiAttrs $sg_ports \
            -inTest True \
            -id $vp \
            -name {$chassis:[dict get $pc ixia_port]-Ethernet} \
            -cardtype {10/100/1000 LSM XMV16} \
            -assignedTo {$chassis:[dict get $pc ixia_port]}
        sg_commit
        set sg_ports [lindex [ixNet remapIds $sg_ports] 0]
    }
}
proc set_quicktest {} {
    global arg
    global sg_top
    global tx_vport
    global rx_vport
    global tx_interface
    global rx_interface
    global sg_trafficItem
    global sg_rfc2544throughput
    
    # configuring the object that corresponds to /quickTest/rfc2544throughput:1
    set sg_rfc2544throughput [ixNet add $sg_top/quickTest rfc2544throughput]
    ixNet setMultiAttrs $sg_rfc2544throughput \
        -name $arg(name) \
        -mode newMode \
        -inputParameters {{}}
    ixNet setMultiAttrs $sg_rfc2544throughput/testConfig \
        -protocolItem [list $tx_interface $rx_interface] \
        -enableMinFrameSize False \
        -framesize 64 \
        -reportTputRateUnit mbps \
        -sendFullyMeshed False \
        -rfc2544ImixDataQoS False \
        -duration $arg(duration) \
        -numtrials $arg(trials) \
        -trafficType constantLoading \
        -burstSize 1 \
        -framesPerBurstGap 1 \
        -tolerance 0 \
        -frameLossUnit {0} \
        -staggeredStart False \
        -framesizeList $arg(frameSizeList) \
        -frameSizeMode custom \
        -rateSelect percentMaxRate \
        -percentMaxRate 100 \
        -resolution 0.01 \
        -detailedResultsEnabled True \
        -forceRegenerate False \
        -reportSequenceError True \
        -ipv4rate 50 \
        -ipv6rate 50 \
        -loadRateList {1,10,50} \
        -fixedLoadUnit percentMaxRate \
        -loadRateValue 80 \
        -incrementLoadUnit percentMaxRate \
        -initialIncrementLoadRate 10 \
        -stepIncrementLoadRate 10 \
        -maxIncrementLoadRate 100 \
        -randomLoadUnit percentMaxRate \
        -minRandomLoadRate 10 \
        -maxRandomLoadRate 80 \
        -countRandomLoadRate 1 \
        -minFpsRate 1000 \
        -minKbpsRate 64 \
        -txDelay 2 \
        -delayAfterTransmit 2 \
        -minRandomFrameSize 64 \
        -maxRandomFrameSize 1518 \
        -countRandomFrameSize 1 \
        -minIncrementFrameSize 64 \
        -stepIncrementFrameSize 64 \
        -maxIncrementFrameSize 1518 \
        -calculateLatency True \
        -latencyType cutThrough \
        -calculateJitter False \
        -enableDataIntegrity True \
        -enableBackoffIteration False \
        -enableSaturationIteration False \
        -enableStopTestOnHighLoss False \
        -enableBackoffUseAs% False \
        -backoffIteration 1 \
        -saturationIteration 1 \
        -stopTestOnHighLoss 0 \
        -loadType binary \
        -stepLoadUnit percentMaxRate \
        -customLoadUnit percentMaxRate \
        -comboLoadUnit percentMaxRate \
        -binaryLoadUnit percentMaxRate \
        -initialBinaryLoadRate $arg(initialRate) \
        -minBinaryLoadRate $arg(minRate) \
        -maxBinaryLoadRate $arg(maxRate) \
        -binaryResolution $arg(resolution) \
        -binaryBackoff 50 \
        -binaryTolerance $arg(tolerance) \
        -binaryFrameLossUnit % \
        -comboFrameLossUnit % \
        -stepFrameLossUnit % \
        -initialStepLoadRate 10 \
        -maxStepLoadRate 100 \
        -stepStepLoadRate 10 \
        -stepTolerance 0 \
        -initialComboLoadRate 10 \
        -maxComboLoadRate 100 \
        -minComboLoadRate 10 \
        -stepComboLoadRate 10 \
        -comboResolution 1 \
        -comboBackoff 50 \
        -comboTolerance 0 \
        -binarySearchType linear \
        -unchangedValueList {0} \
        -enableFastConvergence False \
        -fastConvergenceDuration 10 \
        -rfc2889ordering noOrdering \
        -floodedFramesEnabled False \
        -fastConvergenceThreshold 10 \
        -framesizeFixedValue 128 \
        -gap 3 \
        -unchangedInitial False \
        -generateTrackingOptionAggregationFiles False \
        -enableExtraIterations False \
        -extraIterationOffsets {10, -10} \
        -usePercentOffsets False \
        -imixDistribution weight \
        -imixAdd {0} \
        -imixDelete {0} \
        -imixData {{{{64}{{TOS S:0 S:0 S:0 S:0 S:0} S:0}{1 40}}{{128}{{TOS S:0 S:0 S:0 S:0 S:0} S:0}{1 30}}{{256}{{TOS S:0 S:0 S:0 S:0 S:0} S:0}{1 30}}}} \
        -imixEnabled False \
        -imixTemplates none \
        -framesizeImixList $arg(frameSizeList) \
        -imixTrafficType {ipv4} \
        -ipRatioMode fixed \
        -ipv4RatioList {10,25,50,75,90} \
        -ipv6RatioList {90,75,50,25,10} \
        -minIncrementIpv4Ratio {10} \
        -stepIncrementIpv4Ratio {10} \
        -maxIncrementIpv4Ratio {90} \
        -minIncrementIpv6Ratio {90} \
        -stepIncrementIpv6Ratio {-10} \
        -maxIncrementIpv6Ratio {10} \
        -minRandomIpv4Ratio {10} \
        -maxRandomIpv4Ratio {90} \
        -minRandomIpv6Ratio {90} \
        -maxRandomIpv6Ratio {10} \
        -countRandomIpRatio 1 \
        -mapType {oneToOne|manyToMany|fullMesh} \
        -supportedTrafficTypes {mac,ipv4,ipv6,ipmix}
    ixNet setMultiAttrs $sg_rfc2544throughput/learnFrames \
        -learnFrequency oncePerFramesize \
        -learnNumFrames 10 \
        -learnRate 100 \
        -learnWaitTime 1000 \
        -learnFrameSize 64 \
        -fastPathLearnFrameSize 64 \
        -learnWaitTimeBeforeTransmit 0 \
        -learnSendMacOnly False \
        -learnSendRouterSolicitation False \
        -fastPathEnable False \
        -fastPathRate 100 \
        -fastPathNumFrames 10
    ixNet setMultiAttrs $sg_rfc2544throughput/passCriteria \
        -passCriteriaLoadRateMode average \
        -passCriteriaLoadRateValue 100 \
        -passCriteriaLoadRateScale mbps \
        -enablePassFail False \
        -enableRatePassFail False \
        -enableLatencyPassFail False \
        -enableStandardDeviationPassFail False \
        -latencyThresholdValue 10 \
        -latencyThresholdScale us \
        -latencyThresholdMode average \
        -latencyVariationThresholdValue 0 \
        -latencyVariationThresholdScale us \
        -latencyVarThresholdMode average \
        -enableSequenceErrorsPassFail False \
        -seqErrorsThresholdValue 0 \
        -seqErrorsThresholdMode average \
        -enableDataIntegrityPassFail False \
        -dataErrorThresholdValue 0 \
        -dataErrorThresholdMode average
    sg_commit
    set sg_rfc2544throughput [lindex [ixNet remapIds $sg_rfc2544throughput] 0]
    puts "COMPLETED: add rfc2544 quicktest"
    # configuring the object that corresponds to /quickTest/rfc2544throughput:1/frameData
    set sg_frameData $sg_rfc2544throughput/frameData
    ixNet setMultiAttrs $sg_frameData \
        -trafficType ipv4 \
        -automatic False \
        -showManualQoS True \
        -showManualPriorityMv True
    sg_commit
    set sg_frameData [lindex [ixNet remapIds $sg_frameData] 0]
    
    # configuring the object that corresponds to /quickTest/rfc2544throughput:1/frameData/manualIp:x
    set_quicktest_manualip $sg_frameData
    
    # configuring the object that corresponds to /quickTest/rfc2544throughput:1/trafficMapping
    set sg_trafficMapping $sg_rfc2544throughput/trafficMapping
    ixNet setMultiAttrs $sg_trafficMapping \
        -name {Traffic Mapping Page} \
        -bidirectional $arg(BiDirectional) \
        -hasTimingPort False \
        -mesh oneToOne \
        -timingPortId {0}
    sg_commit
    set sg_trafficMapping [lindex [ixNet remapIds $sg_trafficMapping] 0]
    
    # configuring the object that corresponds to /quickTest/rfc2544throughput:1/trafficMapping/map:1
    set sg_map [ixNet add $sg_trafficMapping map]
    ixNet setMultiAttrs $sg_map \
        -setName {Endpoint Set-1} \
        -source {$chassis:$txport-Ethernet} \
        -sourceId $tx_vport \
        -destination {$chassis:$rxport-Ethernet} \
        -destinationId $rx_vport
    sg_commit
    set sg_map [lindex [ixNet remapIds $sg_map] 0]
    
    # configuring the object that corresponds to /quickTest/rfc2544throughput:1/endpointMode
    set sg_endpointMode $sg_rfc2544throughput/endpointMode
    sg_commit
    set sg_endpointMode [lindex [ixNet remapIds $sg_endpointMode] 0]

    set_quicktest_port $sg_rfc2544throughput
    
    # configuring the object that corresponds to /quickTest/rfc2544throughput:1/trafficSelection:1
    set sg_trafficSelection [ixNet add $sg_rfc2544throughput trafficSelection]
    ixNet setMultiAttrs $sg_trafficSelection \
        -id $sg_trafficItem \
        -includeMode inTest \
        -isGenerated True \
        -itemType trafficItem
    sg_commit
    set sg_trafficSelection [lindex [ixNet remapIds $sg_trafficSelection] 0]
    ixNet commit
    puts "COMPLETED: quicktest settings"
}

set_global_options
set_vport
set_availableHardware
set_impairment
set_traffic
set_quicktest
#ixNet exec start $sg_rfc2544throughput
puts "COMPLETED: config"
puts "start run quicktest"
ixNet exec run $sg_rfc2544throughput
set resultPath [ixNet getAttr $sg_rfc2544throughput/results -resultPath]
puts "result path: $resultPath"
