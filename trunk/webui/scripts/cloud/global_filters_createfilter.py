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

def check_device_devicepage(wui, ap_mac):
    #self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
    #self.w.info('handle to deploy policy', True)
    mac_element = myHome.get('Mac_device_page')
    
    #stat_element =  DeployPolicy.get('stat_xpath')
    i=1
    while 1:
        new_mac_element = (mac_element[0], mac_element[1] % i)
        print new_mac_element
        #new_stat_element = (stat_element[0], stat_element[1] % i)
        try:
            #self.w.wait_until_element_displayed(new_mac_element)
            if ap_mac == wui.find_element(new_mac_element).text:
                print wui.find_element(new_mac_element).text
                wui.info('find the target device', True)
                if i == 1:
                    wui.info('yes, there is only one device', True)
                else:
                    wui.error('not only one device', True)
                break        
        except Exception, e:
            wui.error('not found ', True)
            break
        i+=1

        
@safe_call
def hshao_login():
    wui = WebUI()
    cloud = CLOUD(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id:
        wui.click(myHome.get('Add_device_button'))
        wui.info('go to add device page', True)
        
        wui.input(myHome.get('Add_networkPolicy'), wui.d("visit.network_policy_name"))
        wui.info('go to add network policy page', True)
        
        wui.click(myHome.get('Next_button_networkPolicy'))
        wui.info('save network policy', True)
        
        wui.click(PolicyPage.get('Deploy_button'))
        wui.info('to device page', True)

        mac_element = DeployPolicyPage.get('Device_mac_xpath')
        checkbox_element = DeployPolicyPage.get('Device_checkbox_xpath')
        stat_element =  DeployPolicyPage.get('Device_stat_xpath')
        
        device_mac = wui.d("device.ap_mac")    
        i=1
        while 1:
            new_mac_element = (mac_element[0], mac_element[1] % i)
            new_checkbox_element = (checkbox_element[0], checkbox_element[1] % i)
            new_stat_element = (stat_element[0], stat_element[1] % i)
            try:
                wui.wait_until_element_displayed(new_mac_element)
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
        
        wui.click(myHome.get('Devices_button'))
        wui.info('go to add device page', True)
        
        click_netpolicy_devicepage_filters(wui,wui.d("visit.network_policy_name"))
        wui.click(FiltersDevicepage.get('check_box_realdevice'))
        
        ap_mac = wui.d("device.ap_mac")
        print "the ap mac is :"
        print ap_mac
        check_device_devicepage(wui, ap_mac)
        
if __name__ == '__main__':
    hshao_login()
