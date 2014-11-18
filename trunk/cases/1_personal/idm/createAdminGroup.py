'''
Created on 2013-7-10

@author: ftan
'''

import time
from selenium import webdriver
# def createAdminGroup(groupname,description,privileges,browser):    
#     time.sleep(2)
#     currentTitle=browser.title
#     browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
#     time.sleep(2)
#     browser.find_element_by_xpath("//form[@id='userGrpList']/div/ul/li/a").click()
# #     currentUrl=browser.url
#     time.sleep(2)
#     browser.find_element_by_xpath("//*[@id='groupName']").send_keys(groupname)
#     browser.find_element_by_xpath("//*[@id='description']").send_keys(description)
#     for userPrivilege in privileges:
#         browser.find_element_by_xpath("//input[@name='"+userPrivilege+"']").click()
#     
# #     browser.find_element_by_xpath("//input[@name='monitor_write']").click()
#     browser.find_element_by_xpath("//*[@id='J-create']").click()
#     time.sleep(2)
class createAdminGroup:
    privileges=["monitor_read","logs_read","auditlog_read","smslog_read","config_read","config_write","groups_read","groups_write"
            ,"user_read","user_write","usergroup_read","usergroup_write","notificationProfile_read","notificationProfile_write"
            ,"certificateList_read","certificateList_write","emailSetting_read","emailSetting_write","customerList_read"
            ,"customerList_write","claimDomainMgr_read","claimDomainMgr_write","notificationTemplate_read"
            ,"notificationTemplate_write"]
    description=None
    groupName=None
    browser=None
    log=None
    def createAdminGroup(self):    
#         time.sleep(2)
#         currentTitle=self.browser.title
        self.log.write("click 'admin group'")
        self.browser.find_element_by_xpath("//div[@id='wrapper']/div[2]/div[2]/div[2]/div/div/ul/li[2]/a").click()
        time.sleep(2)
        self.log.write("new a admin group")
        self.browser.find_element_by_xpath("//form[@id='userGrpList']/div/ul/li/a").click()
#     currentUrl=browser.url
        time.sleep(2)
        self.log.write("the group name :"+self.groupName)
        self.browser.find_element_by_xpath("//*[@id='groupName']").send_keys(self.groupName)
        self.log.write("the group description :"+self.description)
        self.browser.find_element_by_xpath("//*[@id='description']").send_keys(self.description)
        self.log.write("the privileges selected:")
        for userPrivilege in self.privileges:
            self.log.write(userPrivilege,)
            self.browser.find_element_by_xpath("//input[@name='"+userPrivilege+"']").click()
    
#     browser.find_element_by_xpath("//input[@name='monitor_write']").click()
        self.log.write("click 'create'")
        self.browser.find_element_by_xpath("//*[@id='J-create']").click()
        time.sleep(2)
    def __init__( self ,groupName,description,privileges,browser,log):
        self.groupName=groupName
        self.privileges=privileges
        self.description=description
        self.browser=browser
        self.log=log
        
        