#!/usr/bin/python3

import socket      # Для работы с сетевыми соединениями (UDP в данном случае)
import binascii    # Для преобразования HEX-строк в байты
import os          # Для генерации случайных данных (транзакционный ID STUN)

def get_stun_info(server='stun.l.google.com', port=19302):
    # Создаём UDP-сокет (STUN работает по UDP)
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # Устанавливаем таймаут 2 секунды (чтобы скрипт не зависал)
    s.settimeout(2)

    # Формируем STUN-запрос (Binding Request):
    # - Первые 8 байт: заголовок STUN-сообщения (0x0001 – тип запроса, 0x0000 – длина, 0x2112A442 – магия)
    # - Остальные 12 байт: случайный транзакционный ID (по протоколу STUN)
    msg = binascii.a2b_hex('000100002112a442') + os.urandom(12)

    try:
        # Отправляем запрос на STUN-сервер
        s.sendto(msg, (server, port))
        # Получаем ответ (макс. 1024 байта)
        data, addr = s.recvfrom(1024)
        
        # Проверяем, что ответ корректный (0x0101 – Binding Response)
        if data[0:2] == b'\x01\x01':
            # Извлекаем внешний порт (байты 26-28 в ответе)
            port = int.from_bytes(data[26:28], 'big')
            # Извлекаем внешний IP (байты 28-32) и преобразуем в строку вида "A.B.C.D"
            ip = '.'.join(str(b) for b in data[28:32])
            return ip, port
    except:
        # Если ошибка (нет ответа, таймаут и т.д.), возвращаем None
        pass
    return None, None

# Получаем внешний IP и порт через STUN
ip, port = get_stun_info()
if ip:
    print(f"External IP: {ip}\nExternal Port: {port}")
else:
    print("STUN request failed")
