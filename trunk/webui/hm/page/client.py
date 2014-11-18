# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class ClientsTablePage(WebElement):
    confirm_btn = (By.XPATH, '//button[contains(text(), "Yes")]')

    @classmethod
    def locate_checkbox(cls, text):
        return (By.XPATH, '//td[contains(text(), "%s")]/../td[@class="listCheck"]/input' % text)

class ActiveClientsPage(WebElement):
    active_clients_page_title = 'Active Clients'

    clients_lnk = (By.LINK_TEXT, 'Clients')
    active_clients_lnk = (By.LINK_TEXT, 'Active Clients')
    client_per_page_sel = (By.ID, 'clientMonitor_pageSize')
    
    #Operate buttons
    operation_btn = (By.XPATH, '//input[@value="Operation..."]')

    #operation menu
    deauth_client_menu = (By.LINK_TEXT, 'Deauth Client')
    
    #Deauth Client
    clear_cache_checkbox = (By.ID, 'isClearCache')
    deauth_btn = (By.ID, 'deauthBtn')
