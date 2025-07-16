SIP (Session Initiation Protocol) — это протокол сигнализации, используемый для установления, изменения и завершения мультимедийных сеансов связи, таких как VoIP-звонки, видеоконференции и обмен сообщениями.  

### **Основные типы SIP-запросов (методы)**  
1. **INVITE** – инициирует сеанс связи (например, звонок).  
2. **ACK** – подтверждает окончательное принятие запроса (после ответа на INVITE).  
3. **BYE** – завершает сеанс связи.  
4. **CANCEL** – отменяет ожидающий запрос (например, если звонок не был принят).  
5. **OPTIONS** – запрашивает информацию о возможностях сервера или UA (User Agent).  
6. **REGISTER** – регистрирует пользователя на SIP-сервере (например, при подключении к VoIP-провайдеру).  
7. **SUBSCRIBE** – подписывается на уведомления о событиях.  
8. **NOTIFY** – отправляет уведомления о событиях.  
9. **PUBLISH** – публикует информацию о состоянии пользователя.  
10. **REFER** – перенаправляет вызов или сеанс.  
11. **MESSAGE** – передает мгновенные сообщения (SMS-подобные).  

-------------
# 📞 Основные методы SIP-протокола  

SIP (Session Initiation Protocol) использует различные методы для установки, управления и завершения мультимедийных сеансов (голосовых/видеозвонков, сообщений и т. д.).  

## **1. `INVITE` – инициация сеанса связи**  
**Назначение:**  
- Начинает сеанс (например, VoIP-звонок, видеоконференцию).  
- Может включать SDP (Session Description Protocol) для согласования параметров (кодеки, порты и т. д.).  

**Пример запроса:**  
```sip
INVITE sip:bob@example.com SIP/2.0
Via: SIP/2.0/UDP alice-pc.example.com:5060
From: Alice <sip:alice@example.com>;tag=12345
To: Bob <sip:bob@example.com>
Call-ID: abc123@alice-pc.example.com
CSeq: 1 INVITE
Contact: <sip:alice@alice-pc.example.com>
Content-Type: application/sdp
Content-Length: [длина тела]

v=0
o=alice 2890844526 2890844526 IN IP4 alice-pc.example.com
s=-
c=IN IP4 192.0.2.1
t=0 0
m=audio 49170 RTP/AVP 0
a=rtpmap:0 PCMU/8000
```

**Ответы:**  
- `180 Ringing` – вызов идет.  
- `200 OK` – вызов принят.  
- `486 Busy Here` – абонент занят.  



## **2. `ACK` – подтверждение установки сеанса**  
**Назначение:**  
- Подтверждает получение финального ответа на `INVITE` (обычно `200 OK`).  
- Используется только с `INVITE`.  

**Пример:**  
```sip
ACK sip:bob@example.com SIP/2.0
Via: SIP/2.0/UDP alice-pc.example.com:5060
From: Alice <sip:alice@example.com>;tag=12345
To: Bob <sip:bob@example.com>;tag=67890
Call-ID: abc123@alice-pc.example.com
CSeq: 1 ACK
Content-Length: 0
```



## **3. `BYE` – завершение сеанса**  
**Назначение:**  
- Завершает установленный сеанс (разговор, видеозвонок).  

**Пример:**  
```sip
BYE sip:alice@example.com SIP/2.0
Via: SIP/2.0/UDP bob-pc.example.com:5060
From: Bob <sip:bob@example.com>;tag=67890
To: Alice <sip:alice@example.com>;tag=12345
Call-ID: abc123@alice-pc.example.com
CSeq: 2 BYE
Content-Length: 0
```

**Ответ:**  
- `200 OK` – сеанс завершен.  



## **4. `CANCEL` – отмена ожидающего запроса**  
**Назначение:**  
- Отменяет `INVITE` до получения финального ответа (если абонент не взял трубку).  

**Пример:**  
```sip
CANCEL sip:bob@example.com SIP/2.0
Via: SIP/2.0/UDP alice-pc.example.com:5060
From: Alice <sip:alice@example.com>;tag=12345
To: Bob <sip:bob@example.com>
Call-ID: abc123@alice-pc.example.com
CSeq: 1 CANCEL
Content-Length: 0
```

**Ответ:**  
- `200 OK` – отмена принята.  



## **5. `OPTIONS` – запрос возможностей UA/сервера**  
**Назначение:**  
- Запрашивает список поддерживаемых методов, кодеков и т. д.  

**Пример:**  
```sip
OPTIONS sip:server.example.com SIP/2.0
Via: SIP/2.0/UDP client.example.com:5060
From: <sip:user@client.example.com>;tag=12345
To: <sip:server@example.com>
Call-ID: 987654@client.example.com
CSeq: 1 OPTIONS
Contact: <sip:user@client.example.com>
Accept: application/sdp
Content-Length: 0
```

**Ответ (`200 OK` с поддерживаемыми методами):**  
```sip
SIP/2.0 200 OK
Allow: INVITE, ACK, BYE, CANCEL, OPTIONS, REGISTER
Content-Length: 0
```


## **6. `REGISTER` – регистрация на SIP-сервере**  
**Назначение:**  
- Регистрирует пользователя на сервере (например, при подключении к VoIP-провайдеру).  

**Пример:**  
```sip
REGISTER sip:example.com SIP/2.0
Via: SIP/2.0/UDP client.example.com:5060
From: <sip:user@example.com>;tag=12345
To: <sip:user@example.com>
Call-ID: 123456@client.example.com
CSeq: 1 REGISTER
Contact: <sip:user@client.example.com>;expires=3600
Content-Length: 0
```

**Ответ:**  
- `200 OK` – регистрация успешна.  
- `401 Unauthorized` – требуется аутентификация.  



## **7. `SUBSCRIBE` / `NOTIFY` – подписка на события**  
**Назначение:**  
- `SUBSCRIBE` – подписывается на события (например, статус presence).  
- `NOTIFY` – отправляет уведомления о событиях.  

**Пример `SUBSCRIBE`:**  
```sip
SUBSCRIBE sip:bob@example.com SIP/2.0
Event: presence
Expires: 3600
```

**Пример `NOTIFY`:**  
```sip
NOTIFY sip:alice@example.com SIP/2.0
Event: presence
Content-Type: application/pidf+xml
```



## **8. `PUBLISH` – публикация состояния**  
**Назначение:**  
- Отправляет информацию о состоянии (например, статус "В сети").  

**Пример:**  
```sip
PUBLISH sip:server.example.com SIP/2.0
Event: presence
Content-Type: application/pidf+xml
```



## **9. `REFER` – перенаправление вызова**  
**Назначение:**  
- Перенаправляет вызов другому пользователю.  

**Пример:**  
```sip
REFER sip:alice@example.com SIP/2.0
Refer-To: <sip:carol@example.com>
```



## **10. `MESSAGE` – отправка мгновенных сообщений**  
**Назначение:**  
- Аналог SMS в SIP (например, чат в VoIP-клиентах).  

**Пример:**  
```sip
MESSAGE sip:bob@example.com SIP/2.0
Content-Type: text/plain
Content-Length: 12

Привет, Bob!
```

**📌 Примечание:**  
- Для работы некоторых методов (`SUBSCRIBE`, `NOTIFY`, `PUBLISH`) требуется поддержка **SIP Event Packages**.  
- `INVITE` и `BYE` управляют сеансами, а `REGISTER` отвечает за аутентификацию.  
-------------

### **SIP-ответы (коды состояний)**  
Ответы SIP делятся на **6 классов**, где первая цифра определяет тип ответа:  

#### **1xx (Информационные)** – запрос в обработке  
- **100 Trying** – запрос получен, обрабатывается.  
- **180 Ringing** – удаленный UA "звонит" (абоненту).  
- **183 Session Progress** – сеанс устанавливается (может включать ранний медиапоток).  

#### **2xx (Успешные)** – запрос выполнен  
- **200 OK** – запрос успешно завершен (например, звонок принят).  
- **202 Accepted** – запрос принят, но еще не обработан (используется в NOTIFY, SUBSCRIBE).  

#### **3xx (Перенаправления)** – требуется дополнительное действие  
- **301 Moved Permanently** – пользователь навсегда переехал на новый адрес.  
- **302 Moved Temporarily** – временное перенаправление.  
- **305 Use Proxy** – запрос должен быть отправлен через указанный прокси.  
- **380 Alternative Service** – альтернативный сервис (например, голосовая почта).  

#### **4xx (Ошибки клиента)** – запрос содержит ошибку  
- **400 Bad Request** – синтаксическая ошибка в запросе.  
- **401 Unauthorized** – требуется аутентификация.  
- **403 Forbidden** – сервер понял запрос, но отказывается его выполнять.  
- **404 Not Found** – пользователь не найден.  
- **405 Method Not Allowed** – метод не поддерживается.  
- **408 Request Timeout** – сервер не дождался ответа.  
- **415 Unsupported Media Type** – неподдерживаемый формат медиа.  
- **420 Bad Extension** – неподдерживаемое расширение SIP.  
- **486 Busy Here** – абонент занят.  
- **487 Request Terminated** – запрос отменен (CANCEL).  

#### **5xx (Ошибки сервера)** – сервер не может выполнить запрос  
- **500 Server Internal Error** – внутренняя ошибка сервера.  
- **501 Not Implemented** – функционал не реализован.  
- **503 Service Unavailable** – сервис временно недоступен.  
- **504 Server Time-out** – сервер не ответил вовремя.  
- **505 Version Not Supported** – версия SIP не поддерживается.  

#### **6xx (Глобальные ошибки)** – запрос не может быть выполнен нигде  
- **600 Busy Everywhere** – абонент занят на всех устройствах.  
- **603 Decline** – вызов отклонен пользователем.  
- **604 Does Not Exist Anywhere** – пользователь не существует.  
- **606 Not Acceptable** – медиа-параметры не поддерживаются.  

---

### **Пример SIP-диалога**  
1. **Вызов (INVITE)**  
   ```  
   INVITE sip:bob@example.com SIP/2.0  
   From: <sip:alice@example.com>  
   To: <sip:bob@example.com>  
   Call-ID: 123456@alicepc  
   CSeq: 1 INVITE  
   ```  

2. **Ответ (180 Ringing)**  
   ```  
   SIP/2.0 180 Ringing  
   From: <sip:alice@example.com>  
   To: <sip:bob@example.com>  
   Call-ID: 123456@alicepc  
   CSeq: 1 INVITE  
   ```  

3. **Успешное соединение (200 OK)**  
   ```  
   SIP/2.0 200 OK  
   From: <sip:alice@example.com>  
   To: <sip:bob@example.com>  
   Call-ID: 123456@alicepc  
   CSeq: 1 INVITE  
   ```  

4. **Подтверждение (ACK)**  
   ```  
   ACK sip:bob@example.com SIP/2.0  
   From: <sip:alice@example.com>  
   To: <sip:bob@example.com>  
   Call-ID: 123456@alicepc  
   CSeq: 1 ACK  
   ```  

5. **Завершение вызова (BYE)**  
   ```  
   BYE sip:bob@example.com SIP/2.0  
   From: <sip:alice@example.com>  
   To: <sip:bob@example.com>  
   Call-ID: 123456@alicepc  
   CSeq: 2 BYE  
   ```  

6. **Подтверждение завершения (200 OK)**  
   ```  
   SIP/2.0 200 OK  
   From: <sip:alice@example.com>  
   To: <sip:bob@example.com>  
   Call-ID: 123456@alicepc  
   CSeq: 2 BYE  
   ```  
----------------


## **1. SIP-заголовки (Headers)**  
Заголовки SIP передают метаданные о запросе/ответе. Они аналогичны HTTP-заголовкам, но со своей спецификой.  

### **Основные обязательные заголовки**  
- **Via** – путь, по которому ответ должен вернуться (добавляется каждым прокси).  
  ```  
  Via: SIP/2.0/UDP pc1.example.com;branch=z9hG4bK776asdhds  
  ```  
- **From** – отправитель запроса.  
  ```  
  From: "Alice" <sip:alice@example.com>;tag=1928301774  
  ```  
- **To** – получатель запроса.  
  ```  
  To: "Bob" <sip:bob@example.org>  
  ```  
- **Call-ID** – уникальный идентификатор сеанса (генерируется UA).  
  ```  
  Call-ID: a84b4c76e66710@pc1.example.com  
  ```  
- **CSeq** – порядковый номер + метод (используется для упорядочивания запросов).  
  ```  
  CSeq: 314159 INVITE  
  ```  
- **Contact** – прямой адрес для связи (используется в REGISTER, 200 OK).  
  ```  
  Contact: <sip:alice@192.0.2.1>  
  ```  
- **Max-Forwards** – ограничивает количество прокси (по умолчанию 70).  

### **Важные опциональные заголовки**  
- **Allow** – поддерживаемые методы (например, `Allow: INVITE, ACK, BYE`).  
- **Content-Type** – тип данных в теле (обычно `application/sdp`).  
- **Expires** – время жизни регистрации/подписки (в секундах).  
- **Route** – принудительный маршрут через прокси.  
- **Record-Route** – запись маршрута для обратного пути.  
- **Authorization/Proxy-Authorization** – данные аутентификации.  

---

## **2. SDP (Session Description Protocol)**  
SDP описывает параметры медиасеанса (аудио, видео, кодеков, IP-адресов и портов). Передается в теле SIP-сообщений (обычно в **INVITE** и **200 OK**).  

### **Формат SDP**  
```  
v=0  // Версия SDP  
o=alice 2890844526 2890844526 IN IP4 192.0.2.1  // Идентификатор сессии  
s=Разговор с Бобом  // Название сессии  
c=IN IP4 192.0.2.1  // IP-адрес для медиа  
t=0 0  // Время активности (0 = бесконечно)  
m=audio 49170 RTP/AVP 0 96  // Медиа: аудио, порт, RTP/AVP, кодеки  
a=rtpmap:0 PCMU/8000  // Кодек 0 (PCMU, 8 kHz)  
a=rtpmap:96 opus/48000/2  // Кодек 96 (Opus, 48 kHz, 2 канала)  
```  

### **Ключевые поля**  
- **`m=` (media)** – тип медиа, порт, протокол, кодеки.  
  - `m=audio 5004 RTP/AVP 0` → аудио, порт 5004, RTP с кодеком PCMU (0).  
- **`a=` (attribute)** – дополнительные параметры:  
  - `a=rtpmap:0 PCMU/8000` → сопоставление кода RTP с кодеком.  
  - `a=sendrecv` / `a=recvonly` / `a=inactive` – направление медиа.  
- **`c=` (connection)** – IP-адрес для медиапотока.  

---

## **3. NAT-проблемы в SIP**  
NAT (Network Address Translation) вызывает сложности в SIP-коммуникации, так как:  
- **SIP сигнализация** содержит IP-адреса в заголовках (`Contact`, `Via`, SDP `c=`), которые могут быть приватными.  
- **RTP-медиапотоки** могут блокироваться NAT, если нет проброса портов.  

### **Основные проблемы**  
1. **Недоступность UA за NAT**  
   - SIP-пакеты уходят на публичный IP, но ответы не доходят, так как приватный IP не маршрутизируется.  
2. **Неправильные адреса в SDP**  
   - UA указывает локальный IP (`192.168.1.100`), но внешний сервер не может до него достучаться.  
3. **Однонаправленный RTP**  
   - Один из абонентов не получает медиа из-за блокировки NAT.  

### **Решения**  
#### **1. STUN (Session Traversal Utilities for NAT)**  
- Позволяет клиенту узнать свой **публичный IP и порт** через внешний STUN-сервер.  
- Пример ответа STUN:  
  ```  
  MAPPED-ADDRESS: 93.184.216.34:5060  
  ```  
- Используется в SDP:  
  ```  
  c=IN IP4 93.184.216.34  
  m=audio 5060 RTP/AVP 0  
  ```  

#### **2. TURN (Traversal Using Relays around NAT)**  
- Если NAT симметричный, STUN не поможет – требуется ретранслятор.  
- TURN-сервер пересылает медиатрафик, но добавляет задержку.  

#### **3. ICE (Interactive Connectivity Establishment)**  
- Комбинирует STUN и TURN, автоматически выбирая лучший маршрут.  
- В SDP добавляются `a=candidate` строки с альтернативными адресами.  

#### **4. SIP ALG (Application Layer Gateway)**  
- NAT-роутер может "исправлять" SIP-пакеты, подменяя приватные IP на публичные.  
- **Проблема:** часто работает некорректно, ломая SIP.  

#### **5. Outbound Proxy (или SIP-прокси с фиксированным NAT)**  
- Весь трафик идет через прокси, который знает, как доставить пакеты.  

-------------------

### **Как узнать внешний IP-адрес через STUN**  

STUN (Session Traversal Utilities for NAT) — это протокол, позволяющий устройству за NAT определить свой **внешний (публичный) IP-адрес и порт**, которые видны из интернета. Это критически важно для работы VoIP, WebRTC и других P2P-технологий.  



## **1. Принцип работы STUN**  
1. **Клиент** (например, SIP-телефон) отправляет запрос на **STUN-сервер** (например, `stun.l.google.com:19302`).  
2. **STUN-сервер** анализирует входящий запрос и возвращает клиенту его **публичный IP и порт**, которые он "видит".  
3. Клиент использует эти данные в **SIP/SDP** для корректной маршрутизации медиатрафика.  


## **2. Как узнать внешний IP через STUN**  

### **Способ 1: Использование публичных STUN-серверов**  
Можно вручную отправить STUN-запрос с помощью утилит или онлайн-сервисов.  

#### **Примеры публичных STUN-серверов:**  
- `stun.l.google.com:19302` (Google)  
- `stun1.l.google.com:19302`  
- `stun.voipbuster.com`  
- `stun.stunprotocol.org`  

#### **Как проверить через python скрипт:** 
```python
#!/usr/bin/python3

import stun

# Задайте ручной выбор STUN-сервера
stun_host = 'stun.l.google.com'
stun_port = 19302

external_ip = stun.get_ip_info()[1]
print(f"Внешний IP адрес: {external_ip}")
```


#### **Как проверить через `curl` (если сервер поддерживает HTTP-запросы):**  
```bash
curl -s https://api.ipify.org  # Альтернатива: просто узнать внешний IP без STUN
# или
curl ifconfig.me ; echo
# или
dig +short myip.opendns.com @resolver1.opendns.com
```  
Но это не STUN, а просто HTTP-запрос.  

#### **Использование `stunclient` (Python)**  
Установка библиотеки:  
```bash
pip install pystun3
```  
Запуск:  
```bash
python -m stun
```  
Вывод:  
```
NAT Type: Restricted Cone
External IP: 93.184.216.34
External Port: 54321
```



### **Способ 2: Через Wireshark (анализ STUN-трафика)**  
1. Запустите **Wireshark**.  
2. Отфильтруйте трафик по `stun`.  
3. Найдите ответ от STUN-сервера с полем **`XOR-MAPPED-ADDRESS`** – это ваш внешний IP и порт.  



### **Способ 3: Использование JavaScript (WebRTC)**  
Браузеры используют STUN для WebRTC. Пример кода:  
```javascript
const pc = new RTCPeerConnection({
  iceServers: [{ urls: "stun:stun.l.google.com:19302" }]
});

pc.createDataChannel("test");
pc.onicecandidate = (e) => {
  if (e.candidate) {
    console.log("Public IP:", e.candidate.address);
  }
};
pc.createOffer().then(offer => pc.setLocalDescription(offer));
```
Вывод в консоли:  
```
Public IP: 93.184.216.34
```



## **3. Формат STUN-запроса и ответа**  
### **Запрос (STUN Binding Request)**  
```
0x0001 (Binding Request)  
0x0000 (Message Length)  
0x2112A442 (Magic Cookie)  
Transaction ID: [12 случайных байт]  
```  

### **Ответ (STUN Binding Response)**  
```
0x0101 (Binding Response)  
0x000C (Message Length = 12 байт)  
0x2112A442 (Magic Cookie)  
Transaction ID: [такой же, как в запросе]  
XOR-MAPPED-ADDRESS: 93.184.216.34:54321  
```  



## **4. Когда STUN не поможет?**  
- **Симметричный NAT** – сервер видит разные порты для каждого подключения.  
- **Двойной NAT** – сложные корпоративные сети.  
- **Блокировка STUN** – некоторые провайдеры блокируют STUN-трафик.  

В таких случаях используется **TURN** или **ICE**.  




