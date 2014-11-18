# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud.page import *
import time


@safe_call
def radio_profile_cfg():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id:
        config.to_url_home()
        config.to_menu(wui.d("policy.menu_name"))
        config.wait_until_to_menu_success(wui.d("policy.menu_name"))
        
        wui.click(radio_cfg.Configuration_btn)
        wui.info('go to configuration page success', True)
        
        wui.click(radio_cfg.Plus_btn)
        wui.info('go to add network policy page success', True)
        policy_name=wui.d("visit.network_policy_name")
        wui.input(radio_cfg.get('policy_name'), policy_name)
        wui.input(radio_cfg.get('Policy_Desc'), wui.d("networkpolicy.PolicyDesc"))
        wui.info('input policy name and description success', True)

        wui.click(radio_cfg.policy_save_btn)
        wui.info('...........', True)
        wui.info('save network policy success',True)
        
        
        wui.click(radio_cfg.policy_next_btn)
        wui.info('skip Wireless Connectivity configuration success',True)
        
        wui.click(radio_cfg.newdevice)
        wui.info('create device template success', True)
        
        wui.click(radio_cfg.accesspoint)
        wui.info('click access point success', True)
        
        ap_platform=wui.d("visit.ap.platform")
        if ap_platform == "AP330" or ap_platform =="AP350":
            wui.click(radio_cfg.AP330)
            wui.info('create AP330 device template success', True)
        elif ap_platform == "AP230":
            wui.click(radio_cfg.AP230)
            wui.info('create AP230 device template success', True)
        else:
            wui.info('the ap platform is incorrect', True)
            
        template_name = wui.d("visit.network_template_name")
        wui.input(radio_cfg.get('templatename'),template_name)
        wui.info('input AP330 device template name success', True)
            
        wui.click(radio_cfg.wifi0)
        wui.info('click 2.4GHz button success', True)
        
        wui.click(radio_cfg.assignBtn)
        wui.info('click ASSIGN button success', True)
        
        wui.click(radio_cfg.createNew)
        wui.info('click Create New button success', True)
        
        wifi0_profile_name=wui.d("visit.wifi0_mode_name")
        wui.input(radio_cfg.get('radioProfileName'),wifi0_profile_name)
        wui.info('input 2.4GHZ radio profile name success', True)
        
        wui.click(radio_cfg.lastsavebtn)      
        wui.info('save 2.4GHz radio profile', True)  
        
        wui.click(radio_cfg.unselect)
        wui.info('cancel 2.4GHz button success', True)
        
        wui.click(radio_cfg.wifi1)
        wui.info('click 5GHz button success', True)

        wui.click(radio_cfg.assignBtn)
        wui.info('click ASSIGN button success', True)
        
        wui.click(radio_cfg.createNew)
        wui.info('click Create New button success', True)
        
        wifi1_profile_name=wui.d("visit.wifi1_mode_name")
        wui.input(radio_cfg.get('radioProfileName1'),wifi1_profile_name)
        wui.info('input 5GHZ radio profile name success', True)
            
        wui.click(radio_cfg.lastsavebtn)
        wui.info('save 5GHz radio profile success', True)

        wui.click(radio_cfg.lastsavebtnagain)
        time.sleep(2)
        wui.info('save Device Templates success', True)
        
        wui.click(radio_cfg.nextBtn2)
        wui.info('go to Additional Settings page success', True)
        

if __name__ == '__main__':
     radio_profile_cfg()
