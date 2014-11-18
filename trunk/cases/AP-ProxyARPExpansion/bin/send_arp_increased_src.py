#!/usr/bin/python
# Filename: send_arp_increased_src.py
# Function: Send more arp pkts
# coding:utf-8
# Author: Will
# Example command: console.py -i 782 -e tb1-ap350-3 -v "show run" -d localhost -u admin -p aerohive -m "AH.*#"
# Transmit command: console -M localhost tb1-ap350-3 -f -l root

# Send a lot of arp request packets to dst-ip, who's src-mac and src-ip is increased.
# $1: parameter of pkt -i,  specify outgoing interface
# $2: parameter of pkt -d,  set destination ip
# $3: parameter of pkt -N, set destination mac address
# $4: packet numbet you want to send

# argv0:dst_ip
# argv1:loop

from scapy.all import *
import sys,os

def main():
    input_list = sys.argv
    dst_ip = input_list[1]
    loop = input_list[2]

    for i in range(int(loop)):
        mac_ip1=(i+1)/200
        mac_ip2=(i+1)%200
        src_ip="192.168.%s.%s" % (mac_ip1,mac_ip2)
        mac="000c%04d%04d" % (mac_ip1,mac_ip2)
        src_mac=mac[:2]+':'+mac[2:4]+':'+mac[4:6]+':'+mac[6:8]+':'+mac[8:10]+':'+mac[10:]
        pkt=Ether(dst="ff:ff:ff:ff:ff:ff",src=src_mac)/ARP(pdst=dst_ip, hwdst="00:00:00:00:00:00",psrc=src_ip, hwsrc=src_mac)
        sendp(pkt)
        print "SrcIP %s, SrcMac %s done" % (src_ip,src_mac)

    return True
            
if __name__ == '__main__':
    exec_result = main()
    if exec_result:
        sys.exit(0)
    else:
        sys.exit(1)
