# -*- coding: UTF-8 -*
#new_policy.py -r http://{sta.ip}:4444/wd/hub -t ff -f LogFile --parameters policy.name=zzzz hive.name='hive0 (not secure)' ssid.name=testssid cwp.name=default radius.name=pub_radius_server user_profile.default_user='1_testa(1)' user_profile.registration_user='1_testb(2)'

from webui import safe_call,WebUI
from webui.hm import HM

@safe_call
def new_policy():
    wui=WebUI()
    hm=HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.new_policy(wui.d("policy.name"))
    
if __name__ == '__main__':
    new_policy()    
    
