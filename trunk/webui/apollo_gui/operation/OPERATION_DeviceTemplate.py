#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'Tiesong'

from webui import WebUIException
from webui.apollo_gui.operation import CLOUD
from webui.apollo_gui.xpath.XPATH_DeviceTemplate import *

class DeviceTemplate(CLOUD):
    def __int__(self, url, title, pre_url=None):
        self.url = url
        self.title = title
        self.pre_url = pre_url if pre_url else url
        self.c = CLOUD(url, title, pre_url)
        self.mode = None
        self.popup = None

    def create_radio_profile(self,radioprofilename):
        self.w.click(DeviceTemplatePage.get('device_template_page_wzard_menu'))
        self.w.wait_until_element_displayed(DeviceTemplatePage.get('device_template_page_title'))
        self.w.click(DeviceTemplatePage.ap230_tmp)
        self.w.wait_until_element_displayed(DeviceTemplatePage.get('ap230_tmp_page_open'))
        self.w.click(DeviceTemplatePage.get('select_wifi0'))
        self.w.info('click assign button')
        self.w.click(DeviceTemplatePage.assign_btn)
        self.w.info('click create new button')
        self.w.click(DeviceTemplatePage.create_new)
        self.w.wait_until_element_displayed(DeviceTemplatePage.get('new_rp_page_open'))
        self.w.input(DeviceTemplatePage.get('radio_profile_name_text'),radioprofilename)
        self.w.click(DeviceTemplatePage.save_radio_profile_button)
        
    def save_device_template(self):
        self.w.click(DeviceTemplatePage.save_template_button)
        self.wait_until_displayed_success(DeviceTemplatePage.get('popup_msg'), "An unknown error has occurred during the execution of this request.")
        
    def wait_until_create_radio_profile_result(self, success_msg, check_success='true'):
        self.wait_until_displayed_success(DeviceTemplatePage.get('popup_msg'), success_msg, check_success)

        
        
        
        
