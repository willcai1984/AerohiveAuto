#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'Tiesong'

from webui import safe_call, WebUI
from webui.apollo_gui.operation.OPERATION_WirelessConnectivity import Configuration

#===============================================================================
# This script starts from click to SSID page wizard.
#===============================================================================

@safe_call
def create_ipfw():
    wui = WebUI()
    ipfw = Configuration(wui.d("visit.url"), wui.d("visit.title"))
    ipfw.to_ssid_list_page()
    ipfw.to_new_ssid_page()
    ipfw.create_SSID_open(wui.d("ipfw.ssid_name"), wui.d("ipfw.ssid_name"))
    ipfw.create_firewall_policy()


if __name__ == '__main__':
    create_ipfw()