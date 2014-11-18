#!/usr/bin/python

# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class LoginPagenew(WebElement):
    login_page_titlenew = 'HiveManager NG'
    username_txtnew = (By.XPATH, '//input[@data-dojo-attach-point="username"]')
    password_txtnew = (By.XPATH, '//input[@data-dojo-attach-point="password"]')
    login_btnnew = (By.XPATH, '//input[@data-dojo-attach-point="loginAction"]')
    invitation_txtnew = (By.XPATH, '//input[@data-dojo-attach-point="keyInput"]')
    invitation_btnnew = (By.XPATH, '//input[@data-dojo-attach-point="inviteAction"]')

class LoginSuccessfulPagenew(WebElement):
    login_successful_page_title11 = (By.XPATH, '//span[@data-dojo-attach-point="userNameEl"]')

class LoginSuccessfulPopupPagenew(WebElement):
    login_successful_popup_page_titlenew = 'HiveManager NG'
    home_topnew = (By.XPATH, '//*[@id="header"]/div/div/ul/li[1]/a')
    logout_btnnew = (By.XPATH, '//*[@id="header"]/div/div/div/div[3]/div[2]/ul/li')


class radio_cfg(WebElement):
    Configuration_btn = (By.XPATH, '//li[@data-dojo-attach-point="configurationtab"]/a')
    Plus_btn = (By.XPATH, '//li[@data-dojo-attach-point="newNetworkPolicy"]')
    policy_name = (By.XPATH, '//input[@data-dojo-attach-point="policyName"]')
    Policy_Desc = (By.XPATH, '//textarea[@data-dojo-attach-point="policyDesc"]')
    policy_save_btn = (By.XPATH, '//button[@data-dojo-attach-point="saveButton"]')
    policy_next_btn = (By.XPATH, '//div[@data-dojo-attach-point="wizardBar"]/div/button[@data-dojo-attach-point="nextBtn"]')
    newdevice = (By.XPATH, '//span[@data-dojo-attach-point="newDevice"]')
    accesspoint = (By.XPATH, '//a[@data-dojo-attach-point="secondTrigger-ap"]')
    AP330 = (By.XPATH, '//a[@data-dojo-attach-point="tmpl-ap330"]')
    AP230 = (By.XPATH, '//li/a[@data-dojo-attach-point="tmpl-ap230"]')
    templatename = (By.XPATH, '//input[@data-dojo-attach-point="tplName"]')
    wifi0 = (By.XPATH, '//div[@data-dojo-attach-point="wireless-first"]')
    assignBtn = (By.XPATH, '//div[@data-dojo-attach-point="assignBtn"]')
    createNew = (By.XPATH, '//li[@data-dojo-attach-point="wirelessmenu-3"]/a')
    radioProfileName = (By.XPATH, '//input[@data-dojo-attach-point="radioProfileName"]')
    beacon_Period = (By.XPATH, '//input[@data-dojo-attach-point="beaconPeriod"]')
    radio_Range = (By.XPATH, '//input[@data-dojo-attach-point="radioRange"]')
    lastsavebtn = (By.XPATH, '//div[starts-with(@id, "ah/comp/configuration/RadioProfile_")]/div[@class="btn-area btn-mir"]/div/button[2]')
    lastsavebtnagain = (By.XPATH, '//div[@data-dojo-attach-point="manageAPTemplate"]/div/div/div/div[9]/div/button[2]')
    nextBtn2 = (By.XPATH, ' //button[@data-dojo-attach-point="nextBtn"]')
    nextBtn3 = (By.XPATH, ' //button[@data-dojo-attach-point="nextBtn"]') 
    Device_mac_xpath = (By.XPATH, '//div[@data-dojo-attach-point="deviceList"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/descendant::td[6]')
    Device_checkbox_xpath = (By.XPATH, '//div[@data-dojo-attach-point="deviceList"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/descendant::td[1]')
    Device_stat_xpath = (By.XPATH, '//div[@data-dojo-attach-point="deviceList"]/descendant::div[starts-with(@id,"dojox_grid__View_")]/div/div/div/div[%s]/descendant::span[@class="hive-status dashboard-icon hive-status-true"]')
    Config_upload_button = (By.XPATH, '//button[@data-dojo-attach-point="upload"]')
    unselect = (By.XPATH, '//button[@data-dojo-attach-point="unselect"]')
    wifi1 = (By.XPATH, '//div[@data-dojo-attach-point="wireless-second"]')
    assignBtn1 = (By.XPATH, '//div[@data-dojo-attach-point="assignBtn"]')
    createNew1 = (By.XPATH, '//li[@data-dojo-attach-point="wirelessmenu-3"]/a')
    radioProfileName1 = (By.XPATH, '//input[@data-dojo-attach-point="radioProfileName"]')
    beaconPeriod1 = (By.XPATH, '//input[@data-dojo-attach-point="beaconPeriod"]')
    radioRange1 = (By.XPATH, '//input[@data-dojo-attach-point="radioRange"]')
    lastsavebtn1 = (By.XPATH, '//div[@data-dojo-attach-point="manageAPTemplate"]/div/div/div[2]/div[55]/div/button[2]')
    radiomode = (By.XPATH, '//div[@data-dojo-attach-point="radioProfile24G_modes"]/table/tbody/tr[2]/td[4]') 
    BackgroundScan = (By.XPATH, '//input[@data-dojo-attach-point="enableBackgroundScan"]/parent::div')
    Client_are_connected = (By.XPATH, '//div[@data-dojo-attach-point="manageAPTemplate"]/div/div/div[2]/div[12]/div[2]/ul/li/label')
    power_save_mode = (By.XPATH, '//div[@data-dojo-attach-point="manageAPTemplate"]/div/div/div[2]/div[12]/div[2]/ul/li/ul/li[1]/label')
    voice_priority_detected = (By.XPATH, '//div[@data-dojo-attach-point="manageAPTemplate"]/div/div/div[2]/div[12]/div[2]/ul/li/ul/li[2]/label')

    

    
    
    
    
    
    
    

   
    
 
    
    
    
    

    
    
    
    
    
                                 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

