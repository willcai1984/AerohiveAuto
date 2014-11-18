#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from selenium.webdriver.common.by import By
from webui import WebElement

class Home(WebElement):
    menu_page_title = 'HiveManager NG'
    Dashboard = (By.XPATH, '//li[@data-dojo-attach-point="dashboardtab"]/a')
    Monitor = (By.XPATH, '//li[@data-dojo-attach-point="monitoringtab"]/a')
    Devices = (By.XPATH, '//li[@data-dojo-attach-point="devicesTab"]/a')
    Configuration = (By.XPATH, '//li[@data-dojo-attach-point="configurationtab"]/a')
    Administration = (By.XPATH, '//li[@class="data-dojo-attach-point="admintab"]/a')



class MenuSuccessfulPage(WebElement):
    menu_successful_page_title = 'HiveManager NG'
    Dashboard_successful_page_menu_title = 'Network Policies'
    Monitor_successful_page_menu_title = 'Network Policies'
    Devices_successful_page_menu_title = 'Devices'
    Devices_successful_page_menu_title_xpath = (By.XPATH, '//div[@data-dojo-attach-point="DeviceListArea"]/descendant::div[span="Devices"]')
    Configuration_successful_page_menu_title = 'Network Policies'
    Configuration_successful_page_menu_title_xpath = (By.XPATH, '//span[@data-dojo-attach-point="btnCard"]')
    Administration_successful_page_menu_title = 'Network Policies'














