    #socket_client.py

import socket

def socket_send(command):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('10.155.34.160', 1000))
    sock.send(command)
    result = sock.recv(2048)
    sock.close()
    return result

if __name__ == '__main__':
#   print socket_send('D:\\tf\\adminGroupAndAdminType.bat')
#   print socket_send('D:\\tf\\guestTypeAndGuestAccount.bat')
   print socket_send('D:\\tf\\clear.bat')
#     print socket_send('D:\\tf\\test.bat')