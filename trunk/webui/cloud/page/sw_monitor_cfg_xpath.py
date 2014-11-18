#!/usr/bin/python

# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class NewLoginPage(WebElement):
    newlogin_page_title = 'HiveManager NG'
    newusername_txt = (By.XPATH, '//input[@data-dojo-attach-point="username"]')
    newpassword_txt = (By.XPATH, '//input[@data-dojo-attach-point="password"]')
    newlogin_btn = (By.XPATH, '//input[@data-dojo-attach-point="loginAction"]')
    newinvitation_txt = (By.XPATH, '//input[@data-dojo-attach-point="keyInput"]')
    newinvitation_btn = (By.XPATH, '//input[@data-dojo-attach-point="inviteAction"]')

class NewLoginSuccessfulPage(WebElement):
    newuser_name = (By.XPATH, '//span[@data-dojo-attach-point="userNameEl"]')

class NewLoginSuccessfulPopupPage(WebElement):
    newnewlogin_successful_popup_page_title = 'HiveManager NG'
    home_top = (By.XPATH, '//*[@id="header"]/div/div/ul/li[1]/a')
    logou_btn = (By.XPATH, '//*[@id="header"]/div/div/div/div[3]/div[2]/ul/li')


class monitor_cfg(WebElement):
    # cfg push elements
    Configuration_button = (By.XPATH, '//li[@data-dojo-attach-point="configurationtab"]/a')
    add_button = (By.XPATH, '//li[@data-dojo-attach-point="newNetworkPolicy"]/span')
    PolicyName_txt = (By.XPATH, '//input[@data-dojo-attach-point="policyName"]')
    PolicyDesc_txt = (By.XPATH, '//textarea[@data-dojo-attach-point="policyDesc"]')
    Next_button = (By.XPATH, '//button[@data-dojo-attach-point="saveButton"]')
    DeviceTemp_button = (By.XPATH, '//li[@data-dojo-attach-point="wiredconnPage"]/span[@class="wiz-item-des"]')
    NewDevice_button = (By.XPATH, '//span[@data-dojo-attach-point="newDevice"]')
    
    #ap template creation trigger button elements
    NewDevice_ap_button = (By.XPATH, '//a[@data-dojo-attach-point="secondTrigger-ap"]')
    NewDevice_ap_type_button = (By.XPATH, '//a[@data-type="AP_330"]')
    
    #sw template creation trigger button elements
    NewDevice_sw_button = (By.XPATH, '//a[@data-dojo-attach-point="secondTrigger-switch"]')
    NewDevice_sw_type_button = (By.XPATH, '//a[@data-type="SR_2124P"]')
    
    Device_template_name_txt = (By.XPATH, '//input[@data-dojo-attach-point="tplName"]')
    Device_template_save_button = (By.XPATH,'//div[@data-dojo-attach-point="deviceTmpl"]/descendant::button[@data-dojo-attach-point="saveButton"]')
    Deploy_policy_button = (By.XPATH, '//li[@data-dojo-attach-point="selectDevicesPage"]/span[@class="wiz-item-des"]')
    Config_upload_button = (By.XPATH, '//button[@data-dojo-attach-point="upload"]') 
    Device_mac_xpath = (By.XPATH, '//div[@data-dojo-attach-point="selectDevicesContainer"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[6]')
    Device_checkbox_xpath = (By.XPATH, '//div[@data-dojo-attach-point="selectDevicesContainer"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[1]')
    Device_stat_xpath = (By.XPATH, '//div[@data-dojo-attach-point="selectDevicesContainer"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/descendant::span[@class="hive-status dashboard-icon hive-status-true"]')
    
    #device monitor elements
    
    Device_list_button = (By.XPATH, '//li[@data-dojo-attach-point="devicesTab"]/a')
    Device_list_mac_xpath = (By.XPATH,'//div[@class="overflow-hidden"]/descendant::div[starts-with(@id, "dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[6]')
    Device_list_checkbox_xpath = (By.XPATH, '//div[@class="overflow-hidden"]/descendant::div[starts-with(@id, "dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[1]')
    Device_list_stat_xpath = (By.XPATH, '//div[@class="overflow-hidden"]/descendant::div[starts-with(@id, "dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[2]/span[@class="hive-status dashboard-icon hive-status-true"]')
    Device_list_ip_xpath = (By.XPATH, '//div[@class="overflow-hidden"]/descendant::div[starts-with(@id, "dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[5]')
    Device_list_hostname_xpath = (By.XPATH, '//div[@class="overflow-hidden"]/descendant::div[starts-with(@id, "dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[3]/a')
    Device_list_sn_xpath = (By.XPATH, '//div[@class="overflow-hidden"]/descendant::div[starts-with(@id, "dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[7]')
    Device_list_ptype_xpath = (By.XPATH, '//div[@class="overflow-hidden"]/descendant::div[starts-with(@id, "dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[4]')
    
    Device_list_next_page_xpath = (By.XPATH, '//div[@id="dojox_grid_enhanced_plugins__Paginator_0"]/table/tbody/tr/td/div[@class="dojoxGridPaginatorStep"]/div[@class="dojoxGridWardButton dojoxGridnextPageBtn"]')
    Device_list_next_page_disable_xpath = (By.XPATH, '//div[@id="dojox_grid_enhanced_plugins__Paginator_0"]/table/tbody/tr/td/div[@class="dojoxGridPaginatorStep"]/div[@class="dojoxGridWardButton dojoxGridnextPageBtnDisable"]')
    
    upload_dialog_title = (By.XPATH, '//h5[@data-dojo-attach-point="stepTitle"]')
    upload_dialog_btn = (By.XPATH, '//div[@data-dojo-attach-point="wizardFooter"]/a[@data-dojo-attach-point="uploadBtn"]')
    upload_success_msg = (By.XPATH, '//h3[@data-dojo-attach-point="textEl"]')
    
    
class monitor_device_overview(WebElement):
    Device_overview_name = (By.XPATH, '//span[@data-dojo-attach-point="deviceHostName"]')
    Device_connect_status = (By.XPATH, '//span[@data-dojo-attach-point="deviceConnStatus"]')
    Device_unique_client_num = (By.XPATH, '//span[@data-dojo-attach-point="uniqueClientsNum"]')
    Device_network_detail_section = (By.XPATH, '//div[@class="view-section clearfix"]/div/h3')
    
    Device_netdetail_netpolicy_name = (By.XPATH, '//span[@data-dojo-attach-point="networkPolicyName"]')
    Device_netdetail_template_name = (By.XPATH, '//span[@data-dojo-attach-point="deviceTemplateName"]')
    Device_netdetail_model_name = (By.XPATH, '//span[@data-dojo-attach-point="deviceModel"]')
    Device_netdetail_function_name = (By.XPATH, '//span[@data-dojo-attach-point="deviceFunction"]')
    Device_netdetail_sn_name = (By.XPATH, '//span[@data-dojo-attach-point="deviceserialNumber"]')
    Device_netdetail_mgt_ip = (By.XPATH, '//span[@data-dojo-attach-point="mgmtIpAddress"]')
    Device_netdetail_dhcp_type = (By.XPATH, '//span[@data-dojo-attach-point="configurationType"]')
    Device_netdetail_subnet_mask = (By.XPATH, '//span[@data-dojo-attach-point="subnetMask"]')
    Device_netdetail_gw = (By.XPATH, '//span[@data-dojo-attach-point="defaultGateway"]')
    Device_netdetail_mgmt_mac = (By.XPATH, '//span[@data-dojo-attach-point="mgmtMacAddress"]')
    Device_netdetail_dns = (By.XPATH, '//span[@data-dojo-attach-point="dnsSrvAddress"]')
    Device_netdetail_ntp = (By.XPATH, '//span[@data-dojo-attach-point="ntpSrvAddress"]')
    Device_netdetail_os = (By.XPATH, '//span[@data-dojo-attach-point="hiveOsVersion"]')
    Device_netdetail_manage_status = (By.XPATH, '//span[@data-dojo-attach-point="deviceAdminStatus"]')
    
    
    
    