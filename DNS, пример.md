### Проверка работоспособности DNS сервера с использованием `nslookup` и `dig`

```bash
; /var/named/master/st107.upscale.croc
; Файл прямой зоны DNS
$TTL 86400
@ IN SOA dc1.st107.upscale.org. admin.st107.upscale.org. (
    2024050101 ; Serial
    3600       ; Refresh
    1800       ; Retry
    604800     ; Expire
    86400 )    ; Minimum TTL

@ IN NS dc1.st107.upscale.org.

; IPv4 адреса DNS серверов
router1             IN A 192.168.107.254 ; router1.st107.upscale.croc

; А-ресурсы (IP-адреса хосты)
dc1.st107.upscale.croc.                     IN      A 192.168.107.10       ; main DNS

; SRV запись для службы LDAP
;_ldap._tcp      IN SRV 0 1 389 ldapserver.mycorp.com.

; Каноническое имя (CNAME)
;ftp-www         IN CNAME www

; Mail Exchange (MX) запись для почты
;@               IN MX 10 mail.mycorp.com.
;
```

```bash
; /var/named/master/107.168.192.in-addr.arpa
; Файл обратной зоны DNS для 192.168.107.*
$TTL 86400
@ IN SOA dc1.st107.upscale.org. admin.st107.upscale.org. (
    2024050101 ; Serial
    3600       ; Refresh
    1800       ; Retry
    604800     ; Expire
    86400 )    ; Minimum TTL

@ IN NS dc1.st107.upscale.org.

; PTR record for reverse lookup of IP address 192.168.107.10
10 IN PTR dc1.st107.upscale.croc.
254 IN PTR router1.st107.upscale.croc.
15  IN PTR cbcontroller1.st107.upscale.croc.
11  IN PTR storage.st107.upscale.croc.
```

#### Настроенные зоны:
1. Прямая зона (`st107.upscale.croc`)
   - Сервер имен (`NS`): **dc1.st107.upscale.org**
   - Хост-записи (`A`):
     * **dc1**: 192.168.107.10
     * **router1**: 192.168.107.254

2. Обратная зона (`107.168.192.in-addr.arpa`)
   - Сервер имен (`NS`): **dc1.st107.upscale.org**
   - Записи обратного преобразования (`PTR`):
     * **10**: **dc1.st107.upscale.croc**  
     * **254**: **router1.st107.upscale.croc**  
     * **15**: **cbcontroller1.st107.upscale.croc**  
     * **11**: **storage.st107.upscale.croc**

---

### Инструкция проверки

Используем две утилиты — `nslookup` и `dig`, обе работают аналогично, однако `dig` предоставляет больше подробностей.

#### Использование команды `nslookup`

##### Шаг 1: Простое использование для прямой записи (DNS-преобразования имени в IP)
```bash
# Получение IP адреса для доменного имени
nslookup dc1.st107.upscale.croc
```
Ожидаемый вывод:
```
Server:		dc1.st107.upscale.org
Address:	192.168.107.10#53

Name:	dc1.st107.upscale.croc
Address: 192.168.107.10
```

##### Шаг 2: Проведение обратного DNS-преобразования (из IP обратно в имя)
```bash
# Преобразование IP адреса в имя хостинга
nslookup 192.168.107.10
```
Ожидаемый вывод:
```
Server:		dc1.st107.upscale.org
Address:	192.168.107.10#53

10.107.168.192.in-addr.arpa	name = dc1.st107.upscale.croc.
```

#### Использование команды `dig`

##### Шаг 1: Проверка прямого разрешения доменных записей
```bash
# Проверяем прямое разрешение имени
dig @dc1.st107.upscale.org dc1.st107.upscale.croc +short
```
Ожидаемый вывод:
```
192.168.107.10
```

##### Шаг 2: Проверка обратного разрешения адресов
```bash
# Проверяем обратное преобразование IP
dig @dc1.st107.upscale.org -x 192.168.107.10 +short
```
Ожидаемый вывод:
```
dc1.st107.upscale.croc.
```

---

### Итоги проверок:

| Тип проверки | Команда                          | Ожидаемый результат                  |
|--------------|---------------------------------|---------------------------------------|
| Прямой DNS   | `nslookup dc1.st107.upscale.croc`   | 192.168.107.10                         |
| Обратный DNS | `nslookup 192.168.107.10`           | dc1.st107.upscale.croc                |
| Direct with Dig | `dig @dc1.st107.upscale.org dc1.st107.upscale.croc +short` | 192.168.107.10              |
| Reverse with Dig | `dig @dc1.st107.upscale.org -x 192.168.107.10 +short` | dc1.st107.upscale.croc          |

Эти тесты позволят убедиться, что ваш DNS-сервер правильно разрешает имена и обратные запросы, обеспечивая стабильную работу инфраструктуры сети.
