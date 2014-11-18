#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration

@safe_call
def create_deployed_ssid():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"))

    if wui.session_id:
        config.to_page_before_deployed_ssid()
        if 'OPEN' == wui.d("ssid.ssid_security").upper():
            config.create_SSID_open(wui.d("ssid.name"), wui.d("ssid.name"))
        elif 'PSK' == wui.d("ssid.ssid_security").upper():
            config.create_SSID_psk(wui.d("ssid.name"), wui.d("ssid.name"), wui.d("ssid.psk_key_value"))
        elif '8021X' == wui.d("ssid.ssid_security").upper():
            config.create_SSID_8021x(wui.d("ssid.name"), wui.d("ssid.name"),  \
                                wui.d("ssid.radius_server"), wui.d("ssid.radius_hostname"), \
                                wui.d("ssid.radius_host_ip"), wui.d("ssid.shared_secret"))

        config.wait_until_create_ssid_result(wui.d("ssid.success_msg"), check_success=wui.d("ssid.check_success"))
    else:
        config.deployedSSID_mode()
        config.logout()


if __name__ == '__main__':
    create_deployed_ssid()