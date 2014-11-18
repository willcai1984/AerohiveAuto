# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class EULAPage(WebElement):
    eula_page_title = 'HiveManager EULA'
    
    agree_btn = (By.ID, 'agreeBut')
