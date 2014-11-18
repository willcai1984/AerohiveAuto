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
        config.to_url_home()
        config.to_menu(wui.d("policy.menu_name"))
        config.wait_until_to_menu_success(wui.d("policy.menu_name"))
        config.to_page_before_policy()
        config.create_network_policy(wui.d("policy.name"), wui.d("policy.Description"))
        wui.wait_until_element_displayed(SelectSSIDPage.get('new_btn'))
        wui.info('Get to SSID select page', True)
        wui.click(SelectSSIDPage.get('new_btn'))  
        #input ssid name
        ssidname=wui.d("ssid.name")
        wui.wait_until_element_displayed(ConfigSSIDPage.get('ssidname_input'))
        wui.info('Get to SSID configure page', True)
        wui.input(ConfigSSIDPage.get('ssidname_input'), ssidname)
        wui.clear(ConfigSSIDPage.get('ssidbroadname_input'))
        wui.input(ConfigSSIDPage.get('ssidbroadname_input'), ssidname)
        wui.info('Input SSID name successfully', True)
                
        #select customer checkbox
        wui.wait_until_element_displayed(DeployedSSID.get('custom_display'))
        wui.click(DeployedSSID.get('custom_span'))
        time.sleep(1)
        wui.info('Select custom option successfully', True)
        
        #select open auth checkbox
        wui.info("Enter to Open mode")
        wui.info('will move scroll to next access security section', True)
        wui.move_scroll_to_element(DeployedSSID.get('access_div'))
        wui.wait_until_element_displayed(DeployedSSID.get('open_access_label'))
        wui.click(DeployedSSID.get('open_access_span'))
        wui.info('Config open successfully', True)
        
        #check optional setting section for mac filter is displayed
        wui.info('will move scroll to bottom page', True)
        wui.move_scroll_bottom()
        wui.wait_until_element_displayed(MacFilter.get('optional_setting_desc_xpath'))
        
        #optional setting page title diplay
        wui.info('Try to click customize button to go to config page', True)
        wui.click(MacFilter.get('opt_customize_btn'))
        wui.info('go to optional setting config page successfully', True)
        
        #go to mac filter config sections
        #enable mac-filter function
        wui.click(MacFilter.get('mac_filter_checkbox'))
        wui.info('mac filter is enabled!', True)
        
        #check the default action is Permit
        global_default_action = "Permit"
        new_global_default_action = wui.find_element(MacFilter.get('mac_filter_default_action')).text
        if global_default_action == new_global_default_action:
            wui.info('the global default action is Permit, it is correct for default setting', True)
        else:
            wui.error('The default action is incorrect!', True)
            
        #click new to add an mac filter entry, for exmaple for apples devices
        wui.info('Try to move to add new mac filter entry section', True)
        wui.move_scroll_to_element_use_px(MacFilter.get('mac_filter_section'))
        wui.info('move to mac filter config section success', True)
        wui.click(MacFilter.get('mac_filter_entry_new_btn'))
        wui.wait_until_element_displayed(MacFilter.get('mac_filter_newentry_input_mac'))
        wui.info('the new mac filter section display success!', True)
        #select apple devices oui
        wui.click(MacFilter.get('mac_filter_newentry_select_mac_btn'))
        wui.wait_until_element_displayed(MacFilter.get('mac_entry_oui_apple'))
        wui.info('can show the mac list success!', True)
        wui.click(MacFilter.get('mac_entry_oui_apple'))
        wui.info('select the apple devices oui success!', True)
        #select the mac entry action as deny
        wui.click(MacFilter.get('mac_entry_action_btn'))
        wui.info('click the dropdown box success!', True)
        tmp_mac_entry_action=wui.find_element(MacFilter.get('mac_entry_action_deny')).text
        selected_mac_entry_action = tmp_mac_entry_action.upper()
        wui.click(MacFilter.get('mac_entry_action_deny'))
        wui.info('select the deny action success!', True)
        #add the mac entry
        wui.click(MacFilter.get('mac_entry_add_btn'))
        wui.info('add the mac entry success!', True)
        
        # click save button to save the config about optional settings
        
        new_mac_entry_oui = wui.find_element(MacFilter.get('added_mac_entry_oui_name')).text
        new_mac_entry_action = wui.find_element(MacFilter.get('added_mac_entry_action')).text


        if (new_mac_entry_oui == "Apple-iPhone") and (new_mac_entry_action == selected_mac_entry_action):
            wui.info('mac filter object is correct....', True)
        else:
            wui.error('mac-filter object is incorrect....', True)
            
        wui.click(MacFilter.get('optional_setting_save_btn'))
        
        # save the ssid level configuration
        wui.click(MacFilter.get('ssid_saved_btn'))
        wui.wait_until_element_displayed(MacFilter.get('ssid_saved_success'))
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