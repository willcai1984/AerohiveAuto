#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import WebUI
from webui import WebUIException
from webui.cloud.page import *
import time

class CLOUD(object):
    # TODO:
    # - based on reply from qa team, the access url should be full qualified
    # name or ip address base on auth conf. since the web server might not be
    # resolved in testing environment or against certain conf which may cause
    # problem when verifying traffic pass-through successfully or not. pre_url
    # is temporary solution which is used to trigger the auth process. for
    # example, pre_url in full qualified name to trigger auth process while
    # url in ip address to verify traffic.
    def __init__(self, url, title, pre_url=None):
        self.url = url
        self.title = title
        self.pre_url = pre_url if pre_url else url

        self.w = WebUI()
        self.mode = None
        self.popup = None

    def check_cloud_on(self, locator, displayed):
        for i in range(4):
            try:
                self.w.wait_until_element_displayed(displayed)
                break
            except Exception, e:
                self.w.warn('Fail to find element %s, before check %s, will try again' \
                          %(str(displayed), str(locator)), True)
        if i == 3:
            raise WebUIException('Fail to find element %s, before check %s' \
                %(str(displayed), str(locator)))

        check_element = self.w.find_element(locator)
        if not check_element.is_selected():
            check_element.click()

    def check_cloud_off(self, locator, displayed):
        for i in range(4):
            try:
                self.w.wait_until_element_displayed(displayed)
                break
            except Exception, e:
                self.w.warn('Fail to find element %s, before check %s, will try again' \
                          %(str(displayed), str(locator)), True)
        if i == 3:
            raise WebUIException('Fail to find element %s, before check %s' \
                %(str(displayed), str(locator)))
        check_element = self.w.find_element(locator)
        if check_element.is_selected():
            check_element.click()

    def click_cloud(self, locator, displayed):
        for i in range(4):
            try:
                self.w.wait_until_element_displayed(displayed)
                break
            except Exception, e:
                self.w.warn('Fail to find element %s, before check %s, will try again' \
                          %(str(displayed), str(locator)), True)
        if i == 3:
            raise WebUIException('Fail to find element %s, before click %s' \
                %(str(displayed), str(locator)))
        self.w.click_element(self.w.find_element(locator))
        self.w.debug('after click %s' % str(locator))


    def try_again_get(self, url, title, times=5):
        for i in range(times):
            try:
                self.w.get(url)
                self.w.wait_until_title_present(title)
                self.w.info('successful get page with title: %s after access url: %s' % (title, url), True)
                break
            except Exception, e:
                if i == times - 1:
                    raise
                self.w.warn('fail to get page with title: %s after access url: %s, will try again' % (title, url), True)

    def to_url(self):
        self.w.info('trying to access %s' % self.url)
        self.try_again_get(self.url, self.title)

    def switch_to_popup(self):
        handles = self.w.window_handles
        for handle in handles:
            self.w.switch_to_window(handle)
            if self.w.title.startswith(LoginSuccessfulPopupPage.get('login_successful_popup_page_title')):
                self.w.info('Switch to window:Network Access Timer', True)
                return
        raise WebUIException('Cannot find window with title %s' % LoginSuccessfulPopupPage.get('login_successful_popup_page_title'))

    def switch_to_window(self, name):
        def __tmp(c):
            try:
                for handle in c.w.window_handles:
                    c.w.switch_to_window(handle)
                    if c.w.driver.title == name:
                        c.w.info('window switch to: %s' % name, True)
                        return True
            except:
                return False
        self.popup = self.w.wait_until(__tmp, msg='window %s' % name, inst=self)

    def to_menu(self, menu_name):
        self.w.wait_until_element_displayed(Home.get(str(menu_name) + '_btn'))
        self.w.info('handle to menu => ' + str(menu_name), True)
        self.w.click(Home.get(str(menu_name) + '_btn'))

    def to_url_before_menu(self, location='Cloud_default_login_page'):
        self.w.info('trying to access %s before login' % self.pre_url)
        self.try_again_get(self.pre_url, Home.get('menu_page_title'))

    def wait_until_to_menu_success(self, menu_name):
        self.wait_deploy_element(1)
        try:
            self.w.wait_until_element_displayed(MenuSuccessfulPage.get(str(menu_name) + '_successful_page_menu_title_xpath'), info=True)
            self.w.info('displayed the menu [ %s ] sucessful! ' %MenuSuccessfulPage.get(str(menu_name)))
        except Exception, e:
            self.w.s.execute_script('return window.onbeforeunload=null')
            self.w.warn('Fail to get menu_successful_page after login, will try again', True)
            self.w.s.refresh()
            self.w.wait_until_element_displayed(MenuSuccessfulPage.get(str(menu_name) + '_successful_page_menu_title_xpath'), info=True)

    def to_url_home(self):
        self.w.info('trying to access %s before to menu page' % self.pre_url)
        self.try_again_get(self.pre_url, Home.get('menu_page_title'))

    def is_check_element(self, locator):
        element_class = self.w.find_element(locator).get_attribute('class')
        if element_class.find('dijitCheckBoxChecked') > -1:
            return 1
        else:
            return 0

    def select_until_to_element(self, need_select_value, select_element, select_value_element):
        self.w.find_element(select_element)
        self.w.check(select_element)
        i = 1
        while 1:
            key_select_el = (select_value_element[0], select_value_element[1] % i)
            try:
                self.w.wait_until_element_displayed(key_select_el)
                select_value = self.w.find_element(key_select_el).text
                if need_select_value == select_value:
                    self.w.click(key_select_el)
                    break
            except Exception, e:
                self.w.error('not found need select value', True)
                break
            i += 1

    def wait_until_displayed_success(self, locator, success_msg, check_success='true'):
        if check_success == 'false':
            pass
        else:
            try:
                self.w.wait_until_element_displayed(locator, info=True)
                result_message = self.w.find_element(locator).text
                if result_message == success_msg:
                    self.w.info('Success to displayed info: %s' % result_message, True)
                else:
                    raise WebUIException('Fail to displayed, failed info: %s' % result_message)
            except Exception, e:
                self.w.warn('Fail to display, will try again', True)
                # self.w.s.execute_script('return window.onbeforeunload=null')
                # self.w.s.refresh()
                self.w.wait_until_element_displayed(locator, info=True)
                result_message = self.w.find_element(locator).text
                if result_message == success_msg:
                    self.w.info('Success to displayed info: %s' % result_message, True)
                else:
                    raise WebUIException('Again fail to displayed, failed info: %s' % result_message)

    def wait_deploy_element(self, second):
        time.sleep(second)
        self.w.info('wait [ %s ] second use to deploy elenment.' %second)

    def logout(self):
       pass

    def exception_thrown(self, msg):
        raise WebUIException(msg)