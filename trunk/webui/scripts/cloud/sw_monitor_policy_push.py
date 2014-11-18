# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud.page import *
import random


@safe_call

def sw_monitor_config_push():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id:
        config.to_url_home()
        config.to_menu(wui.d("policy.menu_name"))
        config.wait_until_to_menu_success(wui.d("policy.menu_name"))
        #go to configuration page to config network policy     
        wui.info('try to new a network policy....', True)
        wui.click(monitor_cfg.get('add_button'))
        wui.info('create new network policy....', True)
        policy_name = wui.d("sw_policy_name")
        wui.input(monitor_cfg.get('PolicyName_txt'), policy_name)
        wui.input(monitor_cfg.get('PolicyDesc_txt'), wui.d("NetworkPolicy.PolicyDesc"))
        wui.info('input policy name and description success', True)
        
        wui.click(monitor_cfg.Next_button)
        wui.info('create network policy success', True)
        
        wui.click(monitor_cfg.DeviceTemp_button)
        wui.info('go to device template creation page', True)
        
        wui.click(monitor_cfg.NewDevice_button)
        wui.click(monitor_cfg.NewDevice_sw_button)
        wui.click(monitor_cfg.NewDevice_sw_type_button)
        
#        switch_template_name = wui.d("TemplateName.switch_tmp_name") + str(random.randrange(1000))
        switch_template_name = wui.d("sw_template_name")
        wui.input(monitor_cfg.get('Device_template_name_txt'), switch_template_name)
        wui.info('input switch device template name success', True)
        
        wui.click(monitor_cfg.Device_template_save_button)
        wui.info('create device template success', True)
       
#        wui.click(monitor_cfg.Deploy_policy_button)
#        wui.info('go to deploy policy page success', True)
#                
#        mac_element = monitor_cfg.get('Device_mac_xpath')
#        checkbox_element = monitor_cfg.get('Device_checkbox_xpath')
#        stat_element =  monitor_cfg.get('Device_stat_xpath')
        
#        device_mac = wui.d("dev_mgt0_mac")        
#        i=1
#        while 1:
#            new_mac_element = (mac_element[0], mac_element[1] % i)
#            new_checkbox_element = (checkbox_element[0], checkbox_element[1] % i)
#            new_stat_element = (stat_element[0], stat_element[1] % i)
#            try:
#                wui.wait_until_element_displayed(new_mac_element)
#                if device_mac == wui.find_element(new_mac_element).text:
#                    try:
#                        wui.wait_until_element_displayed(new_stat_element)
#                    except Exception, e:
#                        wui.error('this device status is false disconnect', True)
#                        break
#                    wui.click(new_checkbox_element)
#                    wui.info('selected the checkbox success', True)
#                    break
#            except Exception, e:
#                wui.error('device is not found in device list ', True)
#                break
#            i+=1        
#        
#        wui.click(monitor_cfg.Config_upload_button)
#        wui.info( 'click upload to push complete config', True)
#        wui.wait_until_element_displayed(monitor_cfg.upload_dialog_title)
#        wui.info('show device update dialog success...', True)
#        wui.click(monitor_cfg.upload_dialog_btn)
#        wui.wait_until_element_displayed(monitor_cfg.upload_success_msg)
#        wui.info('upload config to device successfully', True)
        
        
if __name__ == '__main__':
    sw_monitor_config_push()
