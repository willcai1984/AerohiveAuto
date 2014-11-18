#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import WebUIException
from webui.cloud import CLOUD
from webui.apollo_gui.xpath.devices import DevicesElement
from webui.apollo_gui.xpath.config import DeviceOnboarding

class Devices(CLOUD):

    def __int__(self, url, title, pre_url=None):
        self.url = url
        self.title = title
        self.pre_url = pre_url if pre_url else url
        self.c = CLOUD(url, title, pre_url)
        self.mode = None
        self.popup = None

    def check_sn_exist(self, sn_text):
        device_element = (DevicesElement.get('sn_td')[0], DevicesElement.get('sn_td')[1] %sn_text)
        try:
            self.w.wait_until_element_displayed(device_element)
            self.w.warn('found this sn in this page.', True)
            return True
        except:
            self.w.warn('not found this sn in this page, try click next btn.', True)
            try:
                self.w.wait_until_element_displayed(DevicesElement.get('next_page_btn'))
                next_page_btn_class = self.w.find_element(DevicesElement.get('next_page_btn')).get_attribute('class')
                if 'Disable' == next_page_btn_class[-7:]:
                    self.w.error('not found this sn in devices list ', True)
                    return False
                else:
                    self.w.click(DevicesElement.get('next_page_btn'))
                    return self.check_sn_exist(sn_text)
            except:
                self.w.error('not found this next page btn in devices list', True)
                return False

    def click_new_devices_btn(self):
        self.w.click(DevicesElement.get('new_btn'), DevicesElement.get('popup_div_title'))
        if DevicesElement.new_device_title_msg != self.w.find_element(DevicesElement.get('popup_div_title')).text:
            raise WebUIException('handle deploy popup "Add Your Aerohive Devices" div failed!')
        self.w.info('handle deploy popup "Add Your Aerohive Devices" div success', True)

    def click_add_devices_btn(self):
        self.w.click(DevicesElement.get('add_devices_btn'), DevicesElement.get('popup_div_title'))
        self.w.wait_until_element_displayed(DevicesElement.get('next_btn'))
        if DevicesElement.reg_devices_title_msg != self.w.find_element(DevicesElement.get('popup_div_title')).text:
            raise WebUIException('handle deploy popup "Register my Aerohive Devices" div failed!')
        self.w.info('handle deploy popup "Register my Aerohive Devices" div success', True)

    def input_devices_sn(self, sn_text):
        self.w.wait_until_element_displayed(DevicesElement.get('sn_text'))
        self.w.click(DevicesElement.get('sn_radio'))
        self.w.input(DevicesElement.get('sn_text'), sn_text)
        self.w.info('handle input serial numbers', True)
        self.w.click(DevicesElement.get('next_btn'), DevicesElement.get('popup_div_title'))

    def show_add_devices(self):
        self.wait_deploy_element(1)
        self.w.wait_until_element_displayed(DevicesElement.get('next_btn'))
        if DevicesElement.my_devices_title_msg != self.w.find_element(DevicesElement.get('popup_div_title')).text:
            raise WebUIException('handle deploy popup "My Aerohive Devices" div failed!')
        self.w.info('handle deploy popup "My Aerohive Devices" div success', True)
        self.w.click(DevicesElement.get('next_btn'), DevicesElement.get('popup_div_title'))

    def finish_add_device(self):
        self.wait_deploy_element(1)
        self.w.wait_until_element_displayed(DevicesElement.get('finish_btn'))
        if DevicesElement.congratulations_title_msg != self.w.find_element(DevicesElement.get('popup_div_title')).text:
            raise WebUIException('handle deploy popup "Congratulations!" div failed!')
        self.w.info('handle deploy popup "Congratulations!" div success', True)
        self.w.click(DevicesElement.get('finish_btn'))

    def add_devices_by_serial_numbers(self, sn_text):
        self.click_new_devices_btn()
        self.click_add_devices_btn()
        self.input_devices_sn(sn_text)
        self.show_add_devices()

        self.wait_deploy_element(1)
        if DevicesElement.deploy_policy_title_msg != self.w.find_element(DevicesElement.get('popup_div_title')).text:
            raise WebUIException('handle deploy popup "Deploy a Network Policy" div failed!')
        self.w.info('handle deploy popup "Deploy a Network Policy" div success', True)
        self.deploy_policy_toggle(1)
        self.w.click(DevicesElement.get('next_btn'), DevicesElement.get('popup_div_title'))

        self.finish_add_device()

    def deploy_policy_toggle(self, number):
        toggle_element = DevicesElement.get('deploy_policy_toggle')
        toggle_element_checkbox = DevicesElement.get('deploy_policy_toggle_checkbox')
        new_toggle_element = (toggle_element[0], toggle_element[1] % number)
        new_toggle_element_checkbox = (toggle_element_checkbox[0], toggle_element_checkbox[1] % number)
        if self.w.find_element(new_toggle_element):
            try:
                self.w.wait_until_element_displayed(new_toggle_element)
                if self.w.find_element(new_toggle_element_checkbox).is_selected():
                    self.w.find_element(new_toggle_element_checkbox).click()
                    self.w.info('handle deploy network policy toggle success.', True)
                else:
                    self.w.info('deploy network policy toggle is not selected no need handle.', True)
            except Exception, e:
                print e
                self.w.info('this element [ %s ] is not deploy, try check next element.' %new_toggle_element[1])
                number += 1
                self.deploy_policy_toggle(number)
        else:
            self.w.info('not found this element [%s] or found all elements are not deploy.' %new_toggle_element[1], True)
            raise WebUIException('not found this element [%s] or found all elements are not deploy.' %new_toggle_element[1])

    def remove_devices_by_serial_numbers(self, sn_number):
        device_element = (DevicesElement.get('sn_td')[0], DevicesElement.get('sn_td')[1] %sn_number)
        check_element = (DevicesElement.get('sn_checkbox_div')[0], DevicesElement.get('sn_checkbox_div')[1] %sn_number)
        try:
            self.w.wait_until_element_displayed(device_element)
            checkbox_class = self.w.find_element(check_element).get_attribute('class')
            if not checkbox_class.find('dijitCheckBoxChecked') > -1:
                self.w.click(check_element)
            self.w.click(DevicesElement.get('remove_btn'), DevicesElement.get('popup_div_msg'))
            self.w.info('handle remove device, popup sure message success', True)
            self.w.click(DevicesElement.get('yes_btn'))
            self.w.wait_until_element_displayed(DevicesElement.get('handle_msg_el'))
            self.w.info('handle remove device success', True)
        except:
            self.w.warn('not found this sn in this page, try click next btn.', True)
            try:
                self.w.click(DevicesElement.get('next_btn'))
                self.check_sn_exist(sn_number)
            except:
                self.w.error('not found this sn in devices list', True)

    def device_onboarding_create_new_policy(self, sn_text, netpolicy_name,ssid_name, net_password):
        self.click_new_devices_btn()
        self.click_add_devices_btn()
        self.input_devices_sn(sn_text)
        self.show_add_devices()

        self.wait_deploy_element(1)
        self.w.wait_until_element_displayed(DevicesElement.get('popup_div_title'))
        if DevicesElement.deploy_policy_title_msg != self.w.find_element(DevicesElement.get('popup_div_title')).text:
            raise WebUIException('handle deploy popup "Deploy a Network Policy" div failed!')
        self.w.info('handle deploy popup "Deploy a Network Policy" div success', True)

        self.w.check(DeviceOnboarding.get('Create_new_policy'))
        self.w.info('select create a netpolicy', True)
        self.wait_deploy_element(1)

        self.w.input(DeviceOnboarding.get('Input_netpolicy_textarea'), netpolicy_name)
        self.w.input(DeviceOnboarding.get('Input_ssid_textarea'), ssid_name)
        self.w.info('input network policy and ssid name end', True)

        self.w.move_scroll_by_element(DeviceOnboarding.get('Create_new_policy'))
        #
        self.w.input(DeviceOnboarding.get('Input_network_password_textarea'), net_password)
        self.w.info('input device password end, handle click next of build policy', True)

        self.w.click(DevicesElement.get('next_btn'), DevicesElement.get('popup_div_title'))

        self.finish_add_device()

    def device_onboarding_exsit_policy(self, sn_text, netpolicy_name):
        self.click_new_devices_btn()
        self.click_add_devices_btn()
        self.input_devices_sn(sn_text)
        self.show_add_devices()

        self.wait_deploy_element(1)
        self.w.wait_until_element_displayed(DevicesElement.get('popup_div_title'))
        if DevicesElement.deploy_policy_title_msg != self.w.find_element(DevicesElement.get('popup_div_title')).text:
            raise WebUIException('handle deploy popup "Deploy a Network Policy" div failed!')
        self.w.info('handle deploy popup "Deploy a Network Policy" div success', True)

        self.w.check(DeviceOnboarding.get('Use_existing_pilicy'))
        self.w.info('select use an existing Network Policy', True)
        self.wait_deploy_element(1)

        self.select_until_to_element(netpolicy_name, DeviceOnboarding.get('Existing_policy_dorpdown_list'), \
                                     DeviceOnboarding.get('Policys_of_dorpdown_list'))


        self.w.click(DevicesElement.get('next_btn'), DevicesElement.get('popup_div_title'))

        self.wait_deploy_element(2)
        self.w.wait_until_element_displayed(DevicesElement.get('finish_btn'))
        if DevicesElement.congratulations_title_msg != self.w.find_element(DevicesElement.get('popup_div_title')).text:
            raise WebUIException('handle deploy popup "Congratulations!" div failed!')
        self.w.info('handle deploy popup "Congratulations!" div success', True)
        self.w.click(DevicesElement.get('finish_btn'))

