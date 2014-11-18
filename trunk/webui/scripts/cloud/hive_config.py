# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud import CLOUD
from webui.cloud.page import *
import random
import time


@safe_call
def hive_profile_create():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id:
        config.to_url_home()
        config.to_menu(wui.d("policy.menu_name"))
        config.wait_until_to_menu_success(wui.d("policy.menu_name"))
        config.to_page_before_policy()
        config.create_network_policy(wui.d("policy.name"), wui.d("policy.Description"))
       
        # go to addtional setting to check kddr default status of the created network policy
        wui.click(DeviceDataCollection.additional_setting_button)
        try:
            wui.wait_until_element_displayed(DeviceDataCollection.ntp_elements)
            wui.info( 'go to additional settings page success' , True ) 
        except Exception, e:
            wui.error( 'go to additional settings page failed' , True )
       
        #check hive profile section
        wui.info('try to click the Hive button to go to hive profile config page...', True)
        wui.click(HiveConfig.get('hive_tab'))
        time.sleep(5)
        wui.wait_until_element_displayed(HiveConfig.get('hive_profile_title'))
        wui.info( 'success to go to hive profile page...' , True )
        #input hive name
        hive_name = wui.d( "hive.name") 
        wui.input(HiveConfig.get('new_hive_name'), hive_name)
        wui.info( 'input hive name successfully...' , True )
        #input encryption password
        wui.info('go to security section and turn on the switch for encryption password...', True)
        config.check_cloud_on(HiveConfig.get('encryption_switch_input'),HiveConfig.get('encryption_switch_div'))
        time.sleep(1)
        wui.info("turn on the switch successfully...", True)
        wui.info("try to click the button manual and input password...", True)
        config.click_cloud(HiveConfig.get('manual_pwd_btn_input'),HiveConfig.get('manual_pwd_btn_div'))
        time.sleep(1)
        wui.info('success to select the encryption type as manual...', True)
        wui.input(HiveConfig.get('manual_share_pwd'),wui.d("hive.key"))
        time.sleep(1)
        wui.info('input share password successfully', True)
        wui.input(HiveConfig.get('manual_cfm_pwd'),wui.d("hive.key"))
        time.sleep(1)
        wui.info('input confirm password successfully', True)
        
        wui.info('click save button to save the hive profile setting...', True)
        wui.click(HiveConfig.get('hive_profile_save_btn'))
        wui.wait_until_element_displayed(HiveConfig.get('hive_profile_success'))
        time.sleep(1)
        wui.info( 'save the hive profile setting successfully', True)
        
        wui.info('click next buttong to go to deploy config to device page....', True)
        wui.click(HiveConfig.get('hive_profile_next_btn'))
        time.sleep(1)
        wui.info('go to config deploy page success....', True)
       
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
    hive_profile_create()
