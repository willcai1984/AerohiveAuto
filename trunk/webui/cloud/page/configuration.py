#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from selenium.webdriver.common.by import By
from webui import WebElement

class NetworkPolicy(WebElement):
    menu_successful_page_menu_title = 'New Network Policy'
    new_btn = (By.XPATH, '//li[@data-dojo-attach-point="newNetworkPolicy"]/span')
    next_btn = (By.XPATH, '//*[starts-with(@id,"ah/comp/configuration/ConfigWizard_")]/descendant::button[@data-dojo-attach-point="saveButton"]')
    policy_name = (By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/ConfigPolicyDetails_")]/descendant::input')
    desc_txt = (By.XPATH, '//*[starts-with(@id,"ah/comp/configuration/ConfigPolicyDetails_")]/descendant::textarea')
    popup_msg = (By.XPATH, '//*[@class="ui-tipbox-title"]')

class DeployedSSID(WebElement):
    menu_successful_page_menu_title = 'Deployed Wireless SSIDs'
    external_radius_server_title = 'External Radius Server'
    menu_title_xpath = (By.XPATH,'//div[@data-dojo-attach-point="SSIDListArea"]/div[@class="ui-tle"]/span')
    new_btn = (By.XPATH, '//li[@data-dojo-attach-point="newSSID"]/span')
    next_btn = (By.XPATH, '//button[@data-dojo-attach-point="nextBtn"]')
    save_btn = (By.XPATH, '//div[@data-dojo-attach-point="contentArea"]/descendant::button[@data-dojo-attach-point="saveButton"]')
    ssid_obj_name = (By.XPATH, '//input[@data-dojo-attach-point="ssidName"]')
    ssid_name = (By.XPATH, '//input[@data-dojo-attach-point="ssidBroadcastName"]')

    ssid_usage_title = (By.XPATH, '//div[starts-with(h3,"SSID Usage")]')
    user_profile_title = (By.XPATH, '//div[h3="User Profile"]')

    # customize default user-profile
    user_profile_customize_btn = (By.XPATH, '//button[@data-type="DefaultUserProfileMgmt"]')
    user_profile_edit_title =(By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/UserProfileMgmt_")]/descendant::div[span="Create User Profile"]')
    user_profile_src_ip_input = (By.XPATH, '//input[@data-validid="sourceIp.ipEl"]/parent::div')
    user_profile_src_ip_btn = (By.XPATH, '//input[@data-validid="sourceIp.ipEl"]/parent::div/span[@data-dojo-attach-point="ipMark"]')
    user_profile_src_ip_list = (By.XPATH, '//div[@data-dojo-attach-point="firewallNode"]/div[1]/descendant::ul[li="%s"]')
    user_profile_src_ip_new_btn = (By.XPATH, '//div[@data-dojo-attach-point="ipList"]/descendant::a[@data-type="iphostname"]')
    user_profile_src_ip_name = (By.XPATH, '//input[@data-dojo-attach-point="nameEl"]')
    user_profile_src_ip_host = (By.XPATH, '//input[@data-dojo-attach-point="ipAddress"]')
    user_profile_src_ip_save_btn = (By.XPATH, '//button[@data-dojo-attach-point="saveBtn"]')

    user_profile_des_ip_btn = (By.XPATH, '//input[@data-validid="destinationIp.ipEl"]/parent::div/span[@data-dojo-attach-point="ipMark"]')
    user_profile_des_ip_list = (By.XPATH, '//div[@data-dojo-attach-point="firewallNode"]/div[2]/descendant::ul[li="%s"]')
    user_profile_des_ip_new_btn = (By.XPATH, '//div[@data-dojo-attach-point="ipList"]/descendant::a[@data-type="iphostname"]')
    user_profile_des_ip_name = (By.XPATH, '//input[@data-dojo-attach-point="nameEl"]')
    user_profile_des_ip_host = (By.XPATH, '//input[@data-dojo-attach-point="ipAddress"]')
    user_profile_des_ip_save_btn = (By.XPATH, '//button[@data-dojo-attach-point="saveBtn"]')

    user_profile_service_btn = (By.XPATH, '//a[@data-dojo-attach-point="serviceIp"]')
    user_profile_netservice_tab = (By.XPATH, '//div[@data-dojo-attach-point="networkTab"]/div[a="Network Services"]/a')
    user_profile_netservice_filter_search_input = (By.XPATH, '//input[@data-dojo-attach-point="categoriesFilter"]')
    user_profile_netservice_filter_search_btn = (By.XPATH, '//button[@data-dojo-attach-point="searchNetService"]')
    user_profile_netservice_filter_name = (By.XPATH, '//ul[@data-dojo-attach-point="categories"]/descendant::label[span="%s"]')
    user_profile_netservice_filter_checkbox = (By.XPATH, '//ul[@data-dojo-attach-point="categories"]/descendant::label[span="%s"]')
    user_profile_netservice_save_btn = (By.XPATH, '//div[@data-dojo-attach-point="firewallChildNode"]/descendant::button[@data-dojo-attach-point="saveDialog"]')

    service_type_any_checkbox = (By.XPATH, '//label[@class="checkbox"][span="Any"]')
    service_type_name_any = (By.XPATH, '//div[@data-dojo-attach-point="networkArea"]/div[1]/ul/li[1]/label/span')
    network_service_save_btn = (By.XPATH, '//div[@data-dojo-attach-point="firewallChildNode"]/div/div[2]/button[@data-dojo-attach-point="saveDialog"]')


    user_profile_save_btn = (By.XPATH, '//button[@data-dojo-attach-point="saveDialog"]')

    custom_display = (By.XPATH, '//input[@data-dojo-attach-point="wire-custom"]/parent::label')
    custom_span = (By.XPATH, '//input[@data-dojo-attach-point="wire-custom"]/parent::label/span')

    access_div = (By.XPATH, '//div[@data-dojo-attach-point="ssidTab"]')

    open_access_label = (By.XPATH, '//input[@data-dojo-attach-point="access-open"]/parent::label')
    open_access_span = (By.XPATH, '//input[@data-dojo-attach-point="access-open"]/parent::label/span')

    psk_access_label = (By.XPATH, '//input[@data-dojo-attach-point="access-psk"]/parent::label')
    psk_access_span = (By.XPATH, '//input[@data-dojo-attach-point="access-psk"]/parent::label/span')
    psk_key_value = (By.XPATH, '//input[@data-dojo-attach-point="norEl"][@data-validid="keyVal.norEl"]')
    psk_confirm_value = (By.XPATH, '//input[@data-dojo-attach-point="cfmEl"][@data-validid="keyVal.cfmEl"]')

    access_8021x_label =(By.XPATH, '//input[@data-dojo-attach-point="access-802"]/parent::label')
    access_8021x_span = (By.XPATH, '//input[@data-dojo-attach-point="access-802"]/parent::label/span')
    new_radius_server_btn = (By.XPATH, '//*[@data-dojo-attach-point="newRadiusServer"]')
    external_radius_server_title_xpath = (By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/ExternalRadiusServer_")]/descendant::div[span="External Radius Server"]')
    radius_name = (By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/ExternalRadiusServer_")]/descendant::input[@data-dojo-attach-point="nameEl"]')
    radius_description = (By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/ExternalRadiusServer_")]/descendant::textarea[@data-dojo-attach-point="desEl"]')

    radius_hostname = (By.XPATH, '//div[starts-with(@id,"ah/util/form/ipobject/IPObject_")]/descendant::span[@data-dojo-attach-point="ipMark"]')
    radius_hostname_iplist = (By.XPATH, '//div[starts-with(@id,"ah/util/form/ipobject/IPObject_")]/descendant::div[@data-dojo-attach-point="ipList"]')
    radius_hostname_ip_text = (By.XPATH, '//div[starts-with(@id,"ah/util/form/ipobject/IPObject_")]/descendant::div[@data-dojo-attach-point="ipList"]/div/ul/li[%s]')
    radius_new_hostname_btn = (By.XPATH, '//div[starts-with(@id,"ah/util/form/ipobject/IPObject_")]/descendant::div[@data-dojo-attach-point="ipList"]/div/p/a')
    radius_new_host_div = (By.XPATH, '//div[starts-with(@id,"ah/util/form/ipobject/IPObjectForm_")]')
    radius_new_host_name = (By.XPATH, '//div[starts-with(@id,"ah/util/form/ipobject/IPObjectForm_")]/descendant::input[@data-dojo-attach-point="nameEl"]')
    radius_new_host_ip = (By.XPATH, '//div[starts-with(@id,"ah/util/form/ipobject/IPObjectForm_")]/descendant::input[@data-dojo-attach-point="ipAddress"]')
    radius_new_hostname_save = (By.XPATH, '//div[starts-with(@id,"ah/util/form/ipobject/IPObjectForm_")]/descendant::button[@data-dojo-attach-point="saveBtn"]')

    key_value_8021x = (By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/ExternalRadiusServer_")]/descendant::input[@data-dojo-attach-point="norEl"]')
    confirm_value_8021x = (By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/ExternalRadiusServer_")]/descendant::input[@data-dojo-attach-point="cfmEl"]')
    external_radius_server_save = (By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/ExternalRadiusServer_")]/descendant::button[@data-dojo-attach-point="saveButton"]')


    suc_next_btn = (By.XPATH, '//button[@data-dojo-attach-point="nextBtn"]')
    popup_msg = (By.XPATH, '//h3[@data-dojo-attach-point="textEl"]')
    key_manage_a = (By.XPATH, '//*[@data-dojo-attach-point="ssidAccessSec"]/div/div[2]/div[2]/div/a')
    key_manage_select = (By.XPATH, '//*[@data-dojo-attach-point="ssidAccessSec"]/div/div[2]/div[2]/div/div/ul/li[%s]')
    key_manage_span = (By.XPATH, '//*[@data-dojo-attach-point="ssidAccessSec"]/div/div[2]/div[2]/div/a/span')

class DeviceModel(WebElement):
    next_btn = (By.XPATH, '//*[@data-dojo-attach-point="wizardBar"]/div/button[@data-dojo-attach-point="nextBtn"]')
    radio_checkbox = (By.XPATH, '//input[@data-dojo-attach-point="enableRadio"]')
    radio_checkbox_label = (By.XPATH, '//input[@data-dojo-attach-point="enableRadio"]/parent::label')
    scan_input = (By.XPATH, '//input[@data-dojo-attach-point="enableBackgroundScan"]')
    scan_div = (By.XPATH, '//input[@data-dojo-attach-point="enableBackgroundScan"]/parent::div')
    scan_div_span = (By.XPATH, '//input[@data-dojo-attach-point="enableBackgroundScan"]/parent::div/span')

class AdditionalSettings(WebElement):
    next_btn = (By.XPATH, '//*[@data-dojo-attach-point="wizardBar"]/div/button[@data-dojo-attach-point="nextBtn"]')

class DeployPolicy(WebElement):
    configwizardNav = (By.XPATH, '//div[@data-dojo-attach-point="configwizardNav"]')
    deploypolicy_menu = (By.XPATH, '//li[@data-dojo-attach-point="selectDevicesPage"]')
    deploypolicy_title = (By.XPATH, '//li[@data-dojo-attach-point="selectDevicesPage"]')
    upload_btn = (By.XPATH, '//button[@data-dojo-attach-point="upload"]')
    upload_uploadBtn = (By.XPATH, '//a[@data-dojo-attach-point="uploadBtn"]')
    no_records = (By.XPATH, '//*[@data-dojo-attach-point="deviceList"]/div/div[@dojoattachpoint="messagesNode"]/a')
    mac_xpath = (By.XPATH, '//div[starts-with(@id,"dojox_grid__View_")]/descendant::tr[td="%s"]')
    checkbox_xpath = (By.XPATH, '//div[starts-with(@id,"dojox_grid__View_")]/descendant::tr[td="%s"]/td[1]/div')
    stat_xpath = (By.XPATH, '//div[starts-with(@id,"dojox_grid__View_")]/descendant::tr[td="%s"]/td[2]/span')
    suc_message = (By.XPATH, '//h3[@data-dojo-attach-point="textEl"]')
    popup_step_tetle = (By.XPATH, '//div[@data-dojo-attach-point="containerNode"]/descendant::div[h5="Device Update"]')




#Added by will
class DashBoardPage(WebElement):
    dash_btn = (By.XPATH, '//li[@data-dojo-attach-point="dashboardtab"]/a')
    config_btn = (By.XPATH, '''//li[@data-dojo-attach-point="configurationtab"]/a''')


class SelectPolicyPage(WebElement):
    new_btn = (By.XPATH, '''//li[@data-dojo-attach-point="newNetworkPolicy"]/span''')

class ConfigPolicyPage(WebElement):
    policyname_input = (By.XPATH, '''//input[@data-dojo-attach-point="policyName"]''')
    #next button may cannot visable in linux, so use wireless connect instead
    #next_btn = (By.XPATH, '''//button[@data-dojo-attach-point="saveButton"]''')
    next_btn = (By.XPATH, '''//li[@data-dojo-attach-point="wirelessconnPage"]/span[1]''')

class SelectSSIDPage(WebElement):
    new_btn = (By.XPATH, '''//li[@data-dojo-attach-point="newSSID"]/span''')
    next_btn = (By.XPATH, '''//button[@data-dojo-attach-point="nextBtn"]''')
    #allssid_checkbox = (By.ID, "ah/util/AHGrid_3_rowSelector_-1")
    #checked    aria-checked="True"
    #unchecked  aria-checked="False"

class ConfigSSIDPage(WebElement):
    ssidname_input = (By.XPATH, '''//input[@data-dojo-attach-point="ssidName"]''')
    ssidbroadname_input = (By.XPATH, '''//input[@data-dojo-attach-point="ssidBroadcastName"]''')
    ssidworkfor_custom_checkbox = (By.XPATH, '//div[@class="mt20"]/ul[@class="radio-list"]/li[4]/label/span')
    #open
    ssidsecurity_open_checkbox = (By.XPATH, '//*[@data-dojo-attach-point="accessSecurity"]/li[5]/label/span')
    #psk
    ##use span instead of input due to some browers cannot find the input or input is not visable
    ssidsecurity_wpa_psk_checkbox = (By.XPATH, '''//ul[@data-dojo-attach-point="accessSecurity"]/li/label[span="WPA / WPA2 PSK (Personal)"]/span''')
    ssidsecurity_wpa_psk_key_input = (By.XPATH, '''//input[@data-dojo-attach-point="norEl"][@data-validid="keyVal.norEl"]''')
    ssidsecurity_wpa_psk_keyconfirm_input = (By.XPATH, '''//input[@data-dojo-attach-point="cfmEl"][@data-validid="keyVal.cfmEl"]''')
    #ppsk
    ssidsecurity_private_psk_checkbox = (By.XPATH, '''//input[@value="ppsk"]''')
    private_psk_newug_btn = (By.XPATH, '''//li[@data-dojo-attach-point="newUG"]''')
    #802.1x
    ssidsecurity_wpa_8021x_checkbox = (By.XPATH, '''//label[span='WPA / WPA2 802.1X (Enterprise)']/span''')
    wpa_8021x_external_input = (By.XPATH, '''//label[span='External Radius Server']/span''')
    wpa_8021x_external_new_btn = (By.XPATH, '''//li[@data-dojo-attach-point="newRadiusServer"]''')
    #all
    #click save btn
    save_btn = (By.XPATH, '''//div[@data-dojo-attach-point="contentArea"]/div/div/div/button[@data-dojo-attach-point="saveButton"]''')
    #evice template instead
    #save_btn=(By.XPATH, '''//li[@data-dojo-attach-point="wiredconnPage"]/span[1]''')

class ExternalRadiusServerPage(WebElement):
    name_input = (By.XPATH, '''//input[@data-dojo-attach-point="nameEl"]''')
    ip_dropdown = (By.XPATH, '''//div[label="IP Address/Host Name"]/../div[2]/div/div/div/span[@data-dojo-attach-point="ipMark"]''')
    ip_entry = (By.XPATH, '''//ul[li='168.143.87.77']/li[1]''')
    sharedsecret_input = (By.XPATH, '''//div[label="Shared secret"]/../div[2]/input[@data-dojo-attach-point="norEl"]''')
    confirmsecret_input = (By.XPATH, '''//div[label="Confirm secret"]/../div[2]/input[@data-dojo-attach-point="cfmEl"]''')
    save_btn = (By.XPATH, '''//div[@data-dojo-attach-point="contentArea"]/div[2]/div/div[button='Cancel']/button[@data-dojo-attach-point="saveButton"]''')

class DeviceTemplatePage(WebElement):
    new_btn = (By.XPATH, '''//span[@data-dojo-attach-point="newDevice"]''')
    next_btn = (By.XPATH, '''//button[@data-dojo-attach-point="nextBtn"]''')

class AdditionalPage(WebElement):
    ntp_btn = (By.XPATH, '''//li[@data-dojo-attach-point="nav-NTPServer"]''')
    next_btn = (By.XPATH, '''//button[@data-dojo-attach-point="nextBtn"]''')

class UploadPolicyPage(WebElement):
    upload_btn = (By.XPATH, '''//button[@data-dojo-attach-point="upload"]''')
    upload_info = (By.XPATH, '''//div[h3="Push to device is successful."]/h3''')








