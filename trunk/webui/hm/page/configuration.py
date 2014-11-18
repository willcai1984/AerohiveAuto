# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

class ConfigurationPage(WebElement):
    configuration_page_title = 'Guided Configuration'
    configuration_lnk = (By.LINK_TEXT, 'Configuration')
    policy_table = (By.ID, 'dataTable')
    edit_policy_menu = (By.XPATH, '//td[@style="background-color: rgb(255, 194, 14);"]/span[@class="editText" and @title="More"]')
    remove_policy_menu = (By.XPATH, '//td[@style="background-color: rgb(255, 194, 14);"]/../td/div/ul[3]/li')

    #Policies Table
    list_policy_div = (By.ID, 'networkPolicySelectListTable')
    warn_ok_btn = (By.XPATH, '//button[contains(text(), "OK")]')
    select_policy_ok_btn = (By.LINK_TEXT, 'OK')
    new_policy_btn = (By.LINK_TEXT, 'New')
    new_config_name_txt = (By.ID, 'newNetworkPolicyPanelForm_configName')
    
    continue_btn = (By.LINK_TEXT, 'Continue')
    config_devices_div = (By.ID, 'cofigurePolicy')
    hive_select = (By.ID, 'newNetworkPolicyPanelForm_hiveId')
    create_policy_btn = (By.LINK_TEXT, 'Create')
    
    #SSIDs
    add_remove_ssid_lnk = (By.ID, 'btAddRemoveSsid')
    choose_ssid_ok_btn = (By.XPATH, '//a[@class="btCurrent" and @title="OK"]')
    choose_cwp_link = (By.LINK_TEXT, '<CWP>')
    cwp_list_frame = (By.XPATH, '//iframe[contains(@src, "captivePortalWeb")]')
    choose_cwp_ok_btn = (By.XPATH, '//a[@class="current" and @title="OK"]')
    choose_radius_link = (By.LINK_TEXT, '<RADIUS Settings>')
    
    edit_profile_save_btn = (By.XPATH, '//a[@class="btCurrent" and @title="Save"]')
    add_remove_profile_lnk = (By.XPATH, '//a[@title="Add/Remove"]')
    view_registration_user_lnk = (By.ID, 'subTabviewRegistration')
    #Additional Settings
    advanced_setting_btn = (By.XPATH, '//a[@onclick="editMgtAdvancedSetting();"]')
    show_mgt_server_btn = (By.XPATH, '//td[@onclick="showHideServerSettingsDiv(1);"]')
    add_dns_btn = (By.XPATH, '//a[contains(@href, "newMgtDns")]')
    add_time_btn = (By.XPATH, '//a[contains(@href, "newMgtTime")]')
    mgt_dns_select = (By.ID, 'networkPolicyMgtAdvancedSetting_mgtDnsId')
    mgt_time_select = (By.ID, 'networkPolicyMgtAdvancedSetting_mgtTimeId')
    network_policy_save_btn = (By.ID, 'subNetWorkPolicySpanId_save')
    network_save_btn = (By.ID, 'netWorkPolicySaveSpanId')

    #Devices Table
    filter_select = (By.XPATH, '//select[@id="filterSelect"]')
    page_size_select = (By.ID, 'hiveApList_pageSize')
    settings_btn = (By.XPATH, '//a[@class="btCurrent" and @title="Settings"]')
    modify_btn = (By.LINK_TEXT, 'Modify')
    #Device Settings
    complete_upload_radio = (By.ID, 'hiveApUpdate_configSelectTypefull')
    delta_upload_running_radio = (By.ID, 'hiveApUpdate_configSelectTypedeltaRunning')
    delta_upload_last_radio = (By.ID, 'hiveApUpdate_configSelectTypedeltaConfig')
    save_options_btn = (By.LINK_TEXT, 'Save')
    upload_config_btn = (By.XPATH, '//a[@class="btCurrent" and @title="Upload"]')
    #Device Modify
    network_policy_select = (By.ID, 'hiveAp_configTemplate')
    
    confirm_btn = (By.XPATH, '//button[contains(text(), "Yes")]')

    @classmethod
    def edit_profile_link(cls, name):
        return (By.XPATH, '//a[@class="npcLinkA"]/span[@title="%s"]' % name)

    @classmethod
    def locate_user_registration_link(cls, name):
        return (By.XPATH, '//table[@id="userProfilesSelectionTblRegistration"]/tbody/tr/td/span[@title="%s"]' % name)

    @classmethod
    def locate_policy_link(cls, name):
        return (By.XPATH, '//span[@class="word-wrap" and @title="%s"]' % name)

    @classmethod
    def check_policy_selected(cls, name):
        return (By.XPATH, '//td[@style="background-color: rgb(255, 194, 14);"]/span[@class="word-wrap" and @title="%s"]' % name)        

    @classmethod
    def locate_result_by_ip(cls, mgt0_ip):
        return (By.XPATH, '//td[contains(text(), "%s")]/../td[@id="d39"]' % mgt0_ip)

class NavigationPage(WebElement):
    show_nav_link = (By.ID, 'sliderAnchor')
    network_policies_link = (By.LINK_TEXT, 'Network Policies')
    ssids_link = (By.LINK_TEXT, 'SSIDs')
    user_profiles_link = (By.LINK_TEXT, 'User Profiles')
    
    adv_config_link = (By.LINK_TEXT, 'Advanced Configuration')
    common_objects_link = (By.LINK_TEXT, 'Common Objects')
    ip_host_link = (By.LINK_TEXT, 'IP Objects/Host Names')
    vlans_link = (By.LINK_TEXT, 'VLANs')
    
    mgt_services_link = (By.LINK_TEXT, 'Management Services')
    dns_assign_link = (By.LINK_TEXT, 'DNS Assignments')
    ntp_assign_link = (By.LINK_TEXT, 'NTP Assignments')

    authentication_link = (By.LINK_TEXT, 'Authentication')
    aaa_client_settings_link = (By.LINK_TEXT, 'AAA Client Settings')
    aaa_user_dir_link = (By.LINK_TEXT, 'AAA User Directory Settings')
    cwp_link = (By.LINK_TEXT, 'Captive Web Portals')
    device_aaa_server_link = (By.LINK_TEXT, 'Device AAA Server Settings')
    cwp_link = (By.LINK_TEXT, 'Captive Web Portals')
    
class ProfileListPage(WebElement):
    @classmethod
    def created_setting_link(cls, name):
        return (By.LINK_TEXT, '%s' % name)

    @classmethod
    def locate_created_checkbox(cls, name):
        return (By.XPATH, '//a[contains(text(), "%s")]/../../td[@class="listCheck"]/input' % name)

class NetworkPoliciesPage(WebElement):
    remove_btn = (By.XPATH, '//input[@value="Remove"]')          

class SSIDsPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    save_btn = (By.XPATH, '//form/table/tbody/tr[2]/td/table/tbody/tr/td/input')
    remove_btn = (By.XPATH, '//input[@value="Remove"]')
    
    profile_name_input = (By.ID, 'ssidProfilesFull_dataSource_ssidName')
    ssid_name_input = (By.ID, 'ssidProfilesFull_dataSource_ssid')
    enable_cwp_checkbox = (By.ID, 'enableCwpSelect')

class UserProfilesPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    save_btn = (By.XPATH, '//form/table/tbody/tr[2]/td/table/tbody/tr/td/input')
    remove_btn = (By.XPATH, '//input[@value="Remove"]')
    
    profile_name_input = (By.ID, 'userProfileName')
    attribute_input = (By.ID, 'attributeValue')
    network_select = (By.ID, 'userProfiles2Form_networkObjId')
    choose_vlan_select = (By.ID, 'userProfiles2Form_dataSource_typeOfNetwork')
    vlan_select = (By.ID, 'myVlanSelect')

    created_checkbox = (By.XPATH, '//a[starts-with(text(), "2_")]/../../td[@class="listCheck"]/input')

class NetworksPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    save_btn = (By.XPATH, '//form/table/tbody/tr[2]/td/table/tbody/tr/td/input')
    remove_btn = (By.XPATH, '//input[@value="Remove"]')
    
    profile_name_input = (By.ID, 'vpnNetworks_dataSource_networkName')
    vlan_select = (By.ID, 'vlanIdSelect')

#Common Objects
class VLansPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    save_btn = (By.XPATH, '//form/table/tbody/tr[2]/td/table/tbody/tr/td/input')
    remove_btn = (By.XPATH, '//input[@value="Remove"]')
    
    profile_name_input = (By.ID, 'vlan_dataSource_vlanName')
    vlan_id_input = (By.ID, 'vlan_vlanId')
    applay_btn = (By.XPATH, '''//input[@onclick="submitAction('addVlan');"]''')

#Authentication
class AAAClientSettingsPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    save_btn = (By.XPATH, '//input[@name="create"]')    
    remove_btn = (By.XPATH, '//input[@value="Remove"]')
    name_input = (By.ID, 'radiusAssignment_dataSource_radiusName')
    
    ip_input = (By.ID, 'inputIpValue')
    shared_secret_input = (By.ID, 'sharedSecret')
    shared_secret_confirm_input = (By.ID, 'confirm')
    apply_btn = (By.XPATH, '//input[@value="Apply"]')

class CWPSettingsPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    save_btn = (By.XPATH, '''//form[@id='captivePortalWeb']/table/tbody/tr[2]/td/table/tbody/tr/td/input''')    
    remove_btn = (By.XPATH, '//input[@value="Remove"]')
    name_input = (By.ID, 'captivePortalWeb_dataSource_cwpName')
    
    regist_type_select = (By.ID, 'captivePortalWeb_dataSource_registrationType')
    adv_config_link = (By.XPATH, '''//span[@onclick="alternateFoldingContent('advanced');"]''')
    display_timer_checkbox = (By.ID, 'captivePortalWeb_dataSource_enabledPopup')
    dhcp_dns_external_radio = (By.ID, 'captivePortalWeb_dataSource_serverType1')
    override_vlan_checkbox = (By.ID, 'captivePortalWeb_dataSource_overrideVlan')
    vlan_input = (By.ID, 'inputVlanValue')
    dhcp_dns_internal_radio = (By.ID, 'captivePortalWeb_dataSource_serverType2')

class AAAUserDirSettingsPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    remove_btn = (By.XPATH, '//input[@name="remove"]')
    save_btn = (By.XPATH, '//input[@name="create"]')
    name_input = (By.XPATH, '//input[@id="activeDirectoryOrLdap_dataSource_name"]')
    
    select_ap_conbobox = (By.ID, 'apConboBox')
    ap_name_input = (By.ID, 'apServerName')
    ap_gateway_input = (By.ID, 'hiveAPGateway')
    ap_dns_server_input = (By.ID, 'hiveAPDNSServer')
    update_btn = (By.XPATH, '//input[@name="configAp"]')
    
    domain_input = (By.ID, 'defDomFullName')
    AD_server_select = (By.ID, 'myAdSelect')
    AD_server_input = (By.ID, 'inputAdValue')
    Retrieve_btn = (By.XPATH, '//input[@name="retrieve"]')
    Retrieve_message_txt = (By.ID, 'retrieveMessage')

    domain_admin_name_input = (By.ID, 'userNameA')
    domain_admin_passwd_input = (By.ID, 'passwordA')
    domain_admin_passwd_confirm_input = (By.ID, 'confirmPasswordA')
    save_credential_checkbox = (By.ID, 'chkSaveCredentials')
    join_admin_btn = (By.XPATH, '//input[@name="joinSave"]')
    join_message_txt = (By.ID, 'testJoinMessage')

    domain_user_input = (By.ID, 'defDomBind')
    domain_user_passwd_input = (By.ID, 'defDomBindPass')
    domain_user_passwd_confirm_input = (By.ID, 'defDomConfirmBind')
    validate_user_btn = (By.XPATH, '//input[@name="testAuth"]')
    validate_message_txt = (By.ID, 'testAuthMessage')

class DeviceAAAServerSettingsPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    name_input = (By.ID, 'radiusOnHiveAp_dataSource_radiusName')
    
    unfold_database_link = (By.ID, 'databaseAccessShowImg')
    external_db_checkbox = (By.ID, 'radiusOnHiveAp_externalDb')
    ad_select = (By.ID, 'radiusOnHiveAp_activeDir')
    apply_server_btn = (By.XPATH, '//input[@value="Apply"]')
    
    server_attr_map_checkbox = (By.ID, 'radiusOnHiveAp_dataSource_mapEnable')
    root_group_node = (By.ID, 'ygtvlabelel1')
    user_group_node = (By.ID, 'ygtvlabelel11')
    admin_user_node = (By.ID, 'ygtvlabelel12')
    apply_map_btn = (By.ID, 'addRoleBtn')
    role_map_table = (By.ID, 'roleMapDirTable')

class DNSAssignPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    save_btn = (By.XPATH, '//form/table/tbody/tr[2]/td/table/tbody/tr/td/input')
    remove_btn = (By.XPATH, '//input[@value="Remove"]')    
    name_input = (By.ID, 'mgmtName')
    
    apply_btn = (By.XPATH, '//input[@value="Apply"]')
    ip_input = (By.ID, 'inputIpValue')

class NTPAssignPage(WebElement):
    new_btn = (By.XPATH, '//input[@value="New"]')
    save_btn = (By.XPATH, '//form/table/tbody/tr[2]/td/table/tbody/tr/td/input')
    remove_btn = (By.XPATH, '//input[@value="Remove"]')
    name_input = (By.ID, 'mgmtName')
    clock_radio = (By.ID, 'enableClock')
    
    apply_btn = (By.XPATH, '//input[@value="Apply"]')
    ip_input = (By.ID, 'inputIpValue')

class ConfigSSIDExpressPage(WebElement):
    config_ssid_link = (By.ID, 'ssidSection')
    config_ssid_frame = (By.ID, 'ssidIframe')
    ap_as_ad_setup_radio = (By.ID, 'newRadiusType2')
    
    primary_radius_server_input = (By.ID, 'primaryHiveApRadius')
    ap_ip_input = (By.ID, 'hiveAPIpAddress')
    ap_netmask_input = (By.ID, 'hiveAPNetmask')
    ap_gateway_input = (By.ID, 'hiveAPGateway')
    ap_dns_server_input = (By.ID, 'hiveAPDNSServer')
    update_btn = (By.XPATH, '//input[@value="Update"]')
    
    ad_integration_radio = (By.ID, 'ADIntegration')
    domain_input = (By.ID, 'domainFullName')
    Retrieve_btn = (By.XPATH, '//input[@name="retrieve"]')
    Retrieve_message_txt = (By.ID, 'retrieveMessage')
    
    domain_admin_name_input = (By.ID, 'domainAdmin')
    domain_admin_passwd_input = (By.ID, 'domainAdminPasswd')
    join_admin_btn = (By.XPATH, '//input[@name="jointDomain"]')
    join_message_txt = (By.ID, 'joinDNMessage')
    
    domain_user_input = (By.ID, 'domainTestUser')
    domain_user_passwd_input = (By.ID, 'domainTestUserPasswd')
    validate_user_btn = (By.XPATH, '//input[@name="testAuth"]')
    validate_message_txt = (By.ID, 'testAuthMessage')    