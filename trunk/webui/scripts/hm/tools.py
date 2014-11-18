# -*- coding: UTF-8 -*-
#tools.py -r http://${sta.ip}:4444/wd/hub -t ie -f LogFile --parameters tool.name=set_image_to_boot ap.mgt0_ip=${}

from webui import safe_call, WebUI
from webui.hm import HM

@safe_call
def tools():
    wui = WebUI()
    hm = HM()
    if wui.session_id is None:
        if wui.d("tool.name") == "remove_ap_vhm":
            hm.login(wui.d("login.server"),
                     wui.d("remove_ap_vhm.vhm_name"),
                     wui.d("login.password"))
        else:
            hm.login(wui.d("login.server"),
                     wui.d("login.username"),
                     wui.d("login.password"))
    if wui.d("tool.name") == "set_image_to_boot":
        hm.to_hiveaps_table()
        hm.set_image_to_boot(wui.d("ap.mgt0_ip"))             
    elif wui.d("tool.name") == "get_tech_data":
        hm.to_hiveaps_table()
        hm.get_tech_data(wui.d("ap.mgt0_ip"))
    elif wui.d("tool.name") == "ssh_client":
        hm.to_hiveaps_table()
        hm.ssh_client(wui.d("ap.mgt0_ip"))
    elif wui.d("tool.name") == "get_connection":
        hm.to_hiveaps_table()
        hm.get_ap_status(wui.d("ap.mgt0_ip"), "connection")
    elif wui.d("tool.name") == "view_config":
        hm.to_hiveaps_table()
        hm.view_config(wui.d("ap.mgt0_ip"))
    elif wui.d("tool.name") == "remove_ap":
        hm.to_hiveaps_table()
        hm.remove_ap(wui.d("ap.mgt0_ip"))
    elif wui.d("tool.name") == "reassign_vhm":
        hm.to_hiveaps_table()
        hm.reassign_vhm(wui.d("ap.mgt0_ip"), wui.d("reassign_vhm.vhm_name"))        
    elif wui.d("tool.name") == "remove_policy":
        hm.remove_policy()        
    elif wui.d("tool.name") == "remove_ap_vhm":
        hm.to_hiveaps_table()
        hm.remove_ap_vhm()

if __name__ == '__main__':
    tools()