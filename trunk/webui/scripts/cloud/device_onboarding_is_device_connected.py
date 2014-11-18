# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud import CLOUD
from webui.cloud.page import *


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
            
def click_hostname_devicepage(wui, ap_sn):
    #self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
    #self.w.info('handle to deploy policy', True)
    sn_element = myHome.get('SN_device_page')
    host_element = myHome.get('Device_host_name')
    state_element = myHome.get('State_device_page')
    print host_element
    #stat_element =  DeployPolicy.get('stat_xpath')
    i=1
    while 1:
        print i
        new_sn_element = (sn_element[0], sn_element[1] % i)
        print new_sn_element
        new_host_element = (host_element[0], host_element[1] % i)
        new_state_element = (state_element[0], state_element[1] % i)
        print new_host_element
        print ap_sn
        print wui.find_element(new_sn_element).text
        #new_stat_element = (stat_element[0], stat_element[1] % i)
        try:
            #self.w.wait_until_element_displayed(new_mac_element)
            if ap_sn == wui.find_element(new_sn_element).text:
                print "find it"
                try:
                    wui.wait_until_element_displayed(new_state_element)
                    wui.info('The device state is connected of devicepage',True)
                except Exception, e:
                    wui.error('this device status is false disconnect', True)
                    break
                wui.click(new_host_element)
                print new_host_element
                print "click it"
                break
        except Exception, e:
            wui.error('not found ', True)
            break
        i+=1
        
def remove_device_devicepage(wui, ap_sn):
    #self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
    #self.w.info('handle to deploy policy', True)
    sn_element = myHome.get('SN_device_page')
    host_element = myHome.get('Device_host_name')
    state_element = myHome.get('State_device_page')
    check_box_element = myHome.get('Check_box_device_page')
    print host_element
    #stat_element =  DeployPolicy.get('stat_xpath')
    i=1
    while 1:
        print i
        new_sn_element = (sn_element[0], sn_element[1] % i)
        print new_sn_element
        new_host_element = (host_element[0], host_element[1] % i)
        new_state_element = (state_element[0], state_element[1] % i)
        new_check_box_element = (check_box_element[0], check_box_element[1] % i)
        print ap_sn
        print new_check_box_element
        #new_stat_element = (stat_element[0], stat_element[1] % i)
        try:
            #self.w.wait_until_element_displayed(new_mac_element)
            if ap_sn == wui.find_element(new_sn_element).text:
                print "find it"
                wui.click(new_check_box_element)
                print new_check_box_element
                wui.click(myHome.get('Remove_device_button'))
                print "click it remove device button"
                wui.info('click remove device button',True)
                break
        except Exception, e:
            wui.error('not found ', True)
            break
        i+=1

def check_device_devicepage(wui, ap_SN):
    #self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
    #self.w.info('handle to deploy policy', True)
    SN_element = myHome.get('SN_device_page')
    state_element = myHome.get('State_device_page')
    #stat_element =  DeployPolicy.get('stat_xpath')
    i=1
    while 1:
        new_SN_element = (SN_element[0], SN_element[1] % i)
        new_state_element = (state_element[0], state_element[1] % i)
        
        print new_SN_element
        #new_stat_element = (stat_element[0], stat_element[1] % i)
        try:
            #self.w.wait_until_element_displayed(new_mac_element)
            if ap_SN == wui.find_element(new_SN_element).text:
                print "find the SN"
                print wui.find_element(new_SN_element).text
                wui.info('find the target device, the device has added successfully, SN =' +wui.find_element(new_SN_element).text, True)
                try:
                    wui.wait_until_element_displayed(new_state_element)
                    wui.info('The device state is connected', True)
                except Exception, e:
                    wui.error('this device status is false disconnect', True)    
                    break
        except Exception, e:
            wui.error('not found ', True)
            break
        i+=1

        
@safe_call
def hshao_login():
    wui = WebUI()
    cloud = CLOUD(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id is None:
        wui.info('trying to access %s before login' % wui.d("visit.url"))
        cloud.try_again_get(wui.d("visit.url"), LoginPage.get('login_page_title'))


        wui.wait_until_element_displayed(LoginPage.get('login_btn'))
        wui.input(LoginPage.get('username_txt'), wui.d("login.username"))
        wui.input(LoginPage.get('password_txt'), wui.d("login.password"))
        wui.info('handle login form', True)
        wui.click(LoginPage.get('login_btn'))

        try:
            wui.wait_until_title_present(LoginSuccessfulPage.get('login_successful_page_title'), info=True)
            wui.info('login success', True)
        except Exception, e:
            wui.s.execute_script('return window.onbeforeunload=null')
            wui.warn('Fail to get login_successful_page after login, will try again', True)
            wui.s.refresh()
            wui.wait_until_title_present(LoginSuccessfulPopupPage.get('login_successful_popup_page_title'), info=True)
            
        #---------------------------------is device connected ------------------------------------
        wui.click(myHome.get('Devices_button'))
        wui.info('go to add device page', True)
        

        #ckeck if the device is connected and 
        ap_sn = wui.d("device.ap_SN")
        click_hostname_devicepage(wui, ap_sn)
         
        connection_status_element = myHome.get('Device_connect_status')
        new_connection_status_element = wui.find_element(connection_status_element).text
        device_connection_status_str = "Connected"
        if device_connection_status_str == new_connection_status_element:
            wui.info('The device status on is Connected', True)
        else:
            wui.error('The device status is not Connected', True)
             
        wui.click(myHome.get('Devices_button'))
        wui.info('go to add device page', True)
        
        remove_device_devicepage(wui, ap_sn)
        
        wui.click(myHome.get('Conform_to_remove_device_button'))
        wui.info('confirm to remove device', True)
        
            
        
        
if __name__ == '__main__':
    hshao_login()