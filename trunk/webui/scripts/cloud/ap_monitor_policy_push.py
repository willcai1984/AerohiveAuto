# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud import CLOUD
from webui.cloud.page import *
import random


@safe_call

def ap_monitor_config_push():
    wui = WebUI()
    cloud = CLOUD(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id is None:
        wui.info('trying to access %s before login' % wui.d("visit.url"))
        cloud.try_again_get(wui.d("visit.url"), NewLoginPage.get('newlogin_page_title'))
        
        try:
            wui.wait_until_element_displayed(NewLoginPage.get('newinvitation_txt'))
            wui.wait_until_element_displayed(NewLoginPage.get('newinvitation_btn'))
            wui.input(NewLoginPage.get('newinvitation_txt'), wui.d("login.invitation_code"))
            wui.info('handle invitation code ok', True)
            wui.click(NewLoginPage.get('newinvitation_btn'))
        except Exception, e:
            wui.warn('not found invitation info', True)

        wui.wait_until_element_displayed(NewLoginPage.get('newlogin_btn'))
        wui.input(NewLoginPage.get('newusername_txt'), wui.d("login.username"))
        wui.input(NewLoginPage.get('newpassword_txt'), wui.d("login.password"))
        wui.info('handle login form', True)
        wui.click(NewLoginPage.get('newlogin_btn'))

        try:
            wui.wait_until_title_present(NewLoginSuccessfulPage.get('login_successful_page_title'), info=True)
            wui.info('login success', True)
        except Exception, e:
            wui.s.execute_script('return window.onbeforeunload=null')
            wui.warn('Fail to get login_successful_page after login, will try again', True)
            wui.s.refresh()
            wui.wait_until_title_present(NewLoginSuccessfulPopupPage.get('newnewlogin_successful_popup_page_title'), info=True)
            
        wui.click(monitor_cfg.Configuration_button)
        wui.info('go to configuration page success', True)
        
        wui.click(monitor_cfg.Add_button)
        wui.info('go to add network policy page success', True)
        
        policyname = wui.d("NetworkPolicy.PolicyName") + str(random.randrange(1000))
        wui.input(monitor_cfg.get('PolicyName_txt'), policyname)
        wui.input(monitor_cfg.get('PolicyDesc_txt'), wui.d("NetworkPolicy.PolicyDesc"))
        wui.info('input policy name and description success', True)
        
        wui.click(monitor_cfg.Next_button)
        wui.info('create network policy success', True)
        
        wui.click(monitor_cfg.DeviceTemp_button)
        wui.info('go to device template creation page', True)
        
        wui.click(monitor_cfg.NewDevice_button)
        wui.click(monitor_cfg.NewDevice_ap_button)
        wui.click(monitor_cfg.NewDevice_ap_type_button)
        
        ap_template_name = wui.d("TemplateName.ap_tmp_name") + str(random.randrange(1000))
        wui.input(monitor_cfg.get('Device_template_name_txt'), ap_template_name)
        wui.info('input ap device template name success', True)
        
        wui.click(monitor_cfg.Device_template_save_button)
        wui.info('create device template success', True)
       
        wui.click(monitor_cfg.Deploy_policy_button)
        wui.info('go to deploy policy page success', True)
                
        mac_element = monitor_cfg.get('Device_mac_xpath')
        checkbox_element = monitor_cfg.get('Device_checkbox_xpath')
        stat_element =  monitor_cfg.get('Device_stat_xpath')
        
        device_mac = "E01C41256180"        
        i=1
        while 1:
            new_mac_element = (mac_element[0], mac_element[1] % i)
            new_checkbox_element = (checkbox_element[0], checkbox_element[1] % i)
            new_stat_element = (stat_element[0], stat_element[1] % i)
            wui.info("test1", True)
            try:
                wui.info("test2", True)
                wui.wait_until_element_displayed(new_mac_element)
                wui.info("test3", True)
                wui.info(wui.find_element(new_mac_element).text, True)
                if device_mac == wui.find_element(new_mac_element).text:
                    try:
                        wui.wait_until_element_displayed(new_stat_element)
                    except Exception, e:
                        wui.error('this device status is false disconnect', True)
                        break
                    wui.click(new_checkbox_element)
                    wui.info('selected the checkbox success', True)
                    break
            except Exception, e:
                wui.error('device is not found in device list', True)
                break
            i+=1        
        
        wui.click(monitor_cfg.Config_upload_button)
        wui.info('click upload to push complete config', True)
        
        
if __name__ == '__main__':
    ap_monitor_config_push()
