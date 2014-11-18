#!/usr/bin/python
# -*- coding: utf-8 -*-

from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud.page import *
import time
import random

@safe_call
def mac_filter_configuration():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id:
        config.to_page_before_deployed_ssid()
        ssidname=wui.d("ssid.name")
        config.input_ssid_name(ssidname, ssidname)
        config.ssid_usage_settings('CUSTOM')

        #select to security method as wpa psk  
        psk_key="aerohive"      
        wui.info('will move scroll to access security...', True)
        wui.move_scroll_to_element(DeployedSSID.get('access_div'))
        wui.wait_until_element_displayed(DeployedSSID.get('psk_access_label'))
        wui.click(DeployedSSID.get('psk_access_span'))
        wui.wait_until_element_displayed(DeployedSSID.get('psk_key_value'))
        wui.input(DeployedSSID.get('psk_key_value'), psk_key)
        wui.wait_until_element_displayed(DeployedSSID.get('psk_confirm_value'))
        wui.input(DeployedSSID.get('psk_confirm_value'), psk_key)
        
        #select cwp tab to config cwp
        cwp_name = wui.d("ssid.cwp_name")
        wui.info('try to click captive web portal tab to enable cwp', True)
        wui.move_scroll_to_element_use_px(CWPConfig.get('ssid_tab'))
        wui.click(CWPConfig.get('cwp_tab'))
        wui.wait_until_element_displayed(CWPConfig.get('cwp_enable_switch'))
        wui.info('go to  cwp configuration section successfully...', True)
        #enable cwp switch
        wui.check(CWPConfig.get('cwp_enable_switch'))
        wui.info('enable cwp successfull....', True)
        
        #config cwp web directory name
        wui.info('try to move element to cwp name input line....', True)
        wui.move_scroll_to_element(CWPConfig.get('cwp_name_input_element'))
        wui.input(CWPConfig.get('cwp_to_use_input'),cwp_name)
        time.sleep(1)
        wui.info('input cwp name successfully', True)
        
        wui.info('try to click the save button to save the cwp object', True)
        wui.click(CWPConfig.get('cwp_to_use_save'))
        wui.wait_until_element_displayed(CWPConfig.get('new_cwp_title'))
        time.sleep(1)
        wui.info('go to new cwp page success...', True)
        
        wui.wait_until_element_displayed(CWPConfig.get('cwp_name'))
        wui.click(CWPConfig.get('new_cwp_save'))
        time.sleep(2)
        wui.info('try to move scroll to cwp section', True)
        wui.move_scroll_to_element(CWPConfig.get('cwp_name_input_element'))
        wui.info('create cwp successfully', True)
        
        # save the ssid level configuration
        wui.click(CWPConfig.get('new_ssid_save'))
        wui.wait_until_element_displayed(CWPConfig.get('new_ssid_success'))
        time.sleep(1)
        wui.info('Save ssid successfully', True)
        
        #go to deploy page, and push config
        wui.click(monitor_cfg.Deploy_policy_button)
        time.sleep(2)
        wui.info( 'go to deploy policy page success' , True )
        
       #go to deploy page, and push config
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
    mac_filter_configuration()