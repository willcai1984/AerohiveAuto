#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from selenium.webdriver.common.by import By
from webui import WebElement

class myHome(WebElement):
    menu_page_title = 'HiveManager NG'
    Dashboard_btn = (By.XPATH, '//*[@class="head-nav"]/li[1]/a')
    Monitor_btn = (By.XPATH, '//*[@class="head-nav"]/li[2]/a')
    Devices_button = (By.XPATH, '//li[@data-dojo-attach-point="devicesTab"]/a')
    Configuration_button = (By.XPATH, '//li[@ data-dojo-attach-point="configurationtab"]/a')
    Administration_btn = (By.XPATH, '//*[@class="head-nav"]/li[5]/a')
    Add_device_button = (By.XPATH, '//li[@ data-dojo-attach-point="newNetworkPolicy"]/span')
    Add_networkPolicy = (By.XPATH, '//input[@ data-dojo-attach-point="policyName"]')
    Next_button_networkPolicy = (By.XPATH, '//button[@data-dojo-attach-point="saveButton"]')
    Mac_device_page = (By.XPATH, '//div[@role="presentation"]/descendant::tr[%s]/td[6]')
    SN_device_page = (By.XPATH, '//div[@role="presentation"]/descendant::tr[%s]/td[7]')
    Ip_device_page = (By.XPATH, '//div[@role="presentation"]/descendant::tr[%s]/td[3]/a')
    State_device_page = (By.XPATH, '//div[@class="overflow-hidden"]/descendant::div[starts-with(@id, "dojox_grid__View_")]/div/div/div/div[%s]/table/tbody/tr/td[2]/span[@class="hive-status dashboard-icon hive-status-true"]')
    Device_host_name = (By.XPATH, '//div[@role="presentation"]/descendant::tr[%s]/td[3]/a')
    Check_box_device_page = (By.XPATH, '//div[@role="presentation"]/descendant::tr[%s]/td[1]/div[1]')
    Remove_device_button = (By.XPATH, '//span[@class="table-action-icons table-remove"]')
    Conform_to_remove_device_button = (By.XPATH, '//button[@data-dojo-attach-point="yesBtn"]')
    Device_config_button = (By.XPATH, '//li[@ data-type="devicecfg"]/a')
    Check_box_netpolicy = (By.XPATH, '//div[@data-type="networkPolicy"]/descendant::li[%s]/descendant::label[@class="checkbox"]')
    Name_netpolicy_filter = (By.XPATH, '//div[@data-type="networkPolicy"]/descendant::li[%s]/descendant::span[@class="lbl"]')
    Device_connect_status = (By.XPATH, '//span[@data-dojo-attach-point="deviceConnStatus"]')
    More_button = (By.XPATH, '//* [@ class="J-more"]')
    
class FiltersDevicepage(WebElement):
    More_button = (By.XPATH, '//* [@ class="J-more"]')
    check_box_realdevice = (By.XPATH, '//div[@data-type="deviceType"]/descendant::li[2]/descendant::label[@class="checkbox"]')
   
class PolicyPage(WebElement):
    Deploy_button = (By.XPATH, '//li [@data-dojo-attach-point="selectDevicesPage"]')
    
class DeviceOnboarding(WebElement):
    Add_device_button = (By.XPATH, '//span[@class="table-action-icons table-add"]')
    Add_real_device_button = (By.XPATH, '//button[@data-dojo-attach-point="startOwnDevice"]')
    Input_SN_Textarea = (By.XPATH, '//textarea[@data-dojo-attach-point="serialNumbers"]')
    Next_button_add_SN_page = (By.XPATH, '//a[@data-dojo-attach-point="wizardNextStepBtn"]')
    Next_button_added_device_page = (By.XPATH, '//a[@data-dojo-attach-point="wizardNextStepBtn"]')
    Do_not_deploy_policy = (By.XPATH, '//input[@data-dojo-attach-point="enablePort"]/parent::div')
    Use_existing_pilicy = (By.XPATH, '//div[@data-dojo-attach-point="npArea"]/div[1]/label')
    Create_new_policy = (By.XPATH, '//div[@data-dojo-attach-point="npArea"]/div[3]/label')
    Existing_policy_dorpdown_list = (By.XPATH, '//div[@data-dojo-attach-point="existingNPSection"]/descendant::div[starts-with(@id,"ah_util_Chosen_")]')
    Policys_of_dorpdown_list = (By.XPATH, '//div[@data-dojo-attach-point="existingNPSection"]/descendant::ul[@class="chzn-results"]/li[%s]')
    Input_netpolicy_textarea = (By.XPATH, '//input[@data-dojo-attach-point="policyName"]')
    Input_ssid_textarea = (By.XPATH, '//input[@data-dojo-attach-point="ssidName"]')
    Input_network_password_textarea = (By.XPATH, '//input[@data-dojo-attach-point="pskPassword"]')
    Next_button_build_policy_page = (By.XPATH, '//a[@data-dojo-attach-point="wizardNextStepBtn"]')
    Finish_button_device_onboarding = (By.XPATH, '//div[@data-dojo-attach-point="wizardFooter"]/a[4]')
    
class SsidPage(WebElement):
    Add_ssid_button = (By.XPATH, '//li[@ data-dojo-attach-point="newSSID"]')
    Input_ssid_textarea = (By.XPATH, '//div[@class="grid_12 last column"]/input[@data-dojo-attach-point="ssidName"]')
    Input_ssid_boardcast_textarea = (By.XPATH, '//input[@data-dojo-attach-point="ssidBroadcastName"]')
    Select_PPSK = (By.XPATH, '//input[@data-dojo-attach-point="access-ppsk"]/parent::label')
    Save_button_ssid_page = (By.XPATH, '//div[@ data-dojo-attach-point="contentArea"]/div[1]/div[5]/div[1]/button[@data-dojo-attach-point="saveButton"]')
    
    Add_user_group_button = (By.XPATH, '//div[@data-dojo-attach-point="AHIDMArea"]/descendant::span[@class="table-action-icons table-add"]')
    new_user_group_button = (By.XPATH, '//li[@data-dojo-attach-point="newUserGroup"]/span[@class="table-action-icons table-add"]')
    Input_user_group_name_textarea = (By.XPATH, '//input[@data-dojo-attach-point="groupName"]')
    Save_button_new_user_group_page = (By.XPATH, '//button[@data-dojo-attach-point="saveBtn"]')
    User_group_name_of_seletced_user_group_page = (By.XPATH, '//div[@data-dojo-attach-point="SSIDListArea"]/descendant::div[@class="dojoxGridView"]/div[1]/div[1]/div[1]/div[%s]/descendant::td[@idx=\'1\']/a')
    Num_of_user_of_selected_user_group_page = (By.XPATH, '//div[@data-dojo-attach-point="SSIDListArea"]/descendant::div[@class="dojoxGridView"]/div[1]/div[1]/div[1]/div[%s]/descendant::td[@idx=\'2\']/a[@class="J-user-count"]')
    Check_box_of_user_group = (By.XPATH, '//div[@data-dojo-attach-point="SSIDListArea"]/descendant::div[@class="dojoxGridView"]/div[1]/div[1]/div[1]/div[%s]/descendant::td[@idx=\'0\']/div[1]')
    Add_user_to_user_group_button = (By.XPATH, '//li[@data-dojo-attach-point="newUser"]/span[@class="table-action-icons table-add"]')
    Input_user_name_textarea = (By.XPATH, '//input[@data-dojo-attach-point="userName"]')
    Input_password_textarea = (By.XPATH, '//input[@data-validid="passwordEl.norEl"]')
    Input_user_password_confirm_textarea = (By.XPATH, '//input[@data-validid="passwordEl.cfmEl"]')
    Save_user_button = (By.XPATH, '//button[@data-dojo-attach-point="saveBtn"]')
    Cancel_button_of_user_in_user_group_page = (By.XPATH, '//button[@data-dojo-attach-point="cancelBtn"]')
    Save_button_select_user_group_button = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/IDMUserGroupList_")]/descendant::button[@data-dojo-attach-point="saveButton"]')

    # Modify by hshao
    select_user_groups_tiitle = (By.XPATH, '//div[@data-dojo-attach-point="SSIDListArea"]/div[span="Select User Groups"]')
    user_group_name_tr = (By.XPATH, '//div[starts-with(@id, "dojox_grid__View_")]/descendant::tr[td="%s"]')
    add_user_btn = (By.XPATH, '//div[starts-with(@id, "dojox_grid__View_")]/descendant::tr[td="%s"]/td[4]/a[1]')
    user_account_list = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/UserAccountList_")]')
    user_group_checkbox = (By.XPATH, '//div[starts-with(@id, "dojox_grid__View_")]/descendant::tr[td="%s"]/td[1]')

class DeployPolicyPage(WebElement):
    Device_mac_xpath = (By.XPATH, '//div[@data-dojo-attach-point="deviceList"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/descendant::td[6]')
    Device_checkbox_xpath = (By.XPATH, '//div[@data-dojo-attach-point="deviceList"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/descendant::td[1]')
    Device_stat_xpath = (By.XPATH, '//div[@data-dojo-attach-point="deviceList"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/descendant::span[@class="hive-status dashboard-icon hive-status-true"]')   
    
    
class MenuSuccessfulPage(WebElement):
    menu_successful_page_title = 'HiveManager NG'
    Dashboard_successful_page_menu_title = 'Network Policies'
    Monitor_successful_page_menu_title = 'Network Policies'
    Devices_successful_page_menu_title = 'Network Policies'
    Configuration_successful_page_menu_title = 'Network Policies'
    Configuration_successful_page_menu_title_xpath = (By.XPATH, '//*[@data-dojo-attach-point="configContainer"]/div/div[@data-dojo-attach-point="NetworkPolicyListArea"]/div[@class="ui-tle"]/span')
    Administration_successful_page_menu_title = 'Network Policies'

