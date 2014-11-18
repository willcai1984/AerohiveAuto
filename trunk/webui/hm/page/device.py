# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class APsTablePage(WebElement):
    
    check_all_checkbox = (By.ID, 'checkAll')

    @classmethod
    def locate_checkbox(cls, text):
        return (By.XPATH, '//td[contains(text(), "%s")]/../td[@class="listCheck"]/input' % text)

    @classmethod
    def locate_checkbox_by_linktext(cls, text):
        return (By.XPATH, '//td/a[contains(text(), "%s")]/../../td[@class="listCheck"]/input' % text)

    @classmethod
    def locate_checkbox_of_rogueAP(cls, ssid, mac):
        return (By.XPATH, '//td[4][contains(text(), "%s")]/../td[2][contains(text(), "%s")]/../td[@class="listCheck"]/input' % (ssid, mac))

    @classmethod
    def locate_checkbox_of_rogueAP1(cls, ssid, mac, reporter):
        return (By.XPATH, '//td[4][contains(text(), "%s")]/../td[2][contains(text(), "%s")]/../td[14]/a[contains(text(), "%s")]/../../td[@class="listCheck"]/input' % (ssid, mac, reporter))

    @classmethod
    def locate_hostname(cls, text):
        return (By.XPATH, '//td[contains(text(), "%s")]/../td/a' % text)

    @classmethod
    def get_reporter_hostname(cls, text):
        return (By.XPATH, '//td[contains(text(), "%s")]/../td[14]/a' % text)
    
    @classmethod
    def new_or_managed(cls, text):
        return (By.XPATH, '//td[contains(text(), "%s")]/../@class' % text)


class HiveAPsPage(WebElement):
    hiveAPs_page_title = 'Aerohive APs'
    allAPs_page_title = 'All Devices'

    auto_refresh_off = (By.ID, 'autoRefreshSettingOff')
    auto_refresh_on = (By.ID, 'autoRefreshSettingOn')
    device_per_page_sel = (By.ID, 'hiveAp_pageSize')
    hive_aps_lnk = (By.LINK_TEXT, 'Aerohive APs')
    rogue_aps_lnk = (By.LINK_TEXT, 'Rogue APs')
    
    #Operate buttons
    update_btn = (By.XPATH, '//input[@value="Update..."]')
    tools_btn = (By.XPATH, '//input[@value="Tools..."]')
    modify_btn = (By.XPATH, '//input[@value="Modify"]')
    remove_btn = (By.XPATH, '//input[@value="Remove"]')
    reassign_btn = (By.XPATH, '//input[@value="Reassign..."]')

    #reassign vhm menu
    @classmethod
    def locate_vhm_link(cls, vhm_name):
        return (By.LINK_TEXT, "%s" % vhm_name)    

    #update menu
    upload_and_activate_configuration_menu = (By.LINK_TEXT, 'Upload and Activate Configuration')
    update_bootstrap_menu = (By.LINK_TEXT, 'Update Bootstrap')
    update_country_code_menu = (By.LINK_TEXT, 'Update Country Code')
    
    #tools menu
    set_image_to_boot_menu = (By.LINK_TEXT, 'Set Image to Boot')
    get_tech_data_menu = (By.LINK_TEXT, 'Get Tech Data')
    ssh_client_menu = (By.LINK_TEXT, 'SSH Client')
    
    #upload_and_activate_configuration
    settings_link = (By.ID, 'showOption')
    complete_upload_radio = (By.ID, 'hiveApUpdate_configSelectTypefull')
    delta_upload_running_radio = (By.ID, 'hiveApUpdate_configSelectTypedeltaRunning')
    delta_upload_last_radio = (By.ID, 'hiveApUpdate_configSelectTypedeltaConfig')
    save_options_btn = (By.ID, 'saveOption')
    upload_config_btn = (By.ID, 'updateBtn')
    view_config_menu = (By.LINK_TEXT, 'View Configuration')
    content_viewer_div = (By.ID, 'content_viewer')

    #update_bootstrap
    bootstrap_admin_txt = (By.ID, 'bootstrapAdmin')
    bootstrap_password_txt = (By.ID, 'bootstrapPassword')
    confirm_bootstrap_password_txt = (By.ID, 'confirmPassword')
    upload_bootstrap_btn = (By.XPATH, '//input[@value="Upload"]')

    #set_image_to_boot
    submit_btn = (By.XPATH, '//input[@value="Submit"]')
    confirm_btn = (By.XPATH, '//button[contains(text(), "Yes")]')
    boot_result_div = (By.ID, 'cli_viewer')

    #update_country_code
    country_code_sel = (By.ID, 'countryCode')
    
    upload_btn = (By.XPATH, '//input[@value="Upload"]')
    error_note_txt = (By.XPATH, '//td[@class="noteError"]')

    @classmethod
    def locate_connection_by_ip(cls, mgt0_ip):
        return (By.XPATH, '//td[contains(text(), "%s")]/../td/img[@class="dinl"]' % mgt0_ip)

class ModifyAPPage(WebElement):
    modifyAP_page_title = 'HiveAPs'
    save_btn = (By.XPATH, '//table[@id="editHiveAPTable"]/tbody/tr[2]/td/table/tbody/tr/td/input')
    save_btn1 = (By.XPATH, '//input[@value="Save"]')
    save_btn2 = (By.XPATH, '//input[@value="Save" and @type="button"]')
    save_btn3 = (By.XPATH, '//input[@name="ignore"][11]')

    #Interface and Network
    mgt0_interface_setting_link = (By.XPATH, '''//span[@onclick="alternateFoldingContent('mgt0DhcpSettings');"]''')
    interface_network_setting_link = (By.XPATH, '''//span[@onclick="alternateFoldingContent('networkSettings');"]''')
    advanced_ethernet_setting_link = (By.XPATH, '''//span[@onclick="alternateFoldingContent('ethAdvSettings');"]''')
    
    static_dhcp_radio = (By.ID, 'hiveAp_mgt0NetworkType1')
    dhcp_nofallback_radio = (By.ID, 'hiveAp_mgt0NetworkType3')

    static_ip_input = (By.ID, 'hiveAp_dataSource_cfgIpAddress')
    netmask_input = (By.ID, 'hiveAp_dataSource_cfgNetmask')
    gateway_input = (By.ID, 'hiveAp_dataSource_cfgGateway')
    
    eth0_state_sel = (By.ID, 'hiveAp_dataSource_eth0_adminState')
    eth1_state_sel = (By.ID, 'hiveAp_dataSource_eth1_adminState')


class RogueAPsPage(WebElement):
    rogueAPs_page_title = 'Rogue APs'

    rogue_aps_lnk = (By.LINK_TEXT, 'Rogue APs')
    device_per_page_sel = (By.ID, 'idp_pageSize')

    #Operate buttons
    mitigation_btn = (By.XPATH, '//input[@value="Mitigation..."]')
    settings_btn = (By.XPATH, '//input[@value="Settings..."]')
    management_btn = (By.XPATH, '//input[@value="Management..."]')
    
    #mitigation menu
    start_mitigation_menu = (By.LINK_TEXT, 'Start Mitigation')
    stop_mitigation_menu = (By.LINK_TEXT, 'Stop Mitigation')
    
    confirm_btn = (By.XPATH, '//button[contains(text(), "Yes")]')
    ap_checkbox = (By.XPATH, '//input[@type="checkbox"]')
    mitigate_btn = (By.XPATH, '//input[@value="Mitigate"]')


class UpdateResultsPage(WebElement):
    update_results_title = 'Device Update Results'
    update_results_link = (By.LINK_TEXT, 'Device Update Results')

    retry_btn = (By.XPATH, '//input[@value="Retry"]')
    reboot_btn = (By.XPATH, '//input[@value="Reboot"]')

    @classmethod
    def locate_result_by_ip(cls, mgt0_ip):
        return (By.XPATH, '//td[contains(text(), "%s")]/../td[@id="d9"]' % mgt0_ip)


class SSHClientPage(WebElement):
    ssh_client_title = 'SSH Client'

    connect_btn = (By.XPATH, '//input[@value="Connect"]')
    disconnect_btn = (By.XPATH, '//input[@value="Disconnect"]')
    
    shell_prompt_div = (By.XPATH, '//div[@id="shellContent"]')
    shell_input_txt = (By.XPATH, '//input[@id="input"]')

