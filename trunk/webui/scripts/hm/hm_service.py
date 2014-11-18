# -*- coding: UTF-8 -*
#hm_service.py -r http://{sta.ip}:4444/wd/hub -t ie -f LogFile --parameters service.name=capwap_server

from webui import safe_call,WebUI
from webui.hm import HM

@safe_call
def update():
    wui=WebUI()
    hm=HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.update_hm_service(wui.d("service.name"))
    
if __name__ == '__main__':
    update()    
    
