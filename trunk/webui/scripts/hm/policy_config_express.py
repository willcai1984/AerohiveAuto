# -*- coding: UTF-8 -*
#policy_config.py -r http://{sta.ip}:4444/wd/hub -t ie -f LogFile --parameters policy.name=aaa_user_dir aaa_user_dir.name=new_aaa_ladp

from webui import safe_call,WebUI
from webui.hm import HM

@safe_call
def policy_config():
    wui=WebUI()
    hm=HM()
    if wui.session_id is None:
        hm.login_by_vhm(wui.d("login.server"),
                        wui.d("login.username"),
                        wui.d("login.password"))
    hm.config_ssid_express(wui.d("policy.name"))
    
if __name__ == '__main__':
    policy_config()    
    
