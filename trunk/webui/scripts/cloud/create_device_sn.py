#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import safe_call, WebUI
from webui.cloud.Devices import Devices

@safe_call
def create_device_sn():
    wui = WebUI()
    d = Devices(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id:
        d.to_url_home()
        d.to_menu(wui.d('devices.menu_name'))
        d.wait_until_to_menu_success(wui.d("devices.menu_name"))
        if d.check_sn_exist(wui.d('devices.sn_number')):
            wui.info('this is serial number is exist, do remove it.', True)
            d.remove_devices_by_serial_numbers(wui.d('devices.sn_number'))
        d.add_devices_by_serial_numbers(wui.d('devices.sn_number'))
    else:
        d.logout()


if __name__ == '__main__':
    create_device_sn()