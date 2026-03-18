# 📗 **ИНСТРУКЦИЯ: Установка и настройка zapret на Simply Linux (ALT Linux) в системную директорию**



## **1️⃣ Подготовка системы (установка необходимых пакетов)**

```bash
su -
epm update
epmi nftables libnftnl lua5.3
```

*Почему:* `nftables` нужен для перенаправления трафика, `lua5.3` — для скриптов zapret. В Simply Linux используется менеджер пакетов `epm`.

---

## **2️⃣ Настройка nftables (правила перенаправления трафика)**

Создаем файл с правилами:

```bash
mcedit /etc/nftables/zapret.nft
```

Вставляем:

```nft
#!/usr/sbin/nft -f

table inet zapret
delete table inet zapret
table inet zapret {
    chain post {
        type filter hook postrouting priority 101; policy accept;
        tcp dport {80, 443} ct original packets 1-12 queue flags bypass to 200
        udp dport 443 ct original packets 1-12 queue flags bypass to 200
    }
    chain pre {
        type filter hook prerouting priority -101; policy accept;
        tcp sport {80, 443} ct reply packets 1-12 queue flags bypass to 200
        udp sport 443 ct reply packets 1-12 queue flags bypass to 200
    }
    chain output {
        type filter hook output priority -401; policy accept;
        queue flags bypass to 200
    }
}
```

Проверяем загрузку:

```bash
nft -f /etc/nftables/zapret.nft
nft list ruleset
```

---

## **3️⃣ Настройка параметра ядра (важно для TCP)**

```bash
sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" >> /etc/sysctl.conf
```

---

## **4️⃣ Скачивание zapret в системную директорию**

```bash
cd ~/Загрузки/
wget https://github.com/bol-van/zapret2/releases/download/v0.9.4.5/zapret2-v0.9.4.5.tar.gz
sudo cp zapret2-v0.9.4.5.tar.gz /usr/local/bin/
cd /usr/local/bin/
sudo tar -xzf zapret2-v0.9.4.5.tar.gz
sudo rm zapret2-v0.9.4.5.tar.gz
```

---

## **5️⃣ Использование готовых бинарников (без компиляции)**

```bash
cd /usr/local/bin/zapret2-v0.9.4.5
sudo cp binaries/linux-x86_64/nfqws2 nfq2/
sudo cp binaries/linux-x86_64/ip2net ip2net/
sudo cp binaries/linux-x86_64/mdig mdig/
sudo chmod +x nfq2/nfqws2 ip2net/ip2net mdig/mdig
```

Проверка:

```bash
ls -la nfq2/nfqws2   # должно быть -rwxr-xr-x
```

---

## **6️⃣ ВАЖНО: Права доступа к Lua файлам**

```bash
cd /usr/local/bin/zapret2-v0.9.4.5
sudo chmod a+x /usr/local/
sudo chmod a+x /usr/local/bin/
sudo chmod a+x /usr/local/bin/zapret2-v0.9.4.5/
sudo chmod a+x /usr/local/bin/zapret2-v0.9.4.5/lua/
sudo chmod a+r /usr/local/bin/zapret2-v0.9.4.5/lua/*.lua
```

---

## **7️⃣ Запуск и тестирование стратегий**

### Проверка ДО запуска:

```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть медленно или ошибка
```

### РАБОЧАЯ стратегия (multisplit) с отладкой:

```bash
cd /usr/local/bin/zapret2-v0.9.4.5
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### Проверка ПОСЛЕ запуска (в другом терминале):

```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть быстро с HTTP/2 200
```

### Без отладки (тихий режим):

```bash
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

---

## **8️⃣ Скрипты управления zapret (удобные команды)**

Создаём три скрипта для повседневного использования:

```bash
sudo mcedit /usr/local/bin/zapret-start
```

```bash
#!/bin/bash
# Запуск zapret с проверкой nftables

echo "🔄 Загружаем правила nftables..."
nft -f /etc/nftables/zapret.nft 2>/dev/null || {
    nft delete table inet zapret 2>/dev/null
    nft -f /etc/nftables/zapret.nft
}

echo "🚀 Запускаем nfqws2..."
cd /usr/local/bin/zapret2-v0.9.4.5
./nfq2/nfqws2 --qnum=200 --daemon --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5

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
pkill -f nfqws2
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
nft list table inet zapret &>/dev/null && echo "✅ ЗАГРУЖЕНЫ" || echo "❌ НЕ ЗАГРУЖЕНЫ"

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

## **9️⃣ АВТОЗАПУСК: правильная связка nftables + zapret**

### Создаём сервис для nftables (отдельно)

```bash
sudo mcedit /etc/systemd/system/nftables-zapret.service
```

```ini
[Unit]
Description=nftables rules for zapret
Before=network-pre.target
Wants=network-pre.target
DefaultDependencies=no

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/nft -f /etc/nftables/zapret.nft
ExecStop=/usr/sbin/nft delete table inet zapret
StandardOutput=journal

[Install]
WantedBy=multi-user.target
```

### Создаём сервис для zapret (с зависимостью от nftables)

```bash
sudo mcedit /etc/systemd/system/zapret.service
```

```ini
[Unit]
Description=Zapret2 DPI bypass
After=network.target nftables-zapret.service
Wants=nftables-zapret.service
Before=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/zapret2-v0.9.4.5/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2-v0.9.4.5/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2-v0.9.4.5/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Включаем автозагрузку

```bash
sudo systemctl daemon-reload
sudo systemctl enable nftables-zapret.service
sudo systemctl enable zapret.service
sudo systemctl start nftables-zapret.service
sudo systemctl start zapret.service
```

Проверяем:

```bash
sudo systemctl status nftables-zapret.service
sudo systemctl status zapret.service
zapret-status
```

---

## **🔟 Как посмотреть доступные стратегии**

```bash
cat /usr/local/bin/zapret2-v0.9.4.5/lua/zapret-antidpi.lua | grep -A 5 "desync profiles"
```

---

## **1️⃣1️⃣ Диагностика: сервис запущен, но YouTube не работает**

### Симптомы:
- `systemctl status zapret` показывает `active (running)`
- `zapret-status` показывает, что nfqws2 работает
- Но YouTube тормозит или не открывается

### Возможная причина:
**Правила nftables не загружены**, либо загружены, но не той очередью.

### Проверка:

```bash
# Есть ли таблица?
sudo nft list tables

# Если пусто — правила не загружены
sudo systemctl restart nftables-zapret.service
sudo nft list table inet zapret
```

### Дополнительная диагностика:

```bash
# Проверяем, видит ли nfqws2 Lua файлы
sudo journalctl -u zapret -e | grep -i "bad file"

# Смотрим общие логи
sudo journalctl -u zapret -f
```

### Если после остановки zapret YouTube всё ещё работает:

```bash
sudo zapret-stop
sudo systemctl stop nftables-zapret.service
sudo nft delete table inet zapret 2>/dev/null
curl -I https://www.youtube.com/
```

Если YouTube перестал работать — значит zapret реально работал, а правила nftables просто оставались загруженными.

---

## **1️⃣2️⃣ Как убрать всё (если надоест)**

```bash
sudo systemctl stop zapret
sudo systemctl disable zapret
sudo systemctl stop nftables-zapret
sudo systemctl disable nftables-zapret
sudo rm /etc/systemd/system/zapret.service
sudo rm /etc/systemd/system/nftables-zapret.service
sudo systemctl daemon-reload
sudo nft delete table inet zapret
sudo rm -rf /usr/local/bin/zapret2-v0.9.4.5
sudo rm /usr/local/bin/zapret-{start,stop,status}
```

---

## **📌 ИТОГ: РАБОЧАЯ КОНФИГУРАЦИЯ**

| Компонент | Значение |
|-----------|----------|
| **Стратегия** | `multisplit:pos=1:seqovl=5` |
| **Порты** | TCP 80, 443 |
| **Команда запуска** | `sudo /usr/local/bin/zapret2-v0.9.4.5/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2-v0.9.4.5/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2-v0.9.4.5/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5` |
| **Правила nftables** | `/etc/nftables/zapret.nft` |
| **Сервис nftables** | `nftables-zapret.service` |
| **Сервис zapret** | `zapret.service` |
| **Скрипты управления** | `zapret-start`, `zapret-stop`, `zapret-status` |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **Рабочая директория** | `/usr/local/bin/zapret2-v0.9.4.5` |

---

## ✅ **Что теперь работает**
- YouTube открывается без тормозов
- Другие заблокированные сайты тоже могут работать
- Всё запускается автоматически после перезагрузки
- Удобное управление через `zapret-start/stop/status`

---

## 📝 **Примечание:**
Стратегии могут меняться со временем. Если перестанет работать — попробуйте другие варианты из файла `zapret-antidpi.lua` или проверьте актуальную документацию на https://github.com/bol-van/zapret2/

---
