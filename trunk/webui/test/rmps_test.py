
from webui import safe_call, WebUI
from webui.test.rmps import LoginPage, OutletPage

@safe_call
def rmps_login_logout1():
    wui = WebUI()

    print wui.remote_selenium
    print wui.d("visit.url")
    print wui.d("login.username")
    print wui.d("login.password")
    
    wui.get(wui.d("visit.url")+"/")
    wui.wait_until_title_present(LoginPage.login_page_title)
    wui.info('test1', True)

    wui.wait_until_element_displayed(LoginPage.username_txt)
    wui.click(LoginPage.username_txt)
    wui.input(LoginPage.username_txt, 'admin')

    wui.wait_until_element_displayed(LoginPage.password_txt)
    wui.click(LoginPage.password_txt)
    wui.input(LoginPage.password_txt, 'aerohive')
    
    wui.info('test2', True)

    wui.wait_until_element_displayed(LoginPage.submit_btn)
    wui.click(LoginPage.submit_btn)

    wui.wait_until_element_displayed(OutletPage.autoping_linktxt)
    wui.info('test3', True)

    wui.click(OutletPage.autoping_linktxt)
    
    wui.wait_until_element_displayed(OutletPage.logout_linktxt)
    wui.info('test4', True)
    wui.click(OutletPage.logout_linktxt)

if __name__ == '__main__':
    rmps_login_logout1()
    
