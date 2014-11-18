# -*- coding: UTF-8 -*-

# We can define different browsers in grid mode. To demand certain type we need 
# to extend the definition of DesiredCapabilities which could be added here and 
# the key used here is for shortcut or readable indexing.
# 
# TODO:
# - combination of different version of browser and os
# - grid mode execution
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
class BrowserType(object):
    FF = 'ff'
    IE = 'ie'
    CHROME = 'chrome'
    SAFARI = 'safari'
    CAPABILITIES = {FF:DesiredCapabilities.FIREFOX,
                    IE:DesiredCapabilities.INTERNETEXPLORER,
                    CHROME:DesiredCapabilities.CHROME,
                    SAFARI:DesiredCapabilities.SAFARI
                    }

SELENIUM_INITIALIZATION_RETRY = 2

SELENIUM_INITIALIZATION_RETRY_PERIOD = 5

# Using element guard is more effective
WAIT_FOR_PAGE_TO_LOAD = 30

# Take effect in server side
IMPLICITLY_WAIT = 60

# Take snapshots as much as possible
CRAZY_SNAPPING = False
