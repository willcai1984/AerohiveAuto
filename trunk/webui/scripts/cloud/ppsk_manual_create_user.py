# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud.page import *
import time


def click_netpolicy_devicepage_filters(wui,netpolicy_name):
    try:
        wui.wait_until_element_displayed(myHome.get('More_button'))
        wui.click(myHome.get('More_button'))
        wui.info('click more button', True)
        print "click more button"
    except:
        wui.info('not found more ....,start find netpolicy')    
    netpolicy_element = myHome.get('Name_netpolicy_filter')
    checkbox_element = myHome.get('Check_box_netpolicy')
    i=1
    while 1:
        print i
        new_netpolicy_element = (netpolicy_element[0], netpolicy_element[1] % i)
        print new_netpolicy_element
        new_checkbox_element = (checkbox_element[0], checkbox_element[1] % i)
        print new_checkbox_element
        #new_stat_element = (stat_element[0], stat_element[1] % i)
        try:
            print "try it"
            print netpolicy_name
            print wui.find_element(new_netpolicy_element).text
            #self.w.wait_until_element_displayed(new_mac_element)
            if netpolicy_name == wui.find_element(new_netpolicy_element).text:
                print "find it"
                print new_checkbox_element
                wui.click(new_checkbox_element)
                print new_netpolicy_element
                print "click it"
                wui.info('click the target netpolicy', True)
                break
        except Exception, e:
            wui.error('not found ', True)
            break
        if i == 4:
            i = i+2
        else:
            i = i+1
            
def click_to_add_user_of_usergroup(wui, usergroup_name):
    # name_of_usergroup_element = SsidPage.get('User_group_name_of_seletced_user_group_page')
    # num_of_user_of_usergroup_element = SsidPage.get('Num_of_user_of_selected_user_group_page')
    # #stat_element =  DeployPolicy.get('stat_xpath')
    # i=1
    # while 1:
    #     new_name_of_usergroup_element = (name_of_usergroup_element[0], name_of_usergroup_element[1] % i)
    #     new_num_of_user_of_usergroup_element = (num_of_user_of_usergroup_element[0], num_of_user_of_usergroup_element[1] % i)
    #     try:
    #         if usergroup_name == wui.find_element(new_name_of_usergroup_element).text:
    #             wui.click(new_num_of_user_of_usergroup_element)
    #             wui.info("click the unm of users of user group")
    #             break
    #     except Exception, e:
    #         wui.error('not found the defined usergroup name', True)
    #         break
    #     i+=1
    # Modify by hshao
    wui.wait_until_element_displayed(SsidPage.get('select_user_groups_tiitle'))
    user_group_element = (SsidPage.get('user_group_name_tr')[0], SsidPage.get('user_group_name_tr')[1] % usergroup_name)
    add_user_btn = (SsidPage.get('add_user_btn')[0], SsidPage.get('add_user_btn')[1] % usergroup_name)
    wui.wait_until_element_displayed(user_group_element)
    wui.info("handle to click the unm of users of user group")
    wui.click(add_user_btn)

        
def add_user_group_to_ssid_and_save(wui, usergroup_name):
    #self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
    #self.w.info('handle to deploy policy', True)
    # name_of_usergroup_element = SsidPage.get('User_group_name_of_seletced_user_group_page')
    # check_box_of_user_group_element = SsidPage.get('Check_box_of_user_group')
    # #stat_element =  DeployPolicy.get('stat_xpath')
    # i=1
    # while 1:
    #     new_name_of_usergroup_element = (name_of_usergroup_element[0], name_of_usergroup_element[1] % i)
    #     print new_name_of_usergroup_element
    #     new_check_box_of_user_group_element = (check_box_of_user_group_element[0], check_box_of_user_group_element[1] % i)
    #     print check_box_of_user_group_element
    #     #new_stat_element = (stat_element[0], stat_element[1] % i)
    #     print wui.find_element(new_name_of_usergroup_element).text
    #     try:
    #         #self.w.wait_until_element_displayed(new_mac_element)
    #         if usergroup_name == wui.find_element(new_name_of_usergroup_element).text:
    #             print "find the defined usergroup name"
    #             wui.click(new_check_box_of_user_group_element)
    #             print new_check_box_of_user_group_element
    #             print "click the check box of users of selected user group"
    #             wui.click(SsidPage.get('Save_button_select_user_group_button'))
    #             print "click save button of selected user group"
    #             break
    #     except Exception, e:
    #         wui.error('not found the defined usergroup name', True)
    #         break
    #     i+=1

    wui.wait_until_element_displayed(SsidPage.get('select_user_groups_tiitle'))
    user_group_element = (SsidPage.get('user_group_name_tr')[0], SsidPage.get('user_group_name_tr')[1] % usergroup_name)
    user_group_checkbox = (SsidPage.get('user_group_checkbox')[0], SsidPage.get('user_group_checkbox')[1] % usergroup_name)
    wui.wait_until_element_displayed(user_group_element)
    wui.click(user_group_checkbox)
    wui.info("handle to click save button of user group [%s]" %usergroup_name)
    wui.click(SsidPage.get('Save_button_select_user_group_button'))


def deploy_policy_to_device(wui, device_mac):
    mac_element = DeployPolicyPage.get('Device_mac_xpath')
    checkbox_element = DeployPolicyPage.get('Device_checkbox_xpath')
    stat_element =  DeployPolicyPage.get('Device_stat_xpath') 
    print device_mac
    i=1
    while 1:
        new_mac_element = (mac_element[0], mac_element[1] % i)
        new_checkbox_element = (checkbox_element[0], checkbox_element[1] % i)
        new_stat_element = (stat_element[0], stat_element[1] % i)
        try:
            wui.wait_until_element_displayed(new_mac_element)
            print wui.find_element(new_mac_element).text
            print new_mac_element
            if device_mac == wui.find_element(new_mac_element).text:
                print wui.find_element(new_mac_element).text
                try:
                    wui.wait_until_element_displayed(new_stat_element)
                except Exception, e:
                    wui.error('this device status is false disconnect', True)
                    break
                wui.click(new_checkbox_element)
                wui.info('selected the checkbox success', True)
                break
        except Exception, e:
            wui.error('device is not found in device list ', True)
            break
        i+=1        
    
    wui.click(monitor_cfg.Config_upload_button)
    wui.info('click upload to push complete config', True)

        
@safe_call
def ppsk_manual_create_user():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id:
        config.to_page_before_deployed_ssid()
        #---------------------------------add a user group ------------------------------------

        wui.input(SsidPage.get('Input_ssid_textarea'), wui.d("ssid.ssid_name"))
        wui.input(SsidPage.get('Input_ssid_boardcast_textarea'), wui.d("ssid.ssid_boardcast_name"))
        wui.info('handle input the name of ssid boardcast name', True)

        wui.info('will move scroll to access security...', True)
        wui.move_scroll_to_element(DeployedSSID.get('access_div'))
        wui.wait_until_element_displayed(DeployedSSID.get('access_8021x_label'))
        wui.click(SsidPage.get('Select_PPSK'))
        wui.info('select access security is private psk end.', True)
        
        wui.click(SsidPage.get('Add_user_group_button'))
        wui.info('ge to select user group page', True)
        
        wui.click(SsidPage.get('new_user_group_button'))
        wui.info('ge to create user group page', True)
        config.wait_deploy_element(1)
        
        wui.input(SsidPage.get('Input_user_group_name_textarea'), wui.d("ssid.user_group_name"))
        wui.info('input the name of user group name', True)
        config.wait_deploy_element(1)
        
        wui.click(SsidPage.get('Save_button_new_user_group_page'))
        wui.info('save the created user group', True)
        config.wait_deploy_element(1)
        
        click_to_add_user_of_usergroup(wui, wui.d("ssid.user_group_name"))
        wui.wait_until_element_displayed(SsidPage.get('user_account_list'))
        #---------------------------------add user to user group---------------------------------------------
        wui.click(SsidPage.get('Add_user_to_user_group_button'))
        wui.info('add user to user group', True)

        wui.input(SsidPage.get('Input_user_name_textarea'), wui.d("ssid.user_name"))
        wui.info('input the name of user', True)
        
        wui.input(SsidPage.get('Input_password_textarea'), wui.d("ssid.user_password"))
        wui.info('input the password of user', True)
        
        wui.input(SsidPage.get('Input_user_password_confirm_textarea'), wui.d("ssid.user_password"))
        wui.info('confirm the password of user', True)
        
        wui.click(SsidPage.get('Save_user_button'))
        wui.info('save the user', True)
        config.wait_deploy_element(1)
        wui.click(SsidPage.get('Cancel_button_of_user_in_user_group_page'))
        wui.info('to select usergroup page', True)

        config.wait_deploy_element(1)
        add_user_group_to_ssid_and_save(wui, wui.d("ssid.user_group_name"))
        wui.info('select the defiend user group and save', True)
        
        config.wait_deploy_element(1)
        wui.info('handle create a new ppsk ssid pic', True)
        wui.click(DeployedSSID.get('save_btn'))

        
if __name__ == '__main__':
    ppsk_manual_create_user()