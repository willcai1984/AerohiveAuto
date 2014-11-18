#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'hshao'

from webui import WebUIException
from webui.cloud import CLOUD
from webui.cloud.page.configuration import *

class Configuration(CLOUD):
    def __int__(self, url, title, pre_url=None):
        self.url = url
        self.title = title
        self.pre_url = pre_url if pre_url else url
        self.c = CLOUD(url, title, pre_url)
        self.mode = None
        self.popup = None


    def to_page_before_policy(self):
        self.w.wait_until_element_displayed(NetworkPolicy.get('new_btn'))
        self.w.info('handle to network policies', True)
        self.w.click(NetworkPolicy.get('new_btn'))

    def policy_mode(self):
        self.mode = 'policy'

    def create_network_policy(self, policy_name, desc):
        self.policy_mode()
        self.w.wait_until_element_displayed(NetworkPolicy.get('next_btn'))
        self.w.input(NetworkPolicy.get('policy_name'), policy_name)
        self.w.input(NetworkPolicy.get('desc_txt'), desc)
        self.w.info('handle create network policy', True)
        self.w.click(NetworkPolicy.get('next_btn'))

    def wait_until_create_policy_result(self, success_msg, check_success='true'):
        self.wait_until_displayed_success(NetworkPolicy.get('popup_msg'), success_msg, check_success)

    def wait_until_create_ssid_result(self, success_msg, check_success='true'):
        self.wait_until_displayed_success(DeployedSSID.get('popup_msg'), success_msg, check_success)

    def wait_until_to_deployed_ssid(self):
        self.w.wait_until_element_displayed(DeployedSSID.get('menu_title_xpath'))
        self.w.info('handle to deployed wireless SSID', True)

    def to_page_before_deployed_ssid(self):
        self.w.wait_until_element_displayed(DeployedSSID.get('menu_title_xpath'))
        if self.w.find_element(DeployedSSID.get('menu_title_xpath')).text == DeployedSSID.menu_successful_page_menu_title:
            self.w.wait_until_element_displayed(DeployedSSID.get('new_btn'))
            self.w.info('handle to deployed wireless SSID', True)
            self.w.click(DeployedSSID.get('new_btn'))
        else:
            self.w.error('handle to deployed wireless SSID page warn. This is title not match.', True)
            self.w.quit()

    def to_customize_user_profile_page(self):
        self.w.debug('will move scroll to bottom page, begin to customize default user-profile page', True)
        self.w.move_scroll_bottom()
        self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_title'))
        #edit default user-profile
        self.w.info('click button and try to customize default user-profile', True)
        self.w.click(DeployedSSID.get('user_profile_customize_btn'), DeployedSSID.get('user_profile_edit_title'))
        self.w.debug('after to customize default user-profile page', True)

    def deployedSSID_mode(self):
        self.mode = 'ssid'

    def input_ssid_name(self, ssid_obj_name, ssid_name):
        self.w.move_scroll_top()
        self.w.debug('start input ssid name ...', True)
        self.w.wait_until_element_displayed(DeployedSSID.get('ssid_obj_name'))
        self.w.input(DeployedSSID.get('ssid_obj_name'), ssid_obj_name)
        self.w.wait_until_element_displayed(DeployedSSID.get('ssid_name'))
        self.w.input(DeployedSSID.get('ssid_name'), ssid_name)
        self.w.debug('after input ssid name ...', True)

    def ssid_usage_settings(self, access_security, usage_type='Education (K-12)'):
        self.w.debug('begin select ssid usage ... ', True)
        self.w.wait_until_element_displayed(DeployedSSID.get('ssid_usage_title'))
        self.w.move_scroll_by_element(DeployedSSID.get('ssid_usage_title'))
        if usage_type == 'Education (K-12)':
            if access_security == 'CUSTOM':
                self.w.wait_until_element_displayed(DeployedSSID.get('custom_display'))
                self.w.click(DeployedSSID.get('custom_span'))
        self.w.debug('after select ssid usage ... ', True)

    def set_access_security(self, access_security):
        self.w.debug('begin select ssid access security ... ', True)
        self.w.wait_until_element_displayed(DeployedSSID.get('access_div'))
        self.w.move_scroll_by_element(DeployedSSID.get('access_div'))
        if access_security == 'open':
            self.w.wait_until_element_displayed(DeployedSSID.get('open_access_label'))
            self.w.click(DeployedSSID.get('open_access_span'))
        self.w.debug('after select ssid access security ... ', True)

    def create_SSID_open(self, ssid_obj_name, ssid_name):
        self.deployedSSID_mode()
        self.input_ssid_name(ssid_obj_name, ssid_name)
        self.ssid_usage_settings('CUSTOM')
        self.set_access_security('open')
        self.wait_deploy_element(2)
        self.w.info('handle create new ssid', True)
        self.w.click(DeployedSSID.get('save_btn'), DeployedSSID.get('menu_title_xpath'))

    def create_SSID_psk(self, ssid_obj_name, ssid_name, psk_key):
        self.deployedSSID_mode()
        self.w.move_scroll_top()
        self.w.wait_until_element_displayed(DeployedSSID.get('save_btn'))
        self.w.input(DeployedSSID.get('ssid_obj_name'), ssid_obj_name)
        self.w.input(DeployedSSID.get('ssid_name'), ssid_name)
        self.w.wait_until_element_displayed(DeployedSSID.get('custom_display'))
        self.w.click   (DeployedSSID.get('custom_span'))

        self.w.info('will move scroll to access security...', True)
        self.w.move_scroll_to_element(DeployedSSID.get('access_div'))
        self.w.wait_until_element_displayed(DeployedSSID.get('psk_access_label'))
        self.w.click(DeployedSSID.get('psk_access_span'))
        self.w.wait_until_element_displayed(DeployedSSID.get('psk_key_value'))
        self.w.input(DeployedSSID.get('psk_key_value'), psk_key)
        self.w.wait_until_element_displayed(DeployedSSID.get('psk_confirm_value'))
        self.w.input(DeployedSSID.get('psk_confirm_value'), psk_key)

        self.wait_deploy_element(1)
        self.w.info('handle create new ssid', True)
        self.w.click(DeployedSSID.get('save_btn'), DeployedSSID.get('menu_title_xpath'))

    def create_SSID_8021x(self, ssid_obj_name, ssid_name, radius_server, radius_hostname, radius_host_ip, \
                          shared_secret):
        self.deployedSSID_mode()
        self.w.move_scroll_top()
        self.w.wait_until_element_displayed(DeployedSSID.get('save_btn'))
        self.w.input(DeployedSSID.get('ssid_obj_name'), ssid_obj_name)
        self.w.input(DeployedSSID.get('ssid_name'), ssid_name)
        self.w.wait_until_element_displayed(DeployedSSID.get('custom_display'))
        self.w.click(DeployedSSID.get('custom_span'))

        self.w.info('will move scroll to access security...', True)
        self.w.move_scroll_to_element(DeployedSSID.get('access_div'))
        self.w.wait_until_element_displayed(DeployedSSID.get('access_8021x_label'))
        self.w.click(DeployedSSID.get('access_8021x_span'))
        self.w.info('select access security end.', True)

        self.w.info('begin to add new radius server...')
        self.w.wait_until_element_displayed(DeployedSSID.get('new_radius_server_btn'))
        self.w.click(DeployedSSID.get('new_radius_server_btn'))

        self.w.wait_until_element_displayed(DeployedSSID.get('external_radius_server_title_xpath'))
        self.w.input(DeployedSSID.get('radius_name'), radius_server)
        self.w.input(DeployedSSID.get('radius_description'), self.w.d("ssid.radius_description"))

        self.w.click(DeployedSSID.get('radius_hostname'), DeployedSSID.get('radius_hostname_iplist'))
        i = 1
        try:
            self.w.debug('begin search radius host ip exist in ip List.')
            while 1:
                ip_text_element = DeployedSSID.get('radius_hostname_ip_text')
                new_ip_text_element = (ip_text_element[0], ip_text_element[1] %i)
                self.w.wait_until_element_displayed(new_ip_text_element)
                if radius_host_ip == self.w.find_element(new_ip_text_element).text:
                    self.w.click(new_ip_text_element)
                    break
                i += 1
        except Exception, e:
            self.w.warn('not exist radius host ip in the ip List.')
            self.w.click(DeployedSSID.get('radius_new_hostname_btn'), DeployedSSID.get('radius_new_host_div'))
            self.w.input(DeployedSSID.get('radius_new_host_name'), radius_hostname)
            self.w.input(DeployedSSID.get('radius_new_host_ip'), radius_host_ip)
            self.w.info('handle to add new radius ip ...', True)
            self.w.click(DeployedSSID.get('radius_new_hostname_save'))

        self.w.input(DeployedSSID.get('key_value_8021x'), shared_secret)
        self.w.input(DeployedSSID.get('confirm_value_8021x'), shared_secret)
        self.w.info('handle create new External Radius Server', True)
        self.w.click(DeployedSSID.get('external_radius_server_save'))
        self.w.info('handle create a new 8021x ssid pic 1', True)
        self.w.debug('will move scroll to access security...', True)
        self.w.move_scroll_to_element(DeployedSSID.get('access_div'))

        self.wait_deploy_element(1)
        self.w.info('handle create a new 8021x ssid pic 2', True)
        self.w.click(DeployedSSID.get('save_btn'), DeployedSSID.get('menu_title_xpath'))

    def to_page_device_templates(self):
        pass

    def to_page_additional_settings(self):
        pass

    def to_page_deploy_policy(self):
        self.w.wait_until_element_displayed(DeployPolicy.get('configwizardNav'))
        self.w.click(DeployPolicy.get('deploypolicy_menu'), DeployPolicy.get('deploypolicy_title'))
        self.w.info('handle to menu deploy policy.', True)

    def deploy_policy(self, ap_mac):
        self.select_checkbox_deploy_policy(ap_mac)
        self.w.click(DeployPolicy.get('upload_btn'))
        self.w.info('handle to click update button end!', True)
        self.w.wait_until_element_displayed(DeployPolicy.get('popup_step_tetle'))
        self.w.info('deploy popup step, need to click upload button again.', True)
        self.w.click(DeployPolicy.get('upload_uploadBtn'))

    def wait_until_to_deploy_policy_page(self, success_msg, check_success='true'):
        self.wait_until_displayed_success(DeployPolicy.get('menu_title'), success_msg, check_success)

    def select_checkbox_deploy_policy(self, ap_mac):
        self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
        self.w.info('handle to deploy policy', True)
        mac_element = DeployPolicy.get('mac_xpath')
        checkbox_element = DeployPolicy.get('checkbox_xpath')
        stat_element = DeployPolicy.get('stat_xpath')

        new_mac_element = (mac_element[0], mac_element[1] % ap_mac)
        new_checkbox_element = (checkbox_element[0], checkbox_element[1] % ap_mac)
        new_stat_element = (stat_element[0], stat_element[1] % ap_mac)
        try:
            self.w.wait_until_element_displayed(new_mac_element)
            device_stat_class = self.w.find_element(new_stat_element).get_attribute('class')
            if device_stat_class.find('hive-status-true') > -1:
                if not self.is_check_element(new_checkbox_element):
                    self.w.click(new_checkbox_element)
                self.w.info('select this mac checkbox successfully', True)
            else:
                self.w.error('This device status is false ', True)
                raise WebUIException('This device status is false')
        except:
            self.w.error('not found mac address element [ %s ] or The device status error!' %new_mac_element, True)
            raise WebUIException('not found mac address element [ %s ] or The device status error!' %new_mac_element)

    def wait_until_to_deploy_policy_success(self, success_msg, check_success='true'):
        self.wait_until_displayed_success(DeployPolicy.get('suc_message'), success_msg, check_success)

    def start_deploy_policy(self):
        self.w.wait_until_element_displayed(DeployPolicy.get('upload_btn'))
        self.w.info('handle to deploy policy', True)
        self.w.click(DeployPolicy.get('next_btn'))

    def user_profile_srcurce_ip(self, host_name, host_ip, excpet_use = False):
        self.w.info('try to check source ip address is exists', True)
        if not self.w.find_element(DeployedSSID.get('user_profile_src_ip_btn')):
            raise WebUIException('not found the user profile src ip btn ...')
        self.w.click(DeployedSSID.get('user_profile_src_ip_btn'))

        self.w.info('click the src ip list button use to show the list', True)
        self.wait_deploy_element(1)
        try:
            src_ip_list = DeployedSSID.get('user_profile_src_ip_list')
            src_ip_list_element = (src_ip_list[0], src_ip_list[1] %host_name)
            if self.w.find_element(src_ip_list_element):
                self.w.info('found the element =>'+str(src_ip_list_element))
                i = 1
                while 1:
                    src_host_elm = (src_ip_list[0], (src_ip_list[1] + '/li[%s]') %(host_name, str(i)))
                    self.w.debug('try to found the element =>' + str(src_host_elm))
                    if host_name == self.w.find_element(src_host_elm).text:
                        try:
                            self.w.click(src_host_elm)
                            break
                        except Exception:
                            self.w.debug("not found element => " + str(src_host_elm))
                    i+=1
        except Exception, e:
            if excpet_use:
                self.w.error("Click user_profile_src_ip_list again on the failure!")
                raise WebUIException("Click user_profile_src_ip_list again on the failure!")
            else:
                self.w.info("not found the user_profile_src_ip_list, so add the host to ip list.")
                self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_src_ip_new_btn'))
                self.w.click(DeployedSSID.get('user_profile_src_ip_new_btn'))
                self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_src_ip_name'))
                self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_src_ip_host'))
                self.w.input(DeployedSSID.get('user_profile_src_ip_name'), host_name)
                self.w.input(DeployedSSID.get('user_profile_src_ip_host'), host_ip)
                self.w.click(DeployedSSID.get('user_profile_src_ip_save_btn'))
                self.user_profile_srcurce_ip(host_name, host_ip, True)

    def user_profile_destination_ip(self, host_name, host_ip, excpet_use = False):
        self.w.info('try to check source ip address is exists', True)
        self.w.find_element(DeployedSSID.get('user_profile_des_ip_btn'))

        self.w.click(DeployedSSID.get('user_profile_des_ip_btn'))
        self.w.info('click the des ip list button use to show the list', True)
        self.wait_deploy_element(1)
        try:
            des_ip_list = DeployedSSID.get('user_profile_des_ip_list')
            des_ip_list_element = (des_ip_list[0], des_ip_list[1] %host_name)
            if self.w.find_element(des_ip_list_element):
                self.w.info('found the element =>'+str(des_ip_list_element))
                i = 1
                while 1:
                    des_host_elm = (des_ip_list[0], (des_ip_list[1] + '/li[%s]') %(host_name, str(i)))
                    self.w.debug('try to found the element =>' + str(des_host_elm))
                    if host_name == self.w.find_element(des_host_elm).text:
                        try:
                            self.w.click(des_host_elm)
                            break
                        except Exception:
                            self.w.debug("not found element => " + str(des_host_elm))
                    i+=1
        except Exception, e:
            if excpet_use:
                self.w.error("Click user_profile_des_ip_list again on the failure!")
                raise WebUIException("Click user_profile_des_ip_list again on the failure!")
            else:
                self.w.info("not found the user_profile_des_ip_list, so add the host to ip list.")
                self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_des_ip_new_btn'))
                self.w.click(DeployedSSID.get('user_profile_des_ip_new_btn'))
                self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_des_ip_name'))
                self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_des_ip_host'))
                self.w.input(DeployedSSID.get('user_profile_des_ip_name'), host_name)
                self.w.input(DeployedSSID.get('user_profile_des_ip_host'), host_ip)
                self.w.click(DeployedSSID.get('user_profile_des_ip_save_btn'))
                self.user_profile_destination_ip(host_name, host_ip, True)

    def user_profile_select_net_service(self, filter = "Any"):
        #select the service type for the rule
        self.w.info('try to select service types for rules', True)
        self.w.click(DeployedSSID.get('user_profile_service_btn'))
        self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_netservice_tab'))
        self.w.info('switch to service selection dialog successfully', True)
        self.w.info('begin switch to  network service tab ...', True)
        self.w.click(DeployedSSID.get('user_profile_netservice_tab'))
        self.wait_deploy_element(2)
        self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_netservice_filter_search_input'))
        self.w.wait_until_element_displayed(DeployedSSID.get('user_profile_netservice_filter_search_btn'))
        self.w.info('switch to the network service tab success', True)

        # search filter
        self.w.input(DeployedSSID.get('user_profile_netservice_filter_search_input'), filter)
        self.w.info('input filter use search...', True)
        self.w.click(DeployedSSID.get('user_profile_netservice_filter_search_btn'))

        self.w.info('found the filter [%s] in the list and try to click the checkbox...', filter)
        filter_name_elm = (DeployedSSID.get('user_profile_netservice_filter_name')[0], \
                           DeployedSSID.get('user_profile_netservice_filter_name')[1] % filter)
        self.w.wait_until_element_displayed(filter_name_elm)
        filter_checkbox_elm = (DeployedSSID.get('user_profile_netservice_filter_checkbox')[0], \
                           DeployedSSID.get('user_profile_netservice_filter_checkbox')[1] % filter)
        self.w.click(filter_checkbox_elm)
        self.w.info('click the filter checkbox success, handle to click the save button...')
        self.w.click(DeployedSSID.get('user_profile_netservice_save_btn'))

