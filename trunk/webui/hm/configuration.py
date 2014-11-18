# -*- coding: UTF-8 -*-

from webui import WebUI
from webui import WebUIException
from webui.hm.page import *
import time

class Configuration(object):
    def __init__(self):
        self.w = WebUI()                         

    def create_config(self, config_object):
        getattr(self, config_object)(action='create')

    def remove_config(self, config_object):
        getattr(self, config_object)(action='remove')
    
    def navi_menu(self, name):
        self.w.click(ConfigurationPage.get('configuration_lnk'))
        self.w.wait_for_page_to_load()                
        self.w.click(NavigationPage.get('show_nav_link'))
        if name == 'ssids':
            self.w.click(NavigationPage.get('ssids_link'))
        if name == 'user_profiles':
            self.w.click(NavigationPage.get('user_profiles_link'))        
        if name == 'network_policies':
            self.w.click(NavigationPage.get('network_policies_link'))
        if name == 'vlans':
            self.w.click(NavigationPage.get('adv_config_link'), NavigationPage.get('common_objects_link'))
            self.w.click(NavigationPage.get('common_objects_link'), NavigationPage.get('vlans_link'))
            self.w.click(NavigationPage.get('vlans_link'))
        if name == 'dns_assignment':
            self.w.click(NavigationPage.get('adv_config_link'), NavigationPage.get('mgt_services_link'))
            self.w.click(NavigationPage.get('mgt_services_link'), NavigationPage.get('dns_assign_link'))            
            self.w.click(NavigationPage.get('dns_assign_link'))
        if name == 'ntp_assignment':
            self.w.click(NavigationPage.get('adv_config_link'), NavigationPage.get('mgt_services_link'))
            self.w.click(NavigationPage.get('mgt_services_link'), NavigationPage.get('ntp_assign_link'))  
            self.w.click(NavigationPage.get('ntp_assign_link'))
        if name == 'device_aaa_server':
            self.w.click(NavigationPage.get('adv_config_link'), NavigationPage.get('authentication_link'))
            self.w.click(NavigationPage.get('authentication_link'), NavigationPage.get('device_aaa_server_link'))
            self.w.click(NavigationPage.get('device_aaa_server_link'))
        if name == 'aaa_user_dir':
            self.w.click(NavigationPage.get('adv_config_link'), NavigationPage.get('authentication_link'))
            self.w.click(NavigationPage.get('authentication_link'), NavigationPage.get('aaa_user_dir_link'))
            self.w.click(NavigationPage.get('aaa_user_dir_link'))
        if name == 'aaa_client_settings':
            self.w.click(NavigationPage.get('adv_config_link'), NavigationPage.get('authentication_link'))
            self.w.click(NavigationPage.get('authentication_link'), NavigationPage.get('aaa_client_settings_link'))
            self.w.click(NavigationPage.get('aaa_client_settings_link'))            
        if name == 'cwp_settings':
            self.w.click(NavigationPage.get('adv_config_link'), NavigationPage.get('authentication_link'))
            self.w.click(NavigationPage.get('authentication_link'), NavigationPage.get('cwp_link'))
            self.w.click(NavigationPage.get('cwp_link'))  

    def check_exist(self, name):
        try:
            self.w.wait_until_element_displayed(ProfileListPage.created_setting_link(name))
            return True                       
        except Exception, e:
            return False

    #Configuration objects
    def ssid(self, action):
        self.navi_menu('ssids') 
        exist = self.check_exist(self.w.d('ssid.name'))
        if exist:            
            self.w.click(ProfileListPage.locate_created_checkbox(self.w.d('ssid.name')))
            self.w.click(SSIDsPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)
            if action == 'remove':
                return
        if action == 'create':
            self.w.click(SSIDsPage.get('new_btn'))
            self.w.input(SSIDsPage.get('profile_name_input'), self.w.d('ssid.name'))
            self.w.input(SSIDsPage.get('ssid_name_input'), self.w.d('ssid.name'))
            self.w.click(SSIDsPage.get('enable_cwp_checkbox'))            
            self.w.info('befor save', True)            
            self.w.click(SSIDsPage.get('save_btn'))            
            self.w.info('after save succesfull', True)

    def user_profile(self, action):
        self.navi_menu('user_profiles')
        for profile_name in self.w.d('user_profile.name').split():
            exist = self.check_exist(profile_name)
            if exist:            
                self.w.click(ProfileListPage.locate_created_checkbox(profile_name))
                self.w.click(UserProfilesPage.get('remove_btn'))
                self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
                self.w.info('after remove', True)
        if action == 'remove':
            try:
                profiles = self.w.s.find_elements(UserProfilesPage.get('created_checkbox'))
                for profile in profiles:
                    profile.click()
                    self.w.click(UserProfilesPage.get('remove_btn'))
                    self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
                    self.w.info('after remove', True)
            except Exception, e:
                print str(e)
            return
        if action == 'create':
            self.w.click(UserProfilesPage.get('new_btn'))
            self.w.input(UserProfilesPage.get('profile_name_input'), self.w.d('user_profile.name'))
            self.w.input(UserProfilesPage.get('attribute_input'), self.w.d('user_profile.attribute'))
            if self.w.d('user_profile.network'):
                network_selecter = self.w.get_selecter(UserProfilesPage.get('network_select'))
                network_selecter.select_by_visible_text(self.w.d('user_profile.network'))  
            if self.w.d('user_profile.vlan'):
                choose_vlan_selecter = self.w.get_selecter(UserProfilesPage.get('choose_vlan_select'))
                choose_vlan_selecter.select_by_visible_text('VLAN (Wireless Only)')  
                vlan_selecter = self.w.get_selecter(UserProfilesPage.get('vlan_select'))
                vlan_selecter.select_by_visible_text(self.w.d('user_profile.vlan'))  
            self.w.info('befor save', True)            
            self.w.click(UserProfilesPage.get('save_btn'))            
            self.w.info('after save succesfull', True)
    
    #Advanced Configuration
    #Common Objects
    def vlan(self, action):
        self.navi_menu('vlans') 
        exist = self.check_exist(self.w.d('vlan.name'))
        if exist:            
            self.w.click(ProfileListPage.locate_created_checkbox(self.w.d('user_profile.name')))
            self.w.click(VLansPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)
            if action == 'remove':
                return
        if action == 'create':
            self.w.click(VLansPage.get('new_btn'))
            self.w.input(VLansPage.get('profile_name_input'), self.w.d('vlan.name'))
            self.w.input(VLansPage.get('vlan_id_input'), self.w.d('vlan.id')) 
            self.w.click(VLansPage.get('applay_btn'))
            self.w.info('befor save', True)                        
            self.w.click(VLansPage.get('save_btn'))            
            self.w.info('after save succesfull', True)

    #Management Services
    def dns_assignment(self, action):
        self.navi_menu('dns_assignment')        
        exist = self.check_exist(self.w.d('dns_assign.name'))
        if exist:            
            self.w.click(ProfileListPage.locate_created_checkbox(self.w.d('dns_assign.name')))
            self.w.click(DNSAssignPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)
            if action == 'remove':
                return
        if action == 'create':
            self.w.click(DNSAssignPage.get('new_btn'))
            self.w.input(DNSAssignPage.get('name_input'), self.w.d('dns_assign.name'))
            self.w.input(DNSAssignPage.get('ip_input'), self.w.d('dns_assign.ip'))
            self.w.click(DNSAssignPage.get('apply_btn'))
            self.w.info('befor save', True)            
            self.w.click(DNSAssignPage.get('save_btn'))            
            self.w.info('after save succesfull', True)

    def ntp_assignment(self, action):
        self.navi_menu('ntp_assignment')
        exist = self.check_exist(self.w.d('ntp_assign.name'))
        if exist:            
            self.w.click(ProfileListPage.locate_created_checkbox(self.w.d('ntp_assign.name')))
            self.w.click(NTPAssignPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)
            if action == 'remove':
                return
        if action == 'create':
            self.w.click(NTPAssignPage.get('new_btn'))
            self.w.input(NTPAssignPage.get('name_input'), self.w.d('ntp_assign.name'))
            self.w.click(NTPAssignPage.get('clock_radio'))
            self.w.input(NTPAssignPage.get('ip_input'), self.w.d('ntp_assign.ip'))
            self.w.click(NTPAssignPage.get('apply_btn'))
            self.w.info('befor save', True)            
            self.w.click(NTPAssignPage.get('save_btn'))            
            self.w.info('after save succesfull', True)
    
    #Authentication    
    def aaa_client(self, action):
        self.navi_menu('aaa_client_settings')
        exist = self.check_exist(self.w.d('aaa_client.name'))
        if exist:            
            self.w.click(ProfileListPage.locate_created_checkbox(self.w.d('aaa_client.name')))
            self.w.click(AAAClientSettingsPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)
            if action == 'remove':
                return
        if action == 'create':
            self.w.click(AAAClientSettingsPage.get('new_btn'))
            self.w.input(AAAClientSettingsPage.get('name_input'), self.w.d('aaa_client.name'))
            self.w.input(AAAClientSettingsPage.get('ip_input'), self.w.d('aaa_client.ip'))
            self.w.input(AAAClientSettingsPage.get('shared_secret_input'), self.w.d('aaa_client.shared_secret'))
            self.w.input(AAAClientSettingsPage.get('shared_secret_confirm_input'), self.w.d('aaa_client.shared_secret'))
            self.w.click(AAAClientSettingsPage.get('apply_btn'))
            self.w.info('befor save', True)            
            self.w.click(AAAClientSettingsPage.get('save_btn'))            
            self.w.info('after save succesfull', True)

    def cwp(self, action):
        self.navi_menu('cwp_settings')
        exist = self.check_exist(self.w.d('cwp.name'))
        if exist:            
            self.w.click(ProfileListPage.locate_created_checkbox(self.w.d('cwp.name')))
            self.w.click(CWPSettingsPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)
            if action == 'remove':
                return
        if action == 'create':
            self.w.click(CWPSettingsPage.get('new_btn'))
            self.w.input(CWPSettingsPage.get('name_input'), self.w.d('cwp.name'))
            regist_type_selecter = self.w.get_selecter(CWPSettingsPage.get('regist_type_select'))
            regist_type_selecter.select_by_visible_text(self.w.d('cwp.regist_type')) 
            self.w.click(CWPSettingsPage.get('adv_config_link'))
            self.w.click(CWPSettingsPage.get('display_timer_checkbox'))
            if self.w.d('cwp.dhcp_dns') == 'internal':
                self.w.click(CWPSettingsPage.get('dhcp_dns_internal_radio'))
            else:                            
                self.w.click(CWPSettingsPage.get('dhcp_dns_external_radio'))
                if self.w.d('cwp.vlan'):
                    self.w.click(CWPSettingsPage.get('override_vlan_checkbox'))
                    self.w.input(CWPSettingsPage.get('vlan_input'), self.w.d('cwp.vlan'))

            self.w.info('befor save', True)
            self.w.click(CWPSettingsPage.get('save_btn'))            
            self.w.info('after save succesfull', True)

    def aaa_user_dir(self, action):
        self.navi_menu('aaa_user_dir')
        exist = self.check_exist(self.w.d('aaa_user_dir.name'))
        if exist:
            self.w.click(ProfileListPage.locate_created_checkbox(self.w.d('aaa_user_dir.name')))
            self.w.click(AAAUserDirSettingsPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)
            if action == 'remove':
                return
        if action == 'create':
            self.w.click(AAAUserDirSettingsPage.get('new_btn'))
            if self.w.d('aaa_user_dir.name'):
                self.w.input(AAAUserDirSettingsPage.get('name_input'), self.w.d('aaa_user_dir.name'))
            if self.w.d('aaa_user_dir.domain'):
                self.w.input(AAAUserDirSettingsPage.get('domain_input'), self.w.d('aaa_user_dir.domain'))
            if self.w.d('aaa_user_dir.ap_name'):
                try:
                    self.w.input(AAAUserDirSettingsPage.get('ap_name_input'), self.w.d('aaa_user_dir.ap_name')[:5])
                    self.w.info('Available APs', True)
                except Exception, e:
                    pass
                self.w.input(AAAUserDirSettingsPage.get('ap_name_input'), self.w.d('aaa_user_dir.ap_name'))
            if self.w.d('aaa_user_dir.ap_gateway'):
                self.w.input(AAAUserDirSettingsPage.get('ap_gateway_input'), self.w.d('aaa_user_dir.ap_gateway'))
            if self.w.d('aaa_user_dir.ap_dns_server'):
                self.w.input(AAAUserDirSettingsPage.get('ap_dns_server_input'), self.w.d('aaa_user_dir.ap_dns_server'))            
            if self.w.d('aaa_user_dir.ap_gateway') or self.w.d('aaa_user_dir.ap_dns_server'):
                self.w.click(AAAUserDirSettingsPage.get('update_btn'))
                time.sleep(20)
                self.w.info('after update', True)

            if self.w.d('aaa_user_dir.ad_server'):
                AD_selecter = self.w.get_selecter(AAAUserDirSettingsPage.get('AD_server_select'))
                AD_selecter.select_by_visible_text(self.w.d('aaa_user_dir.ad_server'))            
            if self.w.d('aaa_user_dir.domain'):
                self.w.click(AAAUserDirSettingsPage.get('Retrieve_btn'))
                try:
                    self.w.wait_until_element_displayed(AAAUserDirSettingsPage.get('Retrieve_message_txt'))                        
                    self.w.info('after retrieve directory info', True)
                except Exception, e:
                    pass
                self.w.info('after retrieve directory info', True)

            if self.w.d('aaa_user_dir.domain_admin'):
                self.w.input(AAAUserDirSettingsPage.get('domain_admin_name_input'), self.w.d('aaa_user_dir.domain_admin'))
                self.w.input(AAAUserDirSettingsPage.get('domain_admin_passwd_input'), self.w.d('aaa_user_dir.admin_passwd'))
                self.w.input(AAAUserDirSettingsPage.get('domain_admin_passwd_confirm_input'), self.w.d('aaa_user_dir.admin_passwd'))
            if self.w.d('aaa_user_dir.save_credential'):
                self.w.click(AAAUserDirSettingsPage.get('save_credential_checkbox'))
            if self.w.d('aaa_user_dir.domain_admin'):
                self.w.click(AAAUserDirSettingsPage.get('join_admin_btn'))
                try:
                    self.w.wait_until_element_displayed(AAAUserDirSettingsPage.get('join_message_txt'))                                                
                    self.w.info('after join domain admin', True)
                except Exception, e:
                    pass
                time.sleep(20)
                self.w.info('after join domain admin', True)

            if self.w.d('aaa_user_dir.domain_user'):
                self.w.input(AAAUserDirSettingsPage.get('domain_user_input'), self.w.d('aaa_user_dir.domain_user'))
                self.w.input(AAAUserDirSettingsPage.get('domain_user_passwd_input'), self.w.d('aaa_user_dir.user_passwd'))
                self.w.input(AAAUserDirSettingsPage.get('domain_user_passwd_confirm_input'), self.w.d('aaa_user_dir.user_passwd'))
                self.w.click(AAAUserDirSettingsPage.get('validate_user_btn'))
                try:
                    self.w.wait_until_element_displayed(AAAUserDirSettingsPage.get('validate_message_txt'))                                                                        
                    self.w.info('after validate domain user', True)
                except Exception, e:
                    pass
                time.sleep(20)
                self.w.info('after validate domain user', True)
            
            if self.w.d('aaa_user_dir.save'):
                self.w.info('befor save', True)                
                self.w.click(AAAUserDirSettingsPage.get('save_btn'))
                self.w.info('after save succesfull', True)

    def device_aaa_server(self, action):
        self.navi_menu('device_aaa_server')        
        self.w.click(DeviceAAAServerSettingsPage.get('new_btn'))
        self.w.click(DeviceAAAServerSettingsPage.get('unfold_database_link'))
        self.w.click(DeviceAAAServerSettingsPage.get('external_db_checkbox'))
        self.w.click(DeviceAAAServerSettingsPage.get('server_attr_map_checkbox'))            
        self.w.click(DeviceAAAServerSettingsPage.get('apply_server_btn'))
        time.sleep(20)
        self.w.info('after add directory server', True)

        if self.w.d('device_aaa_server.ad_user'):            
            self.w.click(DeviceAAAServerSettingsPage.get('root_group_node'))
            self.w.click(DeviceAAAServerSettingsPage.get('user_group_node'))
            self.w.click(DeviceAAAServerSettingsPage.get('admin_user_node'))
            time.sleep(20)
            self.w.click(DeviceAAAServerSettingsPage.get('apply_map_btn'))
            time.sleep(20)
            self.w.info('after map user', True)

    def config_ssid_express(self, name):
        self.w.click(ConfigurationPage.get('configuration_lnk'))
        self.w.wait_for_page_to_load()        
        self.w.info('available ap under express mode', True)
        self.w.click(ConfigSSIDExpressPage.get('config_ssid_link'))
        ssid_frame = self.w.find_element(ConfigSSIDExpressPage.get('config_ssid_frame'))
        self.w.switch_to_frame(ssid_frame)
        if name == 'aaa_user_dir':
            self.w.click(ConfigSSIDExpressPage.get('ap_as_ad_setup_radio'))
            self.w.input(ConfigSSIDExpressPage.get('primary_radius_server_input'), self.w.d('aaa_user_dir.primary_radius_server'))
            self.w.find_element(ConfigSSIDExpressPage.get('primary_radius_server_input')).send_keys('\n')            
            self.w.input(ConfigSSIDExpressPage.get('ap_ip_input'), self.w.d('aaa_user_dir.server_ip'))
            self.w.input(ConfigSSIDExpressPage.get('ap_netmask_input'), self.w.d('aaa_user_dir.server_netmask'))
            self.w.input(ConfigSSIDExpressPage.get('ap_gateway_input'), self.w.d('aaa_user_dir.server_gateway'))
            self.w.input(ConfigSSIDExpressPage.get('ap_dns_server_input'), self.w.d('aaa_user_dir.server_dns_server'))
            self.w.click(ConfigSSIDExpressPage.get('update_btn'))
            time.sleep(20)
            self.w.info('after update', True)

            if self.w.d('aaa_user_dir.domain'):
                self.w.click(ConfigSSIDExpressPage.get('ad_integration_radio'))
                self.w.input(ConfigSSIDExpressPage.get('domain_input'), self.w.d('aaa_user_dir.domain'))
                self.w.click(ConfigSSIDExpressPage.get('Retrieve_btn'))
                time.sleep(20)
                self.w.info('after retrieve directory info', True)

            if self.w.d('aaa_user_dir.domain_admin'):
                self.w.input(ConfigSSIDExpressPage.get('domain_admin_name_input'), self.w.d('aaa_user_dir.domain_admin'))
                self.w.input(ConfigSSIDExpressPage.get('domain_admin_passwd_input'), self.w.d('aaa_user_dir.admin_passwd'))
                self.w.click(ConfigSSIDExpressPage.get('join_admin_btn'))
                time.sleep(20)
                self.w.info('after join domain admin', True)

            if self.w.d('aaa_user_dir.domain_user'):
                self.w.input(ConfigSSIDExpressPage.get('domain_user_input'), self.w.d('aaa_user_dir.domain_user'))
                self.w.input(ConfigSSIDExpressPage.get('domain_user_passwd_input'), self.w.d('aaa_user_dir.user_passwd'))
                self.w.click(ConfigSSIDExpressPage.get('validate_user_btn'))
                time.sleep(20)
                self.w.info('after validate domain user', True)
        
        self.w.unregister_cleanup(self.logout)
