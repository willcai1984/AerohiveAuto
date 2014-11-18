# -*- coding: UTF-8 -*-

from selenium.webdriver.common.by import By
from webui import WebElement

# TODO:
# - OO

class VHMRecord(WebElement):
    select_chk = (By.XPATH, './/input')
    
    def __init__(self, hm, mgt_form, record):
        self.hm = hm
        self.mgt_form = mgt_form
        self.record = record

        WebElement.__init__(self, record)
    
    @property    
    def chk(self):
        return self.child(VHMRecord.get('select_chk'))
    
    @classmethod
    def locate_vhm_by_name(cls, name):
        return (By.XPATH, '//div[@id="content"]//a[starts-with(text(), "%s")]/../..' % name)
        
class NewVHMForm(WebElement):
    new_vhm_lbl = (By.XPATH, '//div[@id="content"]//td[./a[text()="VHM Management"] and contains(text(), "New")]')

    save_vhm_btn = (By.XPATH, '//div[@id="content"]//input[@value="Save" and contains(@onclick, "create")]')

    vhm_name_txt = (By.XPATH, '//div[@id="content"]//input[@id="vhmName"]')
    max_ap_txt = (By.XPATH, '//div[@id="content"]//input[@id="vhmMaxAP"]')
    admin_mail_addr_txt = (By.XPATH, '//div[@id="content"]//input[@id="userEmailAddr"]')
    admin_name_txt = (By.XPATH, '//div[@id="content"]//input[@id="userName"]')
    admin_passwd_txt = (By.XPATH, '//div[@id="content"]//input[@id="adminPassword"]')
    admin_passwd_confirm_txt = (By.XPATH, '//div[@id="content"]//input[@id="passwordConfirm"]')

class VHMManagementForm(WebElement):
    vhm_mgt_form = (By.XPATH, '//div[@id="content"]')
    
    new_vhm_btn = (By.XPATH, '//div[@id="content"]//input[@value="New"]')
    remove_vhm_btn = (By.XPATH, '//div[@id="content"]//input[@value="Remove"]')

    def __init__(self, hm):
        self.hm = hm
        
        self.w = self.hm.w
        self.mgt_form = self.w.find_element(VHMManagementForm.get('vhm_mgt_form'))
        
        WebElement.__init__(self, self.mgt_form)

    def add_vhm(self, vhm_name, max_ap, admin_mail_addr, admin_name, admin_passwd):
        self.w.click(VHMManagementForm.get('new_vhm_btn'))
        self.w.wait_until_element_displayed(NewVHMForm.get('new_vhm_lbl'))
    
        self.w.input(NewVHMForm.get('vhm_name_txt'), vhm_name)
        self.w.input(NewVHMForm.get('max_ap_txt'), max_ap)
        self.w.input(NewVHMForm.get('admin_mail_addr_txt'), admin_mail_addr)
        self.w.input(NewVHMForm.get('admin_name_txt'), admin_name)
        self.w.input(NewVHMForm.get('admin_passwd_txt'), admin_passwd)
        self.w.input(NewVHMForm.get('admin_passwd_confirm_txt'), admin_passwd)

        self.w.info('create vhm %s' % vhm_name, True)
        self.w.click(NewVHMForm.get('save_vhm_btn'))
        self.w.wait_until_element_displayed(VHMRecord.locate_vhm_by_name(vhm_name))
    
    def remove_vhm(self, name):
        vhm = self.get_vhm(name)
        self.w.check_element(vhm.chk)
        
        self.w.info('remove vhm %s' % name, True)
        self.w.click(VHMManagementForm.get('remove_vhm_btn'))
        self.hm.confirm()
        self.w.wait_until_element_present(VHMRecord.locate_vhm_by_name(name), False)
    
    def has_vhm(self, name):
        return self.w.is_element_present(VHMRecord.locate_vhm_by_name(name))
    
    def get_vhm(self, name):
        return VHMRecord(self.hm, self.mgt_form, self.w.find_element(VHMRecord.locate_vhm_by_name(name)))
