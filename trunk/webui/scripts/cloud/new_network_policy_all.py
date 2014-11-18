#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'will'

from webui import safe_call, WebUI, WebElement
#from webui.cloud import CLOUD
import time

class TopMenu(WebElement):
    config_btn = ('xpath', '''//li[@data-dojo-attach-point='configurationtab']''')

class SelectPolicyPage(WebElement):
    new_btn = ('xpath', '''//li[@data-dojo-attach-point="newNetworkPolicy"]''')

class ConfigPolicyPage(WebElement):
    policyname_input = ('xpath', '''//input[@data-dojo-attach-point="policyName"]''')
    next_btn = ('xpath', '''//button[@data-dojo-attach-point="saveButton"]''')

class SelectSSIDPage(WebElement):
    new_btn = ('xpath', '''//li[@data-dojo-attach-point="newSSID"]''')
    next_btn = ('xpath', '''//button[@data-dojo-attach-point="nextBtn"]''')
    allssid_checkbox = ('id', "ah/util/AHGrid_3_rowSelector_-1")
    #checked    aria-checked="True"
    #unchecked  aria-checked="False"
    
class ConfigSSIDPage(WebElement):
    ssidname_input = ('xpath', '''//input[@data-dojo-attach-point="ssidName"]''')
    ssidbroadname_input = ('xpath', '''//input[@data-dojo-attach-point="ssidBroadcastName"]''')
    ssidworkfor_custom_checkbox = ('xpath', '''//input[@value="CUSTOM"]''')
    #open
    ssidsecurity_open_checkbox = ('xpath', '''//input[@value="open-access"]''')
    #psk
    ssidsecurity_wpa_psk_checkbox = ('xpath', '''//input[@value="psk"]''')
    ssidsecurity_wpa_psk_key_input = ('xpath', '''//input[@data-dojo-attach-point="norEl"][@data-validid="keyVal.norEl"]''')
    ssidsecurity_wpa_psk_keyconfirm_input = ('xpath', '''//input[@data-dojo-attach-point="cfmEl"][@data-validid="keyVal.cfmEl"]''')
    #ppsk
    ssidsecurity_private_psk_checkbox = ('xpath', '''//input[@value="ppsk"]''')
    private_psk_newug_btn = ('xpath', '''//li[@data-dojo-attach-point="newUG"]''')
    #802.1x
    ssidsecurity_wpa_8021x_checkbox = ('xpath', '''//input[@value="802dot1x"]''')
    wpa_8021x_external_input = ('xpath', '''//input[@data-type="externalRadiusArea"]''')
    wpa_8021x_external_new_btn = ('xpath', '''//li[@data-dojo-attach-point="newRadiusServer"]''')
    #all
    save_btn = ('xpath', '''//div[@id="ah/comp/configuration/SSIDDetailsForm_2"]/div/div/button[@data-dojo-attach-point="saveButton"]''')

class DeviceTemplatePage(WebElement):
    next_btn = ('xpath', '''//button[@data-dojo-attach-point="nextBtn"]''')

class AdditionalPage(WebElement):
    next_btn = ('xpath', '''//button[@data-dojo-attach-point="nextBtn"]''')

class UploadPolicyPage(WebElement):
    upload_btn = ('xpath', '''//button[@data-dojo-attach-point="upload"]''')
    


class cloud(WebUI):
    def __init__(self, webuiargs):
        WebUI.__init__(self, webuiargs)
        print 'Class cloud init successfully'
        
    def unit_click_configure(self):
        self.wait_until_element_displayed(TopMenu.get('config_btn'))
        self.click(TopMenu.get('config_btn'))
        
    def unit_new_netpolicy(self):
        self.wait_until_element_displayed(SelectPolicyPage.get('new_btn'))
        self.click(SelectPolicyPage.get('new_btn'))
        
    def unit_config_netpolicy(self, policyname):
        self.wait_until_element_displayed(ConfigPolicyPage.get('policyname_input'))
        self.input(ConfigPolicyPage.get('policyname_input'), policyname)
        self.click(ConfigPolicyPage.get('next_btn'))
        
    def unit_new_ssid(self):
        self.wait_until_element_displayed(SelectSSIDPage.get('new_btn'))
        self.click(SelectSSIDPage.get('new_btn'))     
    
    def unit_config_basicssid(self, ssidname, security='open', key=''):
        #input ssid name
        self.wait_until_element_displayed(ConfigSSIDPage.get('ssidname_input'))
        self.input(ConfigSSIDPage.get('ssidname_input'), ssidname)
        self.clear(ConfigSSIDPage.get('ssidbroadname_input'))
        self.input(ConfigSSIDPage.get('ssidbroadname_input'), ssidname)
        #select customer
        self.click(ConfigSSIDPage.get('ssidworkfor_custom_checkbox'))
        if security == 'open':
            pass
        elif security == 'psk':
            self.wait_until_element_displayed(ConfigSSIDPage.get('ssidsecurity_wpa_psk_checkbox'))
            self.click(ConfigSSIDPage.get('ssidsecurity_wpa_psk_checkbox'))
            self.info('Enter to psk mode', True)
            
            self.wait_until_element_displayed(ConfigSSIDPage.get('ssidsecurity_wpa_psk_key_input'))
            self.input(ConfigSSIDPage.get('ssidsecurity_wpa_psk_key_input'), key)
            self.input(ConfigSSIDPage.get('ssidsecurity_wpa_psk_keyconfirm_input'), key)
        self.click(ConfigSSIDPage.get('save_btn'))       
    
    def unit_select_all_ssid(self):
         self.wait_until_element_displayed(SelectSSIDPage.get('allssid_checkbox'))
         self.click(SelectSSIDPage.get('allssid_checkbox'))
         #Maybe we can confirm whether the checkbox is in selected mode
         #checked    aria-checked="True"
         #unchecked  aria-checked="False"
         self.click(SelectSSIDPage.get('next_btn'))
         
    def unit_click_devicetemplate(self):
        self.wait_until_element_displayed(DeviceTemplatePage.get('next_btn'))
        self.click(DeviceTemplatePage.get('next_btn'))      
   
    def unit_click_additional(self):
        self.wait_until_element_displayed(AdditionalPage.get('next_btn'))
        self.click(AdditionalPage.get('next_btn'))       
    
    def unit_uploadconfig(self, device_mac):
        self.wait_until_element_displayed(UploadPolicyPage.get('upload_btn'))
        device_element_list = self.driver.find_elements('xpath', '''//div/table/tbody/tr/td[@idx="5"]''')
        is_mac_exist = False
        device_index = ''
        for device_element in device_element_list:
            if device_element.get_attribute("innerHTML") == device_mac:
                is_mac_exist = True
                device_index = device_element_list.index(device_element)
        if is_mac_exist:
            #device_checkbox's id is the same as the index in device_element_list
            device_checkbox_element = self.driver.find_element('id', 'ah/util/AHGrid_6_rowSelector_%d' % device_index)
        else:
            self.info('Cannot find the device via Mac %s' % device_mac, True)
        self.click(UploadPolicyPage.get('upload_btn'))

    def try_again_get(self, url, title, times=5):
        for i in range(times):
            try:
                self.get(url)
                self.wait_until_title_present(title)
                self.info('successful get page with title: %s after access url: %s' % (title, url), True)
                break
            except Exception, e:
                if i == times - 1:
                    raise
                self.warn('fail to get page with title: %s after access url: %s, will try again' % (title, url), True)


#@safe_call
def network_policy():
    web = cloud()
    print 'set web object successfully'
    webdriver = web.driver()
    print 'set webdriver successfully'
    #web.try_again_get(web.d("visit.url"), web.d("visit.title"))
    if web.session_id:
        print 'Get session-id %s successfully' % web.session_id
        web.unit_click_configure()
        web.unit_new_netpolicy()
        web.unit_config_netpolicy(web.d("policy.name"))
        web.unit_new_ssid()
        web.unit_config_basicssid(web.d("ssid.name"), web.d("ssid.security"), web.d("ssid.key"))
        web.unit_select_all_ssid()
        web.unit_click_devicetemplate()
        web.unit_click_additional()
        web.unit_uploadconfig(web.d("device.mac"))
    else:
        print 'Get session-id failed'

if __name__ == '__main__':
    network_policy()
