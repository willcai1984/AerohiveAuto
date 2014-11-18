#!/usr/bin/python

# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class DeviceDataCollection(WebElement):
    #additional settings elemtns xpath
    additional_setting_button = (By.XPATH, '//li[@data-dojo-attach-point="additionalSettingsPage"]/span[@class="wiz-item-des"]')
    ntp_elements = (By.XPATH, '//div[@data-dojo-attach-point="additionalSettingsContentArea"]/div[1]/div/span')
    data_collection_btn = (By.XPATH, '//li[@data-dojo-attach-point="nav-collection"]')
    data_collection_elements = (By.XPATH, '//div[@data-dojo-attach-point="additionalSettingsContentArea"]/div[2]/div/span')
    data_collection_save_btn = (By.XPATH, '//div[@data-dojo-attach-point="additionalSettingsContentArea"]/div/div[17]/div/button[@data-dojo-attach-point="saveButton"]')
    data_collection_save_info = (By.XPATH, '//div[@data-dojo-attach-point="configwizardNav"]/div/div/div')
    
    kddr_name = (By.XPATH, '//div[@data-dojo-attach-point="additionalSettingsContentArea"]/div[2]/div[16]/div[2]/strong')
    
    application_identify_xpath = (By.XPATH, '//input[@data-dojo-attach-point="enableAppVC"]/parent::div')
    statistic_collection_xpath = (By.XPATH, '//input[@data-dojo-attach-point="enableCollection"]/parent::div')
    kddr_xpath = (By.XPATH, '//input[@data-dojo-attach-point="enableKDDR"]/parent::div')
    
    # statistic collection dropdown box xpath
    dropdown_box_button = (By.XPATH, '//div[@id="ah/comp/configuration/DeviceDataCollection_0"]/descendant::div/a/div/b')
    dropdown_box_content_1 = (By.XPATH, '//div[@id="ah/comp/configuration/DeviceDataCollection_0"]/descendant::div/ul/li[1]')
    dropdown_box_content_5 = (By.XPATH, '//div[@id="ah/comp/configuration/DeviceDataCollection_0"]/descendant::div/ul/li[2]')
    dropdown_box_content_10 = (By.XPATH, '//div[@id="ah/comp/configuration/DeviceDataCollection_0"]/descendant::div/ul/li[3]')
    dropdown_box_content_30 = (By.XPATH, '//div[@id="ah/comp/configuration/DeviceDataCollection_0"]/descendant::div/ul/li[4]')
    dropdown_box_content_60 = (By.XPATH, '//div[@id="ah/comp/configuration/DeviceDataCollection_0"]/descendant::div/ul/li[5]')
    collect_statistic_period = (By.XPATH, '//div[@id="ah/comp/configuration/DeviceDataCollection_0"]/descendant::div/a')
    
    device_crc_err_rate = (By.XPATH, '//input[@data-dojo-attach-point="deviceCRC"]')
    device_tx_drop_rate = (By.XPATH, '//input[@data-dojo-attach-point="deviceTxDrop"]')
    device_rx_drop_rate = (By.XPATH, '//input[@data-dojo-attach-point="deviceRxDrop"]')
    device_tx_retry_rate = (By.XPATH, '//input[@data-dojo-attach-point="deviceTxRetry"]')
    device_airtime_consumption = (By.XPATH, '//input[@data-dojo-attach-point="deviceAirTime"]')
    
    client_tx_drop_rate = (By.XPATH, '//input[@data-dojo-attach-point="clientTxDrop"]')
    client_rx_drop_rate = (By.XPATH, '//input[@data-dojo-attach-point="clientRxDrop"]')
    client_tx_retry_rate = (By.XPATH, '//input[@data-dojo-attach-point="clientTxRetry"]')
    client_airtime_consumption = (By.XPATH, '//input[@data-dojo-attach-point="clientAirTime"]')
    
    