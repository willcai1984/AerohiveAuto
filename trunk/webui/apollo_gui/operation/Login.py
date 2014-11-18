#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import WebUIException
from webui.cloud import CLOUD
from webui.apollo_gui.xpath.login import *

class Login(CLOUD):
    def __int__(self, url, title, pre_url=None):
        self.url = url
        self.title = title
        self.pre_url = pre_url if pre_url else url
        self.c = CLOUD(url, title, pre_url)
        self.mode = None
        self.popup = None

    def login_mode(self):
        self.mode = 'login'

    def is_login_mode(self):
        return self.mode == 'login'

    def to_url_before_login(self, location='Cloud_default_login_page'):
        self.w.info('trying to access %s before login' % self.pre_url)
        self.try_again_get(self.pre_url, LoginPage.get('login_page_title'))

    def login(self, username, password):
        self.login_mode()
        self.w.wait_until_element_displayed(LoginPage.get('login_btn'))

        self.w.input(LoginPage.get('username_txt'), username)
        self.w.input(LoginPage.get('password_txt'), password)

        self.w.info('handle login form', True)
        self.w.click(LoginPage.get('login_btn'))

    def wait_until_login_success(self, user_name):
        try:
            self.w.wait_until_element_displayed(LoginSuccessfulPage.get('timestamp'))
            self.w.info('login successful.', True)
        except Exception, e:
            self.w.error('login failed.', True)
        
        
#         try:
#             self.w.wait_until_element_displayed(LoginSuccessfulPage.get('user_name'))
#             if user_name == self.w.find_element(LoginSuccessfulPage.get('user_name')).text:
#                 self.w.info('login successful.', True)
#             else:
#                 self.w.error('login failed.', True)
#         except Exception, e:
#             self.w.s.execute_script('return window.onbeforeunload=null')
#             self.w.warn('Fail to get login_successful_page after login, will try again', True)
#             self.w.s.refresh()
#             self.w.wait_until_element_displayed(LoginSuccessfulPage.get('user_name'))
#             if user_name == self.w.find_element(LoginSuccessfulPage.get('user_name')).text:
#                 self.w.info('login successful.', True)
#             else:
#                 self.w.error('login failed.', True)

