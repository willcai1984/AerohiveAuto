# -*- coding: UTF-8 -*-

from webui import WebUI
from webui import WebUIException
from webui.hm.page import *
from webui.hm.configuration import Configuration
import time

class HM(object):
    def __init__(self):
        self.w = WebUI()
        self.mode = None
        self.configer = Configuration()
    
    def admin_mode(self):
        self.mode = 'admin'
    
    def vhm_mode(self):
        self.mode = 'vhm'
    
    def is_admin_mode(self):
        return self.mode == 'admin'
    
    def is_vhm_mode(self):
        return self.mode == 'vhm'
      
    def _login(self, server, user, passwd):
        self.server = server
        self.user = user
        self.passwd = passwd
        
        self.w.info('trying to login %s as %s:%s' % (self.server, self.user, self.passwd))
        
        self.w.get(self.server)
        self.w.wait_until_element_displayed(LoginPage.get('login_btn'))
        self.w.check_title(LoginPage.get('login_page_title'), 'check title after open')
        
        self.w.input(LoginPage.get('username_txt'), self.user)
        self.w.input(LoginPage.get('password_txt'), self.passwd)
        
        self.w.info('login', True)
        self.w.click(LoginPage.get('login_btn'))

    def login(self, server, user, passwd):
        self.admin_mode()
        
        self._login(server, user, passwd)
        self.w.wait_until_element_displayed(MainPage.get('monitor_lnk'))
        
        self.w.register_cleanup(self.logout)

    def login_by_vhm(self, server, vhm_user, vhm_passwd, hive_name=None, hive_mgt_passwd=None, quick_ssid_passwd=None):
        self.vhm_mode()
        
        self._login(server, vhm_user, vhm_passwd)
        def __tmp(w):
            return w.s.title != LoginPage.get('login_page_title')
        self.w.wait_until(__tmp, msg='login page navigated')
        if self.w.title == EULAPage.get('eula_page_title'):
            self.w.wait_until_element_displayed(EULAPage.get('agree_btn'))
            self.w.info('agree with EUAL', True)
            self.w.click(EULAPage.get('agree_btn'))
            self.w.wait_until_element_displayed(WelcomePage.get('continue_btn'))
            self.w.check_title(WelcomePage.get('welcome_page_title'))
        
            self.w.input(WelcomePage.get('hive_name_txt'), hive_name)
            self.w.input(WelcomePage.get('hive_mgt_passwd_txt'), hive_mgt_passwd)
            self.w.input(WelcomePage.get('hive_mgt_passwd_confirm_txt'), hive_mgt_passwd)
            self.w.check(WelcomePage.get('enterprise_mode_radio'))
            self.w.wait_until_element_displayed(WelcomePage.get('quick_ssid_passwd_txt'))
            self.w.input(WelcomePage.get('quick_ssid_passwd_txt'), quick_ssid_passwd)
            self.w.input(WelcomePage.get('quick_ssid_passwd_confirm_txt'), quick_ssid_passwd)
            
            self.w.info('handle initial configuration', True)
            self.w.click(WelcomePage.get('continue_btn'))
            self.w.check_title(MainPage.get('main_page_title'), 'check title after login')
            
            time.sleep(5)
            
        self.w.register_cleanup(self.logout)

    def to_hiveaps_table(self, type='all'):
        self.w.click(MainPage.get('monitor_lnk'))
        self.w.wait_until_title_present(HiveAPsPage.get('allAPs_page_title'))

        if type == 'all':
            self.w.click(HiveAPsPage.get('hive_aps_lnk'))
            self.w.wait_until_title_present(HiveAPsPage.get('hiveAPs_page_title'))

            self.w.click(HiveAPsPage.get('auto_refresh_off'))
            selecter = self.w.get_selecter(HiveAPsPage.get('device_per_page_sel'))
            if selecter.first_selected_option.text != '500':
                selecter.select_by_value('500')
                self.w.debug('after select page size', True)
        elif type == 'rogue':
            self.w.click(RogueAPsPage.get('rogue_aps_lnk'))
            self.w.wait_until_title_present(RogueAPsPage.get('rogueAPs_page_title'))

            selecter = self.w.get_selecter(RogueAPsPage.get('device_per_page_sel'))
            if selecter.first_selected_option.text != '500':
                selecter.select_by_value('500')

    def select_ap(self, text='', by='default'):
        if by == 'default':
            try:
                self.w.wait_until_element_displayed(APsTablePage.locate_checkbox(text))
            except Exception, e:
                self.w.warn('Cannot find: %s' % text, True)
            checkbox_disabled = self.w.find_element(APsTablePage.locate_checkbox(text)).get_attribute('disabled')       
            if checkbox_disabled == 'true':
                self.w.warn('not selectable AP: %s' % text, True)
            else:
                self.w.check(APsTablePage.locate_checkbox(text))
                self.w.info('after select AP: %s' % text, True)
        elif by == 'linktext':
            try:
                self.w.wait_until_element_displayed(APsTablePage.locate_checkbox_by_linktext(text))
            except Exception, e:
                self.w.warn('Cannot find: %s' % text, True)            
            checkbox_disabled = self.w.find_element(APsTablePage.locate_checkbox_by_linktext(text)).get_attribute('disabled')       
            if checkbox_disabled == 'true':
                self.w.warn('not selectable AP: %s' % text, True)
            else:
                self.w.check(APsTablePage.locate_checkbox_by_linktext(text))
                self.w.info('after select AP: %s' % text, True)         
        elif by == 'rogue':
            try:
                self.w.wait_until_element_displayed(APsTablePage.locate_checkbox_of_rogueAP(text.split()[0], text.split()[1]))
            except Exception, e:
                self.w.warn('Cannot find: %s' % text, True)             
            checkbox_disabled = self.w.find_element(APsTablePage.locate_checkbox_of_rogueAP(text.split()[0], text.split()[1])).get_attribute('disabled')       
            if checkbox_disabled == 'true':
                self.w.warn('not selectable AP: %s' % text, True)
            else:
                self.w.check(APsTablePage.locate_checkbox_of_rogueAP(text.split()[0], text.split()[1]))
                self.w.info('after select AP: %s' % text, True)       
        elif by == 'rogue_stop':
            try:
                self.w.wait_until_element_displayed(APsTablePage.locate_checkbox_of_rogueAP1(text.split()[0], text.split()[1], text.split()[2]))
            except Exception, e:
                self.w.warn('Cannot find: %s' % text, True)             
            checkbox_disabled = self.w.find_element(APsTablePage.locate_checkbox_of_rogueAP1(text.split()[0], text.split()[1], text.split()[2])).get_attribute('disabled')       
            if checkbox_disabled == 'true':
                self.w.warn('not selectable AP: %s' % text, True)
            else:
                self.w.check(APsTablePage.locate_checkbox_of_rogueAP1(text.split()[0], text.split()[1], text.split()[2]))
                self.w.info('after select AP : %s' % text, True)  
    
    def to_clients_table(self, type='active_clients'):
        self.w.click(MainPage.get('monitor_lnk'))
        self.w.wait_until_title_present(HiveAPsPage.get('allAPs_page_title'))

        if type == 'active_clients':
            self.w.click(ActiveClientsPage.get('clients_lnk'))
            self.w.click(ActiveClientsPage.get('active_clients_lnk'))
            self.w.wait_until_title_present(ActiveClientsPage.get('active_clients_page_title'))

            selecter = self.w.get_selecter(ActiveClientsPage.get('client_per_page_sel'))
            if selecter.first_selected_option.text != '500':
                selecter.select_by_value('500')
                self.w.debug('after select page size', True)

    def select_client(self, text='', by='default'):
        if by == 'default':
            try:
                self.w.wait_until_element_displayed(ClientsTablePage.locate_checkbox(text))
            except Exception, e:
                self.w.warn('Cannot find: %s' % text, True)
            checkbox_disabled = self.w.find_element(ClientsTablePage.locate_checkbox(text)).get_attribute('disabled')       
            if checkbox_disabled == 'true':
                self.w.warn('not selectable client: %s' % text, True)
            else:
                self.w.check(ClientsTablePage.locate_checkbox(text))
                self.w.info('after select client: %s' % text, True)     

    #Update Functions...
    def select_policy(self, policy):
        self.w.click(ConfigurationPage.get('configuration_lnk'))
        self.w.wait_for_page_to_load()        
        try:
            self.w.click(ConfigurationPage.locate_policy_link(policy))
            try:
                self.w.wait_until_element_displayed(ConfigurationPage.get('warn_ok_btn')) 
                self.w.click(ConfigurationPage.get('warn_ok_btn'))  
            except Exception, e:
                pass
            self.w.find_element(ConfigurationPage.check_policy_selected(policy))
            return True             
        except Exception, e:
            pass

        # using workaround: resize wondow.
        try:
            self.w.s.set_window_size(600, 500)
            self.w.click(ConfigurationPage.locate_policy_link(policy))
            self.w.maximize_window()
            self.w.find_element(ConfigurationPage.check_policy_selected(policy))      
            return True
        except Exception, e:
            self.w.maximize_window()            
            self.w.warn('Cannot find policy: %s' % policy, True)             
            return False

        #if first workaround failed, using send space workaround
        # try:
        #     self.w.wait_until_element_displayed(ConfigurationPage.get('policy_table'))                    
        #     self.w.find_element(ConfigurationPage.get('policy_table')).send_keys(self.w.keys.SPACE)        
        #     self.w.click(ConfigurationPage.locate_policy_link(policy))
        #     self.w.find_element(ConfigurationPage.check_policy_selected(policy))      
        #     return True
        # except Exception, e:
        #     self.w.info('Cannot find policy %s' % policy, True)        
        #     return False
    
    def network_policy(self, action):
        self.configer.navi_menu('network_policies') 
        try:
            name = self.w.d('remove_policy.name')           
        except Exception, e:
            name = self.w.d('policy.name')
        exist = self.configer.check_exist(name)
        if exist:
            self.w.click(ProfileListPage.locate_created_checkbox(name))
            self.w.click(NetworkPoliciesPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)
        still_exist = self.configer.check_exist(name)
        #Cant delete it, used by devices
        if still_exist:
            self.select_policy(name)
            self.w.click(ConfigurationPage.get('config_devices_div'))
            self.select_ap(name)
            self.w.click(ConfigurationPage.get('modify_btn'))
            policy_selecter = self.w.get_selecter(ConfigurationPage.get('network_policy_select'))
            policy_selecter.select_by_visible_text('def-policy-template')             
            self.w.click(ConfigurationPage.get('save_options_btn'))
            self.configer.navi_menu('network_policies') 
            self.w.click(ProfileListPage.locate_created_checkbox(name))
            self.w.click(NetworkPoliciesPage.get('remove_btn'))
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
            self.w.info('after remove', True)

    def new_policy(self, name):
        self.network_policy('remove')        
        if self.w.d('dns_assign.ip'):
            self.configer.create_config('dns_assignment')
        if self.w.d('ntp_assign.ip'):
            self.configer.create_config('ntp_assignment')

        self.w.click(ConfigurationPage.get('configuration_lnk'))
        self.w.wait_for_page_to_load()          
        self.w.wait_until_element_displayed(ConfigurationPage.get('policy_table'))                    
        self.w.click(ConfigurationPage.get('new_policy_btn'))  
        self.w.input(ConfigurationPage.get('new_config_name_txt'), name)
        if self.w.d('hive.name'):
            hive_selecter = self.w.get_selecter(ConfigurationPage.get('hive_select'))
            hive_selecter.select_by_visible_text(self.w.d('hive.name'))
        self.w.info('befor create config', True)        
        self.w.click(ConfigurationPage.get('create_policy_btn'), ConfigurationPage.get('network_save_btn')) 
        self.w.wait_for_page_to_load()

        if self.w.d('ssid.name'):
            self.w.click(ConfigurationPage.get('add_remove_ssid_lnk'))  
            self.w.click(ConfigurationPage.locate_policy_link(self.w.d('ssid.name')))  
            self.w.click(ConfigurationPage.get('choose_ssid_ok_btn'))
        if self.w.d('cwp.name'):
            self.w.click(ConfigurationPage.get('choose_cwp_link'))
            cwp_list_frame = self.w.find_element(ConfigurationPage.get('cwp_list_frame'))
            self.w.switch_to_frame(cwp_list_frame)         
            self.w.click(ConfigurationPage.locate_policy_link(self.w.d('cwp.name')))  
            self.w.click(ConfigurationPage.get('choose_cwp_ok_btn'))
            self.w.s.switch_to_default_content()
        if self.w.d('radius.name'):
            self.w.click(ConfigurationPage.get('choose_radius_link'))       
            self.w.click(ConfigurationPage.locate_policy_link(self.w.d('radius.name')))  
            self.w.click(ConfigurationPage.get('choose_ssid_ok_btn'))
        if self.w.d('user_profile.default_user'):
            self.w.click(ConfigurationPage.get('add_remove_profile_lnk'))  
            self.w.click(ConfigurationPage.locate_policy_link(self.w.d('user_profile.default_user')))  
            self.w.click(ConfigurationPage.get('view_registration_user_lnk'))
            self.w.click(ConfigurationPage.locate_user_registration_link(self.w.d('user_profile.registration_user')))  
            self.w.click(ConfigurationPage.get('edit_profile_save_btn'))
        if self.w.d('dns_assign.ip'):
            self.w.click(ConfigurationPage.get('advanced_setting_btn'), ConfigurationPage.get('show_mgt_server_btn'))  
            self.w.click(ConfigurationPage.get('show_mgt_server_btn'), ConfigurationPage.get('mgt_dns_select'))  
            selecter_dns = self.w.get_selecter(ConfigurationPage.get('mgt_dns_select'))
            selecter_dns.select_by_visible_text(self.w.d('dns_assign.name'))
            self.w.info('befor setting config', True)                
            self.w.click(ConfigurationPage.get('network_policy_save_btn'))  
        if self.w.d('ntp_assign.ip'):
            self.w.click(ConfigurationPage.get('advanced_setting_btn'), ConfigurationPage.get('show_mgt_server_btn'))  
            self.w.click(ConfigurationPage.get('show_mgt_server_btn'), ConfigurationPage.get('mgt_time_select'))  
            selecter_time = self.w.get_selecter(ConfigurationPage.get('mgt_time_select'))
            selecter_time.select_by_visible_text(self.w.d('ntp_assign.name'))
            self.w.info('befor setting config', True)                
            self.w.click(ConfigurationPage.get('network_policy_save_btn'))  

        self.w.wait_for_page_to_load()
        self.w.info('befor save setting', True)                
        self.w.click(ConfigurationPage.get('network_save_btn'))  
        self.w.wait_for_page_to_load()

    def remove_policy(self):
        if self.w.d('remove_policy.name'):
            self.switch_to_vhm('home')            
            self.network_policy('remove') 
            self.logout()
            self.login(self.w.d("login.server"),
                       self.w.d("login.username"),
                       self.w.d("login.password"))                   
        if self.w.d('dns_assign.name'):
            self.configer.remove_config('dns_assignment')
        if self.w.d('ntp_assign.name'):
            self.switch_to_vhm('home')
            self.configer.remove_config('ntp_assignment')
            self.logout()
            self.login(self.w.d("login.server"),
                       self.w.d("login.username"),
                       self.w.d("login.password"))
        if self.w.d('ssid.name'):
            self.configer.remove_config('ssid')
        if self.w.d('user_profile.name'):
            self.configer.remove_config('user_profile')
        if self.w.d('vlan.name'):
            self.configer.remove_config('vlan')
        if self.w.d('cwp.name'):
            self.configer.remove_config('cwp')
        if self.w.d('aaa_client.name'):
            self.configer.remove_config('aaa_client')
        if self.w.d('aaa_user_dir.name'):
            self.configer.remove_config('aaa_user_dir')
            
    def config_update_device_new(self, policy, mgt0_ips, type):
        self.select_policy(policy)

        self.w.click(ConfigurationPage.get('config_devices_div'))
        selecter_filter = self.w.get_selecter(ConfigurationPage.get('filter_select'))
        selecter_filter.select_by_value('-1')
        selecter_page_size = self.w.get_selecter(ConfigurationPage.get('page_size_select'))
        selecter_page_size.select_by_value('500')
        self.w.wait_for_page_to_load()

        for ip in mgt0_ips.split():
            self.select_ap(ip)

        self.w.click(ConfigurationPage.get('settings_btn'))
        if type == 'compare_running_ap_config':
            self.w.click(ConfigurationPage.get('delta_upload_running_radio'))
        elif type == 'compare_last_ap_config':
            self.w.click(ConfigurationPage.get('delta_upload_last_radio'))
        elif type == 'complete':
            self.w.click(ConfigurationPage.get('complete_upload_radio'))

        self.w.info('preview update config settings', True)
        self.w.click(ConfigurationPage.get('save_options_btn')) 
        self.w.wait_for_page_to_load()          
        self.w.click(ConfigurationPage.get('upload_config_btn'))

        try:
            self.w.wait_until_element_displayed(ConfigurationPage.get('confirm_btn'))
            self.w.info('confirm dialog', True)
            self.w.find_element(ConfigurationPage.get('confirm_btn')).send_keys('\n')            
        except Exception, e:
            self.w.warn('Confirm dialog not found or error click confirm button', True)
        
    def upload_and_activate_configuration(self, mgt0_ips, type):
        for ip in mgt0_ips.split():
            self.select_ap(ip)
        self.w.click(HiveAPsPage.get('update_btn'))
        self.w.wait_for_page_to_load()
        self.w.click(HiveAPsPage.get('upload_and_activate_configuration_menu'))
        if type == 'compare_running_ap_config':
            self.w.click(HiveAPsPage.get('settings_link'))
            self.w.click(HiveAPsPage.get('delta_upload_running_radio'))
            self.w.click(HiveAPsPage.get('save_options_btn'))   
        elif type == 'compare_last_ap_config':
            self.w.click(HiveAPsPage.get('settings_link'))
            self.w.click(HiveAPsPage.get('delta_upload_last_radio'))
            self.w.click(HiveAPsPage.get('save_options_btn'))
        elif type == 'complete':
            self.w.click(HiveAPsPage.get('settings_link'))
            self.w.click(HiveAPsPage.get('complete_upload_radio'))
            self.w.click(HiveAPsPage.get('save_options_btn'))        
        self.w.info('preview update config settings', True)
        self.w.wait_until_element_enabled(HiveAPsPage.get('upload_config_btn'))
        self.w.wait_for_page_to_load()
        self.w.click(HiveAPsPage.get('upload_config_btn'))

    def view_config(self, mgt0_ip):
        self.select_ap(mgt0_ip)
        self.w.click(HiveAPsPage.get('update_btn'))
        self.w.wait_for_page_to_load()
        self.w.click(HiveAPsPage.get('upload_and_activate_configuration_menu'))
        self.w.click(HiveAPsPage.get('settings_link'))
        self.w.click(HiveAPsPage.get('delta_upload_last_radio'))
        self.w.click(HiveAPsPage.get('save_options_btn'))  
        self.w.info('before view config', True)
        self.w.wait_for_page_to_load()
        self.w.click(APsTablePage.locate_hostname(mgt0_ip))
        self.w.click(HiveAPsPage.get('view_config_menu'))
        self.w.wait_until_element_displayed(HiveAPsPage.get('content_viewer_div'))
        self.w.info('after view config', True)
               
    def update_bootstrap(self, mgt0_ips):
        for ip in mgt0_ips.split():
            self.select_ap(ip)
        self.w.click(HiveAPsPage.get('update_btn'))
        self.w.wait_for_page_to_load()
        self.w.click(HiveAPsPage.get('update_bootstrap_menu'))
        self.w.input(HiveAPsPage.get('bootstrap_admin_txt'), self.w.d('login.username'))
        self.w.input(HiveAPsPage.get('bootstrap_password_txt'), self.w.d('login.password'))
        self.w.input(HiveAPsPage.get('confirm_bootstrap_password_txt'), self.w.d('login.password'))
        self.w.info('preview update bootstrap settings', True)
        
        self.w.wait_until_element_enabled(HiveAPsPage.get('upload_bootstrap_btn'))        
        self.w.click(HiveAPsPage.get('upload_bootstrap_btn'))

    def update_country_code(self, mgt0_ips):
        for ip in mgt0_ips.split():
            self.select_ap(ip)          
        self.w.click(HiveAPsPage.get('update_btn'))
        self.w.wait_for_page_to_load()
        self.w.click(HiveAPsPage.get('update_country_code_menu'))
        
        selecter = self.w.get_selecter(HiveAPsPage.get('country_code_sel'))
        selecter.select_by_value(self.w.d('ap.country_code'))
        self.w.info('preview update country code', True)

    def update_country_code1(self, mgt0_ips):
        for ip in mgt0_ips.split():
            self.select_ap(ip)          
        self.w.click(HiveAPsPage.get('update_btn'))
        self.w.wait_for_page_to_load()
        self.w.click(HiveAPsPage.get('update_country_code_menu'))
        
        selecter = self.w.get_selecter(HiveAPsPage.get('country_code_sel'))
        selecter.select_by_value(self.w.d('ap.country_code'))
        self.w.info('preview update country code', True)
        self.w.wait_until_element_enabled(HiveAPsPage.get('upload_btn'))       
        self.w.click(HiveAPsPage.get('upload_btn'))

    def check_update_result(self, mgt0_ips, post_op=None, time_out=240, result_page='monitor'):
        if result_page == 'monitor':
            page_class = UpdateResultsPage
        elif result_page == 'config':
            page_class = ConfigurationPage

        for mgt0_ip in mgt0_ips.split():
            self.w.wait_for_page_to_load()                
            if result_page == 'monitor':
                self.w.info('befor check update result', True)
                self.w.click(UpdateResultsPage.get('update_results_link'))                
                self.w.wait_until_element_displayed(page_class.locate_result_by_ip(mgt0_ip))                
                self.w.wait_until_element_text(page_class.locate_result_by_ip(mgt0_ip), time_out=time_out)
                result = self.w.find_element(page_class.locate_result_by_ip(mgt0_ip)).text.strip()     
            elif result_page == 'config':
                self.w.info('befor check update result', True)
                self.w.wait_until_element_text(page_class.locate_result_by_ip(mgt0_ip), time_out=time_out)
                self.w.wait_until_update_process_end(page_class.locate_result_by_ip(mgt0_ip), time_out=time_out)
                result = self.w.find_element(page_class.locate_result_by_ip(mgt0_ip)).text.strip()     
            self.w.info('update result is: %s' % result, True)

        if post_op == 'retry':
            self.w.check(APsTablePage.locate_checkbox(mgt0_ip))
            self.w.click(page_class.get('retry_btn'))
        elif post_op == 'reboot':
            self.w.check(APsTablePage.locate_checkbox(mgt0_ip))
            self.w.click(page_class.get('reboot_btn'))            

    def modify(self, mgt0_ip, name):
        self.select_ap(mgt0_ip)
        self.w.click(HiveAPsPage.get('modify_btn')) 
        self.w.wait_for_page_to_load()            
        if name == 'enable_dhcp':
            self.w.click(ModifyAPPage.get('mgt0_interface_setting_link'))
            self.w.click(ModifyAPPage.get('dhcp_nofallback_radio'))
        if name == 'disable_dhcp':
            self.w.click(ModifyAPPage.get('mgt0_interface_setting_link'))
            self.w.click(ModifyAPPage.get('static_dhcp_radio'))
            self.w.input(ModifyAPPage.get('static_ip_input'), self.w.d('disable_dhcp.static_ip'))
            self.w.input(ModifyAPPage.get('netmask_input'), self.w.d('disable_dhcp.netmask'))
            self.w.input(ModifyAPPage.get('gateway_input'), self.w.d('disable_dhcp.gateway'))              
        if name == 'eth_state':
            self.w.click(ModifyAPPage.get('advanced_ethernet_setting_link'))
            if  self.w.d('eth_state.name') == "eth0":
                eth0_selecter = self.w.get_selecter(ModifyAPPage.get('eth0_state_sel'))
                eth0_selecter.select_by_value(self.w.d('eth_state.state'))
            elif self.w.d('eth_state.name') == "eth1":
                eth1_selecter = self.w.get_selecter(ModifyAPPage.get('eth1_state_sel'))
                eth1_selecter.select_by_value(self.w.d('eth_state.state'))
            elif self.w.d('eth_state.name') == "all":
                eth0_selecter = self.w.get_selecter(ModifyAPPage.get('eth0_state_sel'))
                eth0_selecter.select_by_value(self.w.d('eth_state.state'))
                eth1_selecter = self.w.get_selecter(ModifyAPPage.get('eth1_state_sel'))
                eth1_selecter.select_by_value(self.w.d('eth_state.state'))

        self.w.info('befor modify ap setting', True)            
        self.w.click(ModifyAPPage.get('save_btn'))  

    #Tools Functions...
    def reassign_vhm(self, mgt0_ip, vhm_name):
        try:
            self.select_ap(mgt0_ip)
            self.w.click(HiveAPsPage.get('reassign_btn'))
            self.w.wait_until_element_displayed(HiveAPsPage.locate_vhm_link(vhm_name))                
            self.w.click(HiveAPsPage.locate_vhm_link(vhm_name))
            self.w.find_element(HiveAPsPage.get('confirm_btn')).send_keys('\n') 
            self.w.info('after reassign:', True)
        except Exception, e:
            self.w.warn('no ap or not selectable', True)    
    
    def remove_ap(self, mgt0_ips):
        for ip in mgt0_ips.split():
            try:
                self.select_ap(ip)
                self.w.click(HiveAPsPage.get('remove_btn'))
                self.w.wait_until_element_displayed(HiveAPsPage.get('confirm_btn'))                
                self.w.find_element(HiveAPsPage.get('confirm_btn')).send_keys('\n') 
                self.w.info('after remove:', True)
            except Exception, e:
                self.w.warn('no ap or not selectable', True)

    def remove_ap_vhm(self):
        try:
            self.w.click(APsTablePage.get('check_all_checkbox'))
            self.w.click(HiveAPsPage.get('remove_btn'))
            self.w.wait_until_element_displayed(HiveAPsPage.get('confirm_btn'))                
            self.w.find_element(HiveAPsPage.get('confirm_btn')).send_keys('\n') 
            self.w.info('after remove:', True)
        except Exception, e:
            self.w.warn('no ap', True)

    def set_image_to_boot(self, mgt0_ips):
        for ip in mgt0_ips.split():
            self.select_ap(ip)
        self.w.click(HiveAPsPage.get('tools_btn'))
        self.w.click(HiveAPsPage.get('set_image_to_boot_menu'))
        #element.click() not working on overlay div, using send_keys('\n').
        #self.w.click(HiveAPsPage.get('submit_btn'))
        self.w.wait_until_element_displayed(HiveAPsPage.get('submit_btn'))
        self.w.find_element(HiveAPsPage.get('submit_btn')).send_keys('\n')
        self.w.wait_until_element_displayed(HiveAPsPage.get('confirm_btn'))
        self.w.find_element(HiveAPsPage.get('confirm_btn')).send_keys('\n')
        self.w.wait_until_element_displayed(HiveAPsPage.get('boot_result_div'))
        result = self.w.find_element(HiveAPsPage.get('boot_result_div')).text
        self.w.info('Set Image to Boot result: %s' % result, True)

    def get_tech_data(self, mgt0_ips):
        for ip in mgt0_ips.split():
            self.select_ap(ip)
        self.w.click(HiveAPsPage.get('tools_btn'))
        self.w.click(HiveAPsPage.get('get_tech_data_menu'))
        #Save file to local dialog is OS GUI, is not supported by Webdriver
        #Using Autoit script: AutoIt3.exe /ErrorStdOut save_file_win7.au3 C:\download_to\downloaded.zip
        # try:
        #     self.w.wait_until_element_displayed(HiveAPsPage.get('error_note_txt'))        
        #     error_note = self.w.find_element(HiveAPsPage.get('error_note_txt')).text            
        #     self.w.error('Error after get tech data: %s' % error_note, True)                    
        # except Exception, e:
        #     self.w.info('No Error after get tech data: ', True)

    def ssh_client(self, mgt0_ip):
        self.select_ap(mgt0_ip)
        self.w.click(HiveAPsPage.get('tools_btn'))
        self.w.click(HiveAPsPage.get('ssh_client_menu'))
        for handle in self.w.window_handles:
            self.w.switch_to_window(handle)
            if self.w.title == SSHClientPage.get('ssh_client_title'):
                self.w.click(SSHClientPage.get('connect_btn'))
                try:
                    self.w.wait_until_element_displayed(SSHClientPage.get('shell_input_txt'))                    
                    shell_prompt = self.w.find_element(SSHClientPage.get('shell_prompt_div')).text
                    self.w.info('SSH connected: %s' % shell_prompt, True)                    
                except Exception, e:
                    error_note = self.w.find_element(HiveAPsPage.get('error_note_txt')).text
                    self.w.info('Could not connect: %s' % error_note, True)                                  

                break

        for handle in self.w.window_handles:
            self.w.switch_to_window(handle)
            if self.w.title == HiveAPsPage.get('hiveAPs_page_title'):
                break           

    def get_ap_status(self, mgt0_ip, element):
        self.w.click(HiveAPsPage.get('auto_refresh_on'))
        time.sleep(60)        
        self.select_ap(mgt0_ip)
        if element == 'connection':
            connection = self.w.find_element(HiveAPsPage.locate_connection_by_ip(mgt0_ip)).get_attribute('src')
            if 'HM-capwap-up' in connection:
                self.w.info('AP "%s" connection is up' % mgt0_ip, True)
            elif 'HM-capwap-down' in connection:
                self.w.info('AP "%s" connection is down' % mgt0_ip, True)

    def update_hm_service(self, name):
        self.w.click(MainPage.get('home_lnk'))
        self.w.wait_until_title_present(HomePage.get('home_page_title'))
        self.w.click(HomePage.get('administration_lnk'))
        self.w.click(HomePage.get('hive_manager_services_lnk'))               
        self.w.wait_until_title_present(HiveManagerServicesPage.get('hive_manager_services_page_title'))
        if name == 'capwap_server':
            self.w.click(HiveManagerServicesPage.get('update_capwap_checkbox'))
            if self.w.d('capwap_server.primary'):                
         
                self.w.input(HiveManagerServicesPage.get('primary_capwap_server_input'), self.w.d('capwap_server.primary'))
            if self.w.d('capwap_server.udp_port'):
                self.w.input(HiveManagerServicesPage.get('capwap_udp_port_input'), self.w.d('capwap_server.udp_port'))
        
        self.w.info('befor update hm service', True)                    
        self.w.click(HiveManagerServicesPage.get('update_btn'))


    def mitigation(self, ssid, mac, reporters):
        ssid_mac = ssid + " " + mac.replace(':', '').upper()
        self.select_ap(ssid_mac, by='rogue')

        # reporters_hostname = []
        # if self.w.d('ap.reporting_mac'):
        #     for reporter in reporters.split():
        #         reporter_hostname = self.w.find_element(APsTablePage.get_reporter_hostname(reporter.replace(':', '').upper())).text
        #         reporters_hostname.append(reporter_hostname)
        # elif self.w.d('ap.reporting_hostname'):
        #     reporters_hostname = reporters.split()

        self.w.click(RogueAPsPage.get('mitigation_btn'))
        self.w.click(RogueAPsPage.get('start_mitigation_menu'))  
        self.w.wait_until_element_displayed(RogueAPsPage.get('confirm_btn'))
        self.w.info('befor mitigate rogue ap', True)                                  
        self.w.find_element(RogueAPsPage.get('confirm_btn')).send_keys('\n')
        self.w.info('after click confirm_btn', True)                                  

        self.w.wait_for_page_to_load()
        try:
            self.w.wait_until_element_displayed(RogueAPsPage.get('mitigate_btn'))
            self.w.info('after wait select reporter dialog', True)                                  
            for reporter in reporters.split():
                self.select_ap(reporter, by='linktext')

            self.w.click(RogueAPsPage.get('mitigate_btn'))               
            self.w.info('after click mitigate_btn', True)  
        except Exception, e:
            self.w.warn('Select reporter dialog did not opened, or can not find reporter ap: %s' % reporters, True)                                  
                                                                                                  
    def stop_mitigation(self, ssid, mac, reporter):
        ssid_mac_reporter = ssid + " " + mac.replace(':', '').upper() + " " + reporter
        self.select_ap(ssid_mac_reporter, by='rogue_stop')

        self.w.click(RogueAPsPage.get('mitigation_btn'))
        self.w.click(RogueAPsPage.get('stop_mitigation_menu'))               
        self.w.wait_until_element_displayed(RogueAPsPage.get('confirm_btn'))
        self.w.info('befor stop mitigate rogue ap', True)
        self.w.find_element(RogueAPsPage.get('confirm_btn')).send_keys('\n')
        self.w.info('after stop mitigate rogue ap', True)                          

    def config_ssid_express(self, name):
        self.w.click(ConfigurationPage.get('configuration_lnk'))
        self.w.wait_for_page_to_load()        
        self.w.info('available ap under express mode', True)
        self.w.click(ConfigSSIDExpressPage.get('config_ssid_link'))
        ssid_frame = self.w.find_element(ConfigSSIDExpressPage.get('config_ssid_frame'))
        self.w.switch_to_frame(ssid_frame)
        if name == 'aaa_user_dir':
            self.w.click(ConfigSSIDExpressPage.get('ap_as_ad_setup_radio'))
            try:
                self.w.input(ConfigSSIDExpressPage.get('primary_radius_server_input'), self.w.d('aaa_user_dir.primary_radius_server')[:5])
                self.w.info('Available APs', True)
            except Exception, e:
                pass            
            self.w.input(ConfigSSIDExpressPage.get('primary_radius_server_input'), self.w.d('aaa_user_dir.primary_radius_server'))
            self.w.find_element(ConfigSSIDExpressPage.get('primary_radius_server_input')).send_keys('\n')            
            self.w.input(ConfigSSIDExpressPage.get('ap_ip_input'), self.w.d('aaa_user_dir.server_ip'))
            self.w.input(ConfigSSIDExpressPage.get('ap_netmask_input'), self.w.d('aaa_user_dir.server_netmask'))
            self.w.input(ConfigSSIDExpressPage.get('ap_gateway_input'), self.w.d('aaa_user_dir.server_gateway'))
            self.w.input(ConfigSSIDExpressPage.get('ap_dns_server_input'), self.w.d('aaa_user_dir.server_dns_server'))
            self.w.click(ConfigSSIDExpressPage.get('update_btn'))
            time.sleep(10)
            self.w.info('after update', True)
            time.sleep(10)

            if self.w.d('aaa_user_dir.domain'):
                self.w.click(ConfigSSIDExpressPage.get('ad_integration_radio'))
                self.w.input(ConfigSSIDExpressPage.get('domain_input'), self.w.d('aaa_user_dir.domain'))
                self.w.click(ConfigSSIDExpressPage.get('Retrieve_btn'))
                try:
                    self.w.wait_until_element_displayed(AAAUserDirSettingsPage.get('Retrieve_message_txt'))                        
                    self.w.info('after retrieve directory info', True)
                except Exception, e:
                    pass
                self.w.info('after retrieve directory info', True)

            if self.w.d('aaa_user_dir.domain_admin'):
                self.w.input(ConfigSSIDExpressPage.get('domain_admin_name_input'), self.w.d('aaa_user_dir.domain_admin'))
                self.w.input(ConfigSSIDExpressPage.get('domain_admin_passwd_input'), self.w.d('aaa_user_dir.admin_passwd'))
                self.w.click(ConfigSSIDExpressPage.get('join_admin_btn'))
                try:
                    self.w.wait_until_element_displayed(AAAUserDirSettingsPage.get('join_message_txt'))                                                
                    self.w.info('after join domain admin', True)
                except Exception, e:
                    pass
                time.sleep(20)
                self.w.info('after join domain admin', True)

            if self.w.d('aaa_user_dir.domain_user'):
                self.w.input(ConfigSSIDExpressPage.get('domain_user_input'), self.w.d('aaa_user_dir.domain_user'))
                self.w.input(ConfigSSIDExpressPage.get('domain_user_passwd_input'), self.w.d('aaa_user_dir.user_passwd'))
                self.w.click(ConfigSSIDExpressPage.get('validate_user_btn'))
                try:
                    self.w.wait_until_element_displayed(AAAUserDirSettingsPage.get('validate_message_txt'))                                                                        
                    self.w.info('after validate domain user', True)
                except Exception, e:
                    pass
                time.sleep(20)
                self.w.info('after validate domain user', True)
        
        self.w.unregister_cleanup(self.logout)

    #Clients
    def client_opration(self, client_identifying, opration):
        self.select_client(client_identifying, by='default')

        if opration == "deauth_client":
            self.w.click(ActiveClientsPage.get('operation_btn'))
            self.w.click(ActiveClientsPage.get('deauth_client_menu'))
            if self.w.d('deauth_client.clear_cache') == "true":
                self.w.click(ActiveClientsPage.get('clear_cache_checkbox'))               
            self.w.click(ActiveClientsPage.get('deauth_btn'))               
            self.w.info('befor deauth client', True)
            self.w.find_element(ClientsTablePage.get('confirm_btn')).send_keys('\n')
            self.w.info('after deauth client', True)      
        
        self.w.wait_for_page_to_load()        

    def test(self):
        time.sleep(10)
        self.switch_to_vhm('home')     
        # self.w.click(ConfigurationPage.get('configuration_lnk'))
        # self.w.wait_for_page_to_load()        
        # self.w.s.set_window_size(600, 500)
        # self.w.click(ConfigurationPage.locate_policy_link('Asservernodns'))
        # #self.w.find_element(ConfigurationPage.get('policy_table')).send_keys(self.w.keys.SPACE)                
        # self.w.maximize_window()
        # self.w.click(ConfigurationPage.get('config_devices_div'))

    def logout(self):
        self.w.info('trying to logout')
        
        if self.is_admin_mode():
            def __tmp(w):
                w.click(MainPage.get('logout_menu'))
                element = w.find_element(MainPage.get('logout_btn'))
                if element.is_displayed():
                    w.info('logout menu', True)
                    w.click_element(element)
                    return True
                else:
                    return False
            self.w.wait_until(__tmp, msg='logout button present and to click')
        elif self.is_vhm_mode():
            self.w.click(MainPage.get('logout_vhm_btn'))
        else:
            raise WebUIException('unknown mode')
        self.w.wait_until_element_displayed(LoginPage.get('login_btn'))
        self.w.check_title(LoginPage.get('login_page_title'), 'check title after logout')
        
        self.w.unregister_cleanup(self.logout)

    def confirm(self, yes=True):
        self.w.wait_until_element_displayed(MainPage.get('confirm_dlg'))
        if yes:
            self.w.click(MainPage.get('confirm_dlg_yes_btn'))
        else:
            self.w.click(MainPage.get('confirm_dlg_no_btn'))
        
    def to_vhm_management_page(self):
        self.w.click(MainPage.get('home_lnk'))
        self.w.wait_until_title_present(HomePage.get('home_page_title'))
        self.w.wait_until_element_displayed(HomePage.get('administration_lnk'))
        
        self.w.click(HomePage.get('administration_lnk'))
        self.w.wait_until_element_displayed(HomePage.get('vhm_management_lnk'))
        
        self.w.click(HomePage.get('vhm_management_lnk'))
        self.w.wait_until_title_present(VHMManagementPage.get('vhm_management_page_title'))

    def switch_to_vhm(self, name):
        self.w.info('switch to vhm %s' % name)

        def __tmp(w):
            try:
                w.click(HomePage.get('home_lnk'))
                w.click(HomePage.get('administration_lnk'))
                w.click(HomePage.get('vhm_management_lnk'))
                w.click(HomePage.locate_vhm_checkbox(name))
                w.click(HomePage.get('opration_btn'))
                w.click(HomePage.get('switch_vhm_link'))
                user_name_element = w.find_element(MainPage.get('login_name'))
                if name in user_name_element.text:
                    return True
                else:
                    return False
            except Exception, e:
                print str(e)
                return False
        self.w.wait_until(__tmp, msg='switch to vhm', time_out=240)
        self.w.info('after switch to vhm %s' % name, True)

