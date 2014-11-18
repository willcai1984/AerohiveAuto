
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.webdriver.common.by import By

class WebUIDriver(WebDriver):
    def __init__(self, command_executor='http://127.0.0.1:4444/wd/hub', desired_capabilities=None, browser_profile=None, session_id=None):
        self.preserved_session_id = session_id
        WebDriver.__init__(self, command_executor, desired_capabilities, browser_profile)

    def start_session(self, desired_capabilities, browser_profile=None):
        if self.preserved_session_id:
            self.command_executor._commands['getSession'] = ('GET', '/session/$sessionId')
            self.session_id = self.preserved_session_id
            response = self.execute('getSession', {'sessionId ': self.session_id})
            self.session_id = response['sessionId']
            self.capabilities = response['value']
        else:
            WebDriver.start_session(self, desired_capabilities, browser_profile)

def login_logout1():
    remote_selenium = 'http://10.155.30.38:4444/wd/hub'
    driver = WebUIDriver(remote_selenium, DesiredCapabilities.INTERNETEXPLORER, FirefoxProfile(None))
    driver.implicitly_wait(90)

    base_url = '10.155.34.225'
    driver.get(base_url + "/")
    driver.find_element_by_id("userName").click()
    driver.find_element_by_id("userName").clear()
    driver.find_element_by_id("userName").send_keys("admin")
    driver.find_element_by_id("authenticateFormID_password").clear()
    driver.find_element_by_id("authenticateFormID_password").send_keys("aerohive")
    driver.find_element_by_css_selector("img.dinl").click()
    # ERROR: Caught exception [ERROR: Unsupported command [selectWindow]]
    driver.find_element_by_css_selector("a.top_right_menu").click()
    driver.find_element_by_link_text("Log Out").click()

def login_logout2():
    remote_selenium = 'http://10.155.30.38:4444/wd/hub'
    driver = WebUIDriver(remote_selenium, DesiredCapabilities.INTERNETEXPLORER, FirefoxProfile(None))
    driver.implicitly_wait(90)

    base_url = '10.155.34.225'
    driver.get(base_url + "/")

    element1 = driver.find_element(By.ID, 'userName')
    element1.click();
    element1.clear();
    element1.send_keys('admin')
    
    element2 = driver.find_element(By.ID, 'authenticateFormID_password')
    element2.click();
    element2.clear();
    element2.send_keys('aerohive')
   
    element3 = driver.find_element(By.CSS_SELECTOR, 'img.dinl')
    element3.click();
    
    element4 = driver.find_element(By.CSS_SELECTOR, 'a.top_right_menu')
    element4.click();

    element5 = driver.find_element(By.LINK_TEXT, 'Log Out')
    element5.click();

def login1():
    remote_selenium = 'http://10.155.30.38:4444/wd/hub'
    driver = WebUIDriver(remote_selenium, DesiredCapabilities.INTERNETEXPLORER, FirefoxProfile(None))
    driver.implicitly_wait(90)

    base_url = '10.155.34.225'
    driver.get(base_url + "/")
    driver.find_element_by_id("userName").click()
    driver.find_element_by_id("userName").clear()
    driver.find_element_by_id("userName").send_keys("admin")
    driver.find_element_by_id("authenticateFormID_password").clear()
    driver.find_element_by_id("authenticateFormID_password").send_keys("aerohive")
    driver.find_element_by_css_selector("img.dinl").click()

    print driver.preserved_session_id

def test_create_user(session_id):
    remote_selenium = 'http://10.155.30.38:4444/wd/hub'
    driver = WebUIDriver(remote_selenium, DesiredCapabilities.INTERNETEXPLORER, FirefoxProfile(None), session_id)
    driver.implicitly_wait(90)

    base_url = '10.155.34.225'
    driver.get(base_url + "/")

    driver.find_element_by_link_text("Home").click()
    driver.find_element_by_id("a3").click()
    driver.find_element_by_id("a14").click()
    driver.find_element_by_xpath("(//a[contains(text(),'Administrators')])[2]").click()
    driver.find_element_by_name("new").click()
    driver.find_element_by_id("email").clear()
    driver.find_element_by_id("email").send_keys("jyu_test5@aerohive.com")
    driver.find_element_by_id("adminUserName").clear()
    driver.find_element_by_id("adminUserName").send_keys("jyu_test5")
    driver.find_element_by_id("adminPassword").clear()
    driver.find_element_by_id("adminPassword").send_keys("aerohive")
    driver.find_element_by_id("passwordConfirm").clear()
    driver.find_element_by_id("passwordConfirm").send_keys("aerohive")
    #driver.find_element_by_css_selector("td.buttons > table > tbody > tr > td > input[name='ignore']").click()
    driver.find_element_by_xpath("(//input[@value='Save' and contains(@onclick,'create')])").click()
    print driver.preserved_session_id

def test_create_user_ex(session_id):
    remote_selenium = 'http://10.155.30.38:4444/wd/hub'
    driver = WebUIDriver(remote_selenium, DesiredCapabilities.INTERNETEXPLORER, FirefoxProfile(None), session_id)
    driver.implicitly_wait(90)

    base_url = '10.155.34.225'
    driver.get(base_url + "/")

    home_link = driver.find_element(By.LINK_TEXT, "Home");
    home_link.click()

    admin_link = driver.find_element(By.ID, "a3")
    admin_link.click()

    admin2_link = driver.find_element(By.ID, "a14")
    admin2_link.click()

    admin3_link = driver.find_element(By.XPATH, "(//a[contains(text(),'Administrators')])[2]")
    admin3_link.click()

    driver.find_element_by_name("new").click()
    driver.find_element_by_id("email").clear()
    driver.find_element_by_id("email").send_keys("jyu_test5@aerohive.com")
    driver.find_element_by_id("adminUserName").clear()
    driver.find_element_by_id("adminUserName").send_keys("jyu_test5")
    driver.find_element_by_id("adminPassword").clear()
    driver.find_element_by_id("adminPassword").send_keys("aerohive")
    driver.find_element_by_id("passwordConfirm").clear()
    driver.find_element_by_id("passwordConfirm").send_keys("aerohive")
    #driver.find_element_by_css_selector("td.buttons > table > tbody > tr > td > input[name='ignore']").click()
    driver.find_element_by_xpath("(//input[@value='Save' and contains(@onclick,'create')])").click()
    print driver.preserved_session_id

def test_remove_user(session_id):
    remote_selenium = 'http://10.155.30.38:4444/wd/hub'
    driver = WebUIDriver(remote_selenium, DesiredCapabilities.INTERNETEXPLORER, FirefoxProfile(None), session_id)
    driver.implicitly_wait(90)

    base_url = '10.155.34.225'
    driver.get(base_url + "/")

    driver.find_element_by_link_text("Home").click()
    driver.find_element_by_id("a3").click()
    driver.find_element_by_id("a14").click()
    driver.find_element_by_xpath("(//a[contains(text(),'Administrators')])[2]").click()
    test_user = 'jyu_test5'
    driver.find_element_by_xpath("(//td[contains(text(), '%s')]/../td[@class='listCheck']/input)" % test_user).click()
    driver.find_element_by_name("remove").click()
    driver.find_element_by_id("yui-gen6-button").click()

def test_remove_user_ex(session_id):
    remote_selenium = 'http://10.155.30.38:4444/wd/hub'
    driver = WebUIDriver(remote_selenium, DesiredCapabilities.INTERNETEXPLORER, FirefoxProfile(None), session_id)
    driver.implicitly_wait(90)

    base_url = '10.155.34.225'
    driver.get(base_url + "/")

    home_link = driver.find_element(By.LINK_TEXT, "Home");
    home_link.click()

    admin_link = driver.find_element(By.ID, "a3")
    admin_link.click()

    admin2_link = driver.find_element(By.ID, "a14")
    admin2_link.click()

    admin3_link = driver.find_element(By.XPATH, "(//a[contains(text(),'Administrators')])[2]")
    admin3_link.click()

    test_user = 'jyu_test5'
    e1 = driver.find_element(By.XPATH, "(//td[contains(text(), '%s')]/../td[@class='listCheck']/input)" % test_user)
    e1.click()

    e2 = driver.find_element(By.NAME, "remove")
    e2.click()

    e3 = driver.find_element(By.ID, "yui-gen6-button")
    e3.click()

if __name__ == '__main__':
    #login1()
    
    #test_create_user_ex(1339499045550)
    test_remove_user_ex(1339499045550)
    
