# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Devices import Devices

@safe_call
def device_onboarding_use_existing_policy():
    wui = WebUI()
    print wui.d("visit.url")
    d = Devices(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id:
        d.to_url_home()
        d.to_menu(wui.d('device.menu_name'))
        d.wait_until_to_menu_success(wui.d("device.menu_name"))
        if d.check_sn_exist(wui.d('device.sn_number')):
            wui.info('this is serial number is exist', True)
            d.remove_devices_by_serial_numbers(wui.d('device.sn_number'))

        d.device_onboarding_exsit_policy(wui.d('device.sn_number'), \
                                              wui.d("device.network_policy_name"))

        if d.check_sn_exist(wui.d('device.sn_number')):
            wui.info('this is serial number is exist, device onboarding deploy exist policy successful!', True)
        else:
            wui.error('this is serial number is not exist, device onboarding deploy exist policy failed!', True)
            d.exception_thrown('this is serial number is not exist, device onboarding deploy exist policy failed!')
        
if __name__ == '__main__':
    device_onboarding_use_existing_policy()