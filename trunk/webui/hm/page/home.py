# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class HomePage(WebElement):
    home_page_title = 'Dashboard'
    
    home_lnk = (By.LINK_TEXT, 'Home')
    administration_lnk = (By.LINK_TEXT, 'Administration')
    vhm_management_lnk = (By.LINK_TEXT, 'VHM Management')
    hive_manager_services_lnk = (By.LINK_TEXT, 'HiveManager Services')
    
    opration_btn = (By.ID, 'operationMenuBtn')
    switch_vhm_link = (By.LINK_TEXT, 'Switch Virtual HM')


    @classmethod
    def locate_vhm_checkbox(cls, text):
        return (By.XPATH, '//a[contains(text(), "%s")]/../../td[@class="listCheck"]/input' % text)

class HiveManagerServicesPage(WebElement):
    hive_manager_services_page_title = 'HiveManager Services'
    
    update_capwap_checkbox = (By.ID, 'updateCAPWAP')
    primary_capwap_server_input = (By.ID, 'primaryCapwapIP')
    capwap_udp_port_input = (By.ID, 'capwapUdpPort')
    
    update_btn = (By.XPATH, '//input[@name="ok"]')
