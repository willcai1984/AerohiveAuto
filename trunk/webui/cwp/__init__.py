# -*- coding: UTF-8 -*-

from webui import WebUI
from webui import WebUIException
from webui.cwp.page import *

class CWP(object):
    # TODO:
    # - based on reply from qa team, the access url should be full qualified 
    # name or ip address base on auth conf. since the web server might not be 
    # resolved in testing environment or against certain conf which may cause 
    # problem when verifying traffic pass-through successfully or not. pre_url 
    # is temporary solution which is used to trigger the auth process. for 
    # example, pre_url in full qualified name to trigger auth process while 
    # url in ip address to verify traffic. 
    def __init__(self, url, title, pre_url=None):
        self.url = url
        self.title = title
        self.pre_url = pre_url if pre_url else url
        
        self.w = WebUI()
        self.mode = None  # login register
        self.popup = None
        
    def login_mode(self):
        self.mode = 'login'
    
    def register_mode(self):
        self.mode = 'register'
    
    def is_login_mode(self):
        return self.mode == 'login'
    
    def is_register_mode(self):
        return self.mode == 'register'

    def to_url_before_login(self, location='CWP_default_login_page'):
        self.w.info('trying to access %s before login' % self.pre_url)
        
        if location == 'CWP_custom_loginpage_amigopod':
            self.try_again_get(self.pre_url, LoginPageAmigopod.get('login_page_title'))            
        elif location == 'amigopod_management_login':
            self.try_again_get(self.pre_url, AmigopodLoginPage.get('login_page_title'))            
        elif location == 'npd_login':
            self.try_again_get(self.pre_url, LoginPageNPD.get('login_page_title'))
        elif location == 'hm_login':
            self.try_again_get(self.pre_url, AmigopodLoginPage.get('login_page_title'))
        elif location == 'login_company':
            self.try_again_get(self.pre_url, CompanyPage.get('company_page_title'))            
        elif location == 'CWP_default_login_page':
            self.try_again_get(self.pre_url, LoginPage.get('login_page_title'))

    def try_again_get(self, url, title, times=5):
        for i in range(times):
            try:
                self.w.get(url)
                self.w.wait_until_title_present(title)
                self.w.info('successful get page with title: %s after access url: %s' % (title, url), True)
                break
            except Exception, e:
                if i == times - 1:
                    raise
                self.w.warn('fail to get page with title: %s after access url: %s, will try again' % (title, url), True)
        
    def register(self, first_name, last_name, email, phone, visiting, reason):
        self.register_mode()

        self.w.wait_until_element_displayed(LoginPage.get('register_btn'))

        self.w.input(LoginPage.get('first_name_txt'), first_name)
        self.w.input(LoginPage.get('last_name_txt'), last_name)
        self.w.input(LoginPage.get('email_txt'), email)
        self.w.input(LoginPage.get('phone_txt'), phone)
        self.w.input(LoginPage.get('visiting_txt'), visiting)
        self.w.input(LoginPage.get('reason_txt'), reason)
    
        self.w.info('handle register form', True)
        self.w.click(LoginPage.get('register_btn'))

    def register123(self, first_name, last_name, email, visiting):
        self.register_mode()

        self.w.wait_until_element_displayed(LoginPageRegistration123.get('register_btn'))

        self.w.input(LoginPageRegistration123.get('first_name_txt'), first_name)
        self.w.input(LoginPageRegistration123.get('last_name_txt'), last_name)
        self.w.input(LoginPageRegistration123.get('email_txt'), email)
        self.w.input(LoginPageRegistration123.get('visiting_txt'), visiting)
    
        self.w.info('handle register form', True)
        self.w.click(LoginPageRegistration123.get('register_btn'))

    def login(self, username, password):
        self.login_mode()
        
        self.w.wait_until_element_displayed(LoginPage.get('login_btn'))
        
        self.w.input(LoginPage.get('username_txt'), username)
        self.w.input(LoginPage.get('password_txt'), password)
        
        self.w.info('handle login form', True)
        self.w.click(LoginPage.get('login_btn'))

    def login_amigopod(self, username, password):
        self.login_mode()
        
        self.w.wait_until_element_displayed(LoginPageAmigopod.get('login_btn'))
        self.w.input(LoginPageAmigopod.get('username_txt'), username)
        self.w.input(LoginPageAmigopod.get('password_txt'), password)
        
        self.w.info('handle login form', True)
        self.w.click(LoginPageAmigopod.get('login_btn'))

    def login_npd(self, username, password):
        self.login_mode()

        self.w.wait_until_element_displayed(LoginPageNPD.get('login_btn'))
        self.w.wait_until_element_displayed(LoginPageNPD.get('logo_img'))
        self.w.input(LoginPageNPD.get('username_txt'), username)
        self.w.input(LoginPageNPD.get('password_txt'), password)
        
        self.w.info('handle login form', True)
        self.w.click(LoginPageNPD.get('login_btn'))
    
    def login_company(self):
        self.w.click(CompanyPage.get('aerohive_img'))
        self.w.wait_for_page_to_load()
        self.w.info('after click logo aerohive.com', True)
    
    def wait_until_login_success(self, popup='true', success_page='true'):
        if success_page == 'false':
            pass
        else:
            try:
                self.w.wait_until_title_present(LoginSuccessfulPage.get('login_successful_page_title'), info=True)
            except Exception, e:
                self.w.s.execute_script('return window.onbeforeunload=null')
                self.w.warn('Fail to get login_successful_page after login, will try again', True)
                self.w.s.refresh()
                self.w.wait_until_title_present(LoginSuccessfulPage.get('login_successful_page_title'), info=True)

        if popup == 'true':
            def __tmp(w):
                handles = w.window_handles
                for handle in handles:
                    w.switch_to_window(handle)
                    try:
                        if w.title.startswith(LoginSuccessfulPopupPage.get('login_successful_popup_page_title')):
                            return handle
                    except Exception, e:
                        try:
                            w.s.execute_script('return window.onbeforeunload=null')
                            w.warn('Fail to get Network Access Timer page after login, will try again', True)
                            w.s.refresh()
                            if w.title.startswith(LoginSuccessfulPopupPage.get('login_successful_popup_page_title')):
                                return handle                            
                        except Exception, e:
                            pass                        
                return None
            self.popup = self.w.wait_until(__tmp, msg='popup window', time_out=600)
            
            self.w.info('left %s' % self.w.find_element(LoginSuccessfulPopupPage.get('left_div')).text, True)
            self.w.s.execute_script('return window.onbeforeunload=null')
            try:
                self.w.switch_to_alert().accept()
                return
            except:
                pass  
        else:
            try:
                self.w.info('left %s' % self.w.find_element(LoginSuccessfulPopupPage.get('left_div')).text, True)
            except Exception, e:
                import urlparse
                self.web_server = urlparse.urlparse(self.w.s.current_url).netloc
                for i in range(4):
                    try:
                        self.w.s.execute_script('return window.onbeforeunload=null')
                        self.w.get(urlparse.urlunparse(('http', self.web_server, 'reg.php', '', 'ah_popup=true', '')))
                        self.w.info('left %s' % self.w.find_element(LoginSuccessfulPopupPage.get('left_div')).text, True)
                        break
                    except Exception, e:
                        if i == 3:
                            raise
                        self.w.warn('Fail to get Network Access Timer page after login, will try again', True)


    def wait_until_login_fail(self, failed_page='default', redirect_page_name='none'):
        if failed_page == 'failed_page2':
            self.w.wait_until_title_present(LoginFailedPage.get('login_failed_page_title2'), info=True)
        elif failed_page == 'default':
            self.w.wait_until_title_present(LoginFailedPage.get('login_failed_page_title'), info=True)
        elif failed_page == 'npd':
            self.w.wait_until_element_displayed(LoginFailedNPDPage.get('login_failed_txt'))
            self.w.info('failed reason', True)            
        elif failed_page == 'false':
            self.w.wait_until_element_displayed(LoginFailedNPDPage.get('login_failed_txt'))
            self.w.info('failed reason', True)            

        if redirect_page_name == 'amigopod':
            self.w.wait_until_title_present(LoginPageAmigopod.get('login_page_title'), info=True)
            self.w.wait_until_element_displayed(LoginPageAmigopod.get('login_btn'))
        elif redirect_page_name == 'default':
            self.w.wait_until_title_present(LoginPage.get('login_page_title'), info=True)
            self.w.wait_until_element_displayed(LoginPage.get('login_btn'))   
        elif redirect_page_name == 'npd':
            self.w.wait_until_title_present(LoginPageNPD.get('login_page_title'), info=True)
            self.w.wait_until_element_displayed(LoginPageNPD.get('login_btn'))                  
        elif redirect_page_name == 'registration123':
            self.w.wait_until_title_present(LoginPageRegistration123.get('login_page_title'), info=True)
            self.w.wait_until_element_displayed(LoginPageRegistration123.get('register_btn'))
        elif redirect_page_name == 'none':
            return

    def to_url(self):
        self.w.info('trying to access %s' % self.url)
        self.try_again_get(self.url, self.title)

    def to_url_after_login(self, redirect='manual'):
        if redirect == 'manual':
            self.w.info('trying to access %s after login' % self.url)
            self.switch_to_window(LoginSuccessfulPage.get('login_successful_page_title'))
            self.try_again_get(self.url, self.title)

        if redirect == 'true':
            self.w.info('trying to verify %s auto redirected' % self.url)
            self.switch_to_window(self.title)
            self.w.info('after access to %s' % self.url, True)

        if redirect == 'amigopod':
            self.w.info('trying to verify auto redirect to amigopod login page')
            self.switch_to_window('amigopod :: Login')
            self.try_again_get(self.url, self.title)

    def switch_to_popup(self):
        handles = self.w.window_handles
        for handle in handles:
            self.w.switch_to_window(handle)
            if self.w.title.startswith(LoginSuccessfulPopupPage.get('login_successful_popup_page_title')):
                self.w.info('Switch to window:Network Access Timer', True)
                return
        raise WebUIException('Cannot find window with title %s' % LoginSuccessfulPopupPage.get('login_successful_popup_page_title'))
    
    def switch_to_window(self, name):
        def __tmp(c):
            try:
                for handle in c.w.window_handles:
                    c.w.switch_to_window(handle)
                    if c.w.driver.title == name:
                        c.w.info('window switch to: %s' % name, True)
                        return True
            except:
                return False
        self.popup = self.w.wait_until(__tmp, msg='window %s' % name, inst=self)
    
    def test(self):
        self.switch_to_popup()
        #self.w.s.execute_script('return window.onbeforeunload=window.confirm')

        self.w.info('logout', True)

        import urlparse
        for i in range(5):
            try:
                self.w.get(urlparse.urlunparse(('http', self.web_server, 'reg.php', '', 'ah_popup=true', '')))
                self.w.click(LoginSuccessfulPopupPage.get('logou_btn'))
                self.w.switch_to_alert().accept()    
                self.w.wait_until_title_present(LogoutPage.get('logout_page_title'))
                return
            except Exception, e:
                if i == 4:
                    raise
                self.w.warn('Fail to get successful logout page after click logout, will try again', True)
                self.w.s.refresh()
                self.w.wait_until_title_present(LogoutPage.get('logout_page_title'))
                return


    def logout(self):
        # If user session timeout, there will be a alert says: Your session has time out.
        try:
            self.w.switch_to_alert().accept()
            return
        except:
            pass

        self.w.info('Try to logout')
        def __tmp(c):
            try:
                c.switch_to_popup()
                c.w.click(LoginSuccessfulPopupPage.get('logou_btn'))
                c.w.switch_to_alert().accept()
                c.w.wait_until_title_present(LogoutPage.get('logout_page_title'), info=True)
                return True
            except:
                # Sometime after click logout, server didn't response to successfull logout page.
                try:
                    self.w.warn('Fail to get Logged Out page, will try again', True)
                    c.w.s.execute_script('return window.onbeforeunload=null')                    
                    c.w.s.refresh()
                    c.w.wait_until_title_present(LogoutPage.get('logout_page_title'), info=True)
                    return True
                except Exception, e:
                    pass
                return False
        self.popup = self.w.wait_until(__tmp, msg='logout alert', inst=self, time_out=600)        
        left_time = self.w.find_element(LogoutPage.get('left_session_time_td')).text
        self.w.info('Left Session Time: %s' % left_time, True)

    def login_to_amigopod_management(self, username, password):        
        self.w.wait_until_element_displayed(AmigopodLoginPage.get('login_btn'))
        
        self.w.input(AmigopodLoginPage.get('username_txt'), username)
        self.w.input(AmigopodLoginPage.get('password_txt'), password)
        
        self.w.info('handle amigopod management login form', True)
        self.w.click(AmigopodLoginPage.get('login_btn'))  
        self.w.wait_until_title_present(AmigopodAdministratorPage.get('page_title'), info=True)
    
    def logout_amigopod_management(self):   
        self.w.wait_until_element_displayed(AmigopodAdministratorPage.get('logout_link'))

        self.w.info('logout amigopod management', True)     
        self.w.click(AmigopodAdministratorPage.get('logout_link'))  