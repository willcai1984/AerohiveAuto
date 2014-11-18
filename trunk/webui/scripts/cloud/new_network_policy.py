#!/usr/bin/python
# -*- coding: utf-8 -*-

from webui import safe_call, WebUI
from webui.cloud import CLOUD
import time

@safe_call
def new_network_policy():
    wui = WebUI()
    cloud = CLOUD(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id:
        cloud.to_url_home()
        cloud.unit_click_configure()
        cloud.unit_new_netpolicy()
        cloud.unit_config_netpolicy(wui.d("policy.name"))
        cloud.unit_new_ssid()
        cloud.unit_config_basicssid(wui.d("ssid.name"), wui.d("ssid.security"), wui.d("ssid.key"))
        #cloud.unit_select_all_ssid()
        cloud.unit_select_ssid(wui.d("ssid.name"))
        cloud.unit_click_devicetemplate()
        cloud.unit_click_additional()
        cloud.unit_uploadconfig(wui.d("device.mac"))

if __name__ == '__main__':
    new_network_policy()

