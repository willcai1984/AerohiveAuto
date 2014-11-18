# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud.page import *
import random
import time


@safe_call
def data_collect_default_config_push():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id:
        config.to_url_home()
        config.to_menu(wui.d("policy.menu_name"))
        config.wait_until_to_menu_success(wui.d("policy.menu_name"))
           
        wui.click(monitor_cfg.Configuration_button)
        wui.info( 'go to configuration page success' , True )

        wui.click(monitor_cfg.add_button)
        wui.info( 'go to add network policy page success' , True )
        policyname = wui.d( "sw_policy_name")
        wui.input(monitor_cfg.get( 'PolicyName_txt'), policyname)
        wui.input(monitor_cfg.get( 'PolicyDesc_txt'), wui.d("NetworkPolicy.PolicyDesc" ))
        wui.info( 'input policy name and description success' , True )
       
        wui.click(monitor_cfg.Next_button)
        wui.info( 'create network policy success', True )
       
        # go to addtional setting to check kddr default status of the created network policy
        wui.click(DeviceDataCollection.additional_setting_button)
        try:
            wui.wait_until_element_displayed(DeviceDataCollection.ntp_elements)
            wui.info( 'go to additional settings page success' , True ) 
        except Exception, e:
            wui.error( 'go to additional settings page failed' , True )
       
        #check the default sections displayed
        wui.info('try to click the data collection button...', True)
        wui.click(DeviceDataCollection.data_collection_btn)
        time.sleep(5)
        wui.wait_until_element_displayed(DeviceDataCollection.application_identify_xpath)
        wui.info( 'application visibility and control section displayed' , True )
        wui.wait_until_element_displayed(DeviceDataCollection.statistic_collection_xpath)
        wui.info( 'statistic collection section displayed' , True )
        wui.move_scroll_bottom()
        wui.wait_until_element_displayed(DeviceDataCollection.kddr_xpath)
        wui.info( 'kddr enable/disable section displayed', True)
       
        #click save button to save the configuration
        wui.click(DeviceDataCollection.data_collection_save_btn)
        wui.wait_until_element_displayed(DeviceDataCollection.data_collection_save_info)
        wui.info( 'the device data collection can be saved successfully' , True )
      
      
      
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
    data_collect_default_config_push()
