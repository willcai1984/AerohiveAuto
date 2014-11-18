#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'Tiesong'

from webui import WebUIException
from webui.apollo_gui.operation import CLOUD
from webui.apollo_gui.xpath.XPATH_AdditionalSettings import *

class AdditionalSettings(CLOUD):
    def __int__(self, url, title, pre_url=None):
        self.url = url
        self.title = title
        self.pre_url = pre_url if pre_url else url
        self.c = CLOUD(url, title, pre_url)
        self.mode = None
        self.popup = None

    def create_hive(self,name,port,probevalue):
        self.w.move_scroll_top()
        self.w.click(Hive.get('additionalsettings_page_wzard_menu'))
        self.w.wait_until_element_displayed(Hive.nav_hive)
        self.w.click(Hive.nav_hive)
        self.w.wait_until_element_displayed(Hive.get('hive_profile'))
        self.w.input(Hive.get('hive_name'),name)
        self.w.input(Hive.get('traffic_port'),port)
        self.w.move_scroll_by_element(Hive.get('security_title'))
        self.w.click(Hive.get('btn_macdos_hive'))
        self.w.wait_until_element_displayed(Hive.get('macdoc_hive_popup'))
        self.w.input(Hive.input_probeREQ_value,probevalue)
        self.w.click(Hive.btn_save_macDOS_dialog)
        self.w.wait_until_element_displayed(Hive.get('hive_profile'))
        self.w.move_scroll_bottom()
        self.w.click(Hive.get('btn_save_hiveprofile'))
      
        
    def wait_until_create_hive_profile_result(self, success_msg, check_success='true'):
        self.wait_until_displayed_success(Hive.get('popup_msg'), success_msg, check_success)

        
