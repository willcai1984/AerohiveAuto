# -*- coding: UTF-8 -*-
from webui import safe_call, WebUI
from webui.cloud.Configuration import Configuration
from webui.cloud.page import *
import random
import time


@safe_call


def sw_device_overview_check():
    wui = WebUI()
    config = Configuration(wui.d("visit.url"), wui.d("visit.title"), wui.d("visit.pre_url"))
    if wui.session_id:
        config.to_url_home()
        config.to_menu(wui.d("policy.menu_name"))
        config.wait_until_to_menu_success(wui.d("policy.menu_name"))
        
        #go to monitor page to check the sw monitor information        
        wui.click(monitor_cfg.Device_list_button)
        wui.info('go to device list page success', True)
        
        device_entry_mac_element = monitor_cfg.get('Device_list_mac_xpath')
        device_entry_checkbox_element = monitor_cfg.get('Device_list_checkbox_xpath')
        device_entry_stat_element =  monitor_cfg.get('Device_list_stat_xpath')
        device_entry_ip_element = monitor_cfg.get('Device_list_ip_xpath')
        device_entry_hostname_element = monitor_cfg.get('Device_list_hostname_xpath')
        device_entry_sn_element = monitor_cfg.get('Device_list_sn_xpath')
        device_entry_ptype_element = monitor_cfg.get('Device_list_ptype_xpath')
        
        device_list_next_page = monitor_cfg.get('Device_list_next_page_xpath')
        device_list_next_page_disable = monitor_cfg.get('Device_list_next_page_disable_xpath')
         
        sw_mac = wui.d("dev_mgt0_mac")     
        
        is_page_exist=False
        page_num=1
        while not is_page_exist: 
            i=1
            find_mac_flag=0;
            while 1:
                new_device_entry_mac_element = (device_entry_mac_element[0], device_entry_mac_element[1] % i)
                new_device_entry_checkbox_element = (device_entry_checkbox_element[0], device_entry_checkbox_element[1] % i)
                new_device_entry_stat_element = (device_entry_stat_element[0], device_entry_stat_element[1] % i)
                new_device_entry_ip_element = (device_entry_ip_element[0], device_entry_ip_element[1] % i)
                new_device_entry_hostname_element = (device_entry_hostname_element[0], device_entry_hostname_element[1] % i)
                new_device_entry_sn_element = (device_entry_sn_element[0], device_entry_sn_element[1] % i)
                new_device_entry_ptype_element = (device_entry_ptype_element[0], device_entry_ptype_element[1] % i)
                
                try:
                    wui.wait_until_element_displayed(new_device_entry_mac_element)
                    if sw_mac == wui.find_element(new_device_entry_mac_element).text:
                        find_mac_flag=1
                        try:
                            wui.wait_until_element_displayed(new_device_entry_stat_element)
                        except Exception, e:
                            wui.error('this device status is false disconnect', True)
                            break
                        wui.click(new_device_entry_checkbox_element)
                        wui.info('selected the checkbox success', True)
                        is_page_exist=True
                        device_hostname_element = wui.find_element(new_device_entry_hostname_element).text
                        device_connection_status_str = "Connected"
                        wui.click(new_device_entry_hostname_element)
                        time.sleep(5)
                        wui.info('go to device overview monitoring page success', True)
                        
                        break
                except Exception, e:
                    wui.error('device is not found',True)
                    break
                i+=1
            if find_mac_flag == 0:
                try:
                    wui.wait_until_element_displayed(device_list_next_page)
                    wui.click(device_list_next_page)
                    wui.info('go to next page to find devices', True)
                    page_num+=1
                    continue
                except Exception, e:
                    wui.wait_until_element_displayed(device_list_next_page_disable)
                    wui.error('this is the last page and the device is not found',True)
                    break
            
        #check hostname on device overview GUI   
        device_hostname_xpath = monitor_device_overview.get('Device_overview_name')
        wui.wait_until_element_displayed(device_hostname_xpath)
        device_hostname_str = wui.find_element(device_hostname_xpath).text
        if device_hostname_str == device_hostname_element:
            wui.info('the device hostname display is correct and consistent with actual', True)
        else:
            wui.error('the device hostname display in monitoring page is incorrect', True)
        
        #check device connection status
        connection_status_element = monitor_device_overview.get('Device_connect_status')
        new_connection_status_element = wui.find_element(connection_status_element).text
        if device_connection_status_str == new_connection_status_element:
            wui.info('The device status on device overview page is Connected, It is Correct', True)
        else:
            wui.error('The device connection status on device overview page is different with actual, Please Check it and Try it agin', True)
        
        #check network details section on device overview GUI
        # check network policy
        policyname = wui.d("sw_policy_name")
        tmp_policy_name_element = monitor_device_overview.get("Device_netdetail_netpolicy_name")
        new_policy_name_element = wui.find_element(tmp_policy_name_element).text
        if policyname == new_policy_name_element:
            wui.info('The network policy name display on overview page is correct!', True)
        else:
            wui.error('The network policy name display on overview page is incorrect!', True)
        
        # check device template
        templatename = wui.d("sw_template_name")
        tmp_template_name_element = monitor_device_overview.get("Device_netdetail_template_name")
        new_template_name_element = wui.find_element(tmp_template_name_element).text
        if templatename == new_template_name_element:
            wui.info('The device template display is correct!', True)
        else:
            wui.error('The device template name is incorrect! ', True)
            
        # check device model
        productname = wui.d("sw_product_name")
        tmp_product_name_element = monitor_device_overview.get("Device_netdetail_model_name")
        new_product_name_element = wui.find_element(tmp_product_name_element).text
        if productname == new_product_name_element:
            wui.info('The product type name is correct!', True)
        else:
            wui.error('The product name is incorrect!', True)
        
        # check device Function
        devicefunc = wui.d("sw_function_name")
        tmp_device_func_element = monitor_device_overview.get("Device_netdetail_function_name")
        new_device_func_element = wui.find_element(tmp_device_func_element).text
        if devicefunc == new_device_func_element:
            wui.info('The device function is correct!', True)
        else:
            wui.error('The device function is wrong!', True)
        # check serial number
        devicesn = wui.d("sw_sn_name")
        tmp_device_sn_element = monitor_device_overview.get("Device_netdetail_sn_name")
        new_device_sn_element = wui.find_element(tmp_device_sn_element).text
        if devicesn == new_device_sn_element:
            wui.info('The device serial number is correct!', True)
        else:
            wui.error('The device serial number is wrong!', True)
        
        # check hiveos version
        device_version = wui.d("sw_hos_ver")
        tmp_device_os_element = monitor_device_overview.get("Device_netdetail_os")
        new_device_os_element = wui.find_element(tmp_device_os_element).text
        if device_version == new_device_os_element:
            wui.info('The device os version is correct!', True)
        else:
            wui.info('The device os version is correct!', True)
        
        # check Device status
        
        # check configuration type
        
        # check mgt0 ip address
        device_ip = wui.d("sw_mgmt_ip")
        tmp_device_ip_element = monitor_device_overview.get("Device_netdetail_mgt_ip")
        new_device_ip_element = wui.find_element(tmp_device_ip_element).text
        if device_ip == new_device_ip_element:
            wui.info('The device ip address is correct!', True)
        else:
            wui.info('The device ip address is correct!', True)
        
        # check subnet mask
        device_netmask = wui.d("sw_netmask")
        tmp_device_mask_element = monitor_device_overview.get("Device_netdetail_subnet_mask")
        new_device_mask_element = wui.find_element(tmp_device_mask_element).text
        if device_netmask == new_device_mask_element:
            wui.info('The device netmask is correct!', True)
        else:
            wui.info('The device netmask is correct!', True)
            
        # check default gateway
        device_gateway = wui.d("sw_gateway")
        tmp_device_gw_element = monitor_device_overview.get("Device_netdetail_gw")
        new_device_gw_element = wui.find_element(tmp_device_gw_element).text
        if device_gateway == new_device_gw_element:
            wui.info('The device gateway is correct!', True)
        else:
            wui.info('The device gateway is correct!', True)
            
        # check mgmt mac address
        tmp_device_mac_element = monitor_device_overview.get("Device_netdetail_mgmt_mac")
        new_device_mac_element = wui.find_element(tmp_device_mac_element).text
        if sw_mac == new_device_mac_element:
            wui.info('The device mgt0 mac is correct!', True)
        else:
            wui.info('The device mgt0 mac is correct!', True)
            
        # check DNS
        
        # check NTP
               
if __name__ == '__main__':
    sw_device_overview_check()
