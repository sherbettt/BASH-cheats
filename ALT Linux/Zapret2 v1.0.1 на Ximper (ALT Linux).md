# 📗 **Полное руководство по установке и настройке Zapret2 v1.0.1 на Ximper Linux**

> **📅 Актуально на 13 июня 2026**  
> **✅ Проверенная рабочая стратегия:** `multisplit:pos=midsld:seqovl=5`
> 
> **https://github.com/bol-van/zapret2/releases/tag/v1.0.1**

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

### **Проверяем правила nftables:**
```bash
# Смотрим все таблицы
sudo nft list tables

# Смотрим конкретную таблицу zapret2
sudo nft list table inet zapret2
```

**Пример вывода:**
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

### **Проверяем работу YouTube:**
```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
```
**Ожидаемый вывод:** `HTTP/2 200` (быстрый ответ)

---

## 🛠️ **6. Удобные скрипты для управления**

### **Скрипт быстрого запуска:**
```bash
sudo mcedit /usr/local/bin/zapret-on
```

```bash
#!/bin/bash
# Быстрый запуск zapret с проверкой
echo "🔄 Запускаем zapret..."
sudo systemctl start zapret2

sleep 2

if systemctl is-active --quiet zapret2; then
    echo "✅ Zapret успешно запущен"
    echo ""
    echo "📊 Проверка YouTube:"
    curl -I https://www.youtube.com 2>/dev/null | head -n 1
else
    echo "❌ Ошибка запуска!"
    echo "📋 Последние логи:"
    sudo journalctl -u zapret2 -n 10 --no-pager
fi
```

### **Скрипт быстрой остановки:**
```bash
sudo mcedit /usr/local/bin/zapret-off
```

```bash
#!/bin/bash
# Быстрая остановка zapret
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

### **Скрипт проверки статуса:**
```bash
sudo mcedit /usr/local/bin/zapret-status
```

```bash
#!/bin/bash
# Полная диагностика zapret

echo "=== 📡 ZAPRET STATUS ==="
if systemctl is-active --quiet zapret2; then
    echo "✅ Сервис: РАБОТАЕТ"
    PID=$(pgrep -f nfqws2)
    echo "   PID процесса: $PID"
else
    echo "❌ Сервис: НЕ РАБОТАЕТ"
fi

echo ""
echo "=== 🔥 NFTABLES RULES ==="
if sudo nft list table inet zapret2 &>/dev/null; then
    echo "✅ Правила загружены"
    RULES_COUNT=$(sudo nft list table inet zapret2 | grep -c "queue flags bypass")
    echo "   Найдено правил: $RULES_COUNT"
else
    echo "❌ Правила не загружены"
fi

echo ""
echo "=== 📋 СПИСКИ САЙТОВ ==="
if [ -f /opt/zapret2/ipset/zapret-hosts-user.txt ]; then
    SIZE=$(wc -l < /opt/zapret2/ipset/zapret-hosts-user.txt)
    echo "✅ Список сайтов: $SIZE записей"
else
    echo "❌ Список сайтов отсутствует"
fi

echo ""
echo "=== 🎬 YOUTUBE TEST ==="
curl -I https://www.youtube.com 2>/dev/null | head -n 1

echo ""
echo "=== 📊 СТАТИСТИКА ==="
if systemctl is-active --quiet zapret2; then
    echo "📈 CPU использование:"
    ps aux | grep nfqws2 | grep -v grep | awk '{print "   CPU: " $3 "%  MEM: " $4 "%"}'
    
    echo "📈 Сетевые очереди:"
    cat /proc/net/netfilter/nfnetlink_queue 2>/dev/null | head -5
fi
```

### **Скрипт смены стратегии:**
```bash
sudo mcedit /usr/local/bin/zapret-change-strategy
```

```bash
#!/bin/bash
# Быстрая смена стратегии обхода DPI

if [ -z "$1" ]; then
    echo "📖 Использование: zapret-change-strategy \"стратегия\""
    echo ""
    echo "📝 Примеры рабочих стратегий:"
    echo "   zapret-change-strategy \"multisplit:pos=midsld:seqovl=5\""
    echo "   zapret-change-strategy \"multisplit:pos=2:seqovl=5\""
    echo "   zapret-change-strategy \"multisplit:pos=1,midsld:seqovl=5\""
    echo "   zapret-change-strategy \"multidisorder:pos=1,midsld\""
    echo ""
    echo "📌 Текущая стратегия:"
    grep "^NFQWS2_OPT=" /etc/zapret2/config | sed 's/NFQWS2_OPT="//' | sed 's/"$//'
    exit 1
fi

NEW_STRATEGY="$1"

# Создаём бэкап
sudo cp /etc/zapret2/config /etc/zapret2/config.backup.$(date +%Y%m%d_%H%M%S)

# Заменяем стратегию
sudo sed -i "s/NFQWS2_OPT=\".*\"/NFQWS2_OPT=\"--filter-tcp=443 --filter-l7=tls --payload=tls_client_hello --lua-desync=$NEW_STRATEGY\"/" /etc/zapret2/config

echo "🔄 Применяем новую стратегию: $NEW_STRATEGY"
sudo systemctl restart zapret2

sleep 2

if systemctl is-active --quiet zapret2; then
    echo "✅ Zapret перезапущен с новой стратегией"
    echo ""
    echo "📊 Проверка YouTube:"
    curl -I https://www.youtube.com 2>/dev/null | head -n 1
else
    echo "❌ Ошибка! Стратегия не работает. Возвращаем предыдущую..."
    sudo cp /etc/zapret2/config.backup.* /etc/zapret2/config 2>/dev/null
    sudo systemctl restart zapret2
    echo "✅ Восстановлена предыдущая стратегия"
fi
```

### **Делаем скрипты исполняемыми:**
```bash
sudo chmod +x /usr/local/bin/zapret-{on,off,status,change-strategy}
```

---

## 🔄 **7. Управление сервисами и автозапуском**

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

# Посмотреть последние 50 строк логов
sudo journalctl -u zapret2 -n 50 --no-pager

# Включить автозапуск при загрузке
sudo systemctl enable zapret2

# Отключить автозапуск
sudo systemctl disable zapret2

# Проверить включён ли автозапуск
sudo systemctl is-enabled zapret2
```

### **Управление автообновлением списков:**
```bash
# Проверить статус таймера
sudo systemctl status zapret2-list-update.timer

# Посмотреть когда будет следующее обновление
sudo systemctl list-timers zapret2-list-update.timer

# Запустить обновление вручную
sudo systemctl start zapret2-list-update

# Отключить автообновление
sudo systemctl disable zapret2-list-update.timer

# Включить автообновление
sudo systemctl enable --now zapret2-list-update.timer
```

---

## 📂 **8. Важные файлы и их расположение**

| Файл/Директория | Назначение | Как посмотреть/изменить |
|----------------|------------|------------------------|
| `/opt/zapret2/` | Основная директория программы | `ls -la /opt/zapret2/` |
| `/opt/zapret2/nfq2/nfqws2` | Исполняемый файл | `file /opt/zapret2/nfq2/nfqws2` |
| `/etc/zapret2/config` | **Главный конфиг** | `sudo mcedit /etc/zapret2/config` |
| `/etc/zapret2/config.backup` | Резервная копия | `sudo cat /etc/zapret2/config.backup` |
| `/opt/zapret2/ipset/zapret-hosts-user.txt` | Список доменов для обхода | `head -20 /opt/zapret2/ipset/zapret-hosts-user.txt` |
| `/opt/zapret2/ipset/get_antizapret_domains.sh` | Скрипт обновления списков | `sudo /opt/zapret2/ipset/get_antizapret_domains.sh` |
| `/usr/lib/systemd/system/zapret2.service` | systemd сервис | `sudo systemctl cat zapret2` |
| `/etc/nftables/zapret2.nft` | Правила nftables | `sudo cat /etc/nftables/zapret2.nft` |
| `/var/log/` | Логи (через journal) | `sudo journalctl -u zapret2` |

---

## 🧪 **9. Диагностика проблем**

### **Проблема 1: Сервис не запускается**
```bash
# Смотрим ошибки
sudo journalctl -u zapret2 -n 50 --no-pager

# Проверяем синтаксис конфига
grep -v "^#" /etc/zapret2/config | grep -v "^$"

# Проверяем наличие бинарных файлов
ls -la /opt/zapret2/nfq2/nfqws2
```

### **Проблема 2: YouTube не открывается**
```bash
# Проверяем что сервис работает
systemctl status zapret2

# Проверяем что nftables правила загружены
sudo nft list table inet zapret2

# Временно отключаем zapret для теста
zapret-off
curl -I https://youtube.com  # Должно быть медленно

# Включаем обратно
zapret-on
```

### **Проблема 3: Ошибка "DNS is not working" при установке**
```bash
# Проверяем DNS
cat /etc/resolv.conf

# Временно меняем DNS на Google
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Продолжаем установку
```

---

## 🗑️ **10. Полное удаление Zapret2**

Если потребуется полностью удалить zapret:

```bash
# Останавливаем и отключаем сервисы
sudo systemctl stop zapret2
sudo systemctl disable zapret2
sudo systemctl stop zapret2-list-update.timer
sudo systemctl disable zapret2-list-update.timer

# Удаляем системные файлы
sudo rm /etc/systemd/system/zapret2.service
sudo rm /etc/systemd/system/zapret2-list-update.*
sudo rm /etc/zapret2 -rf
sudo rm /etc/nftables/zapret2.nft

# Удаляем саму программу
sudo rm /opt/zapret2 -rf

# Удаляем скрипты управления
sudo rm /usr/local/bin/zapret-*

# Удаляем параметр ядра (опционально)
sudo sed -i '/net.netfilter.nf_conntrack_tcp_be_liberal=1/d' /etc/sysctl.conf

# Перезагружаем systemd
sudo systemctl daemon-reload

echo "✅ Zapret2 полностью удалён"
```

---

## 🎯 **11. Заключение и список команд быстрого доступа**

### **Ежедневное управление:**
```bash
zapret-on          # Включить обход
zapret-off         # Выключить обход
zapret-status      # Проверить всё
zapret-change-strategy "multisplit:pos=2:seqovl=5"  # Сменить стратегию
```

### **Мониторинг:**
```bash
sudo systemctl status zapret2           # Статус сервиса
sudo journalctl -u zapret2 -f           # Логи в реальном времени
sudo nft list table inet zapret2        # Правила nftables
htop                                    # Нагрузка на CPU
```

### **Обслуживание:**
```bash
sudo systemctl restart zapret2          # Перезапустить после изменений
sudo /opt/zapret2/ipset/get_antizapret_domains.sh  # Обновить списки вручную
```

---

## 📌 **Ключевые отличия версии v1.0.1 от v0.9.5.2**

| Аспект | v0.9.5.2 (старая) | v1.0.1 (новая) |
|--------|-------------------|----------------|
| **Установка** | Ручная, нужно создавать сервисы | Интерактивный установщик |
| **nftables** | Нужно создавать вручную | Автоматическая настройка |
| **Systemd** | Писать вручную | Автоматически создаётся |
| **Обновление списков** | Ручной скрипт | Автоматический таймер |
| **Конфигурация** | Сложная, много параметров | Упрощённая, одна строка |
| **Стратегии** | Требуют глубокого понимания | Готовые шаблоны |

---

## ✅ **Что у вас получилось после установки**

1. ✅ **Zapret2 v1.0.1** установлен в `/opt/zapret2`
2. ✅ **Systemd сервис** автоматически запускается при загрузке
3. ✅ **nftables правила** настроены для перенаправления трафика
4. ✅ **Списки сайтов** автоматически обновляются каждые несколько дней
5. ✅ **Рабочая стратегия** `multisplit:pos=midsld:seqovl=5`
6. ✅ **Удобные скрипты** для повседневного управления
7. ✅ **YouTube и другие сайты** открываются без блокировок

---

