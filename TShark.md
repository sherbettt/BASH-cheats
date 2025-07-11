**TShark** — это консольная версия Wireshark, позволяющая захватывать, анализировать и фильтровать сетевой трафик без графического интерфейса. Вот основные команды и примеры использования:


### **1. Основные команды**
#### **Захват трафика**
```bash
tshark -i <интерфейс>  # Захват с указанного интерфейса (например, eth0, wlan0)
```
Пример:
```bash
tshark -i eth0
```

#### **Захват с сохранением в файл**
```bash
tshark -i eth0 -w output.pcap  # Сохранить трафик в файл
```

#### **Чтение из файла**
```bash
tshark -r input.pcap  # Анализ сохранённого .pcap/.pcapng файла
```



### **2. Фильтрация трафика**
#### **Фильтр захвата (как в Wireshark)**
```bash
tshark -i eth0 -f "host 192.168.1.1"  # Только трафик с/на указанный IP
```
Другие примеры фильтров:
- `port 80` — только HTTP.
- `icmp` — только ICMP (пинги).
- `tcp port 443` — только HTTPS.

#### **Фильтр отображения (анализ уже захваченного)**
```bash
tshark -r input.pcap -Y "http.request"  # Показать HTTP-запросы
```
Примеры:
- `ip.src == 192.168.1.1` — пакеты от указанного IP.
- `tcp.flags.syn == 1` — только SYN-пакеты (начало TCP-соединения).
- `dns` — только DNS-запросы.



### **3. Полезные опции**
#### **Ограничение количества пакетов**
```bash
tshark -i eth0 -c 100  # Захватить только 100 пакетов
```

#### **Вывод определённых полей**
```bash
tshark -i eth0 -T fields -e ip.src -e ip.dst  # Показывать только IP-адреса источника и назначения
```

#### **Декодирование SSL/TLS (если есть ключи)**
```bash
tshark -r encrypted.pcap -o "tls.keylog_file:sslkeys.log"  # Чтение трафика с ключами
```



### **4. Анализ трафика**
#### **Статистика по протоколам**
```bash
tshark -r input.pcap -qz io,phs  # Иерархия протоколов (аналог Wireshark Statistics)
```

#### **Следование за TCP-потоком**
```bash
tshark -r input.pcap -Y "tcp.stream eq 5"  # Показать все пакеты потока №5
```
Или для HTTP:
```bash
tshark -r input.pcap -Y "http" --color  # Подсветка HTTP-трафика
```

#### **Поиск строк в пакетах**
```bash
tshark -r input.pcap -Y "frame contains 'password'"  # Поиск по содержимому
```



### **5. Экспорт данных**
#### **В JSON**
```bash
tshark -r input.pcap -T json > output.json
```

#### **В CSV (например, HTTP-запросы)**
```bash
tshark -r input.pcap -Y "http.request" -T fields -e http.host -e http.request.uri > urls.csv
```



### **6. Примеры использования**
#### **1. Анализ DNS-запросов**
```bash
tshark -i wlan0 -f "port 53" -Y "dns"  # Только DNS
```

#### **2. Поиск подозрительного трафика**
```bash
tshark -r traffic.pcap -Y "tcp.flags.reset == 1 && ip.src == 10.0.0.5"  # RST-пакеты от конкретного IP
```

#### **3. Мониторинг HTTP-заголовков**
```bash
tshark -i eth0 -Y "http.request or http.response" -O http  # Подробный вывод HTTP
```


### **7. Горячие клавиши в реальном времени**
- `Ctrl+C` — остановить захват.
- `Ctrl+D` — остановить и вывести статистику.


### **8. Дополнительные фичи**
- **Цветной вывод**: `tshark --color` (подсветка пакетов).
- **Геолокация IP**: `tshark -r input.pcap -Y "ip" -T fields -e ip.src -e ip.geoip.country`.



### **Важно**
- Для захвата трафика может потребоваться запуск с `sudo`.
- Фильтры Wireshark (`-Y`) и BPF (`-f`) [различаются](https://www.wireshark.org/docs/man-pages/tshark.html).




