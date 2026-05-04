# 📗 **Установка и настройка zapret на EndeavourOS (Arch Linux)**

## **1️⃣ Подготовка системы (установка необходимых пакетов)**

```bash
# Обновляем систему
sudo pacman -Syu

# Устанавливаем необходимые пакеты
sudo pacman -S nftables lua tcpdump curl

# Для компиляции из исходников
sudo pacman -S gcc make libcap zlib libnetfilter_queue libpcap

# Устанавливаем libnetfilter_queue (обязательно для NFQUEUE)
sudo pacman -S libnetfilter_queue
```

*Почему:*  
- `nftables` — для перенаправления трафика  
- `lua` — для скриптов zapret  
- `tcpdump` — для отладки  
- `curl` — для проверки доступности сайтов  
- `libnetfilter_queue` — библиотека для работы с очередями nftables

---

## **1️⃣.5️⃣ Важная проверка: модули ядра для NFQUEUE**

⚠️ **Перед настройкой nftables обязательно выполните этот раздел!** Без модуля `nfnetlink_queue` правила nftables с `queue` работать не будут.

### **Проверка версии ядра и модуля**

```bash
# Проверяем версию ядра
uname -r

# Ищем модуль nfnetlink_queue
find /lib/modules/$(uname -r)/kernel/net/netfilter/ -name "*nfnetlink_queue*" 2>/dev/null
```

**Ожидаемый вывод:** должен быть файл `nfnetlink_queue.ko.zst` или аналогичный.

### **Если модуль не найден — обновляем ядро**

Иногда после обновления системы старое ядро остаётся загруженным, а модули для него уже удалены. Это вызывает ошибку `No such file or directory` при загрузке правил nftables.

```bash
# Полное обновление системы (обновит и ядро)
sudo pacman -Syu

# Перезагружаемся для загрузки нового ядра
sudo reboot
```

**После перезагрузки** проверьте ещё раз:
```bash
uname -r          # должно быть свежее ядро (например, 7.0.3-arch1-2)
lsmod | grep nfnetlink   # пока ничего, модуль ещё не загружен
```

### **Загрузка модуля nfnetlink_queue**

```bash
# Загружаем модуль
sudo modprobe nfnetlink_queue

# Проверяем, что загрузился
lsmod | grep nfnetlink
```

**Ожидаемый вывод:**
```
nfnetlink_queue        36864  0
nfnetlink              20480  4 nfnetlink_queue,nf_tables
```

### **Автозагрузка модуля при старте системы**

```bash
# Создаём файл для автозагрузки модуля
echo "nfnetlink_queue" | sudo tee /etc/modules-load.d/nfqueue.conf

# Проверяем
cat /etc/modules-load.d/nfqueue.conf
```

---

## **2️⃣ Настройка nftables (правила перенаправления трафика)**

В EndeavourOS используется `nftables`, но по умолчанию он может быть не активен. Мы создадим отдельный файл с правилами для zapret и подключим его к основному конфигу.

### **2.1 Создаем файл с правилами для zapret**

```bash
sudo mcedit /etc/nftables-zapret.conf
```

**⚠️ ВАЖНО:** Не используйте `add table` и `delete table` в одном файле — это вызовет ошибку. Используйте прямое определение таблицы:

```nft
#!/usr/sbin/nft -f

# Таблица для zapret
table inet zapret {
    chain post {
        type filter hook postrouting priority 101; policy accept;
        tcp dport {80, 443} queue flags bypass to 200
        udp dport 443 queue flags bypass to 200
    }
    chain pre {
        type filter hook prerouting priority -101; policy accept;
        tcp sport {80, 443} queue flags bypass to 200
        udp sport 443 queue flags bypass to 200
    }
    chain output {
        type filter hook output priority -401; policy accept;
        queue flags bypass to 200
    }
}
```

**Примечание:** Упрощённые правила (без `ct original packets`) используются для совместимости со всеми версиями ядра. Они работают не менее эффективно.

### **2.2 Подключаем правила к основному конфигу nftables**

```bash
echo 'include "/etc/nftables-zapret.conf"' | sudo tee -a /etc/nftables.conf
```

### **2.3 Загружаем правила вручную (для проверки)**

```bash
# Загружаем правила
sudo nft -f /etc/nftables-zapret.conf

# Проверяем, что таблица создалась
sudo nft list tables
sudo nft list table inet zapret
```

**Должны увидеть таблицу `inet zapret` с цепочками post, pre, output.**

### **2.4 Включаем и запускаем nftables**

```bash
sudo systemctl enable nftables
sudo systemctl start nftables
```

> ⚠️ **Важно:** Статус `inactive (dead)` для сервиса `nftables` — это нормально. Сервис работает по принципу "загрузил правила и завершился". Главное, чтобы правила были видны в `nft list ruleset`.

### **2.5 Типичные ошибки и их решение**

| Ошибка | Решение |
|--------|---------|
| `Could not process rule: No such file or directory` | Не загружен модуль `nfnetlink_queue`. Выполните раздел 1.5 |
| `delete table inet zapret` Error | Уберите строки `add table` и `delete table` из файла правил |
| Модуль не загружается после перезагрузки | Проверьте файл `/etc/modules-load.d/nfqueue.conf` |

---

## **3️⃣ Настройка параметра ядра (важно для TCP)**

```bash
# Временное включение
sudo sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1

# Постоянное включение
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" | sudo tee /etc/sysctl.d/99-zapret.conf
sudo sysctl --system
```

---

## **4️⃣ Скачивание zapret в системную директорию**

```bash
cd ~/Downloads
wget https://github.com/bol-van/zapret2/releases/download/v0.9.5.2/zapret2-v0.9.5.2.tar.gz
sudo tar -xzf zapret2-v0.9.5.2.tar.gz -C /usr/local/bin/
sudo mv /usr/local/bin/zapret2-v0.9.5.2 /usr/local/bin/zapret2
rm zapret2-v0.9.5.2.tar.gz
```

---

## **5️⃣ Использование готовых бинарников (без компиляции)**

```bash
cd /usr/local/bin/zapret2
sudo cp binaries/linux-x86_64/nfqws2 nfq2/
sudo cp binaries/linux-x86_64/ip2net ip2net/
sudo cp binaries/linux-x86_64/mdig mdig/
sudo chmod +x nfq2/nfqws2 ip2net/ip2net mdig/mdig
```

**Проверка:**

```bash
ls -la /usr/local/bin/zapret2/nfq2/nfqws2
# Должно быть: -rwxr-xr-x 1 root root ...
```

---

## **6️⃣ ВАЖНО: Права доступа к Lua файлам**

`nfqws2` после запуска понижает привилегии, поэтому ему нужен доступ на чтение к Lua файлам.

```bash
sudo chmod a+x /usr/local/
sudo chmod a+x /usr/local/bin/
sudo chmod a+x /usr/local/bin/zapret2/
sudo chmod a+x /usr/local/bin/zapret2/lua/
sudo chmod a+r /usr/local/bin/zapret2/lua/*.lua
```

---

## **7️⃣ Скрипты управления zapret (очень удобно!)**

Создаём три скрипта для повседневного использования:

```bash
sudo mcedit /usr/local/bin/zapret-start
```

```bash
#!/bin/bash
# Запуск zapret с проверкой nftables

echo "🔄 Проверяем модуль ядра..."
sudo modprobe nfnetlink_queue 2>/dev/null

echo "🔄 Загружаем правила nftables..."
sudo nft -f /etc/nftables-zapret.conf 2>/dev/null || {
    sudo nft delete table inet zapret 2>/dev/null
    sudo nft -f /etc/nftables-zapret.conf
}

echo "🚀 Запускаем nfqws2..."
cd /usr/local/bin/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --daemon --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5

sleep 2
if pgrep -f nfqws2 >/dev/null; then
    echo "✅ Zapret запущен"
    curl -I https://www.youtube.com 2>/dev/null | head -n 1
else
    echo "❌ Ошибка запуска!"
fi
```

```bash
sudo mcedit /usr/local/bin/zapret-stop
```

```bash
#!/bin/bash
echo "🛑 Останавливаем nfqws2..."
sudo pkill -f nfqws2
echo "✅ Остановлен"
```

```bash
sudo mcedit /usr/local/bin/zapret-status
```

```bash
#!/bin/bash
echo "=== NFQWS2 ==="
pgrep -f nfqws2 >/dev/null && echo "✅ РАБОТАЕТ" || echo "❌ НЕ РАБОТАЕТ"

echo "=== NFTABLES ==="
sudo nft list table inet zapret &>/dev/null && echo "✅ ЗАГРУЖЕНЫ" || echo "❌ НЕ ЗАГРУЖЕНЫ"

echo "=== МОДУЛЬ ЯДРА ==="
lsmod | grep -q nfnetlink_queue && echo "✅ nfnetlink_queue ЗАГРУЖЕН" || echo "❌ nfnetlink_queue НЕ ЗАГРУЖЕН"

echo "=== YouTube тест ==="
curl -I https://www.youtube.com 2>/dev/null | head -n 1 || echo "❌ Не отвечает"
```

Делаем скрипты исполняемыми:

```bash
sudo chmod +x /usr/local/bin/zapret-{start,stop,status}
```

Теперь управление одной командой:

```bash
sudo zapret-start
sudo zapret-stop
zapret-status
```

---

## **8️⃣ Ручной запуск и тестирование стратегий**

### **Проверка ДО запуска:**

```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть медленно или ошибка
```

### **Запуск с отладкой:**

```bash
cd /usr/local/bin/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### **Проверка ПОСЛЕ запуска (в другом терминале):**

```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть HTTP/2 200
```

---

## **9️⃣ АВТОЗАПУСК: systemd сервис с правильной зависимостью**

### Создаём сервис для zapret

```bash
sudo mcedit /etc/systemd/system/zapret.service
```

```ini
[Unit]
Description=Zapret DPI bypass
After=network.target nftables.service
Wants=nftables.service
Before=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStartPre=/usr/bin/modprobe nfnetlink_queue
ExecStart=/usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
Restart=on-failure
RestartSec=5
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
```

### Включаем и запускаем

```bash
sudo systemctl daemon-reload
sudo systemctl enable zapret
sudo systemctl start zapret
sudo systemctl status zapret
```

### Просмотр логов

```bash
sudo journalctl -u zapret -f
```

---

## **🔟 Просмотр доступных стратегий**

```bash
cat /usr/local/bin/zapret2/lua/zapret-antidpi.lua | grep -A 5 "desync profiles"
```

---

## **1️⃣1️⃣ Диагностика: сервис запущен, но YouTube не работает**

### Симптомы:
- `systemctl status zapret` показывает `active (running)`
- `zapret-status` показывает, что nfqws2 работает
- Но YouTube не открывается

### Возможные причины и проверки:

**1. Проверьте, загружены ли правила nftables:**

```bash
sudo nft list table inet zapret
# Если пусто — правила не загружены
sudo systemctl restart nftables
sudo nft list table inet zapret
```

**2. Проверьте модуль ядра:**

```bash
lsmod | grep nfnetlink_queue
# Если пусто — модуль не загружен
sudo modprobe nfnetlink_queue
```

**3. Проверьте, видит ли nfqws2 Lua файлы:**

```bash
sudo journalctl -u zapret -e | grep -i "bad file"
```

Если видите `bad file` — используйте **абсолютные пути** (они уже прописаны в сервисе выше).

**4. Проверка, доходит ли трафик до очереди:**

```bash
# В одном терминале запустите с дебагом
sudo zapret-stop
sudo /usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --debug=1 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5

# В другом терминале
curl -I https://www.youtube.com
```

Если в дебаге видно `packet processed` — трафик доходит, проблема в стратегии.  
Если тишина — проблема в nftables или модуле ядра.

---

## **1️⃣2️⃣ Особенности для EndeavourOS / Arch Linux**

### **Firewalld**
Если у вас включён firewalld, он может мешать:

```bash
sudo systemctl status firewalld
# Если активен, можно остановить:
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

### **Проверка версии ядра**

```bash
uname -r
# Ядро должно быть свежим (например, 7.0.3-arch1-2)
```

---

## **1️⃣3️⃣ Как убрать всё (если надоест)**

```bash
sudo systemctl stop zapret
sudo systemctl disable zapret
sudo rm /etc/systemd/system/zapret.service
sudo systemctl daemon-reload

# Удаляем правила nftables
sudo nft delete table inet zapret
sudo sed -i '/zapret/d' /etc/nftables.conf
sudo rm /etc/nftables-zapret.conf

# Удаляем модуль ядра из автозагрузки
sudo rm /etc/modules-load.d/nfqueue.conf

# Удаляем zapret
sudo rm -rf /usr/local/bin/zapret2
sudo rm /usr/local/bin/zapret-{start,stop,status}

# Удаляем параметр ядра
sudo rm /etc/sysctl.d/99-zapret.conf
sudo sysctl --system
```

---

## **📌 ИТОГ: РАБОЧАЯ КОНФИГУРАЦИЯ**

| Компонент | Значение |
|-----------|----------|
| **Версия zapret** | v0.9.5.2 |
| **Стратегия** | `multisplit:pos=1:seqovl=5` |
| **Порты** | TCP 80, 443 |
| **Команда запуска** | `sudo /usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5` |
| **Правила nftables** | `/etc/nftables-zapret.conf` (упрощённые, без `ct original`) |
| **Модуль ядра** | `nfnetlink_queue` (автозагрузка через `/etc/modules-load.d/nfqueue.conf`) |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **Сервис nftables** | `nftables.service` |
| **Сервис zapret** | `zapret.service` (с `ExecStartPre` для загрузки модуля) |
| **Скрипты управления** | `zapret-start`, `zapret-stop`, `zapret-status` |
| **Рабочая директория** | `/usr/local/bin/zapret2` |

---

## ✅ **Что теперь работает**
- YouTube открывается без тормозов
- Другие заблокированные сайты тоже
- Всё запускается автоматически после перезагрузки (модуль ядра загружается, nftables применяет правила, zapret стартует)
- Удобное управление через `zapret-start/stop/status`

---

## 📚 **Памятка по синтаксису --lua-init:**

| Синтаксис | Что означает |
|-----------|--------------|
| `--lua-init='print("hello")'` | Выполнить код напрямую |
| `--lua-init=@script.lua` | Загрузить из файла **относительно текущей директории** |
| `--lua-init=@/abs/path/script.lua` | Загрузить из файла **по абсолютному пути** (НАДЁЖНО) |

---

## ⚠️ **Частые проблемы и их решение**

| Проблема | Решение |
|----------|---------|
| `No such file or directory` при загрузке nftables | Модуль `nfnetlink_queue` не загружен → раздел 1.5 |
| `delete table inet zapret` Error | Убрать строки `add table` и `delete table` из конфига |
| `bad file 'lua/...'` в логах | Использовать абсолютные пути в `--lua-init=` |
| После перезагрузки zapret не работает | Проверить модуль: `lsmod \| grep nfnetlink_queue` |
| `nfnetlink_queue` не загружается после reboot | Проверить файл `/etc/modules-load.d/nfqueue.conf` |

---

## 📝 **Примечание:** 
Стратегии могут меняться со временем. Если перестанет работать — попробуйте другие варианты из файла `zapret-antidpi.lua` или проверьте актуальную документацию на https://github.com/bol-van/zapret2/

---

Это полная исправленная статья, которая учитывает:
1. ✅ Необходимость загрузки модуля `nfnetlink_queue`
2. ✅ Ошибку с `add table`/`delete table` в nftables
3. ✅ Использование упрощённых правил (без `ct original`)
4. ✅ Проблему с несоответствием версий ядра после обновления
5. ✅ Автозагрузку модуля ядра
6. ✅ Актуальную версию zapret v0.9.5.2
