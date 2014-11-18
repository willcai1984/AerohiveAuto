# -*- coding: UTF-8 -*-

import argparse, os.path, shutil, logging, sys, traceback, json, codecs, time, re
from selenium.common.exceptions import WebDriverException, NoSuchElementException
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.webdriver.support.ui import WebDriverWait, Select
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains

from utils import Singleton, HtmlHandler, AssertionHelper, \
                  get_default_profile, get_default_log_file, get_default_test_data, \
                  json_value
from cfg import BrowserType, \
                SELENIUM_INITIALIZATION_RETRY, SELENIUM_INITIALIZATION_RETRY_PERIOD, \
                WAIT_FOR_PAGE_TO_LOAD, IMPLICITLY_WAIT, CRAZY_SNAPPING

# Main tasks:
# - parse arguments from command line
# - initialize logging relevants and logger
#
# TODO:
# - call function(s) of certain module(s) specified from command line 
class WebUIArgs(object):
    def __init__(self):
        self.parser = argparse.ArgumentParser(description='setup web testing')
        self.parser.add_argument('-r', '--remote-selenium', required=True, dest='remote_selenium',
                                 help='remote selenium url')
        self.parser.add_argument('-t', '--browser-type', required=False, default=BrowserType.FF, dest='browser_type',
                                 help='ff, ie, default is ff')
        self.parser.add_argument('-p', '--browser-profile', required=False, default=get_default_profile(), dest='browser_profile',
                                 help='browser profile, firefox only, default is "webui/profile/ff"')
        self.parser.add_argument('-l', '--log-level', required=False, default='debug', dest='log_level',
                                 help='debug, info, warn, error, default is debug')
        self.parser.add_argument('-f', '--log-file', required=False, default=get_default_log_file(), dest='log_file',
                                 help='log file, default is "[dir of test file]/WebUI.html"')
        self.parser.add_argument('-d', '--data-file', required=False, default=get_default_test_data(), dest='data_file',
                                 help='data file (should be encoded in utf-8), default is "[dir of test file]/[name of test file].json"')
        self.parser.add_argument(      '--property-file', required=False, default=None, dest='property_file',
                                 help='property file used by execution engine')
        self.parser.add_argument(      '--parameters', required=False, default=None, nargs='+', dest='parameters',
                                 help='parameters from command line have higher priority than which specified in data file')
        self.parser.add_argument(      '--preserve-session', required=False, default=False, dest='preserve_session', action='store_true',
                                 help='preserver session')
        self.parser.add_argument(      '--session-id', required=False, default=None, dest='session_id',
                                 help='use existing session')

        self._parse_args()
        self._init_logger()
        self._load_properties()

    def _parse_args(self):
        self.args = self.parser.parse_args()
        
        self.remote_selenium = self.args.remote_selenium
        self.browser_type = self.args.browser_type.lower()
        self.browser_profile = self.args.browser_profile
        self.log_level = self.args.log_level.lower()
        self.log_file = self.args.log_file
        self.data_file = self.args.data_file
        self.property_file = self.args.property_file
        self.parameters = WebUIArgs.pase_properties(self.args.parameters) if self.args.parameters else {}
        self.preserve_session = self.args.preserve_session
        self.session_id = self.args.session_id

        if not os.path.isabs(self.log_file):
            self.log_file = os.path.abspath(os.path.join('.', self.log_file))
        if not self.log_file.endswith('.html'):
            self.log_file = '%s.html' % self.log_file
        if os.path.exists(self.log_file):
            os.remove(self.log_file)
            
        self.log_pic_dir = '%s_pic' % self.log_file.replace('.html', '')
        if os.path.exists(self.log_pic_dir):
            shutil.rmtree(self.log_pic_dir)
        os.mkdir(self.log_pic_dir)
        
        self.log_pic_index = 0

    def _init_logger(self):
        level = getattr(logging, self.log_level.upper())
        
        logger = logging.getLogger('WebUI')
        logger.setLevel(level)
        
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(filename)s:%(lineno)d - %(message)s')
        
        sh = logging.StreamHandler(sys.stdout)
        sh.setLevel(level)
        sh.setFormatter(formatter)
        logger.addHandler(sh)
        
        hh = HtmlHandler(self.log_file)
        hh.setLevel(level)
        hh.setFormatter(formatter)
        logger.addHandler(hh)
        
        self.logger = logger
        
    def _load_properties(self):
        self.properties = {}
        if self.property_file:
            with open(self.property_file, 'r') as f:
                self.properties = WebUIArgs.pase_properties(f)
                       
    @staticmethod 
    def pase_properties(items):
        properties = {}
        for item in items:
            item = item.rstrip('\r\n')
            pos = item.find('=')
            if pos > 0 & pos < len(item) - 1:
                key = item[:pos]
                value = item[pos+1:]
                properties[key] = value
        return properties
            
class WebUIException(WebDriverException):
    pass

# Locator might be different in various browsers hence the the locator could be 
# browser type sensitive. That is the reason browser type is required to get 
# locator. Avoiding explicit constructor is to make both definition and 
# instantiation more easier. 
class WebElement(object):
    def __init__(self, element):
        self.element = element
        
    def child(self, locator):
        return self.element.find_element(*locator)
        
    def is_child_present(self, locator):
        try:
            self.child(locator)
            return True
        except NoSuchElementException, e:
            return False
        
    @classmethod
    def get(cls, name):
        browser_type = WebUI().browser_type
        if hasattr(cls, '%s_%s' % (name, browser_type)):
            return getattr(cls, '%s_%s' % (name, browser_type))
        if hasattr(cls, name):
            return getattr(cls, name)
        raise WebUIException('wrong element name %s.%s' % (cls.__name__, name))
        
class WebUIDriver(WebDriver):
    def __init__(self, command_executor='http://127.0.0.1:4444/wd/hub', desired_capabilities=None, browser_profile=None, session_id=None):
        self.preserved_session_id = session_id
        self.browser_profile = browser_profile
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

    def stop_client(self):
        #clean tmp firefox profile dir under /tmp after driver.quit()
        print "... stop client start remove tmp files ..."
        print " the browser_profile path=>" + str(self.browser_profile.path)
        if self.browser_profile.path:
            import os
            ff_profile_tmp = os.path.dirname(self.browser_profile.path)
            try:
                for dir_name in os.listdir(ff_profile_tmp):
                    if dir_name.startswith('tmp'):
                        shutil.rmtree(os.path.join(ff_profile_tmp, dir_name))
            except Exception, e:
                pass

class WebUI(object):
    __metaclass__ = Singleton
    
    def __init__(self, webuiargs):
        self.remote_selenium = webuiargs.remote_selenium
        self.browser_type = webuiargs.browser_type
        self.browser_profile = webuiargs.browser_profile
        self.log_level = webuiargs.log_level
        self.log_file = webuiargs.log_file
        self.log_pic_dir = webuiargs.log_pic_dir
        self.log_pic_index = webuiargs.log_pic_index
        self.logger = webuiargs.logger
        self.data_file = webuiargs.data_file
        self.property_file = webuiargs.property_file
        self.properties = webuiargs.properties
        self.parameters = webuiargs.parameters
        self.preserve_session = webuiargs.preserve_session
        self.session_id = webuiargs.session_id
        self._data = None
        self._driver = None
        self._assertion = None
        self._cleanup = []
        self.info('dump of webui\n' + str(self))
    
    def debug(self, msg, pic=False):
        if self.logger.isEnabledFor(logging.DEBUG):
            self.logger.debug(self.gen_log_msg(msg, pic))
    
    def info(self, msg, pic=False):
        if self.logger.isEnabledFor(logging.INFO):
            self.logger.info(self.gen_log_msg(msg, pic))
    
    def warn(self, msg, pic=False):
        if self.logger.isEnabledFor(logging.WARN):
            self.logger.warn(self.gen_log_msg(msg, pic))
    
    def error(self, msg, pic=False):
        if self.logger.isEnabledFor(logging.ERROR):
            self.logger.error(self.gen_log_msg(msg, pic))

    def gen_log_msg(self, msg, pic=False):
        if pic == False or self._driver is None:
            return msg
        
        if pic == True:
            pic = self.pic_path()
            self.snapshot(pic)
        
        pic_link = './' + os.path.basename(os.path.dirname(pic)) + '/' + os.path.basename(pic)
        return msg + HtmlHandler.PIC_TAG +  pic_link
        
    def pic_path(self, name=''):
        return os.path.join(self.log_pic_dir, 
                            '%03d_%s.png' % (self.pic_index(), 
                                             name.replace(' ', '_').lower()))
        
    def pic_index(self):
        self.log_pic_index += 1
        return self.log_pic_index
        
    @property
    def data(self):
        if self._data is None:
            self.info('loading data')
            with codecs.open(self.data_file, 'r', 'utf_8_sig') as d:
                self._data = json.load(d)
        return self._data
    
    def test_data(self, path=''):
        if self.parameters.has_key(path):
            return self.parameters[path]
        
        value = json_value(self.data, path)
        if value:
            while True:
                p = r'(\${([^{}]*)})'
                m = re.search(p, value)
                if m:
                    value = value[0:m.start()] + self.properties[m.group(2)] + value[m.end():]
                else:
                    break
        return value
    
    def d(self, path=''):
        return self.test_data(path)
    
    @property
    def keys(self):
        return Keys

    @property
    def driver(self):
        if self._driver is None:
            self.info('initializing webdriver')
            if self.browser_type == BrowserType.IE:
                profile = None
            elif self.browser_type == BrowserType.FF and self.browser_profile:
                profile = FirefoxProfile(self.browser_profile)
            else:
                profile = FirefoxProfile(None) 
            self.browser_profile = profile
            from urllib2 import URLError
            for i in range(SELENIUM_INITIALIZATION_RETRY):
                try:
                    if self.session_id:
                        self.warn('using session - %s' % self.session_id)
                    self._driver = WebUIDriver(self.remote_selenium, BrowserType.CAPABILITIES[self.browser_type], profile, self.session_id)
                    self._driver.implicitly_wait(IMPLICITLY_WAIT)
                    self.maximize_window()
                    break
                except URLError, e:
                    if i < SELENIUM_INITIALIZATION_RETRY - 1:
                        time.sleep(SELENIUM_INITIALIZATION_RETRY_PERIOD)
                    else:
                        raise
        return self._driver
    
    @property
    def s(self):
        return self.driver

    def maximize_window(self, windowHandle='current'):
        self.driver.set_window_position(0, 0, windowHandle)
        self.driver.set_window_size(1280, 1024, windowHandle)

    def move_scroll_to_element(self, locator):
        element = self.find_element(locator)
        if element:
            element_id = element.get_attribute('id')
            self.s.execute_script('document.getElementById("%s").scrollIntoView()' % element_id)
        self.wait_until_element_displayed(locator)

    def move_scroll_bottom(self):
        self.s.execute_script('window.scrollBy(0,document.body.scrollHeight)')

    def move_scroll_top(self):
        self.s.execute_script('document.getElementById("header").scrollIntoView()')

    def move_scroll_to_element_use_px(self, locator):
        element = self.find_element(locator)
        if element:
            element_id = element.get_attribute('id')
            self.s.execute_script('var clientHeight = document.documentElement.clientHeight;var elementHeight = document.getElementById("'+str(element_id)+'").offsetTop; \
            moveHeight=elementHeight-clientHeight;window.scrollTo(0,moveHeight);')
        self.wait_until_element_displayed(locator)

    def move_scroll_by_element(self, locator):
        element = self.find_element(locator)
        if element:
            self.s.execute_script('arguments[0].scrollIntoView();', element)
        self.info('scrollTop move to element [ %s ]' %(str(locator)), True)

    def get(self, url):
        if not url.startswith('http'):
            url = 'http://' + url
        self.info('getting url %s' % url)
        return self.driver.get(url)

    @property
    def title(self):
        return self.driver.title
    
    def check_title(self, desired, msg='check title'):
        self.debug(msg, CRAZY_SNAPPING)
        self.assertion.assertEqual(desired, self.title, msg)
    
    def find_element(self, locator):
        return self.driver.find_element(*locator)
        
    def is_element_present(self, locator):
        try:
            self.find_element(locator)
            return True
        except NoSuchElementException, e:
            return False
        
    # Use instance of WebUI to instantiate the waiting fixture instead of 
    # using WebDriver so the argument parsed into the method is WebUI not 
    # WebDriver and the proposal is to use logging mechanism inside the method.
    def wait_until(self, method, positive=True, msg='', info=False, inst=None, time_out=IMPLICITLY_WAIT):
        msg = msg if positive else 'NOT ' + msg
        inst = self if inst is None else inst

        self.debug('waiting for: %s' % msg, CRAZY_SNAPPING)

        try:
            if positive:
                ret = WebDriverWait(inst, time_out).until(method)
            else:
                ret = WebDriverWait(inst, time_out).until_not(method)
        except Exception, e:
            raise WebUIException('not found element or wait time out in page. waiting for: %s' % msg)
        if info:
            self.info('after waiting for: %s' % msg, True)
        else:
            self.debug('after waiting for: %s' % msg, CRAZY_SNAPPING)
         
        return ret
    
    def wait_until_title_present(self, desired, positive=True, msg='', info=False, inst=None):
        msg = msg if msg else 'title - %s' % desired
        method = lambda w: desired == w.title
        return self.wait_until(method, positive, msg, info, inst)
    
    def wait_until_element_present(self, locator, positive=True, msg='', info=False, inst=None):
        msg = msg if msg else 'present - %s' % str(locator)
        method = lambda w: w.find_element(locator)
        return self.wait_until(method, positive, msg, info, inst)
    
    def wait_until_element_displayed(self, locator, positive=True, msg='', info=False, inst=None):
        msg = msg if msg else 'displayed - %s' % str(locator)
        method = lambda w: w.find_element(locator) and w.find_element(locator).is_displayed()
        return self.wait_until(method, positive, msg, info, inst)

    def wait_until_element_text(self, locator, positive=True, msg='', info=False, inst=None, time_out=IMPLICITLY_WAIT):
        msg = msg if msg else 'text not empty - %s' % str(locator)
        method = lambda w: w.find_element(locator).text.strip() is not ''
        return self.wait_until(method, positive, msg, info, inst, time_out)

    def wait_until_update_process_end(self, locator, positive=True, msg='', info=False, inst=None, time_out=IMPLICITLY_WAIT):
        msg = msg if msg else 'process end - %s' % str(locator)
        method = lambda w: not w.find_element(locator).text.strip().endswith('%')
        return self.wait_until(method, positive, msg, info, inst, time_out)

    def wait_until_element_enabled(self, locator, positive=True, msg='', info=False, inst=None):
        msg = msg if msg else 'enabled - %s' % str(locator)
        method = lambda w: w.find_element(locator).get_attribute('disabled') is not 'true'
        return self.wait_until(method, positive, msg, info, inst)

    def wait_for_page_to_load(self, msg=None):
        if msg:
            self.debug(msg, CRAZY_SNAPPING)
        time.sleep(WAIT_FOR_PAGE_TO_LOAD)
        self.debug('after waiting for page to load', CRAZY_SNAPPING)

    def click_element(self, element):
        element.click()
        
    def click(self, locator, expected=None):
        self.wait_until_element_displayed(locator)
        self.click_element(self.find_element(locator))
        self.debug('after click %s' % str(locator))
        if expected:
            for i in range(4):
                try:
                    self.wait_until_element_displayed(expected)
                    break
                except Exception, e:
                    self.warn('Fail to find element %s, after click %s, will try again' % (str(expected), str(locator)), True)
                    self.wait_until_element_displayed(locator)
                    self.click_element(self.find_element(locator))
                    self.debug('after click %s' % str(locator))

    def clear_element(self, element):
        element.clear()
        
    def clear(self, locator):
        self.clear_element(self.find_element(locator))
        self.debug('after clear %s' % str(locator))

    def input_element(self, element, txt):
        self.click_element(element)
        self.clear_element(element)
        if txt:
            element.send_keys(txt)

    def input(self, locator, txt):
        self.wait_until_element_displayed(locator)        
        self.input_element(self.find_element(locator), txt)
    
    def check_element(self, element):
        if not element.is_selected():
            self.click_element(element)

    def check(self, locator):
        self.wait_until_element_displayed(locator)                
        self.check_element(self.find_element(locator))

    def get_selecter(self, locator):
        self.wait_until_element_displayed(locator)                        
        return Select(self.find_element(locator))

    def action_chains(self):
        return ActionChains(self.driver)

    def snapshot(self, path):
        return self.driver.get_screenshot_as_file(path)
    
    @property
    def current_window_handle(self):
        return self.driver.current_window_handle
    
    @property
    def window_handles(self):
        return self.driver.window_handles
    
    def switch_to_window(self, window):
        return self.driver.switch_to_window(window)
    
    def switch_to_alert(self):
        return self.driver.switch_to_alert()

    def switch_to_frame(self, element):
        return self.driver.switch_to_frame(element)

    def clean_ff_tmp(self):
        #clean tmp firefox profile dir under /tmp
        self.info("... start remove tmp files ...")
        self.info(" the browser_profile path=>" + str(self.browser_profile.path))
        if self.browser_profile.path:
            import os
            ff_profile_tmp = os.path.dirname(self.browser_profile.path)
            try:
                for dir_name in os.listdir(ff_profile_tmp):
                    if dir_name.startswith('tmp'):
                        shutil.rmtree(os.path.join(ff_profile_tmp, dir_name))
            except Exception, e:
                pass

    def get_cookie(self, name):
        return self.driver.get_cookie(name)

    def get_cookies(self):
        return self.driver.get_cookies()

    def quit(self, is_except = False):
        if self.preserve_session and (not is_except or self.logger.isEnabledFor(logging.DEBUG)):
            self.warn('session preserved - %s' % self._driver.session_id, True)
            self.driver.stop_client()
            return
        
        if self._cleanup:
            self.warn('executing registered cleanup method')
            for method in self._cleanup[:]:
                method()
                
        if self._driver:
            self.info('closing webdriver', True)
            return self.driver.quit()

        #if Webdriver not init success, there still ff profile in tmp
        self.clean_ff_tmp()            

    @property
    def assertion(self):
        if self._assertion is None:
            self._assertion = AssertionHelper()
        return self._assertion
    
    @property
    def a(self):
        return self.assertion
    
    def register_cleanup(self, method):
        self._cleanup.append(method)
        
    def unregister_cleanup(self, method):
        if method in self._cleanup:
            self._cleanup.remove(method)
        
    def __str__(self):
        s = []
        s.append('remote-selenium = %s' % self.remote_selenium)
        s.append('browser-type = %s' % self.browser_type)
        if self.browser_type == BrowserType.FF:
            s.append('browser-profile = %s' % self.browser_profile)
        s.append('log-level = %s' % self.log_level)
        s.append('log-file = %s' % self.log_file)
        s.append('log-pic-dir = %s' % self.log_pic_dir)
        s.append('data-file = %s' % self.data_file)
        s.append('property-file = %s' % self.property_file)
        s.append('preserve-session = %s' % self.preserve_session)
        s.append('session-id = %s' % self.session_id)
        return '\n'.join(s)
    
# Make sure to instantiate WebUI before calling certain function. When 
# exception occurred then log down exception and the trace back properly and 
# then terminate the execution with exist status as -1.
def safe_call(f):
    def _f(*args, **kvargs):
        if WebUI not in Singleton._INSTANCES: 
            # WebUI has not been instantiated
            try:
                webuiargs = WebUIArgs()
            except:
                raise
            else:
                WebUI(webuiargs)
        try:
            # Call certain function
            return f(*args, **kvargs)
        except:
            try:
                WebUI().quit(True)
            except:
                raise            
            # Exception occurred
            WebUI().error('error occurred\n%s' % traceback.format_exc(), True)
            # Terminate the execution with exist status as -1
            sys.exit(-1)
        finally:
            try:
                WebUI().quit()
            except:
                pass
    return _f
