#!/usr/bin/python
# -*- coding: utf-8 -*-

from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud.page import *
import random
import time

@safe_call
def firewall_rule_create():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id:
        config.to_page_before_deployed_ssid()
        # input ssid name
        ssidname=wui.d("ssid.name")
        wui.move_scroll_top()
        config.input_ssid_name(ssidname, ssidname)
        config.ssid_usage_settings('CUSTOM')
        config.set_access_security('open')
        config.wait_deploy_element(2)

        config.to_customize_user_profile_page()
        
        wui.move_scroll_by_element(FireWall.get('user_profile_tabs'))
        wui.info('move to user-profile tabs successfully!', True)

        wui.click(FireWall.get('security_tab_btn'))
        wui.info('go to security tab successfully', True)

        wui.info('try to turn on the switch to enable firewall', True)
        wui.check(FireWall.get('firewall_switch'))

        wui.move_scroll_bottom()

        #click dropdown box for firewall rules
        wui.click(FireWall.get('bound_traffic_dropdown_btn'))
        wui.info('click the dropdown box button successfully', True)
        wui.wait_until_element_displayed(FireWall.get('inbound_traffic_element'))
        wui.wait_until_element_displayed(FireWall.get('outbound_traffic_element'))
        wui.info('can display the inbound/outbound elements successfully', True)

        #select outbound traffic
        wui.click(FireWall.get('outbound_traffic_element'))

        outbound_traffic_element = "Outbound Traffic"
        selected_bound_traffic_element = wui.find_element(FireWall.get('bound_traffic_selected')).text
        if outbound_traffic_element == selected_bound_traffic_element:
            wui.info('selected the outbound element successfully', True)
        else:
            wui.error('failed selected the bound element', True)

        #config firewall rules default action
        wui.wait_until_element_displayed(FireWall.get('firwall_defaction_area'))
        wui.info('display firewall rules default action area sucessfully!', True)


        #select the firewall rules default actions is permit
        wui.info('Try to click the dropdown box...', True)
        wui.click(FireWall.get('firewall_defaction_dropdown_btn'))
        wui.wait_until_element_displayed(FireWall.get('firewall_defaction_deny_element'))
        wui.wait_until_element_displayed(FireWall.get('firewall_defaction_permit_element'))
        wui.info('Click the dropdown box success.....', True)
        wui.click(FireWall.get('firewall_defaction_permit_element'))
        wui.info('Success to select action Permit for firewall rules!', True)

        #add a new ip policy rules
        wui.click(FireWall.get('firewall_new_btn'))
        wui.wait_until_element_displayed(FireWall.get('new_firewall_page_title'))
        wui.info('go to new firewall page success', True)
        config.wait_deploy_element(1)


        config.user_profile_srcurce_ip(wui.d("userprofile.src_hostname"), wui.d("userprofile.src_hostip"))
        wui.info('selected the srcurce ip address successfully', True)
        config.user_profile_destination_ip(wui.d("userprofile.des_hostname"), wui.d("userprofile.des_hostip"))
        wui.info('selected the destination ip address successfully', True)
        config.user_profile_select_net_service()
        wui.info('handle to select service successfully', True)




        #config the rule action:
        wui.info('try to config the rule action as Deny', True)
        wui.click(FireWall.get('new_rule_action_btn'))
        wui.wait_until_element_displayed(FireWall.get('new_rule_action_nat'))
        wui.info('click the action dropdown box successfully', True)
        wui.info('try to select the deny action....', True)
        wui.click(FireWall.get('new_rule_action_deny'))
        wui.info('success to select the deny action...', True)
        
        #config the rule logging action:
        wui.info('try to config logging action as drop', True)
        wui.click(FireWall.get('new_rule_log_btn'))
        wui.wait_until_element_displayed(FireWall.get('new_rule_log_off'))
        wui.info('click the logging dropdown box successfully', True)
        wui.info('try to select drop packets....', True)
        wui.click(FireWall.get('new_rule_log_drop'))
        wui.info('success to select the drop logging...', True)
        
        #save the new ip firewall rule
        wui.info('try to save the ip rule setting...', True)
        wui.click(FireWall.get('new_rule_dialog_save'))
        wui.info('save the ip firewall rule success...', True)
        
        #check if the added ip rule correct
        wui.info('try to move scroll to bottom....', True)
        wui.move_scroll_bottom()
        wui.info('check if the added ip rule correct!...', True)
        added_rule_record = (FireWall.get('added_rule_record')[0], FireWall.get('added_rule_record')[1] %(wui.d("userprofile.src_hostname")))
        wui.wait_until_element_displayed(added_rule_record)
        wui.info('success to add ip firewall rule...', True)

        wui.info('Try to click save button to save the user-profile changing')
        wui.click(FireWall.get('user_profile_save_btn'))
        wui.info("Save user-profile success!", True)
        
        # save the ssid level configuration
        wui.click(FireWall.get('ssid_saved_btn'))
        wui.wait_until_element_displayed(FireWall.get('ssid_saved_success'))
        wui.info('Save ssid successfully', True)

        
if __name__ == '__main__':
    firewall_rule_create()