Для правильной настройки прямой DNS зоны важно понимать назначение каждой записи SOA (Start of Authority), особенно если речь идет о закрытой сети (закрытом контуре). Давайте рассмотрим этот процесс подробно.

### Шаги по созданию прямой DNS-зоны

#### 1. **Создание файла зоны**
   Прямая зона DNS описывает сопоставление имен хостов IP адресам внутри домена (например, `example.local`).
   
   Файл зоны создается вручную либо автоматически сервером DNS. Обычно файлы зон находятся в директории `/var/named/`, `/etc/bind/zones/` или аналогичной зависимости от операционной системы и используемого программного обеспечения DNS сервера (BIND, PowerDNS и др.).

#### 2. **Формат записей SOA**
   Каждая прямая зона должна содержать запись Start Of Authority (`SOA`), которая является первой записью в файле зоны. Запись SOA включает ключевые параметры, влияющие на работу DNS:

```
@ IN SOA ns.example.local. admin.example.local. (
     serial_number      ; Серийный номер зоны
     refresh_interval   ; Интервал обновления (секунды)
     retry_interval     ; Повтор попытки обновления (секунды)
     expire_time        ; Время устаревания (секунды)
     minimum_ttl        ; Минимальное TTL (секунды)
 )
```

Рассмотрим каждый параметр подробнее:

##### a. **Серийный номер**  
Этот номер используется для отслеживания изменений в зоне. Каждый раз, когда вносятся изменения в зону, серийный номер увеличивается (обычно добавляют единицу или используют дату-время вида ГГММДДХХ). Если вторичный сервер видит больший серийный номер — он инициирует обновление своей копии зоны.
Пример значения: `2023080701`

##### b. **Интервал обновления (Refresh Interval)**  
Время, спустя которое подчинённые DNS-серверы проверяют наличие обновлений зоны у первичного сервера.
Рекомендуемое значение: 3600 секунд (1 час).

##### c. **Интервал повторной попытки (Retry Interval)**  
Интервал между попытками обновить зону, если первая попытка завершилась неудачей.
Рекомендуемое значение: 600 секунд (10 минут).

##### d. **Срок устаревания (Expire Time)**  
Максимально допустимый срок хранения кэшированной версии зоны на вторичных серверах, если первичный сервер недоступен.
Рекомендуемое значение: 1209600 секунд (2 недели).

##### e. **Минимальный TTL (Minimum TTL)**  
Указывает минимальное время жизни ресурсных записей в кэше рекурсивных DNS серверов.
Рекомендуемое значение: 3600 секунд (1 час).

Таким образом, примерная правильная запись SOA выглядит следующим образом:
```bash
@       IN      SOA     ns.example.local. admin.example.local. (
                                2023080701              ; Serial number
                                3600                    ; Refresh interval
                                600                     ; Retry interval
                                1209600                 ; Expire time
                                3600 )                  ; Minimum TTL
```

---

#### 3. Дополнительные типы записей (NS, A, CNAME, MX и другие)
Помимо SOA-записи, в файл зоны также включаются следующие записи:

- NS (Name Server) — список авторитетных DNS-серверов данной зоны.
- A (Address Record) — IP адреса конкретных хоста.
- PTR (Pointer Record) — обратные разрешения IP → имя хоста (используется редко в закрытых сетях).
- CNAME (Canonical Name) — псевдоним имени хоста.
- MX (Mail Exchanger) — почта для домена (при наличии почтовых сервисов).

Пример дополнительной части файла зоны:
```bash
ns.example.local.          IN      A       192.168.1.10
www.example.local.         IN      A       192.168.1.11
mail.example.local.        IN      A       192.168.1.12
ftp.example.local.         IN      CNAME   www.example.local.
```
---

Вот конкретные примеры записей SOA (Start of Authority) для различных типов сетей и организаций, включая частные корпоративные сети и публичные сервисы.

---

### Пример №1: Локальная сеть предприятия (частная зона `.local`)

Предположим, у вас имеется локальная внутренняя сеть с доменом `company.local`. Настроив внутренний DNS сервер, вы хотите обеспечить быструю синхронизацию и минимальные задержки при обращении к ресурсам сети.

Фрагмент файла зоны:
```bash
$TTL 3600       ; Default TTL for records in this zone
company.local.  IN SOA ns.company.local. hostmaster.company.local. (
                           2023080701     ; Serial Number
                           3600           ; Refresh every hour
                           600            ; Retry after 10 minutes if failed
                           1209600        ; Zone expires after two weeks
                           3600 )         ; Minimal caching period is one hour
```

---

### Пример №2: Облачная инфраструктура провайдера услуг (public cloud provider)

Допустим, ваш бизнес размещён в облаке крупной IT-компании (например, Яндекс.Облако), и вы настраиваете внешний DNS для публичных облачных сервисов (домен `cloud.example.com`):

Фрагмент файла зоны:
```bash
$TTL 3600       ; Default TTL for records in this zone
cloud.example.com. IN SOA ns1.cloud.example.com. dnsadmins@example.com. (
                             2023080702     ; Serial Number
                             7200           ; Check updates every 2 hours
                             900            ; Retry check every 15 minutes
                             604800         ; If unreachable, stop checking after week
                             3600 )         ; Cache at least an hour
```

---

### Пример №3: Открытая публичная зона крупного сайта (.com)

Например, сайт `mycorp.com` принадлежит крупной международной организации, имеющей большое количество географически распределённых офисов и пользователей.

Фрагмент файла зоны:
```bash
$TTL 3600       ; Default TTL for records in this zone
mycorp.com.     IN SOA ns1.mycorp.com. rootdns@mycorp.com. (
                              2023080703     ; Serial Number
                              86400           ; Update once per day
                              7200            ; Retry update after 2 hours
                              2419200         ; Stop trying to sync after month
                              3600 )          ; Minimum cache time is 1 hour
```

---

### Важные моменты при настройке SOA:

- **Serial Number**: Всегда увеличивайте этот номер при изменении любой записи зоны. Рекомендуется использовать форматы типа ГГММДДХХ для простоты понимания дат внесения правок.
- **Timestamps**: Интервалы вроде `refresh`, `retry`, и `expire` зависят от размера вашей сети и частоты изменений конфигурации. Чем чаще меняется информация, тем короче интервалы рекомендуется ставить.
- **Email Contact**: Адрес администратора DNS указывается в формате `hostmaster.company.local.` (точка обязательна в конце строки). Используйте подходящий контактный email или идентификатор администраторов DNS.

Ниже представлен полный образец конфигурационного файла зоны DNS для BIND, одного из наиболее популярных DNS-серверов. Этот файл демонстрирует структуру с примером всех основных типов записей (включая SOA, NS, A, CNAME, MX и дополнительные элементы).

---

### Образец полного конфигурационного файла DNS

```c
; Конфигурационный файл зоны mycorp.com
; Использует стандартную схему и соглашения DNS BIND

$ORIGIN mycorp.com.
$TTL 3600      ; Значение по умолчанию для TTL (в секундах)

; Рекорд SOA (Start of Authority)
@               IN SOA ns1.mycorp.com. dnsadmins@mycorp.com. (
                            2023080701  ; Серийный номер зоны
                            86400        ; Период проверки обновления (раз в сутки)
                            7200         ; Период повторной попытки (каждый два часа)
                            2419200      ; Максимальное время устаревания (месяц)
                            3600 )       ; Минимальный период кеширования (час)

; Имя серверов DNS (Authoritative Nameservers)
@               IN NS ns1.mycorp.com.
@               IN NS ns2.mycorp.com.

; IPv4 адреса DNS серверов
ns1             IN A 192.168.1.10
ns2             IN A 192.168.1.11

; А-ресурсы (IP-адреса хосты)
www             IN A 192.168.1.12
mail            IN A 192.168.1.13
ftp             IN A 192.168.1.14

; Каноническое имя (CNAME)
ftp-www         IN CNAME www

; Mail Exchange (MX) запись для почты
@               IN MX 10 mail.mycorp.com.

; SPF запись для отправки писем (RFC 7208)
@               IN TXT "v=spf1 mx ~all"

; SRV запись для службы LDAP
_ldap._tcp      IN SRV 0 1 389 ldapserver.mycorp.com.

; Точка завершения DKIM подписи (для подписывания электронной почты)
default._domainkey IN TXT "v=DKIM1; k=rsa; p=MIGfMA0GCSq..."

; PGP ключ владельца зоны (опционально)
pgp-key         IN TXT "BEGIN PGP PUBLIC KEY BLOCK\n...\nEND PGP PUBLIC KEY BLOCK"

; Обратная зона для PTR записей (необязательно, если потребуется обратный DNS)
1.168.192.in-addr.arpa. IN PTR www.mycorp.com.

; Запрет доступа к внешним данным (DNSEC NSEC3 record, зависит от реализации)
mycorp.com.     IN NSEC3PARAM 1 0 1 1D48AEC3BCDEF67FEBAFAEEDBDAC94DABDADFEEB

; END OF ZONE FILE
```

---

### Что означает каждая строка?

- `$ORIGIN`: Устанавливает корень текущего доменного пространства (название зоны).
- `$TTL`: Значение по умолчанию для продолжительности жизни (Time To Live) всех записей в данном файле зоны.
- `IN SOA`: Основная запись авторитета, определяющая статус зоны и ответственное лицо.
- `IN NS`: Авторитетные DNS серверы, обслуживающие данную зону.
- `IN A`: Соответствие имени хоста IP адресу.
- `IN CNAME`: Псевдоним другого ресурса.
- `IN MX`: Почта отправляется на указанный сервер (чем меньше число приоритета, тем предпочтительнее сервер).
- `IN TXT`: Тексты различной природы (SPF, DKIM, произвольные данные).
- `IN SRV`: Информация о службе (например, LDAP, Kerberos).
- `IN PTR`: Используется для обратной зоны DNS (преобразование IP в имя).
- `NSEC3PARAM`: Параметры безопасности DNSSEC (если применяется).

---

Файл `/etc/named.conf` — основной конфигурационный файл DNS-сервера BIND, содержащий глобальные настройки и инструкции для управления зонами. Чтобы корректно задать правила обработки запросов и добавить ваши собственные зоны, нужно следовать определённым правилам.

### Как правильно прописывать зоны DNS в файле `/etc/named.conf`

Зона DNS задаётся двумя основными способами:

1. **Прямые зоны:** Определяют прямое разрешение имен (имя → IP).
2. **Обратные зоны:** Преобразуют IP обратно в имена (IP → имя).

Каждая зона состоит из нескольких ключевых элементов:

- **Тип зоны:** Primary (первичная), Secondary (вторичная), Master (главная), Slave (подчинённая).
- **Имя зоны:** Полностью квалифицированное доменное имя (например, `example.com.`).
- **Файл зоны:** Физический путь к файлу, содержащему сведения о зонах.

---

### Основные блоки для добавления зон в `/etc/named.conf`

#### 1. Определение главной (Primary) зоны:
```bash
zone "example.com." {
    type master;
    file "/var/named/db.example.com";
};
```
Здесь:
- `"example.com."` — название зоны (обратите внимание на точку в конце).
- `type master;` — указывает, что эта зона главная.
- `file "/var/named/db.example.com";` — расположение файла зоны.

#### 2. Определение подчинённой (Secondary/Slave) зоны:
```bash
zone "example.com." {
    type slave;
    masters { 192.168.1.10; };
    file "/var/named/slaves/db.example.com";
};
```
Здесь:
- `masters { 192.168.1.10; };` — IP главного DNS-сервера, откуда будут загружаться данные.
- `/var/named/slaves/db.example.com` — файл зоны на подчинённом сервере.

#### 3. Определение reverse-zone (обратная зона):
```bash
zone "1.168.192.in-addr.arpa." {
    type master;
    file "/var/named/db.192.168.1";
};
```
Здесь:
- `"1.168.192.in-addr.arpa."` — обозначает обратную зону для диапазона IP-адресов класса C (например, 192.168.1.xx).

---

### Общий пример полноценного файла `/etc/named.conf`

```c
// named.conf
options {
    directory "/var/named";                // Директория расположения файлов зон
    allow-recursion {"localhost";};        // Разрешить рекурсию только для localhost
    listen-on port 53 { any; };            // Слушаем запросы на любом интерфейсе
    forwarders { 8.8.8.8; 8.8.4.4; };     // Форвардеры (Google DNS)
};

acl internal_network { 192.168.1.0/24; }; // Внутренняя сеть

logging {
    channel default_log {
        file "/var/log/named.log" versions 3 size 10m;
        severity info;
        print-time yes;
    };
    category default { default_log; };
};

view "internal" {
    match-clients { internal_network; };
    recursion yes;

    zone "." {
        type hint;
        file "named.ca";
    };

    // Пример первичной зоны
    zone "example.com." {
        type master;
        file "/var/named/db.example.com";
    };

    // Пример подчиненной зоны
    zone "test.net." {
        type slave;
        masters { 192.168.1.10; };
        file "/var/named/slaves/db.test.net";
    };

    // Пример обратной зоны
    zone "1.168.192.in-addr.arpa." {
        type master;
        file "/var/named/db.192.168.1";
    };
};

view "external" {
    match-clients { any; };
    recursion no;

    zone "." {
        type hint;
        file "named.ca";
    };

    // Внешний доступ ограничен минимумом информации
    zone "example.com." {
        type master;
        file "/var/named/db.external.example.com";
    };
};
```

---

### Объяснение содержимого файла:

- **Options block**: Общие настройки сервера, такие как каталог размещения файлов зон, разрешенные форвардеры, сетевые ограничения.
- **ACL (Access Control List)**: Список клиентов, которым разрешено обращаться к DNS сервису.
- **Logging**: Логирование событий DNS сервера.
- **Views**: Разделение доступности зон для разных классов клиентов (локальных и внешних).
- **Zone definitions**: Описание зон (примеры primary, secondary и reverse).

---

### Рекомендации по безопасности:

- Избегайте открытого предоставления чувствительной информации через внешние view (ограничивайте виды доступной информации для внешнего мира).
- Регулярно проверяйте журналы DNS для выявления подозрительных действий.
- Используйте защищённый протокол DNSSEC, если важна целостность передаваемых данных.

Следуя этому шаблону, вы сможете грамотно организовать свою DNS-инфраструктуру с точки зрения производительности, безопасности и удобства поддержки.

---------
```
Как исправить ошибку DNS сервера

May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: /var/named/master/st107.upscale.croc:7: ignoring out-of-zone data (st107.upscale.croc)
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: /var/named/master/st107.upscale.croc:16: ignoring out-of-zone data (st107.upscale.croc)
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: /var/named/master/st107.upscale.croc:19: ignoring out-of-zone data (dc1.st107.upscale.croc)
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: /var/named/master/st107.upscale.croc:22: ignoring out-of-zone data (st107router1)
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: zone st107.upscale.org/IN: has 0 SOA records
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: zone st107.upscale.org/IN: has no NS records
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: zone st107.upscale.org/IN: not loaded due to errors.
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: _default/st107.upscale.org./IN: bad zone
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: zone localhost.localdomain/IN: loaded serial 0
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: zone localhost/IN: loaded serial 0
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: zone 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa/IN: loaded serial 0
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: zone 1.0.0.127.in-addr.arpa/IN: loaded serial 0
May 01 15:56:17 dc1.st107.upscale.croc bash[1517]: zone 0.in-addr.arpa/IN: loaded serial 0
May 01 15:56:17 dc1.st107.upscale.croc systemd[1]: named.service: Control process exited, code=exited, status=1/FAILURE
```

Ошибка в вашем DNS-сервере (BIND/named) связана с некорректной конфигурацией зоны `st107.upscale.org`. Вот основные проблемы и способы их исправления:

### Основные проблемы:
1. **Несоответствие доменных имен**: В логах видно, что файл зоны называется `st107.upscale.croc`, но сервер пытается загрузить зону `st107.upscale.org`.
2. **Отсутствие обязательных записей**: 
   - Нет SOA-записи (Start of Authority)
   - Нет NS-записей (Name Server)
3. **"Ignoring out-of-zone data"**: Записи в файле зоны относятся к доменам, которые не являются поддоменами основной зоны.

### Как исправить:

1. **Проверьте имя зоны в конфигурации**:
   Убедитесь, что в файле конфигурации named (обычно `/etc/named.conf`) имя зоны указано правильно:
   ```
   zone "st107.upscale.org" {
       type master;
       file "/var/named/master/st107.upscale.croc"; // или исправьте на правильное имя файла
   };
   ```

2. **Проверьте файл зоны** (`/var/named/master/st107.upscale.croc`):
   - Убедитесь, что в начале файла есть обязательные записи SOA и NS:
     ```
     $TTL 86400
     @ IN SOA dc1.st107.upscale.org. admin.st107.upscale.org. (
         2024050101 ; Serial
         3600       ; Refresh
         1800       ; Retry
         604800     ; Expire
         86400 )    ; Minimum TTL
     
     @ IN NS dc1.st107.upscale.org.
     ```
   - Все записи должны быть либо полными доменными именами (FQDN), заканчивающимися точкой, либо относительными к текущей зоне.

3. **Проверьте согласованность имен**:
   - Если домен должен быть `st107.upscale.croc`, измените объявление зоны в named.conf
   - Если домен должен быть `st107.upscale.org`, переименуйте файл зоны или исправьте путь в named.conf

4. **Проверьте синтаксис**:
   После внесения изменений проверьте конфигурацию:
   ```bash
   named-checkconf
   named-checkzone st107.upscale.org /var/named/master/st107.upscale.croc
   ```

5. **Увеличьте serial number**:
   При каждом изменении зоны увеличивайте serial number в SOA-записи.

6. **Перезагрузите сервис**:
   ```bash
   systemctl restart named
   ```

### Дополнительные рекомендации:
- Убедитесь, что все имена в файле зоны либо заканчиваются точкой (FQDN), либо являются относительными к текущей зоне
- Проверьте права доступа к файлу зоны (обычно named должен иметь права на чтение)
- Проверьте логи после перезапуска (`journalctl -u named -f`)


