# -*- coding: UTF-8 -*-

from webui import safe_call, WebUI
from webui.hm import HM

@safe_call
def main():
    wui = WebUI()
    hm = HM()
    if wui.session_id is None:
        hm.login(wui.d("login.server"),
                 wui.d("login.username"),
                 wui.d("login.password"))
    hm.to_clients_table(type='active_clients')
    wui.unregister_cleanup(hm.logout)    
    hm.client_opration(wui.d("deauth_client.ip"), wui.d("opration.name"))             

if __name__ == '__main__':
    main()