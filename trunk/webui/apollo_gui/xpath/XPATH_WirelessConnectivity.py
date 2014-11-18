#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from selenium.webdriver.common.by import By
from webui import WebElement

class NetworkPolicy(WebElement):
    menu_successful_page_menu_title = 'New Network Policy'
    new_btn = (By.XPATH, '//div[@class="card-item card-item-static card-item-first"]')
    new_btn_initial = (By.XPATH,'''//i[@data-dojo-attach-point="imgAdd"]''')
    next_btn = (By.XPATH, '//*[starts-with(@id,"ah/comp/configuration/ConfigWizard_")]/descendant::button[@data-dojo-attach-point="saveButton"]')
    policy_name = (By.XPATH, '//div[starts-with(@id,"ah/comp/configuration/ConfigPolicyDetails_")]/descendant::input')
    desc_txt = (By.XPATH, '//*[starts-with(@id,"ah/comp/configuration/ConfigPolicyDetails_")]/descendant::textarea')
    popup_msg = (By.XPATH, '//*[@class="ui-tipbox-title"]')

class DeployedSSID(WebElement):
    ssid_list_page_wzard_menu = (By.XPATH,'''//li[@data-dojo-attach-point="wirelessconnPage"]/span[@class="wiz-item-des"]''')
    menu_successful_page_menu_title = 'Wireless SSIDs'
    external_radius_server_title = 'External Radius Server'
    menu_title_xpath = (By.XPATH,'//div[@data-dojo-attach-point="SSIDListArea"]/div[@class="ui-tle mt20"]/span')
    new_btn = (By.XPATH, '//div[@data-dojo-attach-point="actionLeft"]/span[@class="table-action-icons table-add"]')
    next_btn = (By.XPATH, '//button[@data-dojo-attach-point="nextBtn"]')
    save_btn = (By.XPATH, '//div[@data-dojo-attach-point="wirelessConnectivityContainer"]/descendant::button[@data-dojo-attach-point="saveButton"]')
    ssid_obj_name = (By.XPATH, '//input[@data-dojo-attach-point="ssidName"]')
    ssid_name = (By.XPATH, '//input[@data-dojo-attach-point="ssidBroadcastName"]')

    ssid_usage_title = (By.XPATH, '//div[starts-with(h3,"SSID Usage")]')
   
    service_type_any_checkbox = (By.XPATH, '//label[@class="checkbox"][span="Any"]')
    service_type_name_any = (By.XPATH, '//div[@data-dojo-attach-point="networkArea"]/div[1]/ul/li[1]/label/span')
    network_service_save_btn = (By.XPATH, '//div[@data-dojo-attach-point="firewallChildNode"]/div/div[2]/button[@data-dojo-attach-point="saveDialog"]')

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
    suc_next_btn = (By.XPATH, '//button[@data-dojo-attach-point="nextBtn"]')
    popup_msg = (By.XPATH, '//h3[@data-dojo-attach-point="textEl"]')
    key_manage_a = (By.XPATH, '//*[@data-dojo-attach-point="ssidAccessSec"]/div/div[2]/div[2]/div/a')
    key_manage_select = (By.XPATH, '//*[@data-dojo-attach-point="ssidAccessSec"]/div/div[2]/div[2]/div/div/ul/li[%s]')
    key_manage_span = (By.XPATH, '//*[@data-dojo-attach-point="ssidAccessSec"]/div/div[2]/div[2]/div/a/span')


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


class UploadPolicyPage(WebElement):
    upload_btn = (By.XPATH, '''//button[@data-dojo-attach-point="upload"]''')
    upload_info = (By.XPATH, '''//div[h3="Push to device is successful."]/h3''')

class UserProfile(WebElement):
    user_profile_txt_in_ssid_page = (By.XPATH,'''//div[h3="User Profile"]''')
    up_customize_btn = (By.XPATH,'''//button[@class="btn btn-3 J-add-widget"][@data-type="DefaultUserProfileMgmt"]''')






