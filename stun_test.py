#!/usr/bin/python3
import socket
import binascii
import os  # Добавляем недостающий импорт

def get_stun_info(server='stun.l.google.com', port=19302):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(2)
    
    # STUN Binding Request
    msg = binascii.a2b_hex('000100002112a442') + os.urandom(12)
    
    try:
        s.sendto(msg, (server, port))
        data, addr = s.recvfrom(1024)
        if data[0:2] == b'\x01\x01':
            port = int.from_bytes(data[26:28], 'big')
            ip = '.'.join(str(b) for b in data[28:32])
            return ip, port
    except:
        pass
    return None, None

ip, port = get_stun_info()
if ip:
    print(f"External IP: {ip}\nExternal Port: {port}")
else:
    print("STUN request failed")
