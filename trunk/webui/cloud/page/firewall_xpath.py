#!/usr/bin/python

# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class FireWall(WebElement):
    user_profile_section = (By.XPATH, '//div[@data-dojo-attach-point="contentArea"]/div/div[3]/div/h3')
    user_profile_customize_btn = (By.XPATH, '//button[@data-type="DefaultUserProfileMgmt"]')
    user_profile_edit_title =(By.XPATH, '//div[@style="position: static;"]/div[1]/div[1]/span')
    user_profile_tabs = (By.XPATH, '//div[@data-dojo-attach-point="userprofileTabs"]')
    security_tab_btn = (By.XPATH, '//div[@data-dojo-attach-point="userprofileTabs"]/div[1]/div[1]')
    firewall_switch = (By.XPATH, '//input[@data-dojo-attach-point="firewallSwitch"]/parent::div')
    ip_firewall_btn = (By.XPATH, '//li[@data-dojo-attach-point="ipFirewall"]/a')
    mac_firewall_btn = (By.XPATH, '//li[@data-dojo-attach-point="macFirewall"]/a')
    bound_traffic_dropdown_btn = (By.XPATH, '//div[@data-dojo-attach-point="firewallContainer"]/div[1]/div[2]/div/a/div/b')
    inbound_traffic_element = (By.XPATH, '//div[@data-dojo-attach-point="firewallContainer"]/div[1]/div[2]/div/div/ul/li[1]')
    outbound_traffic_element = (By.XPATH,'//div[@data-dojo-attach-point="firewallContainer"]/div[1]/div[2]/div/div/ul/li[2]')
    bound_traffic_selected = (By.XPATH, '//div[@data-dojo-attach-point="firewallContainer"]/div[1]/div[2]/div/a/span')
    
    firwall_defaction_area = (By.XPATH, '//div[@data-dojo-attach-point="ipFirewallDefaultActionArea"]')
    firewall_defaction_selected = (By.XPATH, '//div[@data-dojo-attach-point="ipFirewallDefaultActionArea"]/div[2]/div/a/span')
    firewall_defaction_dropdown_btn = (By.XPATH, '//div[@data-dojo-attach-point="ipFirewallDefaultActionArea"]/div[2]/div/a/div/b')
    firewall_defaction_deny_element = (By.XPATH, '//div[@data-dojo-attach-point="ipFirewallDefaultActionArea"]/div[2]/div/div/ul/li[1]')
    firewall_defaction_permit_element = (By.XPATH, '//div[@data-dojo-attach-point="ipFirewallDefaultActionArea"]/div[2]/div/div/ul/li[2]')
    firewall_new_btn = (By.XPATH, '//li[@data-dojo-attach-point="newFirewall"]/span')
    new_firewall_page_title = (By.XPATH, '//div[@class="dijitDialog dijitDialogFocused dijitFocused"]/div/div/div[1]/span')
    src_ip_dropdown_btn = (By.XPATH, '//div[@class="dijitDialog dijitDialogFocused dijitFocused"]/div/div/div[3]/div[1]/div[2]/div/div[1]/span[2]')
    dst_ip_dropdown_btn = (By.XPATH, '//input[@data-validid="destinationIp.ipEl"]/following-sibling::span[2]')
    src_ip_selected = (By.XPATH, '//input[@data-validid="sourceIp.ipEl"]')
    dst_ip_selected = (By.XPATH, '//input[@data-validid="destinationIp.ipEl"]')
    ip_list_1 = (By.XPATH, '//input[@data-validid="sourceIp.ipEl"]/parent::div/following-sibling::div/div/ul/li[@data-id="450971566228"]')
    ip_list_2 = (By.XPATH, '//input[@data-validid="destinationIp.ipEl"]/parent::div/following-sibling::div/div/ul/li[@data-id="450971566229"]')
    
    service_select_btn = (By.XPATH, '//a[@data-dojo-attach-point="serviceIp"]')
    network_service_tab = (By.XPATH, '//div[@data-dojo-attach-point="networkTab"]/div/a')
    service_type_any_checkbox = (By.XPATH, '//label[@class="checkbox"][span="Any"]')
    service_type_name_any = (By.XPATH, '//div[@data-dojo-attach-point="networkArea"]/div[1]/ul/li[1]/label/span')
    network_service_save_btn = (By.XPATH, '//div[@data-dojo-attach-point="firewallChildNode"]/div/div[2]/button[@data-dojo-attach-point="saveDialog"]')
    
    new_rule_action_selected = (By.XPATH, '//div[@data-dojo-attach-point="firewallNode"]/div[4]/div[2]/div[1]/a/span')
    new_rule_action_btn = (By.XPATH, '//div[@data-dojo-attach-point="firewallNode"]/div[4]/div[2]/div/a/div/b')
    new_rule_action_permit = (By.XPATH, '//a[@class="chzn-single chzn-single-with-drop"]/following-sibling::div/ul/li[1]')
    new_rule_action_deny = (By.XPATH, '//a[@class="chzn-single chzn-single-with-drop"]/following-sibling::div/ul/li[2]')
    new_rule_action_drop = (By.XPATH, '//a[@class="chzn-single chzn-single-with-drop"]/following-sibling::div/ul/li[3]')
    new_rule_action_nat = (By.XPATH, '//a[@class="chzn-single chzn-single-with-drop"]/following-sibling::div/ul/li[4]')

    new_rule_log_selected = (By.XPATH, '//div[@data-dojo-attach-point="firewallNode"]/div[5]/div[2]/div[2]/a/span')
    new_rule_log_btn = (By.XPATH, '//div[@data-dojo-attach-point="firewallNode"]/div[5]/div[2]/div[2]/a/div/b')
    new_rule_log_off = (By.XPATH, '//a[@class="chzn-single chzn-single-with-drop"]/following-sibling::div/ul/li[1]')
    new_rule_log_drop = (By.XPATH, '//a[@class="chzn-single chzn-single-with-drop"]/following-sibling::div/ul/li[2]')
    new_rule_dialog_save = (By.XPATH, '//div[@class="btn-area"]/button[@data-dojo-attach-point="saveDialog"]')
    
    user_profile_save_btn = (By.XPATH, '//div[@data-dojo-attach-point="wirelessDetailsContentArea"]/div/div[2]/div/div[7]/div/button[@data-dojo-attach-point="saveButton"]')
    
    added_rule_record = (By.XPATH, '//div[@data-dojo-attach-point="firewallListContainer"]/descendant::tr[td="%s"]')
    
    ssid_saved_btn = (By.XPATH, '//div[@data-dojo-attach-point="contentArea"]/descendant::button[@data-dojo-attach-point="saveButton"]')
    ssid_saved_success = (By.XPATH, '//div[@class="ui-tipbox-con"]/h3')
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    