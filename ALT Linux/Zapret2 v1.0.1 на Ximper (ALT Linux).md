# 📗 **Инструкция: Установка и настройка Zapret2 v1.0.1 на Ximper Linux**

> **📅 Актуально на 13 июня 2026**  
> **✅ Проверенная рабочая стратегия:** `multisplit:pos=midsld:seqovl=5`  
> **📂 Важное примечание:** Конфиг находится в `/opt/zapret2/config`, а НЕ в `/etc/zapret2/config`!
>
> **https://github.com/bol-van/zapret2/releases/tag/v1.0.1**

---

## 🎯 **Что такое Zapret2 и зачем он нужен?**

**Zapret2** — это инструмент для обхода Deep Packet Inspection (DPI), который используют провайдеры для блокировки сайтов. Он работает по принципу "разрыва" пакетов таким образом, что DPI не может определить, к какому сайту обращается пользователь.

**Версия v1.0.1** — это современный релиз, который **значительно упростил установку** по сравнению с предыдущими версиями. Главное новшество — интерактивный установщик `install_easy.sh`, который автоматически:
- Определяет вашу систему (systemd/OpenRC)
- Настраивает правила nftables
- Создаёт systemd сервис
- Настраивает автоматическое обновление списков сайтов

**⚠️ ВАЖНОЕ ОТЛИЧИЕ ОТ СТАРЫХ ВЕРСИЙ:**
- В версии v1.0.1 **НЕ нужно вручную создавать правила nftables** — установщик делает всё сам
- **Конфигурационный файл** находится в `/opt/zapret2/config`, а не в `/etc/zapret2/config`
- **Список сайтов** (hostlist) хранится в `/opt/zapret2/ipset/zapret-hosts-user.txt`

---

## 📋 **1. Подготовка системы**

```bash
# Переключаемся на root
su -

# Обновляем список пакетов
epm update

# Устанавливаем необходимые компоненты
epmi nftables libnftnl lua5.3
```

**Что мы здесь делаем:**
- `su -` — переключение на root-пользователя (требуется для установки ПО)
- `epm update` — обновление кэша пакетов в ALT Linux (аналог `apt update`)
- `epmi` — установка пакетов (расшифровывается как `epm install`)

**Почему именно эти пакеты:**
- `nftables` — современный фреймворк для фильтрации пакетов (замена iptables)
- `libnftnl` — библиотека для работы с nftables из пользовательского пространства
- `lua5.3` — язык скриптования, используется в zapret для продвинутых стратегий обхода

---

## ⚙️ **2. Настройка параметров ядра**

```bash
# Временно применяем параметр
sudo sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1

# Делаем параметр постоянным
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" | sudo tee -a /etc/sysctl.conf
```

**Что делает этот параметр:**
- `net.netfilter.nf_conntrack_tcp_be_liberal=1` — разрешает ядру обрабатывать "нестандартные" TCP-пакеты
- Без этого параметра zapret может работать некорректно, так как его модифицированные пакеты могут быть отброшены
- Параметр сохраняется в `/etc/sysctl.conf` для применения после перезагрузки

---

## 📥 **3. Скачивание и установка Zapret2**

```bash
# Переходим в директорию загрузок
cd ~/Загрузки/

# Скачиваем последнюю версию (v1.0.1)
wget https://github.com/bol-van/zapret2/releases/download/v1.0.1/zapret2-v1.0.1.tar.gz

# Распаковываем в /opt (стандартное место для стороннего ПО)
sudo tar -xzf zapret2-v1.0.1.tar.gz -C /opt/

# Переименовываем для удобства (установщик требует именно /opt/zapret2)
sudo mv /opt/zapret2-v1.0.1 /opt/zapret2

# Удаляем архив
sudo rm zapret2-v1.0.1.tar.gz
```

**Почему именно `/opt/zapret2`:**
- Установщик `install_easy.sh` проверяет путь и требует, чтобы программа была в `/opt/zapret2`
- Это стандарт FHS (Filesystem Hierarchy Standard) для стороннего ПО

---

## 🚀 **4. Запуск интерактивного установщика**

```bash
cd /opt/zapret2
sudo ./install_easy.sh
```

**Что делает установщик:**

Установщик последовательно проверяет систему и задаёт вопросы. Вот **оптимальные ответы для Ximper Linux**:

### **Вопрос 1: Тип файрвола**
```
select firewall type :
1 : iptables
2 : nftables
your choice (default : nftables) : 2
```
**Выбираем nftables**, так как это современный стандарт.

### **Вопрос 2: Включение IPv6**
```
enable ipv6 support (default : N) (Y/N) ? 
```
**Нажимаем Enter** (оставляем N). IPv6 часто не нужен для обхода DPI и может создавать проблемы.

### **Вопрос 3: Flow offloading**
```
select flow offloading :
1 : none
2 : software
3 : hardware
your choice (default : none) :
```
**Оставляем `none`** — offloading нужен только на роутерах с медленным процессором.

### **Вопрос 4: Метод фильтрации (ВАЖНО!)**
```
select filtering :
1 : none
2 : ipset
3 : hostlist
4 : autohostlist
your choice (default : none) : 3
```
**Выбираем `3` (hostlist)** — это позволяет обрабатывать только заблокированные сайты из списка, экономя ресурсы.

**Почему не `none`:**
- `none` — zapret будет обрабатывать ВЕСЬ трафик (очень ресурсоёмко)
- `hostlist` — только сайты из списка (оптимально для домашнего ПК)

### **Вопрос 5: Включение nfqws2**
```
enable nfqws2 ? (default : Y) (Y/N) ? Y
```
**Оставляем Y** — nfqws2 это основной компонент zapret.

### **Вопрос 6: Редактирование опций**
```
do you want to edit the options (default : N) (Y/N) ? Y
```
**Вводим Y** — чтобы настроить стратегию обхода.

### **Редактирование стратегии**
Когда откроется редактор, находим строку:
```bash
NFQWS2_OPT="
--filter-tcp=80 --filter-l7=http <HOSTLIST> 
--payload=http_req --lua-desync=fake:blob=fake_default_http:tcp_md5 --lua-desync=multisplit:pos=method+2 
--new --filter-tcp=443 --filter-l7=tls <HOSTLIST> 
--payload=tls_client_hello --lua-desync=fake:blob=fake_default_tls:tcp_md5:tcp_seq=-10000 --lua-desync=multidisorder:pos=1,midsld 
--new --filter-udp=443 --filter-l7=quic <HOSTLIST_NOAUTO> 
--payload=quic_initial --lua-desync=fake:blob=fake_default_quic:repeats=6 "
```

**Заменяем ВСЁ это на простую рабочую стратегию:**
```bash
NFQWS2_OPT="--filter-tcp=443 --filter-l7=tls --payload=tls_client_hello --lua-desync=multisplit:pos=midsld:seqovl=5"
```

**Что означает эта стратегия:**
- `--filter-tcp=443` — обрабатываем только HTTPS трафик (порт 443)
- `--filter-l7=tls` — фильтруем по протоколу TLS (SSL-сертификаты)
- `--payload=tls_client_hello` — модифицируем именно Client Hello (первый пакет TLS)
- `--lua-desync=multisplit:pos=midsld:seqovl=5` — разрываем SNI (Server Name Indication) посередине домена второго уровня (например, `yout` | `ube.com`)

### **Вопрос 7: LAN/WAN интерфейсы**
```
LAN interface : (default : NONE) 
WAN interface : (default : ANY)
```
**Оставляем по умолчанию** — для домашнего ПК не требуется.

### **Вопрос 8: Автоматическая загрузка списков**
```
do you want to auto download ip/host list (default : N) (Y/N) ? Y
1 : get_refilter_domains.sh
2 : get_antizapret_domains.sh
3 : get_reestr_resolvable_domains.sh
your choice (default : get_antizapret_domains.sh) : 2
```
**Выбираем `2`** — `antizapret` содержит самый полный список заблокированных сайтов.

---

## 🔍 **5. Проверка результатов установки**

### **Проверяем статус сервиса:**
```bash
sudo systemctl status zapret2
```
**Ожидаемый вывод:** `active (running)`

### **Проверяем конфигурационный файл:**
```bash
# Конфиг находится ЗДЕСЬ, а не в /etc/zapret2/
cat /opt/zapret2/config | grep NFQWS2_OPT
```

**Ожидаемый вывод:**
```bash
NFQWS2_OPT="--filter-tcp=443 --filter-l7=tls --payload=tls_client_hello --lua-desync=multisplit:pos=midsld:seqovl=5"
```

### **Проверяем правила nftables (создаются автоматически!):**
```bash
# Смотрим все таблицы
sudo nft list tables

# Смотрим конкретную таблицу zapret2
sudo nft list table inet zapret2
```

**Пример вывода (важно!):**
```nft
table inet zapret2 {
        set zapret {
                type ipv4_addr
                size 522288
                flags interval
                auto-merge
        }

        set ipban {
                type ipv4_addr
                size 522288
                flags interval
                auto-merge
        }

        set nozapret {
                type ipv4_addr
                size 65536      # count 6
                flags interval
                auto-merge
                elements = { 10.0.0.0/8, 100.64.0.0/10,
                             127.0.0.0/8, 169.254.0.0/16,
                             172.16.0.0/12, 192.168.0.0/16 }
        }

        set wanif {
                type ifname
        }

        set wanif6 {
                type ifname
        }

        set lanif {
                type ifname
        }

        chain forward_hook {
                type filter hook forward priority filter - 1; policy accept;
        }

        chain flow_offload {
        }

        chain flow_offload_zapret {
        }

        chain flow_offload_always {
        }

        chain postrouting {
        }

        chain postrouting_hook {
                type filter hook postrouting priority srcnat - 1; policy accept;
        }

        chain postnat {
                meta nfproto ipv4 udp dport 443 ct original packets 1-5 meta mark set meta mark | 0x20000000 ct mark set ct mark | 0x40000000 queue flags bypass to 300
                meta nfproto ipv4 tcp dport { 80, 443 } ct original packets 1-20 meta mark set meta mark | 0x20000000 ct mark set ct mark | 0x40000000 queue flags bypass to 300
        }

        chain postnat_hook {
                type filter hook postrouting priority srcnat + 1; policy accept;
                meta mark & 0x40000000 == 0x00000000 ip daddr != @nozapret jump postnat
        }

        chain prerouting {
        }

        chain prerouting_hook {
                type filter hook prerouting priority dstnat + 1; policy accept;
                icmp type time-exceeded ct state invalid drop
                icmp type time-exceeded ct mark & 0x40000000 != 0x00000000 drop comment "nfqws related : prevent ttl expired socket errors"
        }

        chain prenat_hook {
                type filter hook prerouting priority dstnat - 1; policy accept;
                meta mark & 0x40000000 == 0x00000000 ip saddr != @nozapret jump prenat
        }

        chain prenat {
                meta nfproto ipv4 udp sport 443 ct reply packets 1-3 ct mark set ct mark | 0x40000000 queue flags bypass to 300
                meta nfproto ipv4 tcp sport { 80, 443 } ct reply packets 1-10 ct mark set ct mark | 0x40000000 queue flags bypass to 300
        }

        chain predefrag {
                type filter hook output priority -401; policy accept;
                meta mark & 0x40000000 != 0x00000000 jump predefrag_nfqws comment "nfqws generated : avoid drop by INVALID conntrack state"
        }

        chain predefrag_nfqws {
                meta mark & 0x20000000 != 0x00000000 notrack comment "postnat traffic"
                ip frag-off & 0x1fff != 0x0 notrack comment "ipfrag"
                exthdr frag exists notrack comment "ipfrag"
                tcp flags ! syn,rst,ack notrack comment "datanoack"
        }

        chain ruletest {
        }
}
```

**Обратите внимание:** В v1.0.1 используется **queue 300** (не 200, как в старых версиях)!

### **Проверяем список сайтов (hostlist):**
```bash
# Где хранится список сайтов для обхода
cat /opt/zapret2/ipset/zapret-hosts-user.txt

# Сколько сайтов в списке
wc -l /opt/zapret2/ipset/zapret-hosts-user.txt
```

### **Проверяем работу YouTube:**
```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 3
```
**Ожидаемый вывод:** `HTTP/2 200` (быстрый ответ)

---

## 📂 **6. Где всё лежит: полная структура файлов**

| Что ищем | Где находится | Как посмотреть |
|----------|---------------|----------------|
| **Главный конфиг** | `/opt/zapret2/config` | `cat /opt/zapret2/config` |
| **Стратегия обхода** | В конфиге строка `NFQWS2_OPT` | `grep NFQWS2_OPT /opt/zapret2/config` |
| **Список доменов (hostlist)** | `/opt/zapret2/ipset/zapret-hosts-user.txt` | `cat /opt/zapret2/ipset/zapret-hosts-user.txt` |
| **Исключения** | `/opt/zapret2/ipset/zapret-hosts-user-exclude.txt` | `cat /opt/zapret2/ipset/zapret-hosts-user-exclude.txt` |
| **IP-адреса (сгенерированные)** | В nftables set `zapret` | `sudo nft list set inet zapret2 zapret` |
| **Правила nftables** | В памяти ядра | `sudo nft list table inet zapret2` |
| **Скрипт обновления списков** | `/opt/zapret2/ipset/get_antizapret_domains.sh` | `ls -la /opt/zapret2/ipset/get_*.sh` |
| **Скрипт создания IP** | `/opt/zapret2/ipset/create_ipset.sh` | `cat /opt/zapret2/ipset/create_ipset.sh` |
| **Исполняемый файл** | `/opt/zapret2/nfq2/nfqws2` | `file /opt/zapret2/nfq2/nfqws2` |
| **Systemd сервис** | `/usr/lib/systemd/system/zapret2.service` | `sudo systemctl cat zapret2` |
| **Логи** | Журнал systemd | `sudo journalctl -u zapret2 -f` |

---

## 🔍 **7. Как посмотреть стратегию обхода (Подробно)**

### **Способ 1: Прямой просмотр конфига**
```bash
# Показать всю строку с опциями
grep "^NFQWS2_OPT=" /opt/zapret2/config

# Только значение стратегии (без переменной)
grep "^NFQWS2_OPT=" /opt/zapret2/config | cut -d'"' -f2
```

### **Способ 2: Просмотр с цветом (если установлен ccat)**
```bash
ccat /opt/zapret2/config | grep NFQWS2_OPT --color=always
```

### **Способ 3: Подробный вывод с номерами строк**
```bash
cat -n /opt/zapret2/config | grep -A2 -B2 NFQWS2_OPT
```

---

## 📋 **8. Как посмотреть список сайтов (hostlist)**

**Важное пояснение:** В zapret2 v1.0.1 нет отдельного файла с именем `hostlist`. Список сайтов хранится в виде **доменных имён** в специальном файле, а затем преобразуется в **IP-адреса** для nftables.

### **Способ 1: Посмотреть исходные домены**
```bash
# Основной список доменов для обхода
cat /opt/zapret2/ipset/zapret-hosts-user.txt

# Посмотреть первые 10 доменов
head -10 /opt/zapret2/ipset/zapret-hosts-user.txt

# Посмотреть последние 10 доменов
tail -10 /opt/zapret2/ipset/zapret-hosts-user.txt
```

### **Способ 2: Посмотреть IP-адреса в nftables**
```bash
# IP-адреса, которые реально обрабатываются (сгенерированы из доменов)
sudo nft list set inet zapret2 zapret | head -30

# Только IP-адреса (без форматирования nft)
sudo nft -j list set inet zapret2 zapret | jq -r '.nftables[1].set.elem[].elem.val | if type=="string" then . else .[0] end' 2>/dev/null || \
sudo nft list set inet zapret2 zapret | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -20
```

### **Способ 3: Поиск конкретного сайта в списке**
```bash
# Ищем YouTube
grep -i "youtube" /opt/zapret2/ipset/zapret-hosts-user.txt

# Ищем Discord
grep -i "discord" /opt/zapret2/ipset/zapret-hosts-user.txt

# Ищем Telegram
grep -i "telegram" /opt/zapret2/ipset/zapret-hosts-user.txt
```

### **Способ 4: Статистика по спискам**
```bash
echo "=== СТАТИСТИКА СПИСКОВ ==="
echo "Доменов в основном списке: $(wc -l < /opt/zapret2/ipset/zapret-hosts-user.txt)"
echo "Доменов в исключениях: $(wc -l < /opt/zapret2/ipset/zapret-hosts-user-exclude.txt)"
echo "IP-адресов в nftables: $(sudo nft list set inet zapret2 zapret 2>/dev/null | grep -c '^[[:space:]]*[0-9]' || echo 0)"
```

---

## 🛠️ **9. Если список сайтов пустой (ручное создание)**

```bash
# Создаём базовый список самых популярных сайтов
sudo tee /opt/zapret2/ipset/zapret-hosts-user.txt << 'EOF'
youtube.com
youtu.be
googlevideo.com
ggpht.com
googleapis.com
discord.com
discord.gg
discordapp.com
telegram.org
t.me
web.telegram.org
twitter.com
x.com
facebook.com
instagram.com
whatsapp.com
spotify.com
netflix.com
twitch.tv
reddit.com
github.com
gitlab.com
cloudflare.com
cloudflare.net
EOF

# Проверяем
wc -l /opt/zapret2/ipset/zapret-hosts-user.txt
# Должно быть: 24

# Теперь нужно сгенерировать IP-адреса и загрузить в nftables
sudo systemctl restart zapret2
```

---

## 🎯 **10. Удобные скрипты для управления**

### **Скрипт быстрого запуска:**
```bash
sudo mcedit /usr/local/bin/zapret-on
```

```bash
#!/bin/bash
echo "🔄 Запускаем zapret..."
sudo systemctl start zapret2

sleep 2
if systemctl is-active --quiet zapret2; then
    echo "✅ Zapret успешно запущен"
    echo ""
    echo "📊 Текущая стратегия:"
    grep NFQWS2_OPT /opt/zapret2/config | cut -d'"' -f2
    echo ""
    echo "📊 Проверка YouTube:"
    curl -I https://www.youtube.com 2>/dev/null | head -n 1
else
    echo "❌ Ошибка запуска!"
    sudo journalctl -u zapret2 -n 10 --no-pager
fi
```

### **Скрипт быстрой остановки:**
```bash
sudo mcedit /usr/local/bin/zapret-off
```

```bash
#!/bin/bash
echo "🛑 Останавливаем zapret..."
sudo systemctl stop zapret2

if ! systemctl is-active --quiet zapret2; then
    echo "✅ Zapret остановлен"
    echo ""
    echo "📊 Проверка YouTube (должно быть медленно):"
    curl -I https://www.youtube.com 2>/dev/null | head -n 1
else
    echo "❌ Ошибка остановки!"
fi
```

### **Скрипт проверки статуса (расширенный):**
```bash
sudo mcedit /usr/local/bin/zapret-status
```

```bash
#!/bin/bash
echo "=== 📡 ZAPRET STATUS ==="
if systemctl is-active --quiet zapret2; then
    echo "✅ Сервис: РАБОТАЕТ"
    PID=$(pgrep -f nfqws2)
    echo "   PID процесса: $PID"
else
    echo "❌ Сервис: НЕ РАБОТАЕТ"
fi

echo ""
echo "=== ⚙️ ТЕКУЩАЯ СТРАТЕГИЯ ==="
grep "^NFQWS2_OPT=" /opt/zapret2/config | cut -d'"' -f2

echo ""
echo "=== 🔥 NFTABLES RULES ==="
if sudo nft list table inet zapret2 &>/dev/null; then
    echo "✅ Таблица zapret2 загружена"
    QUEUE_NUM=$(sudo nft list table inet zapret2 | grep -o "queue [^ ]* to [0-9]*" | head -1)
    echo "   Очередь: $QUEUE_NUM"
else
    echo "❌ Таблица zapret2 не найдена"
fi

echo ""
echo "=== 📋 СПИСКИ САЙТОВ ==="
if [ -f /opt/zapret2/ipset/zapret-hosts-user.txt ]; then
    DOMAINS=$(wc -l < /opt/zapret2/ipset/zapret-hosts-user.txt)
    echo "✅ Доменов в списке: $DOMAINS"
    
    # Показываем первые 5 сайтов
    echo "   Первые 5 сайтов:"
    head -5 /opt/zapret2/ipset/zapret-hosts-user.txt | sed 's/^/     - /'
else
    echo "❌ Список доменов отсутствует"
fi

echo ""
echo "=== 🎬 YOUTUBE TEST ==="
curl -I https://www.youtube.com 2>/dev/null | head -n 1

echo ""
echo "=== 📊 СТАТИСТИКА ПРОЦЕССА ==="
if systemctl is-active --quiet zapret2; then
    ps aux | grep nfqws2 | grep -v grep | awk '{print "   CPU: " $3 "%  MEM: " $4 "%  RSS: " $6 " KB"}'
fi
```

### **Делаем скрипты исполняемыми:**
```bash
sudo chmod +x /usr/local/bin/zapret-{on,off,status}
```

---

## 🔄 **11. Управление сервисами**

### **Основные команды systemd:**
```bash
# Запустить zapret
sudo systemctl start zapret2

# Остановить zapret
sudo systemctl stop zapret2

# Перезапустить (после изменения конфига)
sudo systemctl restart zapret2

# Проверить статус
sudo systemctl status zapret2

# Посмотреть логи в реальном времени
sudo journalctl -u zapret2 -f

# Включить автозапуск при загрузке
sudo systemctl enable zapret2

# Отключить автозапуск
sudo systemctl disable zapret2
```

### **Управление обновлением списков:**
```bash
# Обновить список сайтов вручную
sudo /opt/zapret2/ipset/get_antizapret_domains.sh

# После обновления списка перезапустить сервис
sudo systemctl restart zapret2
```

---

## 🔧 **12. Диагностика проблем**

### **Проблема: YouTube не открывается, но сервис работает**
```bash
# 1. Проверяем, есть ли YouTube в списке
grep -i "youtube" /opt/zapret2/ipset/zapret-hosts-user.txt

# 2. Проверяем, загружены ли IP-адреса в nftables
sudo nft list set inet zapret2 zapret | grep -E '(64\.233|74\.125|142\.250|172\.217|216\.58)'

# 3. Временно отключаем фильтрацию по спискам
sudo sed -i 's/MODE_FILTER=hostlist/MODE_FILTER=none/' /opt/zapret2/config
sudo systemctl restart zapret2
curl -I https://youtube.com 2>/dev/null | head -1

# 4. Возвращаем обратно
sudo sed -i 's/MODE_FILTER=none/MODE_FILTER=hostlist/' /opt/zapret2/config
sudo systemctl restart zapret2
```

### **Проблема: Список сайтов пустой**
```bash
# Создаём список вручную (как показано в разделе 9)
sudo tee /opt/zapret2/ipset/zapret-hosts-user.txt > /dev/null << 'EOF'
youtube.com
youtu.be
googlevideo.com
discord.com
telegram.org
EOF

# Перезапускаем сервис
sudo systemctl restart zapret2
```

### **Проблема: Ошибка "Unit zapret2.service not found"**
```bash
# Проверяем, установлен ли сервис
ls -la /usr/lib/systemd/system/zapret2.service

# Если нет - переустанавливаем
cd /opt/zapret2
sudo ./install_easy.sh
```

---

## 📊 **13. Сравнение v1.0.1 с предыдущей версией v0.9.5.2**

| Аспект | v0.9.5.2 (старая) | v1.0.1 (новая) |
|--------|-------------------|----------------|
| **Расположение конфига** | `/etc/zapret2/config` | `/opt/zapret2/config` ⚡ |
| **Создание nftables** | Вручную | **Автоматически** ✅ |
| **Номер очереди** | 200 | **300** ⚡ |
| **Установка** | Ручная, сложная | Интерактивный установщик ✅ |
| **Systemd сервис** | Писать вручную | Автоматически ✅ |
| **Список сайтов** | Нужно скачивать | Автоматическая загрузка ✅ |
| **Стратегия** | `multisplit:pos=midsld:seqovl=5` | Та же (работает) ✅ |

---

## ✅ **14. Итоговый чек-лист: что должно работать**

После правильной установки у вас должно быть:

```bash
# ✅ 1. Конфиг существует и содержит стратегию
[ -f /opt/zapret2/config ] && echo "✅ Конфиг есть"
grep -q "multisplit:pos=midsld:seqovl=5" /opt/zapret2/config && echo "✅ Стратегия установлена"

# ✅ 2. Список сайтов не пустой
[ $(wc -l < /opt/zapret2/ipset/zapret-hosts-user.txt) -gt 0 ] && echo "✅ Список сайтов загружен"

# ✅ 3. Сервис работает
systemctl is-active --quiet zapret2 && echo "✅ Сервис активен"

# ✅ 4. nftables правила загружены
sudo nft list table inet zapret2 &>/dev/null && echo "✅ nftables настроен"

# ✅ 5. YouTube отвечает быстро
curl -I https://youtube.com 2>/dev/null | grep -q "HTTP/2 200" && echo "✅ YouTube работает"
```

---

## 🚀 **15. Быстрые команды для ежедневного использования**

```bash
# Включить обход
zapret-on

# Выключить обход
zapret-off

# Проверить статус
zapret-status

# Посмотреть стратегию
grep NFQWS2_OPT /opt/zapret2/config | cut -d'"' -f2

# Посмотреть список сайтов
head -10 /opt/zapret2/ipset/zapret-hosts-user.txt

# Добавить сайт в список вручную
echo "example.com" | sudo tee -a /opt/zapret2/ipset/zapret-hosts-user.txt
sudo systemctl restart zapret2

# Обновить список сайтов
sudo /opt/zapret2/ipset/get_antizapret_domains.sh
sudo systemctl restart zapret2

# Посмотреть логи
sudo journalctl -u zapret2 -f

# Перезапустить сервис (если что-то пошло не так)
sudo systemctl restart zapret2
```

---

## 📌 **Главные отличия, которые нужно запомнить:**

1. **Конфиг теперь в `/opt/zapret2/config`**, а не в `/etc/zapret2/config`
2. **nftables правила создаются автоматически** — не нужно писать вручную
3. **Очередь 300**, а не 200 (но это не нужно знать для работы)
4. **Список сайтов** в `/opt/zapret2/ipset/zapret-hosts-user.txt`
5. **Стратегия** осталась та же — `multisplit:pos=midsld:seqovl=5` (рабочая на июнь 2026)

---

