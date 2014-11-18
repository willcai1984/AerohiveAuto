# -*- coding: UTF-8 -*-
__author__ = 'Tiesong'
#Before run this script, navigate into a Network Policy.

from webui import safe_call, WebUI
from webui.apollo_gui.operation.OPERATION_DeviceTemplate import DeviceTemplate

@safe_call
def radio_profile_cfg():
    wui = WebUI()
    template = DeviceTemplate(wui.d("visit.url"), wui.d("visit.title"))
    template.create_radio_profile(wui.d("radio_profile.name"))
    template.wait_until_create_radio_profile_result(wui.d("radio_profile.success_msg"), check_success=wui.d("radio_profile.check_success"))
    template.save_device_template()
    
    
if __name__ == '__main__':
    radio_profile_cfg()
    