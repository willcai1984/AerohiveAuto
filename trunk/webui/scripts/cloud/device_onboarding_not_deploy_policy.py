# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Devices import Devices
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
            
def click_ipaddress_devicepage(self, ap_sn):
    #self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
    #self.w.info('handle to deploy policy', True)
    sn_element = myHome.get('SN_device_page')
    ip_element = myHome.get('Ip_device_page')
    #stat_element =  DeployPolicy.get('stat_xpath')
    i=1
    while 1:
        new_sn_element = (sn_element[0], sn_element[1] % i)
        new_ip_element = (ip_element[0], ip_element[1] % i)
        #new_stat_element = (stat_element[0], stat_element[1] % i)
        try:
            #self.w.wait_until_element_displayed(new_mac_element)
            if ap_sn == self.w.find_element(new_sn_element).text:
                print "find it"
                self.w.click(new_ip_element)
                print new_ip_element
                print "click it"
                break
        except Exception, e:
            self.w.error('not found ', True)
            break
        i+=1

def check_device_devicepage(wui, ap_SN):
    #self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
    #self.w.info('handle to deploy policy', True)
    SN_element = myHome.get('SN_device_page')
    
    #stat_element =  DeployPolicy.get('stat_xpath')
    i=1
    while 1:
        new_SN_element = (SN_element[0], SN_element[1] % i)
        print new_SN_element
        #new_stat_element = (stat_element[0], stat_element[1] % i)
        try:
            #self.w.wait_until_element_displayed(new_mac_element)
            if ap_SN == wui.find_element(new_SN_element).text:
                print "find the SN"
                print wui.find_element(new_SN_element).text
                wui.info('find the target device, the device has added successfully, SN =' +wui.find_element(new_SN_element).text, True)
                break    
        except Exception, e:
            wui.error('not found ', True)
            break
        i+=1

        
@safe_call
def device_onboarding_not_deploy_policy():
    wui = WebUI()
    device = Devices(wui.d("visit.url"), wui.d("visit.title"))
    if wui.session_id:
        #---------------------------------device on boarding ------------------------------------
        wui.click(myHome.get('Devices_button'))
        wui.info('go to add device page', True)           
        
        wui.click(DeviceOnboarding.get('Add_device_button'))
        wui.info('go to add device page', True)
        
        wui.click(DeviceOnboarding.get('Add_real_device_button'))
        wui.info('go to enter SN page', True)
        
        wui.input(DeviceOnboarding.get('Input_SN_Textarea'), wui.d("device.ap_SN"))
        wui.info('enter SN', True)
        
        wui.click(DeviceOnboarding.get('Next_button_add_SN_page'))
        wui.info('click of add sn page', True)
        
        wui.click(DeviceOnboarding.get('Next_button_added_device_page'))
        wui.info('click of added device list page', True)
        
        wui.check(DeviceOnboarding.get('Do_not_deploy_policy'))
        wui.info('click do not deploy policy', True)
        
        wui.click(DeviceOnboarding.get('Next_button_build_policy_page'))
        wui.info('click next of build policy', True)
        
        wui.click(DeviceOnboarding.get('Finish_button_device_onboarding'))
        wui.info('click finish button of device onboarding', True)        
        
        ap_SN = wui.d("device.ap_SN")
        check_device_devicepage(wui, ap_SN)
                     

if __name__ == '__main__':
    device_onboarding_not_deploy_policy()