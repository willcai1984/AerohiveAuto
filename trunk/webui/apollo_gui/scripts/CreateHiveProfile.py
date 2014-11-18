# -*- coding: UTF-8 -*-
__author__ = 'Tiesong'
#Click into a Network Policy before run this script.

from webui import safe_call, WebUI
from webui.apollo_gui.operation.OPERATION_AdditionalSettings import AdditionalSettings

@safe_call
def hive_profile_cfg():
    wui = WebUI()
    hivecfg = AdditionalSettings(wui.d("visit.url"), wui.d("visit.title"))
    hivecfg.create_hive(wui.d("hive.name"),wui.d("hive.traffic_port"),wui.d("hive.probeREQ_value"))
    hivecfg.wait_until_create_hive_profile_result(wui.d("hive.success_msg"), check_success=wui.d("hive.check_success"))
    
if __name__ == '__main__':
    hive_profile_cfg()